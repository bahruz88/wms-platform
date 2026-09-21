using FluentValidation;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Documents.Application.Abstractions;
using Wms.Documents.Domain;

namespace Wms.Documents.Application.Queries;

/// <summary><c>GET /api/v1/documents/attachments?entityType=&amp;entityId=&amp;attachmentType=</c> — READY rows only.</summary>
public sealed record GetAttachmentsQuery(string EntityType, long EntityId, string? AttachmentType)
    : IQuery<IReadOnlyList<AttachmentResponse>>;

public sealed class GetAttachmentsQueryValidator : AbstractValidator<GetAttachmentsQuery>
{
    public GetAttachmentsQueryValidator()
    {
        RuleFor(q => q.EntityType).NotEmpty()
            .Must(AttachmentEntityTypes.IsKnown!).WithMessage("entityType is not one of the declared entity types.");
        RuleFor(q => q.EntityId).GreaterThan(0L);
        RuleFor(q => q.AttachmentType!)
            .Must(AttachmentTypes.IsKnown!).WithMessage("attachmentType is not one of the declared attachment types.")
            .When(q => q.AttachmentType is not null);
    }
}

public sealed class GetAttachmentsQueryHandler(IAttachmentQueries queries)
    : IQueryHandler<GetAttachmentsQuery, IReadOnlyList<AttachmentResponse>>
{
    public async Task<Result<IReadOnlyList<AttachmentResponse>>> HandleAsync(GetAttachmentsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var rows = await queries
            .GetByEntityAsync(query.EntityType, query.EntityId, query.AttachmentType, cancellationToken)
            .ConfigureAwait(false);
        return Result.Success(rows);
    }
}
