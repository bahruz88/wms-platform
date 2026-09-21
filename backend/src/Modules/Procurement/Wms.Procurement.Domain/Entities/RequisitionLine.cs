using Wms.Common.Domain;

namespace Wms.Procurement.Domain.Entities;

/// <summary><c>proc_requisition_line</c>. <see cref="ConvertedQty"/> tracks partial conversion into POs (spec §12.8).</summary>
public sealed class RequisitionLine : Entity<long>, ITenantEntity
{
    public const int NoteMaxLength = 500;

    private RequisitionLine()
    {
    }

    public uint TenantId { get; private set; }

    public long RequisitionId { get; private set; }

    public ushort LineNo { get; private set; }

    public uint ProductId { get; private set; }

    public decimal Qty { get; private set; }

    public ushort UomId { get; private set; }

    public decimal ConvertedQty { get; private set; }

    public string? Note { get; private set; }

    internal static Result<RequisitionLine> Create(uint tenantId, ushort lineNo, uint productId, decimal qty, ushort uomId, string? note)
    {
        if (productId == 0 || uomId == 0)
        {
            return ProcurementErrors.InvalidRequisition($"Line {lineNo}: product_id and uom_id are required.");
        }

        if (qty <= 0m)
        {
            return ProcurementErrors.InvalidRequisition($"Line {lineNo}: qty must be positive.");
        }

        return new RequisitionLine
        {
            TenantId = tenantId,
            LineNo = lineNo,
            ProductId = productId,
            Qty = qty,
            UomId = uomId,
            Note = note is { Length: > NoteMaxLength } n ? n[..NoteMaxLength] : note,
        };
    }

    public bool IsFullyConverted() => ConvertedQty >= Qty;

    public decimal RemainingQty() => Math.Max(0m, Qty - ConvertedQty);

    internal Result RegisterConversion(decimal qty)
    {
        if (qty <= 0m)
        {
            return ProcurementErrors.InvalidRequisition("Converted quantity must be positive.");
        }

        if (ConvertedQty + qty > Qty)
        {
            return ProcurementErrors.InvalidRequisition($"Line {LineNo}: converted quantity would exceed the requested quantity.");
        }

        ConvertedQty += qty;
        return Result.Success();
    }
}
