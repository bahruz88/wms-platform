using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Inventory.Application.Abstractions;
using Wms.Inventory.Domain;
using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;
using Wms.MasterData.Contracts;

namespace Wms.Inventory.Application.Commands.Samples;

/// <summary><c>POST /api/v1/inventory/samples</c> — the regulator takes goods away (TOR §23).</summary>
public sealed record CreateSampleCommand(
    DateOnly DocDate,
    uint LocationId,
    string? Authority,
    string? Purpose,
    ushort? ReasonCodeId,
    IReadOnlyList<StockOutLineInput> Lines) : ICommand<long>;

public sealed class CreateSampleCommandValidator : AbstractValidator<CreateSampleCommand>
{
    public CreateSampleCommandValidator()
    {
        RuleFor(c => c.DocDate).NotEqual(default(DateOnly));
        RuleFor(c => c.LocationId).GreaterThan(0u);
        RuleFor(c => c.Authority).MaximumLength(Sample.AuthorityMaxLength);
        RuleFor(c => c.Purpose).MaximumLength(Sample.PurposeMaxLength);
        RuleFor(c => c.Lines).NotEmpty();
        RuleForEach(c => c.Lines).ChildRules(line =>
        {
            line.RuleFor(l => l.ProductId).GreaterThan(0u);
            line.RuleFor(l => l.UomId).GreaterThan((ushort)0);
            line.RuleFor(l => l.Qty).GreaterThan(0m);
        });
    }
}

public sealed class CreateSampleCommandHandler(
    IInventoryUnitOfWork unitOfWork,
    ISampleRepository samples,
    ILocationCatalog locations,
    IReasonCodeCatalog reasonCodes,
    INumberSequenceService numberSequences,
    ITenantContext tenantContext) : ICommandHandler<CreateSampleCommand, long>
{
    public async Task<Result<long>> HandleAsync(CreateSampleCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var location = await locations.GetAsync(command.LocationId, cancellationToken).ConfigureAwait(false);
        if (location is null || !location.IsActive || location.IsVirtual)
        {
            return InventoryErrors.LocationNotFound(command.LocationId);
        }

        if (command.ReasonCodeId is > 0)
        {
            var reason = await reasonCodes.GetAsync(command.ReasonCodeId.Value, cancellationToken).ConfigureAwait(false);
            if (reason is null || !reason.IsActive || !string.Equals(reason.ReasonGroup, ReasonGroups.Sample, StringComparison.Ordinal))
            {
                return InventoryErrors.ReasonCodeNotFound(command.ReasonCodeId.Value, ReasonGroups.Sample);
            }
        }

        var docNo = await numberSequences.NextAsync(DocumentNumberTypes.Sample, command.DocDate, cancellationToken).ConfigureAwait(false);
        var sample = Sample.CreateDraft(
            tenantContext.TenantId, docNo, command.DocDate, command.LocationId,
            command.Authority, command.Purpose, command.ReasonCodeId);
        if (sample.IsFailure)
        {
            return sample.Error;
        }

        var lines = sample.Value.ReplaceLines(command.Lines);
        if (lines.IsFailure)
        {
            return lines.Error;
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        samples.Add(sample.Value);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        unitOfWork.Audit.Record("inv_sample", sample.Value.Id, AuditAction.Create, new { sample.Value.DocNo, sample.Value.Authority, lines = command.Lines.Count });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return sample.Value.Id;
    }
}

public sealed record SamplePostResult(long SampleId, long MovementGroupId, string DocNo);

/// <summary><c>POST /api/v1/inventory/samples/{id}/post</c> — location −qty / V_SAMPLE +qty.</summary>
public sealed record PostSampleCommand(long SampleId, uint RowVersion, Guid IdempotencyKey) : ICommand<SamplePostResult>;

public sealed class PostSampleCommandHandler(
    IInventoryUnitOfWork unitOfWork,
    ISampleRepository samples,
    IDocumentPostingEngine posting,
    ILocationCatalog locations,
    ILocationFreezeChecker freezeChecker,
    ITenantContext tenantContext) : ICommandHandler<PostSampleCommand, SamplePostResult>
{
    public async Task<Result<SamplePostResult>> HandleAsync(PostSampleCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var sample = await samples.GetAsync(command.SampleId, cancellationToken).ConfigureAwait(false);
        if (sample is null)
        {
            return InventoryErrors.DocumentNotFound("sample", command.SampleId);
        }

        if (sample.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        if (sample.Status != SimpleDocStatus.Draft)
        {
            return InventoryErrors.InvalidDocumentTransition("sample", sample.Status.ToString(), nameof(SimpleDocStatus.Posted));
        }

        if (await freezeChecker.IsFrozenAsync(sample.LocationId, cancellationToken).ConfigureAwait(false))
        {
            return InventoryErrors.LocationFrozen(sample.LocationId);
        }

        var sampleLocation = await locations.GetVirtualAsync(LocationTypes.VSample, cancellationToken).ConfigureAwait(false);
        if (sampleLocation is null)
        {
            return InventoryErrors.VirtualLocationMissing(LocationTypes.VSample);
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);

        var request = new PostingRequest(
            DocType.Sample,
            sample.DocNo,
            sample.DocDate,
            command.IdempotencyKey,
            SourceDocType: "SAMPLE",
            SourceDocId: sample.Id,
            ReasonCodeId: sample.ReasonCodeId,
            Note: sample.Purpose,
            Lines: sample.Lines
                .Select(l => new PostingLine(l.Id, l.ProductId, l.Qty, l.UomId, sample.LocationId, sampleLocation.Id, l.BatchId))
                .ToList())
        {
            VirtualLocationIds = [sampleLocation.Id],
        };

        var posted = await posting.PostAsync(request, cancellationToken).ConfigureAwait(false);
        if (posted.IsFailure)
        {
            return posted.Error;
        }

        sample.RecordPostedLines(posted.Value.Lines
            .Select(l => new PostedLineResult(l.Key, l.QtyBase, l.BatchId, l.SuggestedBatchId, l.UnitCost))
            .ToList());

        var marked = sample.MarkPosted(posted.Value.MovementGroupId);
        if (marked.IsFailure)
        {
            return marked.Error;
        }

        unitOfWork.Audit.Record("inv_sample", sample.Id, AuditAction.Post, new { sample.DocNo, movementGroupId = posted.Value.MovementGroupId });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return new SamplePostResult(sample.Id, posted.Value.MovementGroupId, sample.DocNo);
    }
}
