import 'package:dio/dio.dart';
import 'package:wms_core/wms_core.dart';

import '../dto/procurement/procurement_dtos.dart';
import 'module_api.dart';

/// `/api/v1/procurement/*` (spec §10, §13.1).
class ProcurementApi extends ModuleApi {
  ProcurementApi(Dio dio) : super(dio, '/procurement');

  // --- Requisitions -----------------------------------------------------

  Future<Page<RequisitionDto>> listRequisitions({
    RequisitionStatus? status,
    ProductType? productType,
    int? requesterLocationId,
    PageRequest page = const PageRequest(),
  }) => getPage(
    'requisitions',
    fromJson: RequisitionDto.fromJson,
    page: page,
    query: {
      'status': status,
      'productType': productType,
      'requesterLocationId': requesterLocationId,
    },
  );

  Future<RequisitionDto> getRequisition(int id) =>
      getObject('requisitions/$id', fromJson: RequisitionDto.fromJson);

  Future<RequisitionDto> createRequisition(CreateRequisitionRequest body) =>
      postObject(
        'requisitions',
        body: body.toJson(),
        fromJson: RequisitionDto.fromJson,
      );

  Future<RequisitionDto> submitRequisition(int id, {required int rowVersion}) =>
      postObject(
        'requisitions/$id/submit',
        body: ApprovalDecisionRequest(rowVersion: rowVersion).toJson(),
        fromJson: RequisitionDto.fromJson,
      );

  // --- RFQ / quotations -------------------------------------------------

  Future<Page<RfqDto>> listRfqs({
    RfqStatus? status,
    PageRequest page = const PageRequest(),
  }) => getPage(
    'rfqs',
    fromJson: RfqDto.fromJson,
    page: page,
    query: {'status': status},
  );

  Future<RfqDto> getRfq(int id) =>
      getObject('rfqs/$id', fromJson: RfqDto.fromJson);

  /// Quotations received for an RFQ - input of the comparison table.
  Future<List<QuotationDto>> listQuotations(int rfqId) =>
      getList('rfqs/$rfqId/quotations', fromJson: QuotationDto.fromJson);

  /// `POST /procurement/rfqs/{id}/select` - [SelectQuotationRequest.selectionNote]
  /// is mandatory when the selected quote is not the cheapest.
  Future<QuotationDto> selectQuotation(
    int rfqId,
    SelectQuotationRequest body,
  ) => postObject(
    'rfqs/$rfqId/select',
    body: body.toJson(),
    fromJson: QuotationDto.fromJson,
  );

  // --- Purchase orders --------------------------------------------------

  Future<Page<PurchaseOrderDto>> listPurchaseOrders({
    PoStatus? status,
    int? supplierId,
    PageRequest page = const PageRequest(),
  }) => getPage(
    'purchase-orders',
    fromJson: PurchaseOrderDto.fromJson,
    page: page,
    query: {'status': status, 'supplierId': supplierId},
  );

  Future<PurchaseOrderDto> getPurchaseOrder(int id) =>
      getObject('purchase-orders/$id', fromJson: PurchaseOrderDto.fromJson);

  /// `POST /procurement/purchase-orders/{id}/approve` (`proc.po.approve`).
  Future<PurchaseOrderDto> approvePurchaseOrder(
    int id,
    ApprovalDecisionRequest body,
  ) => postObject(
    'purchase-orders/$id/approve',
    body: body.toJson(),
    fromJson: PurchaseOrderDto.fromJson,
  );

  /// `POST /procurement/purchase-orders/{id}/reject` (`proc.po.approve`).
  Future<PurchaseOrderDto> rejectPurchaseOrder(
    int id,
    ApprovalDecisionRequest body,
  ) => postObject(
    'purchase-orders/$id/reject',
    body: body.toJson(),
    fromJson: PurchaseOrderDto.fromJson,
  );

  // --- Price history ----------------------------------------------------

  /// `GET /procurement/price-history?productId=&supplierId=`
  Future<Page<PriceHistoryDto>> listPriceHistory({
    required int productId,
    int? supplierId,
    PageRequest page = const PageRequest(),
  }) => getPage(
    'price-history',
    fromJson: PriceHistoryDto.fromJson,
    page: page,
    query: {'productId': productId, 'supplierId': supplierId},
  );
}
