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

    /// <summary>The nine keys of spec §9.1 with their type, default and accepted range.</summary>
    public static IReadOnlyList<InventorySettingDefinition> Definitions { get; } =
    [
        new(ExpiryWarningDays, SettingValueType.Int, "30", "Bitmə tarixi xəbərdarlığı (gün)", Minimum: 0, Maximum: 3650),
        new(ExpiryCriticalDays, SettingValueType.Int, "7", "Kritik bitmə həddi (gün)", Minimum: 0, Maximum: 3650),
        new(ReceiptOverTolerancePct, SettingValueType.Decimal, "0", "Qəbulda artıq tolerans (%)", Minimum: 0m, Maximum: 100m),
        new(ReceiptUnderTolerancePct, SettingValueType.Decimal, "0", "Qəbulda əskik tolerans (%)", Minimum: 0m, Maximum: 100m),
        new(CostingMethod, SettingValueType.Enum, CostingMovingAverage, "Maya dəyəri metodu", [CostingMovingAverage, CostingFifo]),
        new(CountVarianceApprovalThresholdPct, SettingValueType.Decimal, "2", "Sayım fərqi təsdiq həddi (%)", Minimum: 0m, Maximum: 100m),
        new(BlockTransactionsDuringCount, SettingValueType.Bool, "true", "Sayım zamanı əməliyyatları bloklamaq"),
        new(RequireBranchReceiptConfirmation, SettingValueType.Bool, "true", "Filial qəbulunun təsdiqi məcburidir"),
        new(AllowNegativeStock, SettingValueType.Bool, "false", "Mənfi qalığa icazə"),
    ];

    public static IReadOnlyDictionary<string, InventorySettingDefinition> ByKey { get; } =
        Definitions.ToDictionary(d => d.Key, StringComparer.Ordinal);

    public static IReadOnlyDictionary<string, string> Defaults { get; } =
        Definitions.ToDictionary(d => d.Key, d => d.DefaultValue, StringComparer.Ordinal);
}
