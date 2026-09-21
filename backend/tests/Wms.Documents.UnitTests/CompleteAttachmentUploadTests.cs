using System.Text;
using Wms.Documents.Application.Commands;
using Wms.Documents.Domain;
using Wms.Documents.Domain.Enums;

namespace Wms.Documents.UnitTests;

/// <summary>
/// Contract <c>completeAttachmentUpload</c>: the object MinIO actually stored is re-verified (size, content
/// type, SHA-256, ClamAV) before the row becomes visible. Nothing here trusts what the client declared.
/// </summary>
public sealed class CompleteAttachmentUploadTests
{
    private static readonly byte[] Content = Encoding.UTF8.GetBytes("%PDF-1.7 a small but valid enough payload");

    [Fact]
    public async Task A_verified_upload_becomes_ready_with_the_real_size_and_checksum()
    {
        var scenario = new AttachmentScenario();
        var (row, checksum) = await scenario.PendingUploadAsync(Content);

        var result = await scenario.Complete().HandleAsync(
            new CompleteAttachmentUploadCommand(row.Id, checksum, null), TestCancellation.Token);

        Assert.True(result.IsSuccess);
        Assert.Equal(AttachmentStatus.Ready, result.Value.Status);
        Assert.Equal(checksum, result.Value.ChecksumSha256);
        Assert.Equal((ulong)Content.Length, result.Value.SizeBytes);
        Assert.Equal("SKIPPED", result.Value.ScanResult);
        Assert.Empty(scenario.Storage.RemovedKeys);
    }

    [Fact]
    public async Task A_clean_scan_is_recorded_as_CLEAN()
    {
        var scenario = new AttachmentScenario { Scanner = FakeVirusScanner.Clean() };
        var (row, checksum) = await scenario.PendingUploadAsync(Content);

        var result = await scenario.Complete().HandleAsync(
            new CompleteAttachmentUploadCommand(row.Id, checksum, null), TestCancellation.Token);

        Assert.True(result.IsSuccess);
        Assert.Equal("CLEAN", result.Value.ScanResult);
        Assert.Equal(1, scenario.Scanner.ScanCount);
        Assert.Equal(Content.Length, scenario.Scanner.LastScannedBytes);
    }

    [Fact]
    public async Task An_object_larger_than_the_cap_is_refused_and_removed_even_though_the_presign_declared_less()
    {
        var scenario = new AttachmentScenario();
        var presigned = await scenario.Presign().HandleAsync(AttachmentScenario.PresignCommand(sizeBytes: 1024), TestCancellation.Token);
        var row = scenario.Store.Rows.Single();
        var oversized = new byte[AttachmentPolicy.MaxSizeBytes + 1];
        var checksum = scenario.Storage.Put(row.StorageKey, oversized, ContentTypes.Pdf);

        var result = await scenario.Complete().HandleAsync(
            new CompleteAttachmentUploadCommand(presigned.Value.AttachmentId, checksum, null), TestCancellation.Token);

        Assert.True(result.IsFailure);
        Assert.Equal("ATTACHMENT_TOO_LARGE", result.Error.Code);
        Assert.Equal(422, result.Error.Status);
        Assert.Contains(row.StorageKey, scenario.Storage.RemovedKeys, StringComparer.Ordinal);
        Assert.Equal(AttachmentStatus.Rejected, row.Status);
    }

    [Fact]
    public async Task An_object_stored_with_another_content_type_is_refused_and_removed()
    {
        var scenario = new AttachmentScenario();
        var (row, checksum) = await scenario.PendingUploadAsync(Content, ContentTypes.Pdf, storedContentType: ContentTypes.Png);

        var result = await scenario.Complete().HandleAsync(
            new CompleteAttachmentUploadCommand(row.Id, checksum, null), TestCancellation.Token);

        Assert.True(result.IsFailure);
        Assert.Equal("ATTACHMENT_CONTENT_TYPE_MISMATCH", result.Error.Code);
        Assert.Equal(422, result.Error.Status);
        Assert.Contains(row.StorageKey, scenario.Storage.RemovedKeys, StringComparer.Ordinal);
        Assert.Equal(AttachmentStatus.Rejected, row.Status);
    }

