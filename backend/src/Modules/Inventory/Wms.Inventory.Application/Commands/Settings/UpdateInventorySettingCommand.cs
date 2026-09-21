using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Application.Dtos;
using Wms.Inventory.Domain;

namespace Wms.Inventory.Application.Commands.Settings;

/// <summary>
/// <c>PUT /api/v1/inventory/settings/{key}</c> (inventory.v1.yaml <c>updateInventorySetting</c>).
/// </summary>
/// <remarks>
/// Spec §9.1 and TOR §36 require these parameters to be configurable rather than compiled in. Until now
/// <c>inv_setting</c> could only be read, and only from inside the process — changing a tolerance or the
/// costing method meant running SQL by hand. The value is validated against the key's declared type
/// (<c>INT</c>, <c>DECIMAL</c>, <c>BOOL</c>, <c>ENUM</c>) and range, and the change is audited.
/// </remarks>
public sealed record UpdateInventorySettingCommand(string Key, string Value) : ICommand<InventorySettingDto>;

public sealed class UpdateInventorySettingCommandHandler(
    IInventoryUnitOfWork unitOfWork,
    IInventorySettingWriter writer,
    ITenantContext tenantContext) : ICommandHandler<UpdateInventorySettingCommand, InventorySettingDto>
{
    public async Task<Result<InventorySettingDto>> HandleAsync(UpdateInventorySettingCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        if (!InventorySettingKeys.ByKey.TryGetValue(command.Key ?? string.Empty, out var definition))
        {
            return InventoryErrors.SettingNotFound(command.Key ?? string.Empty);
        }

        var normalized = definition.Normalize(command.Value);
        if (normalized.IsFailure)
        {
            return normalized.Error;
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        var previous = await writer.SetAsync(definition.Key, normalized.Value, cancellationToken).ConfigureAwait(false);
        unitOfWork.Audit.Record(
            "inv_setting",
            0,
            AuditAction.Update,
            new { key = definition.Key, oldValue = previous, newValue = normalized.Value });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return InventorySettingDto.From(definition, normalized.Value);
    }
}
