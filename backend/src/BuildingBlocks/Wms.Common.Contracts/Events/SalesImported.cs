namespace Wms.Common.Contracts.Events;

/// <summary>
/// A branch day's sales have been accepted (ADR-012). Raised for every source — POS adapter, CSV upload or
/// manual entry. Consumers: Consumption (calculation trigger), Reporting.
/// </summary>
public sealed record SalesImported(
    uint TenantId,
    DateTimeOffset OccurredAt,
    long SalesImportId,
    uint LocationId,
    DateOnly BusinessDate,
    string Source,
    int LineCount,
    int UnmappedCount,
    decimal? GrossAmount) : IntegrationEvent(TenantId, OccurredAt);
