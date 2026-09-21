using System.Globalization;
using System.Security.Cryptography;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Security;
using Wms.Common.Contracts;
using Wms.Common.Domain;
using Wms.Documents.Application;
using Wms.Documents.Application.Abstractions;
using Wms.Documents.Contracts;
using Wms.Documents.Domain;
using Wms.Documents.Domain.Entities;
using Wms.Documents.Domain.Enums;

namespace Wms.Documents.UnitTests;

public sealed class FakeTenantContext(uint tenantId) : ITenantContext
{
    public uint TenantId { get; } = tenantId;

    public bool HasTenant => TenantId != 0;
}

public sealed class FakeCurrentUser(uint userId, params string[] permissions) : ICurrentUser
{
    private readonly HashSet<string> _permissions = new(permissions, StringComparer.OrdinalIgnoreCase);

    public bool IsAuthenticated => true;

    public uint UserId { get; } = userId;

    public string ExternalId { get; } = userId.ToString(CultureInfo.InvariantCulture);

    public string Username { get; } = "tester";

    public string FullName { get; } = "Test User";

    public IReadOnlyCollection<string> Roles { get; } = [];

    public IReadOnlyCollection<string> Permissions => _permissions;

    public LocationScope LocationScope => LocationScope.Unrestricted;

    public IReadOnlyCollection<uint> LocationIds => LocationScope.LocationIds;

    public bool HasPermission(string permission) => _permissions.Contains(permission);
}

public sealed class FixedClock(DateTimeOffset now) : IClock
{
    public DateTimeOffset UtcNow { get; } = now;
}

/// <summary>
/// Stands in for <c>common_attachment</c> plus the EF tenant query filter: rows of another tenant are
/// invisible, exactly as the global filter of <c>DocumentsDbContext</c> makes them.
/// </summary>
public sealed class AttachmentStore(uint currentTenantId)
{
    private long _nextId;

    public List<Attachment> Rows { get; } = [];

    public uint CurrentTenantId { get; } = currentTenantId;

    public Attachment Insert(Attachment attachment)
    {
        SetId(attachment, ++_nextId);
        Rows.Add(attachment);
        return attachment;
    }

    public IEnumerable<Attachment> Visible => Rows.Where(r => r.TenantId == CurrentTenantId);

    public static void SetId(Attachment attachment, long id) =>
        typeof(Entity<long>).GetProperty(nameof(Entity<long>.Id))!.SetValue(attachment, id);
}

public sealed class FakeAttachmentRepository(AttachmentStore store) : IAttachmentRepository
{
    public Task<Attachment?> GetAsync(long attachmentId, CancellationToken cancellationToken) =>
        Task.FromResult(store.Visible.FirstOrDefault(a => a.Id == attachmentId));

    public void Add(Attachment attachment) => store.Insert(attachment);

    public void Remove(Attachment attachment) => store.Rows.Remove(attachment);
}

public sealed record AuditEntry(string EntityType, long EntityId, AuditAction Action);

public sealed class FakeDocumentsUnitOfWork : IDocumentsUnitOfWork, IAuditTrail, IIntegrationEventOutbox
{
    public List<AuditEntry> AuditEntries { get; } = [];

    public int SaveCount { get; private set; }

    public int CommitCount { get; private set; }

    public IIntegrationEventOutbox Outbox => this;

    public IAuditTrail Audit => this;

    public Task<IDocumentsUnitOfWorkTransaction> BeginTransactionAsync(CancellationToken cancellationToken) =>
        Task.FromResult<IDocumentsUnitOfWorkTransaction>(new FakeTransaction(this));

    public Task<int> SaveChangesAsync(CancellationToken cancellationToken)
    {
        SaveCount++;
        return Task.FromResult(0);
    }

    public void Record(string entityType, long entityId, AuditAction action, object? changes = null) =>
        AuditEntries.Add(new AuditEntry(entityType, entityId, action));

    public void Enqueue(IntegrationEvent integrationEvent)
    {
    }

    private sealed class FakeTransaction(FakeDocumentsUnitOfWork owner) : IDocumentsUnitOfWorkTransaction
    {
        public Task CommitAsync(CancellationToken cancellationToken)
        {
            owner.CommitCount++;
            return Task.CompletedTask;
        }

        public Task RollbackAsync(CancellationToken cancellationToken) => Task.CompletedTask;

        public ValueTask DisposeAsync() => ValueTask.CompletedTask;
    }
}

public sealed record FakeStoredBlob(byte[] Content, string ContentType, string ETag);

public sealed class FakeObjectStorage : IObjectStorage
{
    public Dictionary<string, FakeStoredBlob> Objects { get; } = new(StringComparer.Ordinal);

    public List<string> PresignedUploadKeys { get; } = [];

    public List<string> RemovedKeys { get; } = [];

    public TimeSpan? LastUploadLifetime { get; private set; }

    public TimeSpan? LastDownloadLifetime { get; private set; }

    public bool? LastDownloadInline { get; private set; }

    public string? LastDownloadKey { get; private set; }

    /// <summary>Stores a blob and returns the SHA-256 the complete endpoint has to be given.</summary>
    public string Put(string key, byte[] content, string contentType)
    {
        Objects[key] = new FakeStoredBlob(content, contentType, "\"fake-etag\"");
        return Convert.ToHexStringLower(SHA256.HashData(content));
    }

