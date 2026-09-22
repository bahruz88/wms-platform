using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Application.Storage;
using Wms.Common.Domain;
using Wms.Documents.Application.Abstractions;
using Wms.Documents.Domain.Entities;
using Wms.Documents.Domain;

namespace Wms.Documents.Application.Commands;

/// <summary><c>POST /api/v1/documents/attachments/presign</c> — creates the PENDING row and signs the upload URL.</summary>
public sealed record PresignAttachmentUploadCommand(
    string EntityType,
    long? EntityId,
    string AttachmentType,
    string FileName,
    string ContentType,
    long SizeBytes,
    string? ChecksumSha256) : ICommand<PresignResponse>;

public sealed class PresignAttachmentUploadCommandValidator : AbstractValidator<PresignAttachmentUploadCommand>
{
    public PresignAttachmentUploadCommandValidator()
    {
        // The size cap and the content-type allow list are business rules, not input validation: they must
        // answer 422 with ATTACHMENT_TOO_LARGE / ATTACHMENT_TYPE_NOT_ALLOWED, so the handler owns them.
        RuleFor(c => c.EntityType).NotEmpty()
            .Must(AttachmentEntityTypes.IsKnown!).WithMessage("entityType is not one of the declared entity types.");
        RuleFor(c => c.AttachmentType).NotEmpty()
            .Must(AttachmentTypes.IsKnown!).WithMessage("attachmentType is not one of the declared attachment types.");
        RuleFor(c => c.FileName).NotEmpty().MaximumLength(AttachmentPolicy.FileNameMaxLength);
        RuleFor(c => c.ContentType).NotEmpty();
        RuleFor(c => c.SizeBytes).GreaterThan(0L);
        RuleFor(c => c.EntityId!.Value).GreaterThan(0L).When(c => c.EntityId.HasValue);
        RuleFor(c => c.ChecksumSha256!)
            .Must(AttachmentPolicy.IsChecksum!).WithMessage("checksumSha256 must be a 64 character lowercase hex digest.")
            .When(c => c.ChecksumSha256 is not null);
    }
}

public sealed class PresignAttachmentUploadCommandHandler(
    IAttachmentRepository attachments,
    IDocumentsUnitOfWork unitOfWork,
    IObjectStorage storage,
    AttachmentLinkOptions linkOptions,
    ITenantContext tenantContext,
    ICurrentUser currentUser,
    IClock clock) : ICommandHandler<PresignAttachmentUploadCommand, PresignResponse>
{
    public async Task<Result<PresignResponse>> HandleAsync(PresignAttachmentUploadCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var declaredSize = (ulong)command.SizeBytes;
        var policy = AttachmentPolicy.Validate(command.ContentType, declaredSize);
        if (policy.IsFailure)
        {
            return policy.Error;
        }

        var contentType = AttachmentPolicy.Normalise(command.ContentType);
        var entityId = command.EntityId ?? Attachment.UnassignedEntityId;

        // The key is derived from the tenant, the owning entity and a fresh GUID. It is never accepted from
        // the client, so no caller can address (or guess) another tenant's objects.
        var storageKey = AttachmentStorageKey.Build(
            tenantContext.TenantId, command.EntityType, entityId, Guid.NewGuid(), command.FileName);

        var attachment = Attachment.CreatePending(
            tenantContext.TenantId,
            command.EntityType,
            entityId,
            command.AttachmentType,
            command.FileName,
            contentType,
            declaredSize,
            storageKey,
            currentUser.UserId,
            clock.UtcNow,
            command.ChecksumSha256);
        if (attachment.IsFailure)
        {
            return attachment.Error;
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        attachments.Add(attachment.Value);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        unitOfWork.Audit.Record(
            "common_attachment",
            attachment.Value.Id,
            AuditAction.Create,
            new
            {
                attachment.Value.EntityType,
                attachment.Value.EntityId,
                attachment.Value.AttachmentType,
                attachment.Value.FileName,
                attachment.Value.ContentType,
                DeclaredSizeBytes = declaredSize,
                Status = attachment.Value.Status.ToString(),
            });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        var presigned = await storage
            .PresignUploadAsync(storageKey, contentType, linkOptions.UploadUrlLifetime, cancellationToken)
            .ConfigureAwait(false);

        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return new PresignResponse(
            attachment.Value.Id,
            presigned.UploadUrl,
            PresignResponse.PutMethod,
            presigned.Headers,
            clock.UtcNow + linkOptions.UploadUrlLifetime,
            AttachmentPolicy.MaxSizeBytes);
    }
}
