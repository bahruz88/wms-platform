using FluentValidation;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Documents.Application.Abstractions;
using Wms.Documents.Domain;

namespace Wms.Documents.Application.Queries;

/// <summary><c>GET /api/v1/documents/attachments/{id}</c>. A PENDING upload does not exist yet (404).</summary>
public sealed record GetAttachmentQuery(long AttachmentId) : IQuery<AttachmentResponse>;

public sealed class GetAttachmentQueryValidator : AbstractValidator<GetAttachmentQuery>
{
    public GetAttachmentQueryValidator() => RuleFor(q => q.AttachmentId).GreaterThan(0L);
}

public sealed class GetAttachmentQueryHandler(IAttachmentQueries queries) : IQueryHandler<GetAttachmentQuery, AttachmentResponse>
{
    public async Task<Result<AttachmentResponse>> HandleAsync(GetAttachmentQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var attachment = await queries.GetVisibleAsync(query.AttachmentId, cancellationToken).ConfigureAwait(false);
        return attachment is null
            ? DocumentsErrors.AttachmentNotFound(query.AttachmentId)
            : Result.Success(attachment);
    }
}
