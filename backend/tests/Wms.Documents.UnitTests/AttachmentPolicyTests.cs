using Wms.Documents.Domain;
using Wms.Documents.Domain.Entities;
using Wms.Documents.Domain.Enums;

namespace Wms.Documents.UnitTests;

/// <summary>Spec §11: 25 MB per file, five allowed content types, server-generated MinIO keys.</summary>
public sealed class AttachmentPolicyTests
{
    [Fact]
    public void The_cap_is_exactly_25_MB() => Assert.Equal(26_214_400UL, AttachmentPolicy.MaxSizeBytes);

    [Fact]
    public void Exactly_five_content_types_are_allowed() => Assert.Equal(5, AttachmentPolicy.AllowedContentTypes.Count);

    [Theory]
    [MemberData(nameof(ContentTypes.Allowed), MemberType = typeof(ContentTypes))]
    public void An_allowed_type_passes(string contentType) =>
        Assert.True(AttachmentPolicy.Validate(contentType, 1024).IsSuccess);

    [Theory]
    [MemberData(nameof(ContentTypes.Rejected), MemberType = typeof(ContentTypes))]
    public void A_forbidden_type_is_422(string contentType)
    {
        var result = AttachmentPolicy.Validate(contentType, 1024);

        Assert.True(result.IsFailure);
        Assert.Equal("ATTACHMENT_TYPE_NOT_ALLOWED", result.Error.Code);
        Assert.Equal(422, result.Error.Status);
    }

    [Theory]
    [InlineData(0UL)]
    [InlineData(26_214_401UL)]
    [InlineData(100UL * 1024 * 1024)]
    public void A_bad_size_is_422(ulong sizeBytes)
    {
        var result = AttachmentPolicy.Validate(ContentTypes.Pdf, sizeBytes);

        Assert.True(result.IsFailure);
        Assert.Equal("ATTACHMENT_TOO_LARGE", result.Error.Code);
        Assert.Equal(422, result.Error.Status);
    }

    [Theory]
    [InlineData("APPLICATION/PDF")]
    [InlineData("application/pdf; charset=binary")]
    [InlineData("  application/pdf  ")]
    public void The_media_type_is_compared_without_case_or_parameters(string contentType) =>
        Assert.True(AttachmentPolicy.IsAllowedContentType(contentType));

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("0123456789abcdef")]
    [InlineData("zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz")]
    public void A_bad_checksum_is_rejected(string? value) => Assert.False(AttachmentPolicy.IsChecksum(value));

    [Fact]
    public void A_64_character_hex_digest_is_a_checksum() => Assert.True(AttachmentPolicy.IsChecksum(new string('a', 64)));
}

public sealed class AttachmentStorageKeyTests
{
    [Fact]
    public void The_key_is_tenant_first_and_ends_with_the_sanitised_name()
    {
        var key = AttachmentStorageKey.Build(7, "GOODS_RECEIPT", 42, Guid.Parse("11111111-2222-3333-4444-555555555555"), "Qaimə 2026.pdf");

        Assert.Equal("7/goods_receipt/42/11111111222233334444555555555555/Qaim_2026.pdf", key);
    }

    [Fact]
    public void An_unlinked_attachment_gets_the_unassigned_segment()
    {
        var key = AttachmentStorageKey.Build(3, "PURCHASE_ORDER", 0, Guid.NewGuid(), "po.pdf");

        Assert.StartsWith("3/purchase_order/unassigned/", key, StringComparison.Ordinal);
    }

    [Theory]
    [InlineData("../../../etc/passwd", "etc_passwd")]
    [InlineData("C:\\Windows\\System32\\cmd.exe", "C_Windows_System32_cmd.exe")]
    [InlineData("a/b/c.pdf", "a_b_c.pdf")]
    [InlineData("   ", "file")]
    [InlineData("", "file")]
    [InlineData("...", "file")]
    [InlineData("rapor 2026.xlsx", "rapor_2026.xlsx")]
    [InlineData("naïve\u0000name.png", "na_ve_name.png")]
    public void The_file_name_is_reduced_to_a_safe_segment(string input, string expected) =>
        Assert.Equal(expected, AttachmentStorageKey.SanitiseFileName(input));

