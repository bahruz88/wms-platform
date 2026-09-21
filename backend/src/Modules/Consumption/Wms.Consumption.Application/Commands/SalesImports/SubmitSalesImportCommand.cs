using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Contracts.Events;
using Wms.Common.Domain;
using Wms.Consumption.Application.Abstractions;
using Wms.Consumption.Application.Dtos;
using Wms.Consumption.Domain;

namespace Wms.Consumption.Application.Commands.SalesImports;

/// <summary>
/// <c>POST /api/v1/consumption/sales-imports/{id}/submit</c> (operationId <c>submitSalesImport</c>).
/// DRAFT -&gt; SUBMITTED. Unmapped lines do not block the submit; they raise <c>SalesItemUnmapped</c> instead
/// (invariant 5).
/// </summary>
public sealed record SubmitSalesImportCommand(long SalesImportId, uint? RowVersion) : ICommand<SalesImportDto>;

public sealed class SubmitSalesImportCommandValidator : AbstractValidator<SubmitSalesImportCommand>
{
    public SubmitSalesImportCommandValidator() => RuleFor(c => c.SalesImportId).GreaterThan(0L);
}

public sealed class SubmitSalesImportCommandHandler(
    ISalesImportRepository imports,
    IRecipeRepository recipes,
    IMenuItemRepository menuItems,
    IConsumptionQueries queries,
    IConsumptionUnitOfWork unitOfWork,
    ITenantContext tenantContext,
    IClock clock) : ICommandHandler<SubmitSalesImportCommand, SalesImportDto>
{
    public async Task<Result<SalesImportDto>> HandleAsync(SubmitSalesImportCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var tenantId = tenantContext.TenantId;
        var import = await imports.GetAsync(command.SalesImportId, cancellationToken).ConfigureAwait(false);
        if (import is null)
        {
            return ConsumptionErrors.SalesImportNotFound(command.SalesImportId);
        }

        if (command.RowVersion is { } rowVersion && import.RowVersion != rowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        var submitted = import.Submit();
        if (submitted.IsFailure)
        {
            return submitted.Error;
        }

        var now = clock.UtcNow;

        // A sold item is "unmapped" when the POS code is unknown OR the menu item has no recipe on the day.
        var effective = await recipes.GetEffectiveBomAsync(tenantId, import.BusinessDate, cancellationToken).ConfigureAwait(false);
        var mappedIds = import.Lines.Where(l => l.MenuItemId is not null).Select(l => l.MenuItemId!.Value).Distinct().ToList();
        var names = await menuItems.GetNamesAsync(tenantId, mappedIds, cancellationToken).ConfigureAwait(false);

        var unmapped = new List<UnmappedSalesItem>();
        foreach (var line in import.Lines)
        {
            if (line.MenuItemId is not { } menuItemId)
            {
                unmapped.Add(new UnmappedSalesItem(line.RawPosCode, null, null, line.QtySold, "UNKNOWN_POS_CODE"));
                continue;
            }

            if (!effective.ContainsKey(menuItemId))
            {
                unmapped.Add(new UnmappedSalesItem(
                    line.RawPosCode, menuItemId, names.GetValueOrDefault(menuItemId), line.QtySold, "NO_ACTIVE_RECIPE"));
            }
        }

        unitOfWork.Audit.Record("cons_sales_import", import.Id, AuditAction.Approve, new { import.BusinessDate, unmapped = unmapped.Count });

        unitOfWork.Outbox.Enqueue(new SalesImported(
            tenantId, now, import.Id, import.LocationId, import.BusinessDate,
            import.Source.ToString().ToUpperInvariant(), import.LineCount, unmapped.Count, import.GrossAmount));

        if (unmapped.Count > 0)
        {
            unitOfWork.Outbox.Enqueue(new SalesItemUnmapped(
                tenantId, now, import.Id, import.LocationId, import.BusinessDate, unmapped));
        }

        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        var dto = await queries.GetSalesImportAsync(import.Id, import.BusinessDate, cancellationToken).ConfigureAwait(false);
        if (dto is null)
        {
            return ConsumptionErrors.SalesImportNotFound(import.Id);
        }

        return new SalesImportDto(
            dto.Id, dto.LocationId, dto.LocationName, dto.BusinessDate, dto.Source, dto.ExternalRef, dto.Status,
            dto.LineCount, dto.UnmappedCount, dto.GrossAmount, dto.ImportedAt, dto.ConsumptionRunId, dto.RowVersion);
    }
}
