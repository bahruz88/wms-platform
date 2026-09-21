using Wms.Documents.Application;
using Wms.Documents.Application.Queries;
using Wms.Documents.Domain;
using Wms.Documents.Domain.Enums;

namespace Wms.Documents.UnitTests;

/// <summary>
/// Contract <c>presignAttachmentUpload</c> and spec §11: the 25 MB cap and the five allowed content types
/// are enforced before any URL is signed, the row starts PENDING and the MinIO key is server-generated.
/// </summary>
public sealed class PresignAttachmentUploadTests
{
    [Fact]
    public async Task A_pdf_under_the_cap_is_presigned_and_the_row_starts_pending()
    {
        var scenario = new AttachmentScenario();

        var result = await scenario.Presign().HandleAsync(AttachmentScenario.PresignCommand(), TestCancellation.Token);

        Assert.True(result.IsSuccess);
        Assert.Equal("PUT", result.Value.Method);
        Assert.Equal(AttachmentPolicy.MaxSizeBytes, result.Value.MaxSizeBytes);
        Assert.Equal(AttachmentScenario.Now.AddMinutes(15), result.Value.ExpiresAt);
        Assert.Equal(ContentTypes.Pdf, result.Value.UploadHeaders["Content-Type"]);

        var row = Assert.Single(scenario.Store.Rows);
        Assert.Equal(AttachmentStatus.Pending, row.Status);
        Assert.Equal(AttachmentScenario.UserId, row.UploadedBy);
        Assert.Equal(AttachmentScenario.TenantId, row.TenantId);
        Assert.Equal(string.Empty, row.ChecksumSha256);
    }

    [Fact]
    public async Task Exactly_25_MB_is_still_allowed()
    {
        var scenario = new AttachmentScenario();

        var result = await scenario.Presign().HandleAsync(
            AttachmentScenario.PresignCommand(sizeBytes: (long)AttachmentPolicy.MaxSizeBytes), TestCancellation.Token);

        Assert.True(result.IsSuccess);
    }

    [Fact]
    public async Task One_byte_over_25_MB_is_refused_with_ATTACHMENT_TOO_LARGE()
    {
        var scenario = new AttachmentScenario();

        var result = await scenario.Presign().HandleAsync(
            AttachmentScenario.PresignCommand(sizeBytes: (long)AttachmentPolicy.MaxSizeBytes + 1), TestCancellation.Token);

        Assert.True(result.IsFailure);
        Assert.Equal("ATTACHMENT_TOO_LARGE", result.Error.Code);
        Assert.Equal(422, result.Error.Status);
        Assert.Empty(scenario.Store.Rows);
        Assert.Empty(scenario.Storage.PresignedUploadKeys);
    }

    [Theory]
    [MemberData(nameof(ContentTypes.Allowed), MemberType = typeof(ContentTypes))]
    public async Task Each_allowed_content_type_is_presigned(string contentType)
    {
        var scenario = new AttachmentScenario();

        var result = await scenario.Presign().HandleAsync(
            AttachmentScenario.PresignCommand(contentType), TestCancellation.Token);

        Assert.True(result.IsSuccess, $"{contentType} must be accepted (spec §11)");
    }

    [Theory]
    [MemberData(nameof(ContentTypes.Rejected), MemberType = typeof(ContentTypes))]
    public async Task Every_other_content_type_is_refused_with_ATTACHMENT_TYPE_NOT_ALLOWED(string contentType)
    {
        var scenario = new AttachmentScenario();

        var result = await scenario.Presign().HandleAsync(
            AttachmentScenario.PresignCommand(contentType), TestCancellation.Token);

        Assert.True(result.IsFailure, $"{contentType} must be rejected (spec §11)");
        Assert.Equal("ATTACHMENT_TYPE_NOT_ALLOWED", result.Error.Code);
        Assert.Equal(422, result.Error.Status);
        Assert.Empty(scenario.Store.Rows);
    }

    [Fact]
    public async Task A_charset_parameter_does_not_smuggle_a_forbidden_type_past_the_allow_list()
    {
        var scenario = new AttachmentScenario();

        var result = await scenario.Presign().HandleAsync(
            AttachmentScenario.PresignCommand("text/html; charset=utf-8"), TestCancellation.Token);

        Assert.True(result.IsFailure);
        Assert.Equal("ATTACHMENT_TYPE_NOT_ALLOWED", result.Error.Code);
    }