    [Theory]
    [MemberData(nameof(ContentTypes.Rejected), MemberType = typeof(ContentTypes))]
    public async Task An_object_stored_with_a_forbidden_content_type_is_refused_and_removed(string storedContentType)
    {
        var scenario = new AttachmentScenario();
        var (row, checksum) = await scenario.PendingUploadAsync(Content, ContentTypes.Pdf, storedContentType);

        var result = await scenario.Complete().HandleAsync(
            new CompleteAttachmentUploadCommand(row.Id, checksum, null), TestCancellation.Token);

        Assert.True(result.IsFailure);
        Assert.Equal("ATTACHMENT_TYPE_NOT_ALLOWED", result.Error.Code);
        Assert.Contains(row.StorageKey, scenario.Storage.RemovedKeys, StringComparer.Ordinal);
    }

    [Fact]
    public async Task A_checksum_typo_in_the_complete_request_is_refused_but_the_upload_survives()
    {
        // The digest restated in the complete body is a client assertion, not the authorisation: the bytes
        // in the bucket still match what was signed at presign time. Rejecting the row here would let one
        // mistyped request destroy a perfectly good upload and force the whole flow to start again, so the
        // answer is 422 with the row left PENDING and the object left in place.
        var scenario = new AttachmentScenario();
        var (row, checksum) = await scenario.PendingUploadAsync(Content);

        var result = await scenario.Complete().HandleAsync(
            new CompleteAttachmentUploadCommand(row.Id, new string('b', 64), null), TestCancellation.Token);

        Assert.True(result.IsFailure);
        Assert.Equal("CHECKSUM_MISMATCH", result.Error.Code);
        Assert.Equal(422, result.Error.Status);
        Assert.DoesNotContain(row.StorageKey, scenario.Storage.RemovedKeys, StringComparer.Ordinal);
        Assert.Equal(AttachmentStatus.Pending, row.Status);

        // ... and the corrected retry goes through.
        var retry = await scenario.Complete().HandleAsync(
            new CompleteAttachmentUploadCommand(row.Id, checksum, null), TestCancellation.Token);

        Assert.True(retry.IsSuccess);
        Assert.Equal(AttachmentStatus.Ready, row.Status);
    }

    [Fact]
    public async Task A_checksum_declared_at_presign_time_must_also_match()
    {
        var scenario = new AttachmentScenario();
        var declared = new string('c', 64);
        var presigned = await scenario.Presign().HandleAsync(
            AttachmentScenario.PresignCommand(checksum: declared), TestCancellation.Token);
        var row = scenario.Store.Rows.Single();
        var actual = scenario.Storage.Put(row.StorageKey, Content, ContentTypes.Pdf);

        var result = await scenario.Complete().HandleAsync(
            new CompleteAttachmentUploadCommand(presigned.Value.AttachmentId, actual, null), TestCancellation.Token);

        Assert.True(result.IsFailure);
        Assert.Equal("CHECKSUM_MISMATCH", result.Error.Code);
        Assert.Equal(AttachmentStatus.Rejected, row.Status);
    }

    [Fact]
    public async Task A_mismatching_etag_is_refused()
    {
        var scenario = new AttachmentScenario();
        var (row, checksum) = await scenario.PendingUploadAsync(Content);

        var result = await scenario.Complete().HandleAsync(
            new CompleteAttachmentUploadCommand(row.Id, checksum, "\"some-other-etag\""), TestCancellation.Token);

        Assert.True(result.IsFailure);
        Assert.Equal("CHECKSUM_MISMATCH", result.Error.Code);
    }

    [Fact]
    public async Task A_matching_etag_is_accepted_whether_or_not_it_is_quoted()
    {
        var scenario = new AttachmentScenario();
        var (row, checksum) = await scenario.PendingUploadAsync(Content);

        var result = await scenario.Complete().HandleAsync(
            new CompleteAttachmentUploadCommand(row.Id, checksum, "fake-etag"), TestCancellation.Token);

        Assert.True(result.IsSuccess);
    }

    [Fact]
    public async Task An_infected_file_is_deleted_rejected_and_reported_as_ATTACHMENT_INFECTED()
    {
        var scenario = new AttachmentScenario { Scanner = FakeVirusScanner.Infected("Eicar-Test-Signature") };
        var (row, checksum) = await scenario.PendingUploadAsync(Content);

        var result = await scenario.Complete().HandleAsync(
            new CompleteAttachmentUploadCommand(row.Id, checksum, null), TestCancellation.Token);

        Assert.True(result.IsFailure);
        Assert.Equal("ATTACHMENT_INFECTED", result.Error.Code);
        Assert.Equal(422, result.Error.Status);
        Assert.Contains(row.StorageKey, scenario.Storage.RemovedKeys, StringComparer.Ordinal);
        Assert.False(scenario.Storage.Objects.ContainsKey(row.StorageKey));
        Assert.Equal(AttachmentStatus.Rejected, row.Status);
        Assert.Equal("INFECTED:Eicar-Test-Signature", row.ScanResult);
    }

