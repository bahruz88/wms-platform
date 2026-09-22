using Wms.Common.Domain;
using Wms.Procurement.Domain.Enums;

namespace Wms.Procurement.Domain.Entities;

/// <summary>
/// <c>proc_rfq</c> (spec §10). The spec DDL stops at the header; the comparison matrix of
/// <c>procurement.v1.yaml</c> (<c>getRfqComparison</c>) needs the requested lines and the invited suppliers,
/// so <c>proc_rfq_line</c> and <c>proc_rfq_supplier</c> are added here.
/// </summary>
public sealed class Rfq : AuditableAggregateRoot<long>, ITenantEntity
{
    public const int DocNoMaxLength = 32;
    public const int NoteMaxLength = 1000;

    /// <summary>TOR: a price request must reach at least two suppliers so a comparison is possible.</summary>
    public const int MinimumSuppliers = 2;

    private readonly List<RfqLine> _lines = [];
    private readonly List<RfqSupplier> _suppliers = [];

    private Rfq()
    {
    }

    public uint TenantId { get; private set; }

    public string DocNo { get; private set; } = string.Empty;

    public DateOnly DocDate { get; private set; }

    public DateOnly? DueDate { get; private set; }

    public RfqStatus Status { get; private set; } = RfqStatus.Draft;

    public string? Note { get; private set; }

    public IReadOnlyList<RfqLine> Lines => _lines.AsReadOnly();

    public IReadOnlyList<RfqSupplier> Suppliers => _suppliers.AsReadOnly();

    public static Result<Rfq> CreateDraft(uint tenantId, string docNo, DateOnly docDate, DateOnly? dueDate, string? note)
    {
        if (string.IsNullOrWhiteSpace(docNo) || docNo.Length > DocNoMaxLength)
        {
            return ProcurementErrors.InvalidRfq($"doc_no must be 1..{DocNoMaxLength} characters.");
        }

        if (dueDate is { } due && due < docDate)
        {
            return ProcurementErrors.InvalidRfq("due_date cannot be earlier than doc_date.");
        }

        return new Rfq
        {
            TenantId = tenantId,
            DocNo = docNo,
            DocDate = docDate,
            DueDate = dueDate,
            Note = Requisition.Truncate(note, NoteMaxLength),
        };
    }

    public Result ReplaceLines(IEnumerable<RfqLineDraft> lines)
    {
        ArgumentNullException.ThrowIfNull(lines);
        if (Status != RfqStatus.Draft)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(Rfq), Status.ToString(), "lines replaced");
        }

        var replacement = new List<RfqLine>();
        ushort lineNo = 1;
        foreach (var draft in lines)
        {
            var line = RfqLine.Create(TenantId, lineNo, draft.ProductId, draft.Qty, draft.UomId, draft.RequisitionLineId, draft.Note);
            if (line.IsFailure)
            {
                return line.Error;
            }

            replacement.Add(line.Value);
            lineNo++;
        }

        if (replacement.Count == 0)
        {
            return ProcurementErrors.InvalidRfq("An RFQ needs at least one line.");
        }

        _lines.Clear();
        _lines.AddRange(replacement);
        return Result.Success();
    }

    public Result ReplaceSuppliers(IEnumerable<uint> supplierIds)
    {
        ArgumentNullException.ThrowIfNull(supplierIds);
        if (Status != RfqStatus.Draft)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(Rfq), Status.ToString(), "suppliers replaced");
        }

        var distinct = supplierIds.Where(id => id != 0).Distinct().ToList();
        if (distinct.Count < MinimumSuppliers)
        {
            return ProcurementErrors.InvalidRfq($"At least {MinimumSuppliers} suppliers must be invited so the quotations can be compared.");
        }

        _suppliers.Clear();
        foreach (var supplierId in distinct)
        {
            _suppliers.Add(RfqSupplier.Create(TenantId, supplierId));
        }

        return Result.Success();
    }

    public Result Send()
    {
        if (Status != RfqStatus.Draft)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(Rfq), Status.ToString(), nameof(RfqStatus.Sent));
        }

        if (_lines.Count == 0)
        {
            return ProcurementErrors.InvalidRfq("An RFQ needs at least one line before it is sent.");
        }

        if (_suppliers.Count < MinimumSuppliers)
        {
            return ProcurementErrors.InvalidRfq($"At least {MinimumSuppliers} suppliers must be invited so the quotations can be compared.");
        }

        Status = RfqStatus.Sent;
        return Result.Success();
    }

    public Result Close()
    {
        if (Status != RfqStatus.Sent)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(Rfq), Status.ToString(), nameof(RfqStatus.Closed));
        }

        Status = RfqStatus.Closed;
        return Result.Success();
    }

    public Result Cancel()
    {
        if (Status is RfqStatus.Closed or RfqStatus.Cancelled)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(Rfq), Status.ToString(), nameof(RfqStatus.Cancelled));
        }

        Status = RfqStatus.Cancelled;
        return Result.Success();
    }

    /// <summary>A quotation may only be entered while the request is out with the suppliers.</summary>
    public bool AcceptsQuotations() => Status == RfqStatus.Sent;

    /// <summary>A selection may still be made on a closed RFQ, but not on a cancelled one (contract: <c>selectQuotation</c>).</summary>
    public bool AcceptsSelection() => Status == RfqStatus.Sent;
}

/// <summary><c>proc_rfq_line</c>.</summary>
public sealed class RfqLine : Entity<long>, ITenantEntity
{
    public const int NoteMaxLength = 500;

    private RfqLine()
    {
    }

    public uint TenantId { get; private set; }

    public long RfqId { get; private set; }

    public ushort LineNo { get; private set; }

    /// <summary>The PR line this request came from, when the RFQ was assembled from requisitions.</summary>
    public long? RequisitionLineId { get; private set; }

    public uint ProductId { get; private set; }

    public decimal Qty { get; private set; }

    public ushort UomId { get; private set; }

    public string? Note { get; private set; }

    internal static Result<RfqLine> Create(uint tenantId, ushort lineNo, uint productId, decimal qty, ushort uomId, long? requisitionLineId, string? note)
    {
        if (productId == 0 || uomId == 0)
        {
            return ProcurementErrors.InvalidRfq($"Line {lineNo}: product_id and uom_id are required.");
        }

        if (qty <= 0m)
        {
            return ProcurementErrors.InvalidRfq($"Line {lineNo}: qty must be positive.");
        }

        return new RfqLine
        {
            TenantId = tenantId,
            LineNo = lineNo,
            ProductId = productId,
            Qty = Quantity.Round(qty, Quantity.StorageDecimals),
            UomId = uomId,
            RequisitionLineId = requisitionLineId,
            Note = Requisition.Truncate(note, NoteMaxLength),
        };
    }
}

/// <summary><c>proc_rfq_supplier</c> — the invitation list the comparison matrix is built from.</summary>
public sealed class RfqSupplier : Entity<long>, ITenantEntity
{
    private RfqSupplier()
    {
    }

    public uint TenantId { get; private set; }

    public long RfqId { get; private set; }

    public uint SupplierId { get; private set; }

    internal static RfqSupplier Create(uint tenantId, uint supplierId) =>
        new() { TenantId = tenantId, SupplierId = supplierId };
}

public sealed record RfqLineDraft(uint ProductId, decimal Qty, ushort UomId, long? RequisitionLineId, string? Note);
