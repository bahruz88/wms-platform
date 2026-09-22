using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Application.Storage;
using Wms.Common.Domain;
using Wms.Documents.Application.Abstractions;
using Wms.Documents.Domain;

namespace Wms.Documents.Application.Commands;

/// <summary>
/// <c>DELETE /api/v1/documents/attachments/{id}</c> — only the uploader, or a holder of
/// <c>doc.attachment.manage</c>, may remove an attachment.
/// </summary>
public sealed record DeleteAttachmentCommand(long AttachmentId) : ICommand<bool>;

public sealed class DeleteAttachmentCommandValidator : AbstractValidator<DeleteAttachmentCommand>
{
    public DeleteAttachmentCommandValidator() => RuleFor(c => c.AttachmentId).GreaterThan(0L);
}

public sealed class DeleteAttachmentCommandHandler(
    IAttachmentRepository attachments,
    IDocumentsUnitOfWork unitOfWork,
    IObjectStorage storage,
    ITenantContext tenantContext,
    ICurrentUser currentUser) : ICommandHandler<DeleteAttachmentCommand, bool>
{
    public async Task<Result<bool>> HandleAsync(DeleteAttachmentCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var attachment = await attachments.GetAsync(command.AttachmentId, cancellationToken).ConfigureAwait(false);
        if (attachment is null)
        {
            return DocumentsErrors.AttachmentNotFound(command.AttachmentId);
        }

        if (attachment.UploadedBy != currentUser.UserId && !currentUser.HasPermission(DocumentsPermissions.AttachmentManage))
        {
            return DocumentsErrors.NotTheUploader();
        }

        var storageKey = attachment.StorageKey;
        var snapshot = new
        {
            attachment.EntityType,
            attachment.EntityId,
            attachment.AttachmentType,
            attachment.FileName,
            attachment.SizeBytes,
            Status = attachment.Status.ToString(),
        };

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        attachments.Remove(attachment);
        unitOfWork.Audit.Record("common_attachment", command.AttachmentId, AuditAction.Delete, snapshot);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        // Best effort: whatever is left behind is swept by the AttachmentOrphanCleaner job (spec §15).
        await storage.RemoveAsync(storageKey, cancellationToken).ConfigureAwait(false);

        return true;
    }
}
