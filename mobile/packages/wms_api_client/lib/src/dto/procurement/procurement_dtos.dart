import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wms_core/wms_core.dart';

import '../../json/date_only_converter.dart';

part 'procurement_dtos.freezed.dart';
part 'procurement_dtos.g.dart';

// ---------------------------------------------------------------------------
// Requisition (PR)
// ---------------------------------------------------------------------------

@freezed
abstract class RequisitionLineDto with _$RequisitionLineDto {
  const factory RequisitionLineDto({
    required int lineNo,
    required int productId,
    required Quantity qty,
    required int uomId,
    required Quantity convertedQty,
    String? productName,
    String? uomCode,
    String? note,
  }) = _RequisitionLineDto;

  const RequisitionLineDto._();

  factory RequisitionLineDto.fromJson(Map<String, Object?> json) =>
      _$RequisitionLineDtoFromJson(json);

  Quantity get remainingQty => qty - convertedQty;
}

/// `proc_requisition`.
@freezed
abstract class RequisitionDto with _$RequisitionDto {
  const factory RequisitionDto({
    required int id,
    required String docNo,
    @DateOnlyConverter() required DateTime docDate,
    required int requesterLocationId,
    required ProductType productType,
    required RequisitionStatus status,
    @Default(Priority.normal) Priority priority,
    String? requesterLocationName,
    @NullableDateOnlyConverter() DateTime? requiredDate,
    String? note,
    DateTime? createdAt,
    @Default(1) int rowVersion,
    @Default(<RequisitionLineDto>[]) List<RequisitionLineDto> lines,
  }) = _RequisitionDto;

  factory RequisitionDto.fromJson(Map<String, Object?> json) =>
      _$RequisitionDtoFromJson(json);
}

@freezed
abstract class CreateRequisitionLine with _$CreateRequisitionLine {
  const factory CreateRequisitionLine({
    required int productId,
    required Quantity qty,
    required int uomId,
    String? note,
  }) = _CreateRequisitionLine;

  factory CreateRequisitionLine.fromJson(Map<String, Object?> json) =>
      _$CreateRequisitionLineFromJson(json);
}

/// `POST /procurement/requisitions` body.
@freezed
abstract class CreateRequisitionRequest with _$CreateRequisitionRequest {
  const factory CreateRequisitionRequest({
    @DateOnlyConverter() required DateTime docDate,
    required int requesterLocationId,
    required ProductType productType,
    required List<CreateRequisitionLine> lines,
    @Default(Priority.normal) Priority priority,
    @NullableDateOnlyConverter() DateTime? requiredDate,
    String? note,
  }) = _CreateRequisitionRequest;

  factory CreateRequisitionRequest.fromJson(Map<String, Object?> json) =>
      _$CreateRequisitionRequestFromJson(json);
}

// ---------------------------------------------------------------------------
// RFQ / quotation
// ---------------------------------------------------------------------------

/// `proc_rfq`.
@freezed
abstract class RfqDto with _$RfqDto {
  const factory RfqDto({
    required int id,
    required String docNo,
    @DateOnlyConverter() required DateTime docDate,
    required RfqStatus status,
    @NullableDateOnlyConverter() DateTime? dueDate,
    @Default(<int>[]) List<int> requisitionIds,
    @Default(<int>[]) List<int> supplierIds,
    @Default(0) int quotationCount,
  }) = _RfqDto;

  factory RfqDto.fromJson(Map<String, Object?> json) => _$RfqDtoFromJson(json);
}

@freezed
abstract class QuotationLineDto with _$QuotationLineDto {
  const factory QuotationLineDto({
    required int productId,
    required Quantity qty,
    required int uomId,
    required Money unitPrice,
    required Money lineTotal,
    String? productName,
    String? uomCode,
  }) = _QuotationLineDto;

  factory QuotationLineDto.fromJson(Map<String, Object?> json) =>
      _$QuotationLineDtoFromJson(json);
}

/// `proc_quotation`. [selectionNote] is mandatory when the selected quote is
/// not the cheapest (spec §10).
@freezed
abstract class QuotationDto with _$QuotationDto {
  const factory QuotationDto({
    required int id,
    required int supplierId,
    @DateOnlyConverter() required DateTime quoteDate,
    required String currency,
    int? rfqId,
    String? supplierName,
    String? quoteNo,
    @NullableDateOnlyConverter() DateTime? validUntil,
    int? deliveryDays,
    String? paymentTerms,
    Money? totalAmount,
    Money? totalAmountBase,
    @Default(false) bool isSelected,
    String? selectionNote,
    @Default(<QuotationLineDto>[]) List<QuotationLineDto> lines,
  }) = _QuotationDto;

