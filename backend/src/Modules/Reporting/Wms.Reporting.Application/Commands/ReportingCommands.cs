using System.Globalization;
using System.Text.Json;
using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Reporting.Application.Abstractions;
using Wms.Reporting.Application.Dtos;
using Wms.Reporting.Domain;
using Wms.Reporting.Domain.Entities;
using Wms.Reporting.Domain.Enums;

namespace Wms.Reporting.Application.Commands;

/// <summary>
/// <c>POST /api/v1/reporting/reports/{code}/run</c> (reporting.v1.yaml <c>runReport</c>). It is a POST because
/// the parameter object does not fit a query string, but it creates nothing: a repeated
/// <c>Idempotency-Key</c> simply runs the report again.
/// </summary>
public sealed record RunReportCommand(
    string Code,
    IReadOnlyDictionary<string, JsonElement> Parameters,
    int Page,
    int Size,
    string? Sort) : ICommand<ReportResultPageDto>;

public sealed class RunReportCommandValidator : AbstractValidator<RunReportCommand>
{
    public RunReportCommandValidator()
    {
        RuleFor(c => c.Code).NotEmpty().Matches("^[A-Z][A-Z0-9_]{2,47}$");
        RuleFor(c => c.Parameters).NotNull();
        RuleFor(c => c.Page).GreaterThanOrEqualTo(1);
        RuleFor(c => c.Size).InclusiveBetween(1, 200);
    }
}

public sealed class RunReportCommandHandler(IReportRunner runner, ICurrentUser currentUser)
    : ICommandHandler<RunReportCommand, ReportResultPageDto>
{
    public async Task<Result<ReportResultPageDto>> HandleAsync(RunReportCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        var (sortKey, descending) = SortParser.Parse(command.Sort);
        var filter = new ReportRunFilter(
            command.Code,
            command.Parameters,
            currentUser.LocationScope,
            currentUser.HasPermission(ReportingPermissions.ViewCost),
            command.Page,
            command.Size,
            sortKey,
            descending);

        return await runner.RunAsync(filter, cancellationToken).ConfigureAwait(false);
    }
}

/// <summary><c>columnKey,asc|desc</c> of <c>ReportRunRequest.sort</c>.</summary>
public static class SortParser
{
    public static (string? Key, bool Descending) Parse(string? sort)
    {
        if (string.IsNullOrWhiteSpace(sort))
        {
            return (null, false);
        }

        var parts = sort.Split(',', 2, StringSplitOptions.TrimEntries);
        var descending = parts.Length > 1 && parts[1].Equals("desc", StringComparison.OrdinalIgnoreCase);
        return (parts[0].Length == 0 ? null : parts[0], descending);
    }
}

/// <summary><c>POST /api/v1/reporting/exports</c> (reporting.v1.yaml <c>createExport</c>).</summary>
public sealed record CreateExportCommand(
    string ReportCode,
    ExportFormat Format,
    IReadOnlyDictionary<string, JsonElement> Parameters,
    string? FileName,
    string? Locale,
    Guid IdempotencyKey) : ICommand<ExportJobDto>;

public sealed class CreateExportCommandValidator : AbstractValidator<CreateExportCommand>
{
    public CreateExportCommandValidator()
    {
        RuleFor(c => c.ReportCode).NotEmpty().Matches("^[A-Z][A-Z0-9_]{2,47}$");
        RuleFor(c => c.Parameters).NotNull();
        RuleFor(c => c.FileName).MaximumLength(200);
        RuleFor(c => c.IdempotencyKey).NotEmpty();
    }
}

