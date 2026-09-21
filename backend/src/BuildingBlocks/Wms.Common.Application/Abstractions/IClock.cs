namespace Wms.Common.Application.Abstractions;

/// <summary>Testable time source. Storage is always UTC (spec §6.3, Əlavə A).</summary>
public interface IClock
{
    DateTimeOffset UtcNow { get; }

    DateOnly Today => DateOnly.FromDateTime(UtcNow.UtcDateTime);
}
