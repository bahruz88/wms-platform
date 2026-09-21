using Wms.Documents.Application;
using Wms.Documents.Application.Commands;
using Wms.Documents.Application.Queries;
using Wms.Documents.Domain.Enums;

namespace Wms.Documents.UnitTests;

/// <summary>
/// Contract <c>listAttachments</c>, <c>getAttachment</c>, <c>getAttachmentDownloadUrl</c> and
/// <c>deleteAttachment</c>: only verified rows are visible, the download link is short-lived and presigned,
/// and another tenant's row is a 404.
/// </summary>
public sealed class AttachmentReadTests
{
    [Fact]
    public async Task Listing_returns_only_ready_rows()
    {
        var scenario = new AttachmentScenario();
        var ready = scenario.ReadyRow();
        scenario.NewPending(fileName: "still-uploading.pdf");
        var rejected = scenario.NewPending(fileName: "infected.pdf");
        Assert.True(rejected.MarkRejected("INFECTED:Eicar-Test-Signature").IsSuccess);

        var result = await scenario.List().HandleAsync(
            new GetAttachmentsQuery(AttachmentScenario.EntityType, AttachmentScenario.EntityId, null), TestCancellation.Token);

        Assert.True(result.IsSuccess);
        var only = Assert.Single(result.Value);
        Assert.Equal(ready.Id, only.Id);
    }

    [Fact]
    public async Task Listing_can_be_filtered_by_attachment_type()
    {
        var scenario = new AttachmentScenario();
        var invoice = scenario.ReadyRow("INVOICE", "invoice.pdf");
        scenario.ReadyRow("CERTIFICATE", "cert.pdf");

        var result = await scenario.List().HandleAsync(
            new GetAttachmentsQuery(AttachmentScenario.EntityType, AttachmentScenario.EntityId, "INVOICE"), TestCancellation.Token);

        Assert.True(result.IsSuccess);
        var only = Assert.Single(result.Value);
        Assert.Equal(invoice.Id, only.Id);
    }

    [Fact]
    public async Task Listing_never_crosses_the_tenant_boundary()
    {
        var scenario = new AttachmentScenario();
        var foreign = scenario.ReadyRow(tenantId: AttachmentScenario.OtherTenantId);

        var result = await scenario.List().HandleAsync(
            new GetAttachmentsQuery(AttachmentScenario.EntityType, AttachmentScenario.EntityId, null), TestCancellation.Token);

        Assert.True(result.IsSuccess);
        Assert.Empty(result.Value);
        Assert.Equal(AttachmentScenario.OtherTenantId, foreign.TenantId);
    }

    [Fact]
    public async Task A_rejected_row_can_still_be_read_so_the_client_sees_why()
    {
        var scenario = new AttachmentScenario();
        var rejected = scenario.NewPending();
        Assert.True(rejected.MarkRejected("INFECTED:Eicar-Test-Signature").IsSuccess);

        var result = await scenario.GetOne().HandleAsync(new GetAttachmentQuery(rejected.Id), TestCancellation.Token);

        Assert.True(result.IsSuccess);
        Assert.Equal(AttachmentStatus.Rejected, result.Value.Status);
        Assert.Equal("INFECTED:Eicar-Test-Signature", result.Value.ScanResult);
    }

    [Fact]
    public async Task Another_tenants_attachment_is_a_404_on_read()
    {
        var scenario = new AttachmentScenario();
        var foreign = scenario.ReadyRow(tenantId: AttachmentScenario.OtherTenantId);

        var result = await scenario.GetOne().HandleAsync(new GetAttachmentQuery(foreign.Id), TestCancellation.Token);

        Assert.True(result.IsFailure);
        Assert.Equal(404, result.Error.Status);
    }

    [Fact]
    public async Task A_ready_attachment_gets_a_five_minute_presigned_download_url()
    {
        var scenario = new AttachmentScenario();
        var ready = scenario.ReadyRow();

        var result = await scenario.DownloadUrl().HandleAsync(
            new GetAttachmentDownloadUrlQuery(ready.Id, Inline: false), TestCancellation.Token);

        Assert.True(result.IsSuccess);
        Assert.Equal(TimeSpan.FromMinutes(5), scenario.Storage.LastDownloadLifetime);
        Assert.Equal(AttachmentScenario.Now.AddMinutes(5), result.Value.ExpiresAt);
        Assert.Equal(ready.StorageKey, scenario.Storage.LastDownloadKey);
        Assert.Contains("X-Amz-Signature", result.Value.DownloadUrl.Query, StringComparison.Ordinal);
        Assert.False(scenario.Storage.LastDownloadInline);
    }

