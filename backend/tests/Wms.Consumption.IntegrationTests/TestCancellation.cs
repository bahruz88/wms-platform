namespace Wms.Consumption.IntegrationTests;

/// <summary>Timeout guard for async assertions; xunit v2 has no ambient test cancellation token.</summary>
internal static class TestCancellation
{
    public static TimeSpan Timeout { get; } = TimeSpan.FromMinutes(5);

    public static CancellationToken Token => new CancellationTokenSource(Timeout).Token;
}
