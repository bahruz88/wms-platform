using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.Reporting.Application.Abstractions;
using Wms.Reporting.Application.Dtos;
using Wms.Reporting.Domain;
using Wms.Reporting.Domain.Enums;

namespace Wms.Reporting.Application.Queries;

/// <summary><c>GET /api/v1/reporting/dashboard/summary</c> (reporting.v1.yaml <c>getDashboardSummary</c>).</summary>
public sealed record GetDashboardSummaryQuery(uint? LocationId, DashboardPeriod Period) : IQuery<DashboardSummaryDto>;

public sealed class GetDashboardSummaryQueryHandler(IDashboardQueries queries, ICurrentUser currentUser)
    : IQueryHandler<GetDashboardSummaryQuery, DashboardSummaryDto>
{
    public async Task<Result<DashboardSummaryDto>> HandleAsync(GetDashboardSummaryQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);

        // Fail-closed: a principal without iam.location.view_all is asking about their own locations only, and a
        // location they were not granted is simply not theirs to ask about (spec §16, README §8.17).
        var scope = currentUser.LocationScope;
        if (query.LocationId is { } locationId && !scope.Allows(locationId))
        {
            return CommonErrors.Forbidden("iam.location.view_all");
        }

        var filter = new DashboardFilter(
            query.LocationId,
            query.Period,
            scope,
            currentUser.HasPermission(ReportingPermissions.ViewCost),
            currentUser.HasPermission(ReportingPermissions.AuditView));

        return await queries.GetAsync(filter, cancellationToken).ConfigureAwait(false);
    }
}

/// <summary><c>GET /api/v1/reporting/reports</c> (reporting.v1.yaml <c>listReports</c>).</summary>
public sealed record ListReportsQuery(ReportCategory? Category) : IQuery<IReadOnlyList<ReportDefinitionDto>>;

public sealed class ListReportsQueryHandler(IReportCatalogQueries queries, ICurrentUser currentUser)
    : IQueryHandler<ListReportsQuery, IReadOnlyList<ReportDefinitionDto>>
{
    public async Task<Result<IReadOnlyList<ReportDefinitionDto>>> HandleAsync(ListReportsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var includeCostReports = currentUser.HasPermission(ReportingPermissions.ViewCost);
        var rows = await queries.ListAsync(query.Category, includeCostReports, cancellationToken).ConfigureAwait(false);
        return Result.Success(Strip(rows, includeCostReports));
    }

    /// <summary>Spec §16: a cost column is absent from the catalogue too, not only from the rows.</summary>
    internal static IReadOnlyList<ReportDefinitionDto> Strip(IReadOnlyList<ReportDefinitionDto> rows, bool includeCost) =>
        includeCost ? rows : [.. rows.Select(r => r with { Columns = [.. r.Columns.Where(c => !c.IsCost)] })];
}

/// <summary><c>GET /api/v1/reporting/reports/{code}</c> (reporting.v1.yaml <c>getReportDefinition</c>).</summary>
public sealed record GetReportDefinitionQuery(string Code) : IQuery<ReportDefinitionDto>;

public sealed class GetReportDefinitionQueryValidator : AbstractValidator<GetReportDefinitionQuery>
{
    public GetReportDefinitionQueryValidator() =>
        RuleFor(q => q.Code).NotEmpty().Matches("^[A-Z][A-Z0-9_]{2,47}$");
}

public sealed class GetReportDefinitionQueryHandler(IReportCatalogQueries queries, ICurrentUser currentUser)
    : IQueryHandler<GetReportDefinitionQuery, ReportDefinitionDto>
{
    public async Task<Result<ReportDefinitionDto>> HandleAsync(GetReportDefinitionQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var definition = await queries.GetAsync(query.Code, cancellationToken).ConfigureAwait(false);
        var includeCost = currentUser.HasPermission(ReportingPermissions.ViewCost);
        if (definition is null || (definition.RequiresCostPermission && !includeCost))
        {
            return ReportingErrors.ReportNotFound(query.Code);
        }

        return Result.Success(ListReportsQueryHandler.Strip([definition], includeCost)[0]);
    }
}

/// <summary><c>GET /api/v1/reporting/exports</c> (reporting.v1.yaml <c>listExports</c>).</summary>
public sealed record ListExportsQuery(ExportStatus? Status, PageRequest Page) : IQuery<PagedResult<ExportJobDto>>;

public sealed class ListExportsQueryHandler(IExportJobQueries queries, ICurrentUser currentUser, IClock clock)
    : IQueryHandler<ListExportsQuery, PagedResult<ExportJobDto>>
{
    /// <summary>Contract: the last 30 days of the current user's jobs.</summary>
    public const int WindowDays = 30;

    public async Task<Result<PagedResult<ExportJobDto>>> HandleAsync(ListExportsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var filter = new ExportJobFilter(query.Status, currentUser.UserId, clock.UtcNow.AddDays(-WindowDays));
        return await queries.ListAsync(filter, query.Page, cancellationToken).ConfigureAwait(false);
    }
}

/// <summary><c>GET /api/v1/reporting/exports/{id}</c> (reporting.v1.yaml <c>getExport</c>).</summary>
public sealed record GetExportQuery(long Id) : IQuery<ExportJobDto>;

public sealed class GetExportQueryHandler(IExportJobQueries queries, ICurrentUser currentUser)
    : IQueryHandler<GetExportQuery, ExportJobDto>
{
    public async Task<Result<ExportJobDto>> HandleAsync(GetExportQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var anyUser = currentUser.HasPermission(ReportingPermissions.AuditView);
        var job = await queries.GetAsync(query.Id, currentUser.UserId, anyUser, cancellationToken).ConfigureAwait(false);
        return job is null ? ReportingErrors.ExportNotFound(query.Id) : Result.Success(job);
    }
}
