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
            Note = note is { Length: > NoteMaxLength } n ? n[..NoteMaxLength] : note,
        };
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

    public Result Reject()
    {
        if (Status is not (RequisitionStatus.Submitted or RequisitionStatus.InProcurement))
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(Requisition), Status.ToString(), nameof(RequisitionStatus.Rejected));
        }

        Status = RequisitionStatus.Rejected;
        return Result.Success();
    }

    /// <summary>Records how much of each line went into a PO; the PR closes once every line is fully converted.</summary>
    public Result RegisterConversion(ushort lineNo, decimal convertedQty)
    {
        var line = _lines.Find(l => l.LineNo == lineNo);
        if (line is null)
        {
            return ProcurementErrors.InvalidRequisition($"Line {lineNo} does not exist.");
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
}
