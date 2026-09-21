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
}