    [Fact]
    public async Task The_storage_key_is_tenant_scoped_and_carries_a_fresh_guid()
    {
        var scenario = new AttachmentScenario();

        var first = await scenario.Presign().HandleAsync(AttachmentScenario.PresignCommand(), TestCancellation.Token);
        var second = await scenario.Presign().HandleAsync(AttachmentScenario.PresignCommand(), TestCancellation.Token);

        Assert.True(first.IsSuccess);
        Assert.True(second.IsSuccess);

        var keys = scenario.Store.Rows.Select(r => r.StorageKey).ToList();
        Assert.Equal(2, keys.Distinct(StringComparer.Ordinal).Count());

        var segments = keys[0].Split('/');
        Assert.Equal(5, segments.Length);
        Assert.Equal("7", segments[0]);
        Assert.Equal("goods_receipt", segments[1]);
        Assert.Equal("1234", segments[2]);
        Assert.Equal(32, segments[3].Length);
        Assert.Equal("invoice.pdf", segments[4]);
        Assert.Equal(keys, scenario.Storage.PresignedUploadKeys);
    }

    [Fact]
    public async Task A_file_name_cannot_traverse_out_of_its_prefix()
    {
        var scenario = new AttachmentScenario();

        var result = await scenario.Presign().HandleAsync(
            AttachmentScenario.PresignCommand(fileName: "../../../etc/passwd"), TestCancellation.Token);

        Assert.True(result.IsSuccess);
        var key = scenario.Store.Rows.Single().StorageKey;
        Assert.Equal(5, key.Split('/').Length);
        Assert.DoesNotContain("..", key, StringComparison.Ordinal);
        Assert.StartsWith("7/goods_receipt/1234/", key, StringComparison.Ordinal);
    }

    [Fact]
    public async Task An_attachment_without_a_document_yet_is_keyed_as_unassigned()
    {
        var scenario = new AttachmentScenario();

        var result = await scenario.Presign().HandleAsync(
            AttachmentScenario.PresignCommand(entityId: null), TestCancellation.Token);

        Assert.True(result.IsSuccess);
        var row = scenario.Store.Rows.Single();
        Assert.False(row.IsLinked);
        Assert.Contains("/unassigned/", row.StorageKey, StringComparison.Ordinal);
    }

    [Fact]
    public async Task The_upload_url_lifetime_comes_from_configuration()
    {
        var scenario = new AttachmentScenario
        {
            Links = new AttachmentLinkOptions(TimeSpan.FromMinutes(3), TimeSpan.FromMinutes(1)),
        };

        var result = await scenario.Presign().HandleAsync(AttachmentScenario.PresignCommand(), TestCancellation.Token);

        Assert.True(result.IsSuccess);
        Assert.Equal(TimeSpan.FromMinutes(3), scenario.Storage.LastUploadLifetime);
        Assert.Equal(AttachmentScenario.Now.AddMinutes(3), result.Value.ExpiresAt);
    }

    [Fact]
    public async Task A_pending_row_is_not_returned_by_getAttachment()
    {
        var scenario = new AttachmentScenario();
        var presigned = await scenario.Presign().HandleAsync(AttachmentScenario.PresignCommand(), TestCancellation.Token);

        var read = await scenario.GetOne().HandleAsync(
            new GetAttachmentQuery(presigned.Value.AttachmentId), TestCancellation.Token);

        Assert.True(read.IsFailure);
        Assert.Equal("ATTACHMENT_NOT_FOUND", read.Error.Code);
        Assert.Equal(404, read.Error.Status);
    }

    [Fact]
    public async Task A_pending_row_is_not_listed()
    {
        var scenario = new AttachmentScenario();
        await scenario.Presign().HandleAsync(AttachmentScenario.PresignCommand(), TestCancellation.Token);

        var listed = await scenario.List().HandleAsync(
            new GetAttachmentsQuery(AttachmentScenario.EntityType, AttachmentScenario.EntityId, null), TestCancellation.Token);

        Assert.True(listed.IsSuccess);
        Assert.Empty(listed.Value);
    }

    [Fact]
    public async Task The_presign_is_audited()
    {
        var scenario = new AttachmentScenario();

        await scenario.Presign().HandleAsync(AttachmentScenario.PresignCommand(), TestCancellation.Token);

        var audit = Assert.Single(scenario.UnitOfWork.AuditEntries);
        Assert.Equal("common_attachment", audit.EntityType);
        Assert.Equal(1, scenario.UnitOfWork.CommitCount);
    }
}
