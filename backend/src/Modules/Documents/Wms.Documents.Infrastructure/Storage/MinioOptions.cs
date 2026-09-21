using System.Globalization;

namespace Wms.Documents.Infrastructure.Storage;

/// <summary>
/// Bound from the <c>Minio</c> configuration section (CONVENTIONS.md). Every key is a plain
/// <c>[A-Za-z0-9_]</c> identifier in env-var form, as README §8.7 requires.
/// </summary>
public sealed class MinioOptions
{
    public const string SectionName = "Minio";

    /// <summary>Endpoint the API itself talks to, e.g. <c>minio:9000</c> inside the compose network.</summary>
    public string Endpoint { get; set; } = "localhost:9000";

    /// <summary>
    /// Endpoint the browser can reach, e.g. <c>localhost:9000</c> from the developer's machine. Used ONLY to
    /// sign the URLs handed to clients — a presigned URL is bound to the host it was signed for, so signing
    /// with <c>minio:9000</c> would produce links no browser can open. Falls back to <see cref="Endpoint"/>.
    /// </summary>
    public string? PublicEndpoint { get; set; }

    public string AccessKey { get; set; } = string.Empty;

    public string SecretKey { get; set; } = string.Empty;

    public string Bucket { get; set; } = "wms-attachments";

    /// <summary>Set explicitly so presigning never has to ask the server for the bucket location.</summary>
    public string Region { get; set; } = "us-east-1";

    /// <summary>Default scheme when an endpoint carries no <c>http://</c> / <c>https://</c> prefix.</summary>
    public bool UseSsl { get; set; }

    /// <summary>Lifetime of the presigned PUT (contract: 15 minutes).</summary>
    public int UploadUrlMinutes { get; set; } = 15;

    /// <summary>Lifetime of the presigned GET (contract: 5 minutes).</summary>
    public int DownloadUrlMinutes { get; set; } = 5;

    public TimeSpan UploadUrlLifetime => TimeSpan.FromMinutes(Math.Clamp(UploadUrlMinutes, 1, 60 * 24));

    public TimeSpan DownloadUrlLifetime => TimeSpan.FromMinutes(Math.Clamp(DownloadUrlMinutes, 1, 60 * 24));

    /// <summary>Endpoint used for signing; <see cref="PublicEndpoint"/> when set, otherwise <see cref="Endpoint"/>.</summary>
    public string SigningEndpoint => string.IsNullOrWhiteSpace(PublicEndpoint) ? Endpoint : PublicEndpoint;
}

/// <summary>Host / port / scheme of a <c>Minio__*Endpoint</c> value, which may or may not carry a scheme.</summary>
public sealed record MinioEndpoint(string Host, int Port, bool UseSsl)
{
    public static MinioEndpoint Parse(string? value, bool defaultUseSsl)
    {
        var raw = (value ?? string.Empty).Trim();
        if (raw.Length == 0)
        {
            return new MinioEndpoint("localhost", defaultUseSsl ? 443 : 9000, defaultUseSsl);
        }

        if (raw.Contains("://", StringComparison.Ordinal))
        {
            var uri = new Uri(raw, UriKind.Absolute);
            var secure = string.Equals(uri.Scheme, Uri.UriSchemeHttps, StringComparison.OrdinalIgnoreCase);
            return new MinioEndpoint(uri.Host, uri.IsDefaultPort ? (secure ? 443 : 80) : uri.Port, secure);
        }

        var separator = raw.LastIndexOf(':');
        if (separator > 0
            && int.TryParse(raw[(separator + 1)..], NumberStyles.Integer, CultureInfo.InvariantCulture, out var port)
            && port is > 0 and <= 65535)
        {
            return new MinioEndpoint(raw[..separator], port, defaultUseSsl);
        }

        return new MinioEndpoint(raw, defaultUseSsl ? 443 : 80, defaultUseSsl);
    }
}
