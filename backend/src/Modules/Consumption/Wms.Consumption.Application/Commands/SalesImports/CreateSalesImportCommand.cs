using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Consumption.Application.Abstractions;
using Wms.Consumption.Application.Dtos;
using Wms.Consumption.Domain;
using Wms.Consumption.Domain.Entities;
using Wms.Consumption.Domain.Enums;
using Wms.MasterData.Contracts;

namespace Wms.Consumption.Application.Commands.SalesImports;

/// <summary>One sold menu item; identified either by id or by the POS code (contract <c>SalesLineInput</c>).</summary>
public sealed record SalesLineInput(uint? MenuItemId, string? PosCode, decimal QtySold, decimal? GrossAmount);

/// <summary><c>POST /api/v1/consumption/sales-imports</c> (operationId <c>createSalesImport</c>).</summary>
public sealed record CreateSalesImportCommand(
    uint LocationId,
    DateOnly BusinessDate,
    SalesSource Source,
    string? ExternalRef,
    IReadOnlyList<SalesLineInput> Lines) : ICommand<SalesImportDetailDto>;

public sealed class CreateSalesImportCommandValidator : AbstractValidator<CreateSalesImportCommand>
{
    public CreateSalesImportCommandValidator()
    {
        RuleFor(c => c.LocationId).GreaterThan(0u);
        RuleFor(c => c.Lines).NotEmpty();
        RuleForEach(c => c.Lines).ChildRules(line => line.RuleFor(l => l.QtySold).GreaterThan(0m));
    }
}

public sealed class CreateSalesImportCommandHandler(
    ISalesImportRepository imports,
    IMenuItemRepository menuItems,
    IConsumptionQueries queries,
    IConsumptionUnitOfWork unitOfWork,
    ILocationCatalog locations,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : ICommandHandler<CreateSalesImportCommand, SalesImportDetailDto>
{
    public async Task<Result<SalesImportDetailDto>> HandleAsync(CreateSalesImportCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var tenantId = tenantContext.TenantId;
        var now = clock.UtcNow;
        var today = DateOnly.FromDateTime(now.UtcDateTime);

        var location = await locations.GetAsync(command.LocationId, cancellationToken).ConfigureAwait(false);
        if (location is null || !location.IsActive)
        {
            return ConsumptionErrors.LocationNotFound(command.LocationId);
        }

        // Invariant 2: one document per branch-day; a repeat is a conflict, not a second document.
        var existing = await imports.FindByDayAsync(tenantId, command.LocationId, command.BusinessDate, cancellationToken).ConfigureAwait(false);
        if (existing is not null)
        {
            return ConsumptionErrors.DuplicateBusinessDate(command.LocationId, command.BusinessDate);
        }

        var draft = SalesImport.CreateDraft(
            tenantId, command.LocationId, command.BusinessDate, command.Source, command.ExternalRef, now, currentUser.UserId, today);
        if (draft.IsFailure)
        {
            return draft.Error;
        }

        var built = await SalesLineFactory.BuildAsync(tenantId, command.Lines, menuItems, cancellationToken).ConfigureAwait(false);
        if (built.IsFailure)
        {
            return built.Error;
        }

        var replaced = draft.Value.ReplaceLines(built.Value.Lines);
        if (replaced.IsFailure)
        {
            return replaced.Error;
        }

        imports.Add(draft.Value);
        unitOfWork.Audit.Record("cons_sales_import", 0, AuditAction.Create, new
        {
            command.LocationId,
            command.BusinessDate,
            source = command.Source.ToString(),
            lineCount = built.Value.Lines.Count,
        });

        // SalesImported is raised on submit, where the document id exists and the day is actually accepted.
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        var dto = await queries.GetSalesImportAsync(draft.Value.Id, command.BusinessDate, cancellationToken).ConfigureAwait(false);
        return dto is null ? ConsumptionErrors.SalesImportNotFound(draft.Value.Id) : Result.Success(dto);
    }
}

public sealed record BuiltSalesLines(List<SalesLine> Lines, int UnmappedCount);

/// <summary>Resolves menu items from ids or POS codes. An unknown POS code is kept raw, never dropped (invariant 5).</summary>
public static class SalesLineFactory
{
    public static async Task<Result<BuiltSalesLines>> BuildAsync(
        uint tenantId,
        IReadOnlyList<SalesLineInput> inputs,
        IMenuItemRepository menuItems,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(inputs);
        ArgumentNullException.ThrowIfNull(menuItems);

        var posCodes = inputs
            .Where(i => i.MenuItemId is null or 0 && !string.IsNullOrWhiteSpace(i.PosCode))
            .Select(i => i.PosCode!.Trim())
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();
        IReadOnlyDictionary<string, uint> resolved = posCodes.Count == 0
            ? new Dictionary<string, uint>(StringComparer.OrdinalIgnoreCase)
            : await menuItems.ResolveByPosCodeAsync(tenantId, posCodes, cancellationToken).ConfigureAwait(false);

        var lines = new List<SalesLine>(inputs.Count);
        var unmapped = 0;
        foreach (var input in inputs)
        {
            uint? menuItemId = input.MenuItemId is > 0 ? input.MenuItemId : null;
            string? rawPosCode = string.IsNullOrWhiteSpace(input.PosCode) ? null : input.PosCode.Trim();

            if (menuItemId is null && rawPosCode is not null && resolved.TryGetValue(rawPosCode, out var mapped))
            {
                menuItemId = mapped;
            }

            if (menuItemId is { } id && await menuItems.GetAsync(id, cancellationToken).ConfigureAwait(false) is null)
            {
                return ConsumptionErrors.MenuItemNotFound(id);
            }

            if (menuItemId is null)
            {
                unmapped++;
            }

            var line = SalesLine.Create(tenantId, menuItemId, rawPosCode, input.QtySold, input.GrossAmount);
            if (line.IsFailure)
            {
                return line.Error;
            }

            lines.Add(line.Value);
        }

        return new BuiltSalesLines(lines, unmapped);
    }
}
