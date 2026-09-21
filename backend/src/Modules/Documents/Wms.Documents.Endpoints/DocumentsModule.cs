using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.Common.Infrastructure.Modules;
using Wms.Documents.Application;
using Wms.Documents.Application.Commands;
using Wms.Documents.Application.Queries;
using Wms.Documents.Contracts;
using Wms.Documents.Infrastructure;

namespace Wms.Documents.Endpoints;

/// <summary>
/// <c>--Modules=documents</c>. Route prefix <c>/api/v1/documents</c>, table prefix <c>doc_</c>.
/// Implements the six operations of <c>contracts/openapi/documents.v1.yaml</c>: the MinIO presign /
/// complete / download-url flow plus the attachment reads.
/// </summary>
public sealed class DocumentsModule : IModule
{
    public const string ModuleName = "documents";

    public string Name => ModuleName;

    public void RegisterServices(IServiceCollection services, IConfiguration configuration)
    {
        services.AddDocumentsApplication();
        services.AddDocumentsInfrastructure(configuration);
    }

    public void RegisterRemoteContracts(IServiceCollection services, IConfiguration configuration) =>
        services.AddDocumentsRemoteContracts(configuration);

    public void MapEndpoints(IEndpointRouteBuilder app)
    {
        var group = app.MapGroup(DocumentsRoutes.Prefix).WithTags("Documents").RequireAuthorization();

        group.MapGet("/ping", (ITenantContext tenant, ICurrentUser user, IClock clock) =>
                TypedResults.Ok(new ModulePing(ModuleName, tenant.TenantId, user.Username, clock.UtcNow)))
            .WithName("DocumentsPing");

        group.MapGet("/attachments", async ([AsParameters] AttachmentsRequest request, IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var query = new GetAttachmentsQuery(request.EntityType, request.EntityId, request.AttachmentType);
                var result = await dispatcher.QueryAsync(query, cancellationToken).ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(DocumentsPermissions.AttachmentView)
            .WithName("ListAttachments");

        group.MapPost("/attachments/presign", async (PresignAttachmentRequest request, IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var command = new PresignAttachmentUploadCommand(
                    request.EntityType,
                    request.EntityId,
                    request.AttachmentType,
                    request.FileName,
                    request.ContentType,
                    request.SizeBytes,
                    request.ChecksumSha256);
                var result = await dispatcher.SendAsync(command, cancellationToken).ConfigureAwait(false);
                return result.ToCreated(response => $"{DocumentsRoutes.Attachments}/{response.AttachmentId}");
            })
            .RequirePermission(DocumentsPermissions.AttachmentUpload)
            .RequireIdempotencyKey()
            .WithName("PresignAttachmentUpload");

        group.MapPost("/attachments/{id:long}/complete", async (
                long id,
                CompleteAttachmentRequest request,
                IDispatcher dispatcher,
                CancellationToken cancellationToken) =>
            {
                var command = new CompleteAttachmentUploadCommand(id, request.ChecksumSha256, request.ETag);
                var result = await dispatcher.SendAsync(command, cancellationToken).ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(DocumentsPermissions.AttachmentUpload)
            .RequireIdempotencyKey()
            .WithName("CompleteAttachmentUpload");

        group.MapGet("/attachments/{id:long}", async (long id, IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var result = await dispatcher.QueryAsync(new GetAttachmentQuery(id), cancellationToken).ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(DocumentsPermissions.AttachmentView)
            .WithName("GetAttachment");

        group.MapGet("/attachments/{id:long}/download-url", async (
                long id,
                bool? inline,
                IDispatcher dispatcher,
                CancellationToken cancellationToken) =>
            {
                var query = new GetAttachmentDownloadUrlQuery(id, inline ?? false);
                var result = await dispatcher.QueryAsync(query, cancellationToken).ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(DocumentsPermissions.AttachmentView)
            .WithName("GetAttachmentDownloadUrl");

        group.MapDelete("/attachments/{id:long}", async (long id, IDispatcher dispatcher, CancellationToken cancellationToken) =>
            {
                var result = await dispatcher.SendAsync(new DeleteAttachmentCommand(id), cancellationToken).ConfigureAwait(false);
                return result.ToNoContent();
            })
            .RequirePermission(DocumentsPermissions.AttachmentUpload)
            .WithName("DeleteAttachment");

        group.MapGet("/internal/attachments/{attachmentId:long}",
                async (long attachmentId, IAttachmentReader reader, CancellationToken cancellationToken) =>
                {
                    var attachment = await reader.GetAsync(attachmentId, cancellationToken).ConfigureAwait(false);
                    return attachment is null ? Results.NotFound() : Results.Ok(attachment);
                })
            .WithName("InternalAttachment")
            .ExcludeFromDescription();
    }
}

/// <summary>Query string of <c>GET /attachments</c> (contract <c>listAttachments</c>).</summary>
public sealed record AttachmentsRequest(string EntityType, long EntityId, string? AttachmentType);

/// <summary>Body of <c>POST /attachments/presign</c> (contract <c>PresignRequest</c>).</summary>
public sealed record PresignAttachmentRequest(
    string EntityType,
    long? EntityId,
    string AttachmentType,
    string FileName,
    string ContentType,
    long SizeBytes,
    string? ChecksumSha256);

/// <summary>Body of <c>POST /attachments/{id}/complete</c> (contract <c>CompleteUploadRequest</c>).</summary>
public sealed record CompleteAttachmentRequest(string ChecksumSha256, string? ETag);
