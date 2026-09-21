namespace Wms.Inventory.Domain;

/// <summary>Keys of <c>inv_setting</c> (spec §9.1, TOR §36 — nothing hard-coded).</summary>
public static class InventorySettingKeys
{
    public const string ExpiryWarningDays = "expiry_warning_days";
    public const string ExpiryCriticalDays = "expiry_critical_days";
    public const string ReceiptOverTolerancePct = "receipt_over_tolerance_pct";
    public const string ReceiptUnderTolerancePct = "receipt_under_tolerance_pct";
    public const string CostingMethod = "costing_method";
    public const string CountVarianceApprovalThresholdPct = "count_variance_approval_threshold_pct";
    public const string BlockTransactionsDuringCount = "block_transactions_during_count";
    public const string RequireBranchReceiptConfirmation = "require_branch_receipt_confirmation";
    public const string AllowNegativeStock = "allow_negative_stock";

    public const string CostingMovingAverage = "MOVING_AVERAGE";
    public const string CostingFifo = "FIFO";

    public static IReadOnlyDictionary<string, string> Defaults { get; } = new Dictionary<string, string>(StringComparer.Ordinal)
    {
        [ExpiryWarningDays] = "30",
        [ExpiryCriticalDays] = "7",
        [ReceiptOverTolerancePct] = "0",
        [ReceiptUnderTolerancePct] = "0",
        [CostingMethod] = CostingMovingAverage,
        [CountVarianceApprovalThresholdPct] = "2",
        [BlockTransactionsDuringCount] = "true",
        [RequireBranchReceiptConfirmation] = "true",
        [AllowNegativeStock] = "false",
    };
}
