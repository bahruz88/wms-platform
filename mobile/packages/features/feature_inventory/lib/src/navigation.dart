/// Route names and paths of the inventory feature.
abstract final class InventoryRoutes {
  static const String balancesName = 'balances';
  static const String balancesPath = '/inventory/balances';

  static const String scanName = 'scan';
  static const String scanPath = '/inventory/scan';

  static const String receiptsName = 'goods-receipts';
  static const String receiptsPath = '/inventory/goods-receipts';

  static const String receiptCreateName = 'goods-receipt-create';

  static const String receiptCreatePath = '$receiptsPath/new';
  static const String receiptCreateFullPath = receiptCreatePath;

  static const String stockRequestCreateName = 'stock-request-create';
  static const String stockRequestCreatePath = '/inventory/stock-requests/new';

  static const String issuesName = 'issues';
  static const String issuesPath = '/inventory/issues';

  static const String issueConfirmName = 'issue-confirm';

  static const String issueConfirmPath = '$issuesPath/:issueId/confirm';
  static String issueConfirm(int id) => '$issuesPath/$id/confirm';

  static const String countsName = 'counts';
  static const String countsPath = '/inventory/counts';

  static const String countDetailName = 'count-detail';
  static const String countDetailPath = '$countsPath/:countId';
  static String countDetail(int id) => '$countsPath/$id';

  static const String wasteName = 'waste';
  static const String wastePath = '/inventory/waste';

  static const String wasteCreateName = 'waste-create';
  static const String wasteCreatePath = '$wastePath/new';
  static const String wasteCreateFullPath = wasteCreatePath;

  static const String samplesName = 'samples';
  static const String samplesPath = '/inventory/samples';

  static const String sampleCreateName = 'sample-create';
  static const String sampleCreatePath = '$samplesPath/new';
  static const String sampleCreateFullPath = sampleCreatePath;

  /// `inv_setting` viewer; it lives in the web app's admin section, hence
  /// the `/admin` path even though the data is an inventory concern.
  static const String settingsName = 'inventory-settings';
  static const String settingsPath = '/admin/settings';
}
