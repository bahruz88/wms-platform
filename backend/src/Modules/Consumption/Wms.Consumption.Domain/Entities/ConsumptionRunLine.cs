using Wms.Common.Domain;

namespace Wms.Consumption.Domain.Entities;

/// <summary>
/// <c>cons_run_line</c> — the theoretical consumption of one product for one branch-day, and how much of it
/// could actually be taken out of stock. <c>posted + shortfall = theoretical</c> always holds (invariant 3).
/// </summary>
public sealed class ConsumptionRunLine : Entity<long>, ITenantEntity
{
    private ConsumptionRunLine()
    {
    }

    public uint TenantId { get; private set; }

    public long RunId { get; private set; }

    public uint ProductId { get; private set; }

    /// <summary>Result of the BOM explosion, in the product's base UoM.</summary>
    public decimal TheoreticalQtyBase { get; private set; }

    /// <summary><c>min(theoretical, available)</c> — what the ledger actually removed.</summary>
    public decimal PostedQtyBase { get; private set; }

    /// <summary>The part that stock did not cover. Never hidden: it is the earliest signal of an unrecorded receipt.</summary>
    public decimal ShortfallQtyBase { get; private set; }

    public ushort BaseUomId { get; private set; }

    public decimal? UnitCost { get; private set; }

    public static Result<ConsumptionRunLine> Create(uint tenantId, uint productId, decimal theoreticalQtyBase, ushort baseUomId)
    {
        if (productId == 0)
        {
            return ConsumptionErrors.InvalidRecipeLine("product_id is required.");
        }

        if (theoreticalQtyBase < 0m)
        {
            return ConsumptionErrors.InvalidRecipeLine("theoretical_qty_base cannot be negative.");
        }

        return new ConsumptionRunLine
        {
            TenantId = tenantId,
            ProductId = productId,
            TheoreticalQtyBase = theoreticalQtyBase,
            PostedQtyBase = 0m,
            ShortfallQtyBase = theoreticalQtyBase,
            BaseUomId = baseUomId,
        };
    }

    /// <summary>
    /// Invariant 3: the ledger never goes negative, so the posted quantity is capped at what is available and the
    /// remainder becomes the shortfall.
    /// </summary>
    public void Plan(decimal availableQtyBase)
    {
        var posted = Math.Min(TheoreticalQtyBase, Math.Max(availableQtyBase, 0m));
        PostedQtyBase = posted;
        ShortfallQtyBase = TheoreticalQtyBase - posted;
    }

    /// <summary>Applies the quantity Inventory actually posted after locking the balances (the authoritative number).</summary>
    public void Settle(decimal postedQtyBase, decimal? unitCost)
    {
        var posted = Math.Clamp(postedQtyBase, 0m, TheoreticalQtyBase);
        PostedQtyBase = posted;
        ShortfallQtyBase = TheoreticalQtyBase - posted;
        UnitCost = unitCost;
    }

    public void ResetToPlanned()
    {
        PostedQtyBase = 0m;
        ShortfallQtyBase = TheoreticalQtyBase;
        UnitCost = null;
    }
}
