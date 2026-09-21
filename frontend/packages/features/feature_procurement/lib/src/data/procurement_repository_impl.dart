import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

import '../domain/procurement_repository.dart';

class ProcurementRepositoryImpl implements ProcurementRepository {
  ProcurementRepositoryImpl(this._api);

  final ProcurementApi _api;

  @override
  Future<Result<Page<RequisitionDto>>> requisitions({
    RequisitionStatus? status,
    PageRequest page = const PageRequest(),
  }) => Result.guard(() => _api.listRequisitions(status: status, page: page));

  @override
  Future<Result<RequisitionDto>> createRequisition(
    CreateRequisitionRequest request,
  ) => Result.guard(() => _api.createRequisition(request));

  @override
  Future<Result<Page<RfqDto>>> rfqs({
    RfqStatus? status,
    PageRequest page = const PageRequest(),
  }) => Result.guard(() => _api.listRfqs(status: status, page: page));

  @override
  Future<Result<List<QuotationDto>>> quotations(int rfqId) =>
      Result.guard(() => _api.listQuotations(rfqId));

  @override
  Future<Result<QuotationDto>> selectQuotation(
    int rfqId,
    SelectQuotationRequest request,
  ) => Result.guard(() => _api.selectQuotation(rfqId, request));

  @override
  Future<Result<Page<PurchaseOrderDto>>> purchaseOrders({
    PoStatus? status,
    PageRequest page = const PageRequest(),
  }) => Result.guard(() => _api.listPurchaseOrders(status: status, page: page));

  @override
  Future<Result<PurchaseOrderDto>> purchaseOrder(int id) =>
      Result.guard(() => _api.getPurchaseOrder(id));

  @override
  Future<Result<PurchaseOrderDto>> approve(
    int id, {
    required int rowVersion,
    String? comment,
  }) => Result.guard(
    () => _api.approvePurchaseOrder(
      id,
      ApprovalDecisionRequest(rowVersion: rowVersion, comment: comment),
    ),
  );

  @override
  Future<Result<PurchaseOrderDto>> reject(
    int id, {
    required int rowVersion,
    String? comment,
  }) => Result.guard(
    () => _api.rejectPurchaseOrder(
      id,
      ApprovalDecisionRequest(rowVersion: rowVersion, comment: comment),
    ),
  );

  @override
  Future<Result<Page<PriceHistoryDto>>> priceHistory({
    required int productId,
    int? supplierId,
    PageRequest page = const PageRequest(),
  }) => Result.guard(
    () => _api.listPriceHistory(
      productId: productId,
      supplierId: supplierId,
      page: page,
    ),
  );
}