  factory QuotationDto.fromJson(Map<String, Object?> json) =>
      _$QuotationDtoFromJson(json);
}

/// `POST /procurement/rfqs/{id}/select` body.
@freezed
abstract class SelectQuotationRequest with _$SelectQuotationRequest {
  const factory SelectQuotationRequest({
    required int quotationId,
    String? selectionNote,
  }) = _SelectQuotationRequest;

  factory SelectQuotationRequest.fromJson(Map<String, Object?> json) =>
      _$SelectQuotationRequestFromJson(json);
}

// ---------------------------------------------------------------------------
// Purchase order (PO)
// ---------------------------------------------------------------------------

@freezed
abstract class PurchaseOrderLineDto with _$PurchaseOrderLineDto {
  const factory PurchaseOrderLineDto({
    required int lineNo,
    required int productId,
    required Quantity qty,
    required int uomId,
    required Money unitPrice,
    required Decimal vatRate,
    required Money lineTotal,
    required Quantity receivedQty,
    int? requisitionLineId,
    String? productName,
    String? uomCode,
  }) = _PurchaseOrderLineDto;

  const PurchaseOrderLineDto._();

  factory PurchaseOrderLineDto.fromJson(Map<String, Object?> json) =>
      _$PurchaseOrderLineDtoFromJson(json);

  Quantity get outstandingQty => qty - receivedQty;
}

/// One approval step of the parametric workflow (`proc_approval_step`).
@freezed
abstract class ApprovalStepDto with _$ApprovalStepDto {
  const factory ApprovalStepDto({
    required int stepNo,
    required ApprovalStatus decision,
    int? approverUserId,
    String? approverName,
    int? delegatedFromUserId,
    DateTime? decidedAt,
    String? comment,
  }) = _ApprovalStepDto;

  factory ApprovalStepDto.fromJson(Map<String, Object?> json) =>
      _$ApprovalStepDtoFromJson(json);
}

/// `proc_purchase_order`.
@freezed
abstract class PurchaseOrderDto with _$PurchaseOrderDto {
  const factory PurchaseOrderDto({
    required int id,
    required String docNo,
    @DateOnlyConverter() required DateTime docDate,
    required int supplierId,
    required String currency,
    required Decimal fxRate,
    required Money subtotal,
    required Money vatAmount,
    required Money totalAmount,
    required Money totalAmountBase,
    required int deliveryLocationId,
    required PoStatus status,
    String? supplierName,
    String? deliveryLocationName,
    @NullableDateOnlyConverter() DateTime? expectedDate,
    String? incoterms,
    DateTime? sentAt,
    DateTime? createdAt,
    int? createdBy,
    @Default(1) int rowVersion,
    @Default(<PurchaseOrderLineDto>[]) List<PurchaseOrderLineDto> lines,
    @Default(<ApprovalStepDto>[]) List<ApprovalStepDto> approvalSteps,
  }) = _PurchaseOrderDto;

  factory PurchaseOrderDto.fromJson(Map<String, Object?> json) =>
      _$PurchaseOrderDtoFromJson(json);
}

/// `POST /procurement/purchase-orders/{id}/approve|reject` body.
@freezed
abstract class ApprovalDecisionRequest with _$ApprovalDecisionRequest {
  const factory ApprovalDecisionRequest({
    required int rowVersion,
    String? comment,
  }) = _ApprovalDecisionRequest;

  factory ApprovalDecisionRequest.fromJson(Map<String, Object?> json) =>
      _$ApprovalDecisionRequestFromJson(json);
}

/// `proc_price_history` row.
@freezed
abstract class PriceHistoryDto with _$PriceHistoryDto {
  const factory PriceHistoryDto({
    required int id,
    required int productId,
    required int supplierId,
    @DateOnlyConverter() required DateTime priceDate,
    required Money unitPrice,
    required String currency,
    required Money unitPriceBase,
    String? supplierName,
    int? poId,
    String? poDocNo,
    Money? prevPriceBase,
    Money? diffAmount,
    Decimal? diffPct,
  }) = _PriceHistoryDto;

  factory PriceHistoryDto.fromJson(Map<String, Object?> json) =>
      _$PriceHistoryDtoFromJson(json);
}
