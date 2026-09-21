namespace Wms.Documents.Infrastructure.Antivirus;

/// <summary>
/// Bound from the <c>Antivirus</c> configuration section. Keys in env-var form are
/// <c>Antivirus__Enabled</c>, <c>Antivirus__Host</c>, <c>Antivirus__Port</c>,
/// <c>Antivirus__TimeoutSeconds</c> — plain <c>[A-Za-z0-9_]</c> identifiers (README §8.7).
/// </summary>
public sealed class AntivirusOptions
{
    public const string SectionName = "Antivirus";

    /// <summary>Off by default so the dev stack runs without a clamd container; on in staging and production.</summary>
    public bool Enabled { get; set; }

    public string Host { get; set; } = "clamav";

    /// <summary>clamd TCP port (<c>TCPSocket</c> in clamd.conf).</summary>
    public int Port { get; set; } = 3310;

    /// <summary>Connect + scan budget. Exceeding it fails closed with <c>VIRUS_SCAN_UNAVAILABLE</c>.</summary>
    public int TimeoutSeconds { get; set; } = 30;

    public TimeSpan Timeout => TimeSpan.FromSeconds(Math.Clamp(TimeoutSeconds, 1, 600));
}
