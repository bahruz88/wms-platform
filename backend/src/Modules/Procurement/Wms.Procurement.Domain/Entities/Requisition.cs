using Wms.Common.Domain;
using Wms.Procurement.Domain.Enums;

namespace Wms.Procurement.Domain.Entities;

/// <summary><c>proc_requisition</c> (spec §10). A PR is never converted into a PO automatically (TOR §9).</summary>
public sealed class Requisition : AuditableAggregateRoot<long>, ITenantEntity
{
    public const int DocNoMaxLength = 32;
    public const int NoteMaxLength = 1000;

    private readonly List<RequisitionLine> _lines = [];

    private Requisition()
    {
    }

    public uint TenantId { get; private set; }

    public string DocNo { get; private set; } = string.Empty;

    public DateOnly DocDate { get; private set; }

    public uint RequesterLocationId { get; private set; }

    public ProductType ProductType { get; private set; }

    public Priority Priority { get; private set; } = Priority.Normal;

    public DateOnly? RequiredDate { get; private set; }

    public RequisitionStatus Status { get; private set; } = RequisitionStatus.Draft;

    public string? Note { get; private set; }

    /// <summary>Why the procurement officer sent the request back (contract: <c>rejectComment</c>).</summary>
    public string? RejectComment { get; private set; }

    public IReadOnlyList<RequisitionLine> Lines => _lines.AsReadOnly();

    public static Result<Requisition> CreateDraft(
        uint tenantId,
        string docNo,
        DateOnly docDate,
        uint requesterLocationId,
        ProductType productType,
        Priority priority = Priority.Normal,
        DateOnly? requiredDate = null,
        string? note = null)
    {
        if (string.IsNullOrWhiteSpace(docNo) || docNo.Length > DocNoMaxLength)
        {
            return ProcurementErrors.InvalidRequisition($"doc_no must be 1..{DocNoMaxLength} characters.");
        }

        if (requesterLocationId == 0)
        {
            return ProcurementErrors.InvalidRequisition("requester_location_id is required.");
        }

        return new Requisition
        {
            TenantId = tenantId,
            DocNo = docNo,
            DocDate = docDate,
            RequesterLocationId = requesterLocationId,
            ProductType = productType,
            Priority = priority,
            RequiredDate = requiredDate,
            Note = Truncate(note, NoteMaxLength),
        };
    }

    /// <summary>Header edit of a DRAFT PR; the document number never changes.</summary>
    public Result UpdateHeader(
        DateOnly docDate,
        uint requesterLocationId,
        ProductType productType,
        Priority priority,
        DateOnly? requiredDate,
        string? note)
    {
        if (Status != RequisitionStatus.Draft)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(Requisition), Status.ToString(), "updated");
        }

        if (requesterLocationId == 0)
        {
            return ProcurementErrors.InvalidRequisition("requester_location_id is required.");
        }

        DocDate = docDate;
        RequesterLocationId = requesterLocationId;
        ProductType = productType;
        Priority = priority;
        RequiredDate = requiredDate;
        Note = Truncate(note, NoteMaxLength);
        return Result.Success();
    }

    public Result<RequisitionLine> AddLine(uint productId, decimal qty, ushort uomId, string? note = null)
    {
        if (Status != RequisitionStatus.Draft)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(Requisition), Status.ToString(), "line added");
        }

        var line = RequisitionLine.Create(TenantId, (ushort)(_lines.Count + 1), productId, qty, uomId, note);
        if (line.IsFailure)
        {
            return line.Error;
        }

        _lines.Add(line.Value);
        return line.Value;
    }

    /// <summary>Replaces every line of a DRAFT PR; line numbers are re-issued from 1.</summary>
    public Result ReplaceLines(IEnumerable<RequisitionLineDraft> lines)
    {
        ArgumentNullException.ThrowIfNull(lines);
        if (Status != RequisitionStatus.Draft)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(Requisition), Status.ToString(), "lines replaced");
        }

        var replacement = new List<RequisitionLine>();
        ushort lineNo = 1;
        foreach (var draft in lines)
        {
            var line = RequisitionLine.Create(TenantId, lineNo, draft.ProductId, draft.Qty, draft.UomId, draft.Note);
            if (line.IsFailure)
            {
                return line.Error;
            }

            replacement.Add(line.Value);
            lineNo++;
        }

        if (replacement.Count == 0)
        {
            return ProcurementErrors.InvalidRequisition("A requisition needs at least one line.");
        }

        _lines.Clear();
        _lines.AddRange(replacement);
        return Result.Success();
    }

    public Result Submit()
    {
        if (Status != RequisitionStatus.Draft)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(Requisition), Status.ToString(), nameof(RequisitionStatus.Submitted));
        }

        if (_lines.Count == 0)
        {
            return ProcurementErrors.InvalidRequisition("A requisition needs at least one line before submission.");
        }

        Status = RequisitionStatus.Submitted;
        return Result.Success();
    }

    public Result Reject(string comment)
    {
        if (Status is not (RequisitionStatus.Submitted or RequisitionStatus.InProcurement))
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(Requisition), Status.ToString(), nameof(RequisitionStatus.Rejected));
        }

        if (string.IsNullOrWhiteSpace(comment))
        {
            return ProcurementErrors.CommentRequired("comment");
        }

        Status = RequisitionStatus.Rejected;
        RejectComment = Truncate(comment, NoteMaxLength);
        return Result.Success();
    }

    /// <summary>Cancelled by the requester while nothing has been procured yet.</summary>
    public Result Cancel(string? comment)
    {
        if (Status is not (RequisitionStatus.Draft or RequisitionStatus.Submitted))
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(Requisition), Status.ToString(), nameof(RequisitionStatus.Cancelled));
        }

        Status = RequisitionStatus.Cancelled;
        RejectComment = Truncate(comment, NoteMaxLength);
        return Result.Success();
    }

    /// <summary>An RFQ built from this PR moves it into procurement (contract: <c>createRfq</c>).</summary>
    public Result MarkInProcurement()
    {
        if (Status is RequisitionStatus.Submitted or RequisitionStatus.InProcurement)
        {
            Status = RequisitionStatus.InProcurement;
            return Result.Success();
        }

        return ProcurementErrors.InvalidStatusTransition(nameof(Requisition), Status.ToString(), nameof(RequisitionStatus.InProcurement));
    }

    /// <summary>Records how much of one line went into a PO; the PR closes once every line is fully converted (spec §12.8).</summary>
    public Result RegisterConversion(long lineId, decimal convertedQty)
    {
        if (Status is RequisitionStatus.Rejected or RequisitionStatus.Cancelled or RequisitionStatus.Closed)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(Requisition), Status.ToString(), "converted");
        }

        var line = _lines.Find(l => l.Id == lineId);
        if (line is null)
        {
            return ProcurementErrors.InvalidRequisition($"Line {lineId} does not belong to requisition {DocNo}.");
        }

        var registered = line.RegisterConversion(convertedQty);
        if (registered.IsFailure)
        {
            return registered;
        }

        Status = _lines.TrueForAll(l => l.IsFullyConverted())
            ? RequisitionStatus.ConvertedToPo
            : RequisitionStatus.InProcurement;
        return Result.Success();
    }

    internal static string? Truncate(string? value, int maxLength) =>
        value is { Length: > 0 } && value.Length > maxLength ? value[..maxLength] : value;
}

/// <summary>Input shape of <see cref="Requisition.ReplaceLines"/>; keeps the aggregate free of DTO types.</summary>
public sealed record RequisitionLineDraft(uint ProductId, decimal Qty, ushort UomId, string? Note);
