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

    /// <summary>1 CASE = 12 PCS → 12.00000000.</summary>
    public decimal FactorToBase { get; private set; }

    public bool IsPurchaseDefault { get; private set; }

    public bool IsIssueDefault { get; private set; }

    public DateOnly ValidFrom { get; private set; }

    public DateOnly? ValidTo { get; private set; }

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

    internal void Close(DateOnly validTo) => ValidTo = validTo;
}
