namespace Wms.Documents.Application.Abstractions;

/// <summary>What MinIO reports about a stored object (<c>StatObject</c>).</summary>
public sealed record StoredObject(string Key, ulong SizeBytes, string ContentType, string? ETag);

/// <summary>A presigned <c>PUT</c> the client performs directly against MinIO; the bytes never pass through the API (spec §3).</summary>
public sealed record PresignedUpload(Uri UploadUrl, IReadOnlyDictionary<string, string> Headers);

/// <summary>
/// Object store behind the attachment flow. Kept as an interface so the upload rules can be unit tested
/// without a MinIO container, and so the handlers never see a provider exception.
/// </summary>
public interface IObjectStorage
{
    /// <summary>Signs a <c>PUT</c> URL for <paramref name="key"/>. Signed with the public endpoint, so a browser can reach it.</summary>
    Task<PresignedUpload> PresignUploadAsync(string key, string contentType, TimeSpan lifetime, CancellationToken cancellationToken);

    /// <summary>Signs a short-lived <c>GET</c> URL. The bucket stays private; there is no public object URL.</summary>
    Task<Uri> PresignDownloadAsync(
        string key,
        string fileName,
        string contentType,
        bool inline,
        TimeSpan lifetime,
        CancellationToken cancellationToken);

    /// <summary>Metadata of the stored object, or <c>null</c> when nothing was uploaded.</summary>
    Task<StoredObject?> StatAsync(string key, CancellationToken cancellationToken);

    /// <summary>
    /// Buffers the object into a rewindable stream so it can be hashed and scanned in one download.
    /// Callers must have checked the size first; <c>null</c> when the object is gone.
    /// </summary>
    Task<Stream?> DownloadAsync(string key, CancellationToken cancellationToken);

    /// <summary>Best effort delete; <c>false</c> when the object could not be removed (already logged by the implementation).</summary>
    Task<bool> RemoveAsync(string key, CancellationToken cancellationToken);
}
