using Wms.Common.Domain;

namespace Wms.MasterData.Domain.Entities;

/// <summary><c>master_product_uom</c> (spec §8): <c>factor_to_base DECIMAL(18,8)</c> with a validity window.</summary>
public sealed class ProductUom : Entity<uint>, ITenantEntity
{
    private ProductUom()
    {
    }

    public uint TenantId { get; private set; }

    public uint ProductId { get; private set; }

    public ushort UomId { get; private set; }

    /// <summary>1 CASE = 12 PCS → 12.00000000. Never UPDATEd — a change closes this row and opens a new one (spec §12.1).</summary>
    public decimal FactorToBase { get; private set; }

    public bool IsPurchaseDefault { get; private set; }

    public bool IsIssueDefault { get; private set; }

    public DateOnly ValidFrom { get; private set; }

    public DateOnly? ValidTo { get; private set; }

    /// <summary>True while no <c>valid_to</c> closes the row.</summary>
    public bool IsOpen => ValidTo is null;

    internal static ProductUom CreateBase(uint tenantId, ushort baseUomId, DateOnly validFrom) =>
        new()
        {
            TenantId = tenantId,
            UomId = baseUomId,
            FactorToBase = 1m,
            ValidFrom = validFrom,
            IsPurchaseDefault = false,
            IsIssueDefault = true,
        };

    internal static ProductUom Create(uint tenantId, ushort uomId, decimal factorToBase, DateOnly validFrom, bool isPurchaseDefault, bool isIssueDefault) =>
        new()
        {
            TenantId = tenantId,
            UomId = uomId,
            FactorToBase = factorToBase,
            ValidFrom = validFrom,
            IsPurchaseDefault = isPurchaseDefault,
            IsIssueDefault = isIssueDefault,
        };

    public bool IsValidOn(DateOnly date) => date >= ValidFrom && (ValidTo is null || date <= ValidTo);

    /// <summary>True when a window starting on <paramref name="validFrom"/> would overlap this row.</summary>
    internal bool OverlapsFrom(DateOnly validFrom) => ValidTo is null ? validFrom <= ValidFrom : validFrom <= ValidTo.Value;

    internal void Close(DateOnly validTo) => ValidTo = validTo;

    /// <summary>The purchase/issue defaults are plain flags, not part of the versioned factor (spec §12.1).</summary>
    internal void SetDefaults(bool isPurchaseDefault, bool isIssueDefault)
    {
        IsPurchaseDefault = isPurchaseDefault;
        IsIssueDefault = isIssueDefault;
    }
}
