using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.Common.Infrastructure.Modules;
using Wms.Documents.Application;
using Wms.Documents.Application.Queries;
using Wms.Documents.Contracts;
using Wms.Documents.Infrastructure;

namespace Wms.Documents.Endpoints;

/// <summary><c>--Modules=documents</c>. Route prefix <c>/api/v1/documents</c>, table prefix <c>doc_</c>.</summary>
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
                var query = new GetAttachmentsQuery(request.EntityType, request.EntityId, new PagingRequest(request.Page, request.Size).ToPageRequest());
                var result = await dispatcher.QueryAsync(query, cancellationToken).ConfigureAwait(false);
                return result.ToOk();
            })
            .RequirePermission(DocumentsPermissions.AttachmentView)
            .WithName("GetAttachments");

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

public sealed record AttachmentsRequest(string EntityType, long EntityId, int? Page, int? Size);
