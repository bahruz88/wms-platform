using System.Security.Cryptography;
using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Documents.Application.Abstractions;
using Wms.Documents.Domain;
using Wms.Documents.Domain.Entities;

namespace Wms.Documents.Application.Commands;

/// <summary>
/// <c>POST /api/v1/documents/attachments/{id}/complete</c> — verifies the object the client PUT straight to
/// MinIO (size, content type, SHA-256, virus scan) and only then makes the row visible.
/// </summary>
public sealed record CompleteAttachmentUploadCommand(long AttachmentId, string ChecksumSha256, string? ETag)
    : ICommand<AttachmentResponse>;

public sealed class CompleteAttachmentUploadCommandValidator : AbstractValidator<CompleteAttachmentUploadCommand>
{
    public CompleteAttachmentUploadCommandValidator()
    {
        RuleFor(c => c.AttachmentId).GreaterThan(0L);
        RuleFor(c => c.ChecksumSha256)
            .NotEmpty()
            .Must(AttachmentPolicy.IsChecksum!).WithMessage("checksumSha256 must be a 64 character lowercase hex digest.");
    }
}

public sealed class CompleteAttachmentUploadCommandHandler(
    IAttachmentRepository attachments,
    IDocumentsUnitOfWork unitOfWork,
    IObjectStorage storage,
    IVirusScanner virusScanner,
    ITenantContext tenantContext) : ICommandHandler<CompleteAttachmentUploadCommand, AttachmentResponse>
{
    public async Task<Result<AttachmentResponse>> HandleAsync(CompleteAttachmentUploadCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        // The repository reads through the tenant query filter, so another tenant's row is a 404, not a 403.
        var attachment = await attachments.GetAsync(command.AttachmentId, cancellationToken).ConfigureAwait(false);
        if (attachment is null)
        {
            return DocumentsErrors.AttachmentNotFound(command.AttachmentId);
        }

        if (!attachment.CanComplete)
        {
            return DocumentsErrors.InvalidStatusTransition(attachment.Status.ToString(), "READY");
        }

        var stored = await storage.StatAsync(attachment.StorageKey, cancellationToken).ConfigureAwait(false);
        if (stored is null)
        {
            return DocumentsErrors.AttachmentObjectMissing(attachment.Id);
        }

        // 1. Size — re-checked against what MinIO actually holds, not the size the client declared at presign.
        if (stored.SizeBytes == 0 || stored.SizeBytes > AttachmentPolicy.MaxSizeBytes)
        {
            return await RejectAsync(
                attachment,
                $"OVERSIZED:{stored.SizeBytes}",
                DocumentsErrors.FileTooLarge(stored.SizeBytes, AttachmentPolicy.MaxSizeBytes),
                cancellationToken).ConfigureAwait(false);
        }

        // 2. Content type — a client must not be able to presign a PDF and upload an executable.
        var storedContentType = AttachmentPolicy.Normalise(stored.ContentType);
        if (!AttachmentPolicy.IsAllowedContentType(storedContentType))
        {
            return await RejectAsync(
                attachment,
                $"TYPE_NOT_ALLOWED:{storedContentType}",
                DocumentsErrors.ContentTypeNotAllowed(storedContentType),
                cancellationToken).ConfigureAwait(false);
        }

        if (!string.Equals(storedContentType, attachment.ContentType, StringComparison.OrdinalIgnoreCase))
        {
            return await RejectAsync(
                attachment,
                $"TYPE_MISMATCH:{storedContentType}",
                DocumentsErrors.ContentTypeMismatch(attachment.ContentType, storedContentType),
                cancellationToken).ConfigureAwait(false);
        }

        // A mismatch on a value the CLIENT restates in this request (etag, checksum) is a client bug, not
        // tampering: the answer is 422 and the row stays PENDING so a corrected retry still works. Only a
        // disagreement with what was signed at presign time - or an infected file - is terminal, because at
        // that point the bytes in the bucket are not the bytes that were authorised.
        if (!ETagMatches(command.ETag, stored.ETag))
        {
            return DocumentsErrors.ChecksumMismatch(command.ETag!, stored.ETag ?? string.Empty);
        }

        await using var content = await storage.DownloadAsync(attachment.StorageKey, cancellationToken).ConfigureAwait(false);
        if (content is null)
        {
            return DocumentsErrors.AttachmentObjectMissing(attachment.Id);
        }

        // 3. Checksum — MinIO's ETag is only the MD5 of a single-part upload, so the SHA-256 of the spec is
        //    computed here from the stored bytes.
        var actualChecksum = Convert.ToHexStringLower(await SHA256.HashDataAsync(content, cancellationToken).ConfigureAwait(false));

        // 3a. Against the digest declared when the upload was presigned: this one IS the authorisation.
        if (attachment.ChecksumSha256.Length == AttachmentPolicy.ChecksumLength
            && !string.Equals(attachment.ChecksumSha256, actualChecksum, StringComparison.Ordinal))
        {
            return await RejectAsync(
                attachment,
                "CHECKSUM_MISMATCH",
                DocumentsErrors.ChecksumMismatch(attachment.ChecksumSha256, actualChecksum),
                cancellationToken).ConfigureAwait(false);
        }

        // 3b. Against the digest restated in this request: a typo here must not destroy the upload.
        var expectedChecksum = command.ChecksumSha256.ToLowerInvariant();
        if (!string.Equals(actualChecksum, expectedChecksum, StringComparison.Ordinal))
        {
            return DocumentsErrors.ChecksumMismatch(expectedChecksum, actualChecksum);
        }

        // 4. Virus scan — fails closed: an unreachable clamd leaves the row PENDING and answers 503.
        var verdict = ScanVerdict.Clean;
        if (virusScanner.IsEnabled)
        {
            if (content.CanSeek)
            {
                content.Position = 0;
            }

            var scan = await virusScanner.ScanAsync(content, cancellationToken).ConfigureAwait(false);
            if (scan.IsFailure)
            {
                return Result<AttachmentResponse>.Failure(scan.Error);
            }

            verdict = scan.Value;
        }

        if (!verdict.IsClean)
        {
            return await RejectAsync(
                attachment,
                verdict.ToScanResult(scannerEnabled: true),
                DocumentsErrors.AttachmentInfected(verdict.Signature ?? "unknown"),
                cancellationToken).ConfigureAwait(false);
        }

        var ready = attachment.MarkReady(stored.SizeBytes, actualChecksum, verdict.ToScanResult(virusScanner.IsEnabled));
        if (ready.IsFailure)
        {
            return ready.Error;
        }

        await using (var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false))
        {
            unitOfWork.Audit.Record(
                "common_attachment",
                attachment.Id,
                AuditAction.Update,
                new
                {
                    Status = attachment.Status.ToString(),
                    attachment.SizeBytes,
                    attachment.ChecksumSha256,
                    attachment.ScanResult,
                });
            await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
            await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);
        }

        return AttachmentResponse.From(attachment);
    }

    /// <summary>Quoted or unquoted, case-insensitive; no ETag in the request means no ETag check.</summary>
    private static bool ETagMatches(string? requested, string? stored)
    {
        if (string.IsNullOrWhiteSpace(requested))
        {
            return true;
        }

        return string.Equals(requested.Trim('"'), stored?.Trim('"'), StringComparison.OrdinalIgnoreCase);
    }

    /// <summary>Removes the object from MinIO and keeps the row as REJECTED so the audit trail survives.</summary>
    private async Task<Result<AttachmentResponse>> RejectAsync(
        Attachment attachment,
        string reason,
        Error error,
        CancellationToken cancellationToken)
    {
        await storage.RemoveAsync(attachment.StorageKey, cancellationToken).ConfigureAwait(false);

        var rejected = attachment.MarkRejected(reason);
        if (rejected.IsFailure)
        {
            return rejected.Error;
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        unitOfWork.Audit.Record(
            "common_attachment",
            attachment.Id,
            AuditAction.Reject,
            new { Status = attachment.Status.ToString(), Reason = reason, error.Code });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return Result<AttachmentResponse>.Failure(error);
    }
}