    [Fact]
    public async Task An_unreachable_scanner_fails_closed_and_leaves_the_upload_pending()
    {
        var scenario = new AttachmentScenario { Scanner = FakeVirusScanner.Unreachable() };
        var (row, checksum) = await scenario.PendingUploadAsync(Content);

        var result = await scenario.Complete().HandleAsync(
            new CompleteAttachmentUploadCommand(row.Id, checksum, null), TestCancellation.Token);

        Assert.True(result.IsFailure);
        Assert.Equal("VIRUS_SCAN_UNAVAILABLE", result.Error.Code);
        Assert.Equal(503, result.Error.Status);
        Assert.Equal(AttachmentStatus.Pending, row.Status);
        Assert.Empty(scenario.Storage.RemovedKeys);
        Assert.True(scenario.Storage.Objects.ContainsKey(row.StorageKey));
    }

    [Fact]
    public async Task The_scan_is_skipped_entirely_when_antivirus_is_disabled()
    {
        var scenario = new AttachmentScenario { Scanner = FakeVirusScanner.Disabled() };
        var (row, checksum) = await scenario.PendingUploadAsync(Content);

        var result = await scenario.Complete().HandleAsync(
            new CompleteAttachmentUploadCommand(row.Id, checksum, null), TestCancellation.Token);

        Assert.True(result.IsSuccess);
        Assert.Equal(0, scenario.Scanner.ScanCount);
    }

    [Fact]
    public async Task Completing_without_an_uploaded_object_is_a_404()
    {
        var scenario = new AttachmentScenario();
        var presigned = await scenario.Presign().HandleAsync(AttachmentScenario.PresignCommand(), TestCancellation.Token);

        var result = await scenario.Complete().HandleAsync(
            new CompleteAttachmentUploadCommand(presigned.Value.AttachmentId, new string('d', 64), null), TestCancellation.Token);

        Assert.True(result.IsFailure);
        Assert.Equal(404, result.Error.Status);
        Assert.Equal(AttachmentStatus.Pending, scenario.Store.Rows.Single().Status);
    }

    [Fact]
    public async Task Completing_twice_is_an_INVALID_STATE_TRANSITION()
    {
        var scenario = new AttachmentScenario();
        var (row, checksum) = await scenario.PendingUploadAsync(Content);
        var first = await scenario.Complete().HandleAsync(
            new CompleteAttachmentUploadCommand(row.Id, checksum, null), TestCancellation.Token);
        Assert.True(first.IsSuccess);

        var second = await scenario.Complete().HandleAsync(
            new CompleteAttachmentUploadCommand(row.Id, checksum, null), TestCancellation.Token);

        Assert.True(second.IsFailure);
        Assert.Equal("INVALID_STATE_TRANSITION", second.Error.Code);
        Assert.Equal(409, second.Error.Status);
    }

    [Fact]
    public async Task Another_tenants_attachment_is_a_404_and_never_a_403()
    {
        var scenario = new AttachmentScenario();
        var foreign = scenario.NewPending(tenantId: AttachmentScenario.OtherTenantId);
        scenario.Storage.Put(foreign.StorageKey, Content, ContentTypes.Pdf);

        var result = await scenario.Complete().HandleAsync(
            new CompleteAttachmentUploadCommand(foreign.Id, new string('e', 64), null), TestCancellation.Token);

        Assert.True(result.IsFailure);
        Assert.Equal("ATTACHMENT_NOT_FOUND", result.Error.Code);
        Assert.Equal(404, result.Error.Status);
        Assert.Equal(AttachmentStatus.Pending, foreign.Status);
    }

    [Fact]
    public async Task An_empty_object_is_refused()
    {
        var scenario = new AttachmentScenario();
        var presigned = await scenario.Presign().HandleAsync(AttachmentScenario.PresignCommand(), TestCancellation.Token);
        var row = scenario.Store.Rows.Single();
        var checksum = scenario.Storage.Put(row.StorageKey, [], ContentTypes.Pdf);

        var result = await scenario.Complete().HandleAsync(
            new CompleteAttachmentUploadCommand(presigned.Value.AttachmentId, checksum, null), TestCancellation.Token);

        Assert.True(result.IsFailure);
        Assert.Equal("ATTACHMENT_TOO_LARGE", result.Error.Code);
    }
}