    public Task<PresignedUpload> PresignUploadAsync(string key, string contentType, TimeSpan lifetime, CancellationToken cancellationToken)
    {
        PresignedUploadKeys.Add(key);
        LastUploadLifetime = lifetime;
        var headers = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase) { ["Content-Type"] = contentType };
        return Task.FromResult(new PresignedUpload(
            new Uri($"http://localhost:9000/wms-attachments/{key}?X-Amz-Signature=fake"),
            headers));
    }

    public Task<Uri> PresignDownloadAsync(
        string key,
        string fileName,
        string contentType,
        bool inline,
        TimeSpan lifetime,
        CancellationToken cancellationToken)
    {
        LastDownloadKey = key;
        LastDownloadLifetime = lifetime;
        LastDownloadInline = inline;
        return Task.FromResult(new Uri($"http://localhost:9000/wms-attachments/{key}?X-Amz-Expires={(int)lifetime.TotalSeconds}&X-Amz-Signature=fake"));
    }

    public Task<StoredObject?> StatAsync(string key, CancellationToken cancellationToken) =>
        Task.FromResult(Objects.TryGetValue(key, out var blob)
            ? new StoredObject(key, (ulong)blob.Content.Length, blob.ContentType, blob.ETag)
            : null);

    public Task<Stream?> DownloadAsync(string key, CancellationToken cancellationToken) =>
        Task.FromResult<Stream?>(Objects.TryGetValue(key, out var blob)
            ? new MemoryStream(blob.Content, writable: false)
            : null);

    public Task<bool> RemoveAsync(string key, CancellationToken cancellationToken)
    {
        RemovedKeys.Add(key);
        return Task.FromResult(Objects.Remove(key));
    }
}

/// <summary>Configurable <see cref="IVirusScanner"/>: clean, infected, or unreachable (fails closed).</summary>
public sealed class FakeVirusScanner : IVirusScanner
{
    public bool IsEnabled { get; set; }

    public string? InfectedSignature { get; set; }

    public bool Unavailable { get; set; }

    public int ScanCount { get; private set; }

    public long LastScannedBytes { get; private set; }

    public static FakeVirusScanner Disabled() => new();

    public static FakeVirusScanner Clean() => new() { IsEnabled = true };

    public static FakeVirusScanner Infected(string signature) => new() { IsEnabled = true, InfectedSignature = signature };

    public static FakeVirusScanner Unreachable() => new() { IsEnabled = true, Unavailable = true };

    public async Task<Result<ScanVerdict>> ScanAsync(Stream content, CancellationToken cancellationToken)
    {
        ScanCount++;
        using var buffer = new MemoryStream();
        await content.CopyToAsync(buffer, cancellationToken);
        LastScannedBytes = buffer.Length;

        if (Unavailable)
        {
            return DocumentsErrors.VirusScanUnavailable();
        }

        return InfectedSignature is null
            ? Result.Success(ScanVerdict.Clean)
            : Result.Success(ScanVerdict.Infected(InfectedSignature));
    }
}

/// <summary>In-memory <see cref="IAttachmentQueries"/> with the same visibility rules as the EF implementation.</summary>
public sealed class FakeAttachmentQueries(AttachmentStore store) : IAttachmentQueries
{
    public Task<AttachmentDto?> GetAsync(long attachmentId, CancellationToken cancellationToken)
    {
        var row = store.Visible.FirstOrDefault(a => a.Id == attachmentId && a.Status == AttachmentStatus.Ready);
        return Task.FromResult(row is null
            ? null
            : new AttachmentDto(
                row.Id,
                row.EntityType,
                row.IsLinked ? row.EntityId : null,
                row.AttachmentType,
                row.FileName,
                row.ContentType,
                row.SizeBytes,
                row.StorageKey,
                row.ChecksumSha256,
                row.Status.ToString().ToUpperInvariant(),
                row.UploadedAt));
    }

    public Task<AttachmentResponse?> GetVisibleAsync(long attachmentId, CancellationToken cancellationToken)
    {
        var row = store.Visible.FirstOrDefault(a => a.Id == attachmentId && a.IsVisible);
        return Task.FromResult(row is null ? null : AttachmentResponse.From(row));
    }

    public Task<IReadOnlyList<AttachmentResponse>> GetByEntityAsync(
        string entityType,
        long entityId,
        string? attachmentType,
        CancellationToken cancellationToken)
    {
        IReadOnlyList<AttachmentResponse> rows = store.Visible
            .Where(a => a.EntityType == entityType
                && a.EntityId == entityId
                && a.Status == AttachmentStatus.Ready
                && (attachmentType is null || a.AttachmentType == attachmentType))
            .OrderByDescending(a => a.UploadedAt)
            .ThenByDescending(a => a.Id)
            .Select(AttachmentResponse.From)
            .ToList();
        return Task.FromResult(rows);
    }

    public Task<AttachmentDownloadTarget?> GetDownloadTargetAsync(long attachmentId, CancellationToken cancellationToken)
    {
        var row = store.Visible.FirstOrDefault(a => a.Id == attachmentId);
        return Task.FromResult(row is null
            ? null
            : new AttachmentDownloadTarget(row.Id, row.StorageKey, row.FileName, row.ContentType, row.SizeBytes, row.Status));
    }
}

/// <summary>Content types the contract allows, and a representative sample of the ones it does not.</summary>
public static class ContentTypes
{
    public const string Pdf = "application/pdf";
    public const string Jpeg = "image/jpeg";
    public const string Png = "image/png";
    public const string Xlsx = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
    public const string Docx = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";

    public static TheoryData<string> Allowed() => [Pdf, Jpeg, Png, Xlsx, Docx];

    public static TheoryData<string> Rejected() =>
    [
        "application/octet-stream",
        "application/x-msdownload",
        "application/x-dosexec",
        "application/zip",
        "application/x-sh",
        "text/html",
        "text/plain",
        "image/svg+xml",
        "image/gif",
        "application/vnd.ms-excel",
        "application/msword",
        "application/json",
    ];
}
