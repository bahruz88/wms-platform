using Wms.Common.Domain;

namespace Wms.Reporting.Domain;

/// <summary>RFC 7807 <c>code</c> values of reporting.v1.yaml (spec §13.3).</summary>
public static class ReportingErrors
{
    public static Error ReportNotFound(string code) =>
        new("NOT_FOUND", $"Report '{code}' is not in the catalogue.", 404);

    public static Error ExportNotFound(long id) =>
        new("NOT_FOUND", $"Export job '{id}' was not found.", 404);

    public static Error InvalidParameters(IReadOnlyDictionary<string, string[]> details) =>
        CommonErrors.Validation(details);

    public static Error UnsupportedFormat(string reportCode, string format) =>
        CommonErrors.Unprocessable(
            "UNSUPPORTED_FORMAT",
            $"Report '{reportCode}' does not support the '{format}' export format.");

    public static Error TooManyActiveExports(int limit) =>
        CommonErrors.Unprocessable(
            "TOO_MANY_ACTIVE_EXPORTS",
            $"A user may have at most {limit} queued or running export jobs at a time.");

    public static Error IdempotentReplay() =>
        CommonErrors.Conflict("IDEMPOTENT_REPLAY", "An export job with this Idempotency-Key already exists.");

    public static Error ReportTimedOut() =>
        CommonErrors.Unprocessable("REPORT_TIMEOUT", "The report did not finish in time.") with
        {
            Details = new Dictionary<string, string[]>(StringComparer.Ordinal)
            {
                ["parameters"] = ["Dövrü daraldın və ya export istifadə edin"],
            },
        };

    public static Error ExportNotDownloadable(string status) =>
        CommonErrors.Conflict("EXPORT_NOT_READY", $"The export job is {status}; only a COMPLETED job has a file.");
}