    [Fact]
    public void A_very_long_file_name_is_truncated()
    {
        var sanitised = AttachmentStorageKey.SanitiseFileName(new string('x', 400) + ".pdf");

        Assert.Equal(120, sanitised.Length);
    }

    [Fact]
    public void Two_uploads_of_the_same_file_never_share_a_key()
    {
        var first = AttachmentStorageKey.Build(1, "PRODUCT", 5, Guid.NewGuid(), "a.png");
        var second = AttachmentStorageKey.Build(1, "PRODUCT", 5, Guid.NewGuid(), "a.png");

        Assert.NotEqual(first, second);
    }
}

public sealed class AttachmentEntityTests
{
    private static Wms.Common.Domain.Result<Attachment> NewPending(string contentType = ContentTypes.Pdf, ulong size = 1024) =>
        Attachment.CreatePending(
            7, "GOODS_RECEIPT", 42, "INVOICE", "invoice.pdf", contentType, size,
            "7/goods_receipt/42/abc/invoice.pdf", 9, DateTimeOffset.UnixEpoch);

    [Fact]
    public void A_new_row_is_pending_invisible_and_has_no_checksum()
    {
        var attachment = NewPending().Value;

        Assert.Equal(AttachmentStatus.Pending, attachment.Status);
        Assert.False(attachment.IsVisible);
        Assert.True(attachment.CanComplete);
        Assert.Equal(string.Empty, attachment.ChecksumSha256);
    }

    [Fact]
    public void Marking_ready_records_the_verified_size_checksum_and_scan_result()
    {
        var attachment = NewPending().Value;

        Assert.True(attachment.MarkReady(2048, new string('A', 64), "CLEAN").IsSuccess);

        Assert.Equal(AttachmentStatus.Ready, attachment.Status);
        Assert.True(attachment.IsVisible);
        Assert.False(attachment.CanComplete);
        Assert.Equal(2048UL, attachment.SizeBytes);
        Assert.Equal(new string('a', 64), attachment.ChecksumSha256);
        Assert.Equal("CLEAN", attachment.ScanResult);
    }

    [Fact]
    public void A_ready_row_cannot_be_completed_again()
    {
        var attachment = NewPending().Value;
        Assert.True(attachment.MarkReady(2048, new string('a', 64), "CLEAN").IsSuccess);

        var again = attachment.MarkReady(2048, new string('a', 64), "CLEAN");

        Assert.True(again.IsFailure);
        Assert.Equal("INVALID_STATE_TRANSITION", again.Error.Code);
    }

    [Fact]
    public void A_ready_row_cannot_be_rejected()
    {
        var attachment = NewPending().Value;
        Assert.True(attachment.MarkReady(2048, new string('a', 64), "CLEAN").IsSuccess);

        var rejected = attachment.MarkRejected("INFECTED:X");

        Assert.True(rejected.IsFailure);
        Assert.Equal(409, rejected.Error.Status);
    }

    [Fact]
    public void Marking_ready_re_checks_the_size_cap()
    {
        var attachment = NewPending().Value;

        var result = attachment.MarkReady(AttachmentPolicy.MaxSizeBytes + 1, new string('a', 64), "CLEAN");

        Assert.True(result.IsFailure);
        Assert.Equal("ATTACHMENT_TOO_LARGE", result.Error.Code);
        Assert.Equal(AttachmentStatus.Pending, attachment.Status);
    }

    [Fact]
    public void A_forbidden_content_type_never_produces_a_row()
    {
        var result = NewPending("application/x-msdownload");

        Assert.True(result.IsFailure);
        Assert.Equal("ATTACHMENT_TYPE_NOT_ALLOWED", result.Error.Code);
    }

    [Fact]
    public void An_unlinked_row_can_be_linked_once()
    {
        var attachment = Attachment.CreatePending(
            7, "PURCHASE_ORDER", Attachment.UnassignedEntityId, "CONTRACT", "c.pdf", ContentTypes.Pdf, 10,
            "7/purchase_order/unassigned/abc/c.pdf", 9, DateTimeOffset.UnixEpoch).Value;

        Assert.False(attachment.IsLinked);
        Assert.True(attachment.LinkTo(77).IsSuccess);
        Assert.True(attachment.IsLinked);
        Assert.Equal(77, attachment.EntityId);
        Assert.True(attachment.LinkTo(78).IsFailure);
    }
}
