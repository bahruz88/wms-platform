namespace Wms.Common.Contracts.Events;

public sealed record UnmappedSalesItem(string? RawPosCode, uint? MenuItemId, string? MenuItemName, decimal QtySold, string Reason);

/// <summary>
/// Sales lines that produced no consumption: an unknown POS code, or a known menu item without a recipe version
/// effective on the business date (ADR-012 invariant 5). Consumer: Notification (manager).
/// </summary>
public sealed record SalesItemUnmapped(
    uint TenantId,
    DateTimeOffset OccurredAt,
    long SalesImportId,
    uint LocationId,
    DateOnly BusinessDate,
    IReadOnlyList<UnmappedSalesItem> Items) : IntegrationEvent(TenantId, OccurredAt);
