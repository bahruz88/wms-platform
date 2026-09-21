using Wms.Common.Domain;

namespace Wms.Reporting.Domain.Entities;

/// <summary><c>rpt_stock_snapshot</c>: end-of-day balance projection maintained by the ReportingProjector job (spec §15).</summary>
public sealed class StockSnapshot : Entity<long>, ITenantEntity
{
    private StockSnapshot()
    {
    }

    public uint TenantId { get; private set; }

    public DateOnly SnapshotDate { get; private set; }

    public uint ProductId { get; private set; }

    public uint LocationId { get; private set; }

    public decimal QtyOnHand { get; private set; }

    public decimal AvgUnitCost { get; private set; }

    public decimal TotalValue { get; private set; }

    public DateTimeOffset BuiltAt { get; private set; }

    public static StockSnapshot Create(uint tenantId, DateOnly snapshotDate, uint productId, uint locationId, decimal qtyOnHand, decimal avgUnitCost, DateTimeOffset builtAt) =>
        new()
        {
            TenantId = tenantId,
            SnapshotDate = snapshotDate,
            ProductId = productId,
            LocationId = locationId,
            QtyOnHand = qtyOnHand,
            AvgUnitCost = avgUnitCost,
            TotalValue = Quantity.Round(qtyOnHand * avgUnitCost, Money.StorageDecimals),
            BuiltAt = builtAt,
        };
}

/// <summary><c>rpt_report_definition</c>: catalogue of the reports of TOR §29.</summary>
public sealed class ReportDefinition : Entity<ushort>, ITenantEntity
{
    private ReportDefinition()
    {
    }

    public uint TenantId { get; private set; }

    public string Code { get; private set; } = string.Empty;

    public string Name { get; private set; } = string.Empty;

    public string Category { get; private set; } = string.Empty;

    public bool SupportsExcelExport { get; private set; } = true;

    public bool IsActive { get; private set; } = true;

    public static ReportDefinition Create(uint tenantId, string code, string name, string category, bool supportsExcelExport = true)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(code);
        return new ReportDefinition
        {
            TenantId = tenantId,
            Code = code.Trim().ToUpperInvariant(),
            Name = (name ?? string.Empty).Trim(),
            Category = (category ?? string.Empty).Trim(),
            SupportsExcelExport = supportsExcelExport,
        };
    }
}
