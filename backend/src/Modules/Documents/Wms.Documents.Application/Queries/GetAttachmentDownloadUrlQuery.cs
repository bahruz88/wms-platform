using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Application.Storage;
using Wms.Common.Domain;
using Wms.Documents.Application.Abstractions;
using Wms.Documents.Domain.Enums;
using Wms.Documents.Domain;

namespace Wms.Documents.Application.Queries;

/// <summary>
/// <c>GET /api/v1/documents/attachments/{id}/download-url</c> — a short-lived presigned GET.
/// The bucket is private; no public object URL is ever handed out.
/// </summary>
public sealed record GetAttachmentDownloadUrlQuery(long AttachmentId, bool Inline) : IQuery<DownloadUrlResponse>;

public sealed class GetAttachmentDownloadUrlQueryValidator : AbstractValidator<GetAttachmentDownloadUrlQuery>
{
    public GetAttachmentDownloadUrlQueryValidator() => RuleFor(q => q.AttachmentId).GreaterThan(0L);
}

public sealed class GetAttachmentDownloadUrlQueryHandler(
    IAttachmentQueries queries,
    IObjectStorage storage,
    AttachmentLinkOptions linkOptions,
    IClock clock) : IQueryHandler<GetAttachmentDownloadUrlQuery, DownloadUrlResponse>
{
    public async Task<Result<DownloadUrlResponse>> HandleAsync(GetAttachmentDownloadUrlQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);

        var target = await queries.GetDownloadTargetAsync(query.AttachmentId, cancellationToken).ConfigureAwait(false);
        if (target is null)
        {
            return DocumentsErrors.AttachmentNotFound(query.AttachmentId);
        }

        if (target.Status is not AttachmentStatus.Ready)
        {
            return DocumentsErrors.AttachmentNotReady(target.Status.ToString());
        }

        var url = await storage
            .PresignDownloadAsync(
                target.StorageKey,
                target.FileName,
                target.ContentType,
                query.Inline,
                linkOptions.DownloadUrlLifetime,
                cancellationToken)
            .ConfigureAwait(false);

        return Result.Success(new DownloadUrlResponse(
            url,
            clock.UtcNow + linkOptions.DownloadUrlLifetime,
            target.FileName,
            target.ContentType,
            target.SizeBytes));
    }
}
