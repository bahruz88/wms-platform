/// Route names and paths of the procurement feature.
abstract final class ProcurementRoutes {
  static const String requisitionsName = 'requisitions';
  static const String requisitionsPath = '/procurement/requisitions';

  static const String requisitionCreateName = 'requisition-create';

  /// Child path of [requisitionsPath].
  static const String requisitionCreatePath = 'new';
  static const String requisitionCreateFullPath = '$requisitionsPath/new';

  static const String rfqsName = 'rfqs';
  static const String rfqsPath = '/procurement/rfqs';

  static const String quotationComparisonName = 'quotation-comparison';

  /// Child path of [rfqsPath].
  static const String quotationComparisonPath = ':rfqId/quotations';
  static String quotationComparison(int rfqId) => '$rfqsPath/$rfqId/quotations';

  static const String purchaseOrdersName = 'purchase-orders';
  static const String purchaseOrdersPath = '/procurement/purchase-orders';

  static const String purchaseOrderDetailName = 'purchase-order-detail';
  static const String purchaseOrderDetailPath = ':poId';
  static String purchaseOrderDetail(int id) => '$purchaseOrdersPath/$id';

  static const String priceHistoryName = 'price-history';
  static const String priceHistoryPath = '/procurement/price-history';
}
