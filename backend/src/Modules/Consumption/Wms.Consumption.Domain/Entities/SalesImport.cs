using Wms.Common.Domain;
using Wms.Consumption.Domain.Enums;

namespace Wms.Consumption.Domain.Entities;

/// <summary>
/// <c>cons_sales_import</c> — one branch, one business day, one document (invariant 2), whatever the source
/// (POS adapter, CSV upload or manual entry). All three feed the same downstream flow (ADR-012).
/// </summary>
public sealed class SalesImport : AggregateRoot<long>, ITenantEntity, IVersioned
{
    public const int ExternalRefMaxLength = 120;

    private readonly List<SalesLine> _lines = [];

    private SalesImport()
    {
    }

    public uint TenantId { get; private set; }

    public uint LocationId { get; private set; }

    public DateOnly BusinessDate { get; private set; }

    public SalesSource Source { get; private set; }

    public string? ExternalRef { get; private set; }

    public SalesImportStatus Status { get; private set; } = SalesImportStatus.Draft;

    public ushort LineCount { get; private set; }

    public decimal? GrossAmount { get; private set; }

    public DateTimeOffset ImportedAt { get; private set; }

    public uint ImportedBy { get; private set; }

    public uint RowVersion { get; private set; } = 1;

    public IReadOnlyList<SalesLine> Lines => _lines.AsReadOnly();

    public void BumpVersion() => RowVersion++;

    public static Result<SalesImport> CreateDraft(
        uint tenantId,
        uint locationId,
        DateOnly businessDate,
        SalesSource source,
        string? externalRef,
        DateTimeOffset importedAt,
        uint importedBy,
        DateOnly today)
    {
        if (locationId == 0)
        {
            return ConsumptionErrors.InvalidSalesLine("location_id is required.");
        }

        if (businessDate > today)
        {
            return ConsumptionErrors.InvalidSalesLine($"business_date {businessDate:yyyy-MM-dd} is in the future.");
        }

        return new SalesImport
        {
            TenantId = tenantId,
            LocationId = locationId,
            BusinessDate = businessDate,
            Source = source,
            ExternalRef = externalRef is { Length: > ExternalRefMaxLength } ? externalRef[..ExternalRefMaxLength] : externalRef,
            Status = SalesImportStatus.Draft,
            ImportedAt = importedAt,
            ImportedBy = importedBy,
        };
    }

    /// <summary>Replaces all sales lines (PUT has replace semantics). Only a DRAFT import may be edited.</summary>
    public Result ReplaceLines(IEnumerable<SalesLine> lines)
    {
        ArgumentNullException.ThrowIfNull(lines);
        if (Status != SalesImportStatus.Draft)
        {
            return ConsumptionErrors.InvalidStateTransition(nameof(SalesImport), Id, Status, SalesImportStatus.Draft);
        }

        var replacement = lines.ToList();
        var duplicate = replacement
            .GroupBy(l => (l.MenuItemId, l.RawPosCode))
            .FirstOrDefault(g => g.Count() > 1);
        if (duplicate is not null)
        {
            return ConsumptionErrors.InvalidSalesLine(
                $"Menu item '{duplicate.Key.MenuItemId?.ToString(System.Globalization.CultureInfo.InvariantCulture) ?? duplicate.Key.RawPosCode}' appears more than once; sum the quantities instead.");
        }

        _lines.Clear();
        _lines.AddRange(replacement);
        LineCount = (ushort)Math.Min(_lines.Count, ushort.MaxValue);
        GrossAmount = _lines.Any(l => l.GrossAmount is not null) ? _lines.Sum(l => l.GrossAmount ?? 0m) : null;
        return Result.Success();
    }

    public Result Submit()
    {
        if (Status != SalesImportStatus.Draft)
        {
            return ConsumptionErrors.InvalidStateTransition(nameof(SalesImport), Id, Status, SalesImportStatus.Submitted);
        }

        if (_lines.Count == 0)
        {
            return ConsumptionErrors.InvalidSalesLine("A sales import without lines cannot be submitted.");
        }

        Status = SalesImportStatus.Submitted;
        return Result.Success();
    }

    /// <summary>Set when the consumption run built from this import is posted.</summary>
    public Result MarkConsumed()
    {
        if (Status != SalesImportStatus.Submitted)
        {
            return ConsumptionErrors.InvalidStateTransition(nameof(SalesImport), Id, Status, SalesImportStatus.Consumed);
        }

        Status = SalesImportStatus.Consumed;
        return Result.Success();
    }

    /// <summary>A reversed run releases its import so the day can be recalculated.</summary>
    public Result ReopenAfterReversal()
    {
        if (Status != SalesImportStatus.Consumed)
        {
            return ConsumptionErrors.InvalidStateTransition(nameof(SalesImport), Id, Status, SalesImportStatus.Submitted);
        }

        Status = SalesImportStatus.Submitted;
        return Result.Success();
    }

    public Result Cancel()
    {
        if (Status is SalesImportStatus.Consumed or SalesImportStatus.Cancelled)
        {
            return ConsumptionErrors.InvalidStateTransition(nameof(SalesImport), Id, Status, SalesImportStatus.Cancelled);
        }

        Status = SalesImportStatus.Cancelled;
        return Result.Success();
    }
}
