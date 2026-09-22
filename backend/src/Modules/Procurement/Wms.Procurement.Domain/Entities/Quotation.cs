using Wms.Common.Domain;

namespace Wms.Procurement.Domain.Entities;

/// <summary>
/// <c>proc_quotation</c> (spec §10). Amounts are stored both in the supplier's currency and in the tenant base
/// currency; the comparison and the "cheapest" rule only ever look at the base amounts.
/// </summary>
public sealed class Quotation : AuditableAggregateRoot<long>, ITenantEntity
{
    public const int QuoteNoMaxLength = 64;
    public const int PaymentTermsMaxLength = 200;
    public const int SelectionNoteMaxLength = 500;

    private readonly List<QuotationLine> _lines = [];

    private Quotation()
    {
    }

    public uint TenantId { get; private set; }

    public long? RfqId { get; private set; }

    public uint SupplierId { get; private set; }

    public string? QuoteNo { get; private set; }

    public DateOnly QuoteDate { get; private set; }

    public DateOnly? ValidUntil { get; private set; }

    public string Currency { get; private set; } = "AZN";

    public ushort? DeliveryDays { get; private set; }

    public string? PaymentTerms { get; private set; }

    /// <summary>Rate of <see cref="QuoteDate"/>, frozen when the quotation is entered (spec §12.5).</summary>
    public decimal FxRate { get; private set; } = 1m;

    public decimal TotalAmount { get; private set; }

    public decimal TotalAmountBase { get; private set; }

    public bool IsSelected { get; private set; }

    /// <summary>Mandatory when a quotation other than the cheapest is selected (spec §10).</summary>
    public string? SelectionNote { get; private set; }

    public IReadOnlyList<QuotationLine> Lines => _lines.AsReadOnly();

    public static Result<Quotation> Create(
        uint tenantId,
        long? rfqId,
        uint supplierId,
        string? quoteNo,
        DateOnly quoteDate,
        DateOnly? validUntil,
        string currency,
        decimal fxRate,
        ushort? deliveryDays,
        string? paymentTerms)
    {
        if (supplierId == 0)
        {
            return ProcurementErrors.InvalidQuotation("supplier_id is required.");
        }

        if (!Money.IsValidCurrency(currency))
        {
            return ProcurementErrors.InvalidQuotation("currency must be an ISO 4217 code.");
        }

        if (fxRate <= 0m)
        {
            return ProcurementErrors.InvalidQuotation("fx_rate must be positive (spec §12.5).");
        }

        if (validUntil is { } until && until < quoteDate)
        {
            return ProcurementErrors.InvalidQuotation("valid_until cannot be earlier than quote_date.");
        }

        return new Quotation
        {
            TenantId = tenantId,
            RfqId = rfqId,
            SupplierId = supplierId,
            QuoteNo = Requisition.Truncate(quoteNo, QuoteNoMaxLength),
            QuoteDate = quoteDate,
            ValidUntil = validUntil,
            Currency = currency.ToUpperInvariant(),
            FxRate = fxRate,
            DeliveryDays = deliveryDays,
            PaymentTerms = Requisition.Truncate(paymentTerms, PaymentTermsMaxLength),
        };
    }