    [Fact]
    public async Task The_download_url_lifetime_is_configurable()
    {
        var scenario = new AttachmentScenario
        {
            Links = new AttachmentLinkOptions(TimeSpan.FromMinutes(15), TimeSpan.FromMinutes(2)),
        };
        var ready = scenario.ReadyRow();

        var result = await scenario.DownloadUrl().HandleAsync(
            new GetAttachmentDownloadUrlQuery(ready.Id, Inline: true), TestCancellation.Token);

        Assert.True(result.IsSuccess);
        Assert.Equal(TimeSpan.FromMinutes(2), scenario.Storage.LastDownloadLifetime);
        Assert.Equal(AttachmentScenario.Now.AddMinutes(2), result.Value.ExpiresAt);
        Assert.True(scenario.Storage.LastDownloadInline);
    }

    [Fact]
    public async Task A_pending_attachment_has_no_download_url()
    {
        var scenario = new AttachmentScenario();
        var pending = scenario.NewPending();

        var result = await scenario.DownloadUrl().HandleAsync(
            new GetAttachmentDownloadUrlQuery(pending.Id, Inline: false), TestCancellation.Token);

        Assert.True(result.IsFailure);
        Assert.Equal("ATTACHMENT_NOT_READY", result.Error.Code);
        Assert.Equal(409, result.Error.Status);
        Assert.Null(scenario.Storage.LastDownloadKey);
    }

    [Fact]
    public async Task Another_tenant_gets_no_download_url()
    {
        var scenario = new AttachmentScenario();
        var foreign = scenario.ReadyRow(tenantId: AttachmentScenario.OtherTenantId);

        var result = await scenario.DownloadUrl().HandleAsync(
            new GetAttachmentDownloadUrlQuery(foreign.Id, Inline: false), TestCancellation.Token);

        Assert.True(result.IsFailure);
        Assert.Equal(404, result.Error.Status);
    }

    [Fact]
    public async Task The_uploader_can_delete_its_own_attachment_and_the_object_goes_with_it()
    {
        var scenario = new AttachmentScenario();
        var ready = scenario.ReadyRow();
        scenario.Storage.Put(ready.StorageKey, [1, 2, 3], ContentTypes.Pdf);

        var result = await scenario.Delete().HandleAsync(new DeleteAttachmentCommand(ready.Id), TestCancellation.Token);

        Assert.True(result.IsSuccess);
        Assert.Empty(scenario.Store.Rows);
        Assert.Contains(ready.StorageKey, scenario.Storage.RemovedKeys, StringComparer.Ordinal);
    }

    [Fact]
    public async Task Somebody_elses_attachment_cannot_be_deleted_without_doc_attachment_manage()
    {
        var scenario = new AttachmentScenario();
        var ready = scenario.ReadyRow(uploadedBy: 99);

        var result = await scenario.Delete().HandleAsync(new DeleteAttachmentCommand(ready.Id), TestCancellation.Token);

        Assert.True(result.IsFailure);
        Assert.Equal(403, result.Error.Status);
        Assert.Single(scenario.Store.Rows);
    }

    [Fact]
    public async Task A_manager_can_delete_somebody_elses_attachment()
    {
        var scenario = new AttachmentScenario
        {
            User = new FakeCurrentUser(AttachmentScenario.UserId, DocumentsPermissions.AttachmentManage),
        };
        var ready = scenario.ReadyRow(uploadedBy: 99);

        var result = await scenario.Delete().HandleAsync(new DeleteAttachmentCommand(ready.Id), TestCancellation.Token);

        Assert.True(result.IsSuccess);
        Assert.Empty(scenario.Store.Rows);
    }

    [Fact]
    public async Task Another_tenants_attachment_cannot_be_deleted()
    {
        var scenario = new AttachmentScenario();
        var foreign = scenario.ReadyRow(tenantId: AttachmentScenario.OtherTenantId);

        var result = await scenario.Delete().HandleAsync(new DeleteAttachmentCommand(foreign.Id), TestCancellation.Token);

        Assert.True(result.IsFailure);
        Assert.Equal(404, result.Error.Status);
        Assert.Single(scenario.Store.Rows);
    }
}
