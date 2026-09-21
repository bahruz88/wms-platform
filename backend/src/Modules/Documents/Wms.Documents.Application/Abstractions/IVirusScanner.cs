using Wms.Common.Domain;

namespace Wms.Documents.Application.Abstractions;

/// <summary>Outcome of a ClamAV scan. <see cref="Signature"/> is set only when the file is infected.</summary>
public sealed record ScanVerdict(bool IsClean, string? Signature)
{
    public const string CleanResult = "CLEAN";
    public const string SkippedResult = "SKIPPED";

    public static ScanVerdict Clean { get; } = new(true, null);

    public static ScanVerdict Infected(string signature) => new(false, signature);

    /// <summary>Value stored in <c>common_attachment.scan_result</c>.</summary>
    public string ToScanResult(bool scannerEnabled) => IsClean
        ? scannerEnabled ? CleanResult : SkippedResult
        : $"INFECTED:{Signature}";
}

/// <summary>
/// Virus scanning of uploaded objects (spec §11). The ClamAV implementation talks INSTREAM to clamd over
/// plain TCP; <c>Antivirus__Enabled=false</c> swaps in a no-op so the dev stack runs without a clamd container.
/// Failures are values: an unreachable clamd fails closed with <c>VIRUS_SCAN_UNAVAILABLE</c> (503).
/// </summary>
public interface IVirusScanner
{
    /// <summary>False when <c>Antivirus__Enabled</c> is off; the caller then records <c>SKIPPED</c>.</summary>
    bool IsEnabled { get; }

    /// <summary>Scans the stream from its current position. A failed result means the scanner could not be reached.</summary>
    Task<Result<ScanVerdict>> ScanAsync(Stream content, CancellationToken cancellationToken);
}
