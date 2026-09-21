using Wms.Common.Domain;

namespace Wms.Inventory.Domain.Entities;

/// <summary>
/// One append-only ledger line of <c>inv_movement</c> (spec §9.4). There is intentionally no method that changes
/// a persisted line: corrections are new <c>REVERSAL</c> groups.
/// </summary>
public sealed class Movement : Entity<long>, ITenantEntity
{
    private Movement()
    {
    }

    public uint TenantId { get; private set; }

    public long GroupId { get; private set; }

    public ushort LineNo { get; private set; }

    public uint ProductId { get; private set; }

    public long? BatchId { get; private set; }

    public uint LocationId { get; private set; }

    /// <summary>Signed base quantity: + receipt into the location, − issue out of it.</summary>
    public decimal QtyBase { get; private set; }

    public ushort BaseUomId { get; private set; }

    public decimal EnteredQty { get; private set; }

    public ushort EnteredUomId { get; private set; }

    /// <summary>Frozen at posting time (spec §12.1); later factor changes never touch history.</summary>
    public decimal ConversionRate { get; private set; }

    /// <summary>Per base UoM, in the tenant currency (spec §12.5).</summary>
    public decimal? UnitCost { get; private set; }

    public string? Currency { get; private set; }

    public decimal? FxRate { get; private set; }

    public DateTimeOffset PostedAt { get; private set; }

    public uint PostedBy { get; private set; }

    internal static Movement Create(MovementGroup group, ushort lineNo, MovementLineInput input, decimal qtyBase) =>
        new()
        {
            TenantId = group.TenantId,
            LineNo = lineNo,
            ProductId = input.ProductId,
            BatchId = input.BatchId,
            LocationId = input.LocationId,
            QtyBase = qtyBase,
            BaseUomId = input.BaseUomId,
            EnteredQty = input.EnteredQty,
            EnteredUomId = input.EnteredUomId,
            ConversionRate = input.ConversionRate,
            UnitCost = input.UnitCost,
            Currency = input.Currency,
            FxRate = input.FxRate,
            PostedAt = group.PostedAt,
            PostedBy = group.PostedBy,
        };
}
