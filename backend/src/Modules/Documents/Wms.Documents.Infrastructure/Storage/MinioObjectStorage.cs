using System.Globalization;
using System.Text;
using Microsoft.Extensions.Options;
using Minio;
using Minio.DataModel.Args;
using Minio.Exceptions;
using Wms.Documents.Application.Abstractions;
using Wms.Documents.Domain;

namespace Wms.Documents.Infrastructure.Storage;

/// <summary>
/// MinIO implementation of <see cref="IObjectStorage"/> (spec §3: file bytes never pass through the API and
/// are never stored in MySQL). Two clients are built on purpose:
/// <list type="bullet">
///   <item>the internal client talks to <c>Minio__Endpoint</c> and does stat / download / delete;</item>
///   <item>the signing client talks to <c>Minio__PublicEndpoint</c> and only signs URLs, because a presigned
///   URL is bound to the host it was signed for and the browser cannot resolve <c>minio:9000</c>.</item>
/// </list>
/// The bucket stays private: clients only ever receive short-lived presigned URLs.
/// </summary>
public sealed class MinioObjectStorage : IObjectStorage, IDisposable
{
    private readonly IMinioClient _internalClient;
    private readonly IMinioClient _signingClient;
    private readonly bool _sharesClient;
    private readonly MinioOptions _options;
    private readonly ILogger<MinioObjectStorage> _logger;

    public MinioObjectStorage(IOptions<MinioOptions> options, ILogger<MinioObjectStorage> logger)
    {
        ArgumentNullException.ThrowIfNull(options);
        _options = options.Value;
        _logger = logger;

        var internalEndpoint = MinioEndpoint.Parse(_options.Endpoint, _options.UseSsl);
        var signingEndpoint = MinioEndpoint.Parse(_options.SigningEndpoint, _options.UseSsl);

        _internalClient = Build(internalEndpoint, _options);
        _sharesClient = internalEndpoint == signingEndpoint;
        _signingClient = _sharesClient ? _internalClient : Build(signingEndpoint, _options);
    }

    public async Task<PresignedUpload> PresignUploadAsync(string key, string contentType, TimeSpan lifetime, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();

        // Content-Type is deliberately NOT signed: MinIO only signs `host` for presigned URLs, and the
        // client library turns WithHeaders on a PUT into a bogus query parameter. The header is returned in
        // uploadHeaders so the client sends it, and what MinIO actually stored is re-checked on complete.
        var url = await _signingClient.PresignedPutObjectAsync(new PresignedPutObjectArgs()
            .WithBucket(_options.Bucket)
            .WithObject(key)
            .WithExpiry(ToSeconds(lifetime))).ConfigureAwait(false);

        var headers = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            ["Content-Type"] = AttachmentPolicy.Normalise(contentType),
        };

        return new PresignedUpload(new Uri(url, UriKind.Absolute), headers);
    }

    public async Task<Uri> PresignDownloadAsync(
        string key,
        string fileName,
        string contentType,
        bool inline,
        TimeSpan lifetime,
        CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();

        // These become signed `response-*` query parameters, so the disposition cannot be tampered with.
        var headers = new Dictionary<string, string>(StringComparer.Ordinal)
        {
            ["response-content-type"] = AttachmentPolicy.Normalise(contentType),
            ["response-content-disposition"] = ContentDisposition(fileName, inline),
        };

        var url = await _signingClient.PresignedGetObjectAsync(new PresignedGetObjectArgs()
            .WithBucket(_options.Bucket)
            .WithObject(key)
            .WithHeaders(headers)
            .WithExpiry(ToSeconds(lifetime))).ConfigureAwait(false);

        return new Uri(url, UriKind.Absolute);
    }

    public async Task<StoredObject?> StatAsync(string key, CancellationToken cancellationToken)
    {
        try
        {
            var stat = await _internalClient.StatObjectAsync(
                new StatObjectArgs().WithBucket(_options.Bucket).WithObject(key),
                cancellationToken).ConfigureAwait(false);

            return new StoredObject(
                key,
                stat.Size < 0 ? 0UL : (ulong)stat.Size,
                stat.ContentType ?? string.Empty,
                stat.ETag);
        }
        catch (ObjectNotFoundException)
        {
            return null;
        }
        catch (BucketNotFoundException ex)
        {
            _logger.LogError(ex, "MinIO bucket {Bucket} does not exist", _options.Bucket);
            return null;
        }
    }

    public async Task<Stream?> DownloadAsync(string key, CancellationToken cancellationToken)
    {
        // The caller has already rejected anything above the 25 MB cap, so buffering is bounded.
        var buffer = new MemoryStream();
        try
        {
            await _internalClient.GetObjectAsync(
                new GetObjectArgs()
                    .WithBucket(_options.Bucket)
                    .WithObject(key)
                    .WithCallbackStream((stream, token) => stream.CopyToAsync(buffer, token)),
                cancellationToken).ConfigureAwait(false);
        }
        catch (ObjectNotFoundException)
        {
            await buffer.DisposeAsync().ConfigureAwait(false);
            return null;
        }
        catch (BucketNotFoundException ex)
        {
            await buffer.DisposeAsync().ConfigureAwait(false);
            _logger.LogError(ex, "MinIO bucket {Bucket} does not exist", _options.Bucket);
            return null;
        }

        buffer.Position = 0;
        return buffer;
    }

    public async Task<bool> RemoveAsync(string key, CancellationToken cancellationToken)
    {
        try
        {
            await _internalClient.RemoveObjectAsync(
                new RemoveObjectArgs().WithBucket(_options.Bucket).WithObject(key),
                cancellationToken).ConfigureAwait(false);
            return true;
        }
        catch (MinioException ex)
        {
            // Orphans are swept by the AttachmentOrphanCleaner job (spec §15); never fail the request for this.
            _logger.LogWarning(ex, "Could not remove MinIO object {StorageKey}", key);
            return false;
        }
    }

    public void Dispose()
    {
        if (!_sharesClient)
        {
            _signingClient.Dispose();
        }

        _internalClient.Dispose();
    }

    public static string ContentDisposition(string fileName, bool inline)
    {
        var disposition = inline ? "inline" : "attachment";
        var ascii = new StringBuilder(fileName.Length);
        foreach (var c in fileName)
        {
            ascii.Append(c is >= ' ' and <= '~' && c is not ('"' or '\\') ? c : '_');
        }

        var fallback = ascii.ToString().Trim();
        if (fallback.Length == 0)
        {
            fallback = "download";
        }

        return string.Create(
            CultureInfo.InvariantCulture,
            $"{disposition}; filename=\"{fallback}\"; filename*=UTF-8''{Uri.EscapeDataString(fileName)}");
    }

    private static int ToSeconds(TimeSpan lifetime) =>
        (int)Math.Clamp(lifetime.TotalSeconds, 1, TimeSpan.FromDays(7).TotalSeconds);

    private static IMinioClient Build(MinioEndpoint endpoint, MinioOptions options) =>
        new MinioClient()
            .WithEndpoint(endpoint.Host, endpoint.Port)
            .WithCredentials(options.AccessKey, options.SecretKey)
            .WithRegion(options.Region)
            .WithSSL(endpoint.UseSsl)
            .Build();
}
