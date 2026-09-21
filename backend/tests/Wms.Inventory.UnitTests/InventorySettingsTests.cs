using Wms.Inventory.Domain;

namespace Wms.Inventory.UnitTests;

/// <summary>Spec §9.1 / TOR §36: every tunable has a default and nothing is hard-coded elsewhere.</summary>
public sealed class InventorySettingsTests
{
    [Theory]
    [InlineData(InventorySettingKeys.ExpiryWarningDays, "30")]
    [InlineData(InventorySettingKeys.ExpiryCriticalDays, "7")]
    [InlineData(InventorySettingKeys.ReceiptOverTolerancePct, "0")]
    [InlineData(InventorySettingKeys.ReceiptUnderTolerancePct, "0")]
    [InlineData(InventorySettingKeys.CostingMethod, "MOVING_AVERAGE")]
    [InlineData(InventorySettingKeys.CountVarianceApprovalThresholdPct, "2")]
    [InlineData(InventorySettingKeys.BlockTransactionsDuringCount, "true")]
    [InlineData(InventorySettingKeys.RequireBranchReceiptConfirmation, "true")]
    [InlineData(InventorySettingKeys.AllowNegativeStock, "false")]
    public void Defaults_match_the_specification(string key, string expected)
    {
        Assert.Equal(expected, InventorySettingKeys.Defaults[key]);
    }
}
