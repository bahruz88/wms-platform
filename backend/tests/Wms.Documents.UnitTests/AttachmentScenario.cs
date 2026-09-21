using Wms.Documents.Application;
using Wms.Documents.Application.Commands;
using Wms.Documents.Application.Queries;
using Wms.Documents.Domain.Entities;

namespace Wms.Documents.UnitTests;

/// <summary>Wires the attachment handlers to in-memory doubles so the upload rules can be exercised without MinIO, clamd or MySQL.</summary>
internal sealed class AttachmentScenario
{
    public const uint TenantId = 7;
    public const uint OtherTenantId = 8;
    public const uint UserId = 42;
    public const string EntityType = "GOODS_RECEIPT";
    public const long EntityId = 1234;

    public static readonly DateTimeOffset Now = new(2026, 9, 22, 10, 0, 0, TimeSpan.Zero);

    public AttachmentScenario()
    {
        Store = new AttachmentStore(TenantId);
        Tenant = new FakeTenantContext(TenantId);
        User = new FakeCurrentUser(UserId);
    }

    public AttachmentStore Store { get; }

    public FakeObjectStorage Storage { get; } = new();

    public FakeVirusScanner Scanner { get; set; } = FakeVirusScanner.Disabled();

    public FakeDocumentsUnitOfWork UnitOfWork { get; } = new();

    public FakeTenantContext Tenant { get; }

    public FakeCurrentUser User { get; set; }

    public AttachmentLinkOptions Links { get; set; } = AttachmentLinkOptions.Default;

    public FixedClock Clock { get; } = new(Now);

    public PresignAttachmentUploadCommandHandler Presign() => new(
        new FakeAttachmentRepository(Store), UnitOfWork, Storage, Links, Tenant, User, Clock);

    public CompleteAttachmentUploadCommandHandler Complete() => new(
        new FakeAttachmentRepository(Store), UnitOfWork, Storage, Scanner, Tenant);

    public DeleteAttachmentCommandHandler Delete() => new(
        new FakeAttachmentRepository(Store), UnitOfWork, Storage, Tenant, User);

    public GetAttachmentQueryHandler GetOne() => new(new FakeAttachmentQueries(Store));

    public GetAttachmentsQueryHandler List() => new(new FakeAttachmentQueries(Store));

    public GetAttachmentDownloadUrlQueryHandler DownloadUrl() => new(
        new FakeAttachmentQueries(Store), Storage, Links, Clock);

    public static PresignAttachmentUploadCommand PresignCommand(
        string contentType = ContentTypes.Pdf,
        long sizeBytes = 1024,
        string fileName = "invoice.pdf",
        long? entityId = EntityId,
        string? checksum = null) =>
        new(EntityType, entityId, "INVOICE", fileName, contentType, sizeBytes, checksum);

    /// <summary>Presigns, uploads the bytes into the fake bucket and returns the row plus the SHA-256 to complete with.</summary>
    public async Task<(Attachment Row, string Checksum)> PendingUploadAsync(
        byte[] content,
        string contentType = ContentTypes.Pdf,
        string storedContentType = ContentTypes.Pdf)
    {
        var presigned = await Presign().HandleAsync(
            PresignCommand(contentType, content.Length), TestCancellation.Token);
        Assert.True(presigned.IsSuccess);

        var row = Store.Rows.Single(r => r.Id == presigned.Value.AttachmentId);
        var checksum = Storage.Put(row.StorageKey, content, storedContentType);
        return (row, checksum);
    }

    /// <summary>A row that has already been completed, for the read-side tests.</summary>
    public Attachment ReadyRow(
        string attachmentType = "INVOICE",
        string fileName = "invoice.pdf",
        long entityId = EntityId,
        uint tenantId = TenantId,
        uint uploadedBy = UserId)
    {
        var row = NewPending(attachmentType, fileName, entityId, tenantId, uploadedBy);
        Assert.True(row.MarkReady(1024, new string('a', 64), "SKIPPED").IsSuccess);
        return row;
    }

    public Attachment NewPending(
        string attachmentType = "INVOICE",
        string fileName = "invoice.pdf",
        long entityId = EntityId,
        uint tenantId = TenantId,
        uint uploadedBy = UserId)
    {
        var created = Attachment.CreatePending(
            tenantId,
            EntityType,
            entityId,
            attachmentType,
            fileName,
            ContentTypes.Pdf,
            1024,
            $"{tenantId}/goods_receipt/{entityId}/{Guid.NewGuid():N}/{fileName}",
            uploadedBy,
            Now);
        Assert.True(created.IsSuccess);
        return Store.Insert(created.Value);
    }
}
