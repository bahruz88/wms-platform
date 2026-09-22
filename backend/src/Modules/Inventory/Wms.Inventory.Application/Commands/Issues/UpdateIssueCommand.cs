using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Domain;
using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.Application.Commands.Issues;

/// <summary>
/// Replaces a DRAFT issue or transfer (<c>PUT /api/v1/inventory/issues/{id}</c>).
///
/// Only DRAFT is editable: once dispatched the document has moved the ledger, and the ledger is
/// append-only (ADR-003). The aggregate enforces that; the handler only guards the row version.
/// </summary>
public sealed record UpdateIssueCommand(
    long IssueId,
    uint RowVersion,
    DateOnly DocDate,
    IssueType IssueType,
    uint FromLocationId,
    uint ToLocationId,
    long? RequestId,
    string? Note,
    IReadOnlyList<IssueLineInput> Lines) : ICommand<long>;

public sealed class UpdateIssueCommandValidator : AbstractValidator<UpdateIssueCommand>
{
    public UpdateIssueCommandValidator()
    {
        RuleFor(c => c.IssueId).GreaterThan(0L);
        RuleFor(c => c.DocDate).NotEqual(default(DateOnly));
        RuleFor(c => c.FromLocationId).GreaterThan(0u);
        RuleFor(c => c.ToLocationId).GreaterThan(0u);
        RuleFor(c => c.Note).MaximumLength(Issue.NoteMaxLength);
        RuleFor(c => c.Lines).NotEmpty();
        RuleForEach(c => c.Lines).ChildRules(line =>
        {
            line.RuleFor(l => l.ProductId).GreaterThan(0u);
            line.RuleFor(l => l.UomId).GreaterThan((ushort)0);
            line.RuleFor(l => l.Qty).GreaterThan(0m);
        });
    }
}

public sealed class UpdateIssueCommandHandler(
    IInventoryUnitOfWork unitOfWork,
    IIssueRepository issues,
    ITenantContext tenantContext) : ICommandHandler<UpdateIssueCommand, long>
{
    public async Task<Result<long>> HandleAsync(UpdateIssueCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var issue = await issues.GetAsync(command.IssueId, cancellationToken).ConfigureAwait(false);
        if (issue is null)
        {
            return InventoryErrors.DocumentNotFound("issue", command.IssueId);
        }

        if (issue.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        var header = issue.UpdateDraft(
            command.DocDate,
            command.IssueType,
            command.FromLocationId,
            command.ToLocationId,
            command.RequestId,
            command.Note);
        if (header.IsFailure)
        {
            return header.Error;
        }

        var replaced = issue.ReplaceLines(command.Lines);
        if (replaced.IsFailure)
        {
            return replaced.Error;
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        unitOfWork.Audit.Record("inv_issue", issue.Id, AuditAction.Update, new { issue.DocNo, lines = command.Lines.Count });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return issue.Id;
    }
}