public sealed class CreateExportCommandHandler(
    IReportCatalogQueries catalogue,
    IExportJobRepository repository,
    IExportJobQueries queries,
    IReportingUnitOfWork unitOfWork,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : ICommandHandler<CreateExportCommand, ExportJobDto>
{
    public async Task<Result<ExportJobDto>> HandleAsync(CreateExportCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);

        var definition = await catalogue.GetAsync(command.ReportCode, cancellationToken).ConfigureAwait(false);
        var includeCost = currentUser.HasPermission(ReportingPermissions.ViewCost);
        if (definition is null || (definition.RequiresCostPermission && !includeCost))
        {
            return ReportingErrors.ReportNotFound(command.ReportCode);
        }

        if (!definition.SupportedFormats.Contains(command.Format))
        {
            return ReportingErrors.UnsupportedFormat(definition.Code, command.Format.ToString().ToUpperInvariant());
        }

        var existing = await repository
            .FindByIdempotencyKeyAsync(currentUser.UserId, command.IdempotencyKey, cancellationToken)
            .ConfigureAwait(false);
        if (existing is not null)
        {
            return ReportingErrors.IdempotentReplay();
        }

        var active = await repository.CountActiveAsync(currentUser.UserId, cancellationToken).ConfigureAwait(false);
        if (active >= ExportJob.MaxActivePerUser)
        {
            return ReportingErrors.TooManyActiveExports(ExportJob.MaxActivePerUser);
        }

        var now = clock.UtcNow;
        var scope = currentUser.LocationScope;
        var job = ExportJob.Create(
            tenantContext.TenantId,
            definition.Code,
            command.Format,
            ReportingJson.Serialize(command.Parameters),
            // The worker has no HTTP principal and would therefore be unrestricted (README §8.17), so the
            // requester's scope and cost permission are frozen onto the row here.
            scope.IsRestricted ? ReportingJson.Serialize(scope.VisibleIds) : null,
            includeCost,
            command.Locale,
            NormaliseFileName(command.FileName),
            currentUser.UserId,
            command.IdempotencyKey,
            now);

        repository.Add(job);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        // TOR: exporting a report is audited. Recorded after the first save so the row id is real.
        unitOfWork.Audit.Record(
            nameof(ExportJob),
            job.Id,
            AuditAction.Export,
            new { definition.Code, Format = command.Format.ToString().ToUpperInvariant(), command.Parameters });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        var dto = await queries.GetAsync(job.Id, currentUser.UserId, anyUser: false, cancellationToken).ConfigureAwait(false);
        return dto is null ? ReportingErrors.ExportNotFound(job.Id) : Result.Success(dto);
    }

    private static string? NormaliseFileName(string? fileName)
    {
        if (string.IsNullOrWhiteSpace(fileName))
        {
            return null;
        }

        var trimmed = fileName.Trim();
        return trimmed.Length > 200 ? trimmed[..200] : trimmed;
    }
}

/// <summary><c>DELETE /api/v1/reporting/exports/{id}</c> (reporting.v1.yaml <c>cancelExport</c>).</summary>
public sealed record CancelExportCommand(long Id) : ICommand<bool>;

public sealed class CancelExportCommandHandler(
    IExportJobRepository repository,
    IExportFileStore files,
    IReportingUnitOfWork unitOfWork,
    ICurrentUser currentUser,
    IClock clock) : ICommandHandler<CancelExportCommand, bool>
{
    public async Task<Result<bool>> HandleAsync(CancelExportCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);

        var job = await repository.GetAsync(command.Id, cancellationToken).ConfigureAwait(false);
        var anyUser = currentUser.HasPermission(ReportingPermissions.AuditView);
        if (job is null || (!anyUser && job.RequestedBy != currentUser.UserId))
        {
            return ReportingErrors.ExportNotFound(command.Id);
        }

        var storageKey = job.StorageKey;
        job.Cancel(clock.UtcNow);
        unitOfWork.Audit.Record(nameof(ExportJob), job.Id, AuditAction.Delete, new { job.ReportCode });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        if (!string.IsNullOrEmpty(storageKey))
        {
            // Best effort: the row is already cancelled, so a stale object is an orphan, never a wrong answer.
            await files.RemoveAsync(storageKey, cancellationToken).ConfigureAwait(false);
        }

        return Result.Success(true);
    }
}

/// <summary>Object key of a rendered export file in the shared MinIO bucket.</summary>
public static class ExportObjectKey
{
    public static string For(uint tenantId, long jobId, string extension) =>
        string.Create(CultureInfo.InvariantCulture, $"exports/{tenantId}/{jobId}/{Guid.NewGuid():N}.{extension}");
}
