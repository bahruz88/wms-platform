import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

/// Procurement reads and approval actions (spec §10).
abstract interface class ProcurementRepository {
  Future<Result<Page<RequisitionDto>>> requisitions({
    RequisitionStatus? status,
    PageRequest page,
  });

  Future<Result<RequisitionDto>> createRequisition(
    CreateRequisitionRequest request,
  );

  Future<Result<Page<RfqDto>>> rfqs({RfqStatus? status, PageRequest page});

  Future<Result<List<QuotationDto>>> quotations(int rfqId);

  /// Selecting a quote that is not the cheapest requires a justification.
  Future<Result<QuotationDto>> selectQuotation(
    int rfqId,
    SelectQuotationRequest request,
  );

  Future<Result<Page<PurchaseOrderDto>>> purchaseOrders({
    PoStatus? status,
    PageRequest page,
  });

  Future<Result<PurchaseOrderDto>> purchaseOrder(int id);

  /// Requires `proc.po.approve`.
  Future<Result<PurchaseOrderDto>> approve(
    int id, {
    required int rowVersion,
    String? comment,
  });

  /// Requires `proc.po.approve`; a comment explains the rejection.
  Future<Result<PurchaseOrderDto>> reject(
    int id, {
    required int rowVersion,
    String? comment,
  });

  Future<Result<Page<PriceHistoryDto>>> priceHistory({
    required int productId,
    int? supplierId,
    PageRequest page,
  });
}
