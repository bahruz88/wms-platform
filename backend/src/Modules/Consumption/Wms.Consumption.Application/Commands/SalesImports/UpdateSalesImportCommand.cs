using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Consumption.Application.Abstractions;
using Wms.Consumption.Application.Dtos;
using Wms.Consumption.Domain;

namespace Wms.Consumption.Application.Commands.SalesImports;

/// <summary><c>PUT /api/v1/consumption/sales-imports/{id}</c> (operationId <c>updateSalesImport</c>). DRAFT only, replace semantics.</summary>
public sealed record UpdateSalesImportCommand(long SalesImportId, uint RowVersion, IReadOnlyList<SalesLineInput> Lines)
    : ICommand<SalesImportDetailDto>;

public sealed class UpdateSalesImportCommandValidator : AbstractValidator<UpdateSalesImportCommand>
{
    public UpdateSalesImportCommandValidator()
    {
        RuleFor(c => c.SalesImportId).GreaterThan(0L);
        RuleFor(c => c.RowVersion).GreaterThan(0u);
        RuleFor(c => c.Lines).NotNull();
    }
}

public sealed class UpdateSalesImportCommandHandler(
    ISalesImportRepository imports,
    IMenuItemRepository menuItems,
    IConsumptionQueries queries,
    IConsumptionUnitOfWork unitOfWork,
    ITenantContext tenantContext) : ICommandHandler<UpdateSalesImportCommand, SalesImportDetailDto>
{
    public async Task<Result<SalesImportDetailDto>> HandleAsync(UpdateSalesImportCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var import = await imports.GetAsync(command.SalesImportId, cancellationToken).ConfigureAwait(false);
        if (import is null)
        {
            return ConsumptionErrors.SalesImportNotFound(command.SalesImportId);
        }

        if (import.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        var built = await SalesLineFactory.BuildAsync(tenantContext.TenantId, command.Lines, menuItems, cancellationToken).ConfigureAwait(false);
        if (built.IsFailure)
        {
            return built.Error;
        }

        var replaced = import.ReplaceLines(built.Value.Lines);
        if (replaced.IsFailure)
        {
            return replaced.Error;
        }

        unitOfWork.Audit.Record("cons_sales_import", import.Id, AuditAction.Update, new { lineCount = built.Value.Lines.Count });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        var dto = await queries.GetSalesImportAsync(import.Id, import.BusinessDate, cancellationToken).ConfigureAwait(false);
        return dto is null ? ConsumptionErrors.SalesImportNotFound(import.Id) : Result.Success(dto);
    }
}