    public Result UpdateHeader(
        long? rfqId,
        uint supplierId,
        string? quoteNo,
        DateOnly quoteDate,
        DateOnly? validUntil,
        string currency,
        decimal fxRate,
        ushort? deliveryDays,
        string? paymentTerms)
    {
        if (IsSelected)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(Quotation), "SELECTED", "updated");
        }

        var validated = Create(TenantId, rfqId, supplierId, quoteNo, quoteDate, validUntil, currency, fxRate, deliveryDays, paymentTerms);
        if (validated.IsFailure)
        {
            return validated.Error;
        }

        RfqId = rfqId;
        SupplierId = supplierId;
        QuoteNo = Requisition.Truncate(quoteNo, QuoteNoMaxLength);
        QuoteDate = quoteDate;
        ValidUntil = validUntil;
        Currency = currency.ToUpperInvariant();
        FxRate = fxRate;
        DeliveryDays = deliveryDays;
        PaymentTerms = Requisition.Truncate(paymentTerms, PaymentTermsMaxLength);
        return Result.Success();
    }

    /// <summary>
    /// Replaces the lines and recomputes the totals. <paramref name="baseUomFactors"/> maps a line index to the
    /// entered UoM's factor to the product's base UoM so <c>unit_price_base</c> is comparable across suppliers
    /// who quote in different packs (spec §12.1).
    /// </summary>
    public Result ReplaceLines(IReadOnlyList<QuotationLineDraft> lines)
    {
        ArgumentNullException.ThrowIfNull(lines);
        if (IsSelected)
        {
            return ProcurementErrors.InvalidStatusTransition(nameof(Quotation), "SELECTED", "lines replaced");
        }

        var replacement = new List<QuotationLine>();
        ushort lineNo = 1;
        foreach (var draft in lines)
        {
            var line = QuotationLine.Create(TenantId, lineNo, draft, FxRate);
            if (line.IsFailure)
            {
                return line.Error;
            }

            replacement.Add(line.Value);
            lineNo++;
        }

        if (replacement.Count == 0)
        {
            return ProcurementErrors.InvalidQuotation("A quotation needs at least one line.");
        }

        _lines.Clear();
        _lines.AddRange(replacement);
        Recalculate();
        return Result.Success();
    }

    public void Recalculate()
    {
        TotalAmount = Quantity.Round(_lines.Sum(l => l.LineTotal), Money.StorageDecimals);
        TotalAmountBase = Quantity.Round(TotalAmount * FxRate, Money.StorageDecimals);
    }

    /// <summary>
    /// Marks this quotation as the basis of the future PO. <paramref name="isCheapest"/> comes from the ranking of
    /// every quotation of the same RFQ; when it is false a <paramref name="selectionNote"/> is mandatory (spec §10).
    /// </summary>
    public Result Select(bool isCheapest, string? selectionNote)
    {
        if (!isCheapest && string.IsNullOrWhiteSpace(selectionNote))
        {
            return ProcurementErrors.SelectionNoteRequired();
        }

        IsSelected = true;
        SelectionNote = Requisition.Truncate(selectionNote, SelectionNoteMaxLength);
        return Result.Success();
    }

    /// <summary>The previously selected quotation of the same RFQ loses the selection.</summary>
    public void Deselect()
    {
        IsSelected = false;
        SelectionNote = null;
    }
}

/// <summary><c>proc_quotation_line</c>.</summary>
public sealed class QuotationLine : Entity<long>, ITenantEntity
{
    public const int NoteMaxLength = 500;

    private QuotationLine()
    {
    }

    public uint TenantId { get; private set; }

    public long QuotationId { get; private set; }

    public ushort LineNo { get; private set; }

    public long? RfqLineId { get; private set; }

    public uint ProductId { get; private set; }

    public decimal Qty { get; private set; }

    public ushort UomId { get; private set; }

    /// <summary>In the quotation currency, per entered UoM, VAT excluded.</summary>
    public decimal UnitPrice { get; private set; }

    /// <summary>Base currency, per the product's base UoM — the only figure the comparison ranks on.</summary>
    public decimal UnitPriceBase { get; private set; }

    public decimal LineTotal { get; private set; }

    public string? Note { get; private set; }

    internal static Result<QuotationLine> Create(uint tenantId, ushort lineNo, QuotationLineDraft draft, decimal fxRate)
    {
        ArgumentNullException.ThrowIfNull(draft);
        if (draft.ProductId == 0 || draft.UomId == 0)
        {
            return ProcurementErrors.InvalidQuotation($"Line {lineNo}: product_id and uom_id are required.");
        }

        if (draft.Qty <= 0m)
        {
            return ProcurementErrors.InvalidQuotation($"Line {lineNo}: qty must be positive.");
        }

        if (draft.UnitPrice < 0m)
        {
            return ProcurementErrors.InvalidQuotation($"Line {lineNo}: unit_price cannot be negative.");
        }

        if (draft.UomFactorToBase <= 0m)
        {
            return ProcurementErrors.InvalidQuotation($"Line {lineNo}: no UoM conversion factor is defined for this product.");
        }

        return new QuotationLine
        {
            TenantId = tenantId,
            LineNo = lineNo,
            RfqLineId = draft.RfqLineId,
            ProductId = draft.ProductId,
            Qty = Quantity.Round(draft.Qty, Quantity.StorageDecimals),
            UomId = draft.UomId,
            UnitPrice = Quantity.Round(draft.UnitPrice, Money.StorageDecimals),
            UnitPriceBase = Quantity.Round(draft.UnitPrice / draft.UomFactorToBase * fxRate, Money.StorageDecimals),
            LineTotal = Quantity.Round(draft.Qty * draft.UnitPrice, Money.StorageDecimals),
            Note = Requisition.Truncate(draft.Note, NoteMaxLength),
        };
    }
}

/// <summary>Input of <see cref="Quotation.ReplaceLines"/>. <paramref name="UomFactorToBase"/> comes from MasterData.</summary>
public sealed record QuotationLineDraft(
    uint ProductId,
    decimal Qty,
    ushort UomId,
    decimal UnitPrice,
    decimal UomFactorToBase,
    long? RfqLineId,
    string? Note);
