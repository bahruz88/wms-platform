namespace Wms.MasterData.Contracts;

/// <summary>Document numbering <c>PR-2026-00001</c> from <c>master_number_sequence</c> with <c>SELECT ... FOR UPDATE</c> (spec Əlavə B). Gaps are acceptable.</summary>
public interface INumberSequenceService
{
    Task<string> NextAsync(string docType, DateOnly docDate, CancellationToken cancellationToken);
}

public static class DocumentNumberTypes
{
    public const string PurchaseRequisition = "PR";
    public const string PurchaseOrder = "PO";
    public const string GoodsReceipt = "GR";
    public const string StockRequest = "SR";
    public const string Issue = "IS";
    public const string InventoryCount = "IC";
    public const string Waste = "WS";
    public const string Sample = "SM";
    public const string ReturnToVendor = "RV";

    /// <summary>Branch consumption document: <c>CN-2026-00042</c> (ADR-012).</summary>
    public const string Consumption = "CN";

    /// <summary>Storno group created by <c>IStockPostingService.ReverseAsync</c>: <c>REV-2026-00007</c>.</summary>
    public const string Reversal = "REV";
}
