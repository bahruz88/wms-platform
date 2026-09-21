// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'procurement_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RequisitionLineDto _$RequisitionLineDtoFromJson(Map<String, dynamic> json) =>
    _RequisitionLineDto(
      lineNo: (json['lineNo'] as num).toInt(),
      productId: (json['productId'] as num).toInt(),
      qty: Quantity.fromJson(json['qty'] as String),
      uomId: (json['uomId'] as num).toInt(),
      convertedQty: Quantity.fromJson(json['convertedQty'] as String),
      productName: json['productName'] as String?,
      uomCode: json['uomCode'] as String?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$RequisitionLineDtoToJson(_RequisitionLineDto instance) =>
    <String, dynamic>{
      'lineNo': instance.lineNo,
      'productId': instance.productId,
      'qty': instance.qty.toJson(),
      'uomId': instance.uomId,
      'convertedQty': instance.convertedQty.toJson(),
      'productName': instance.productName,
      'uomCode': instance.uomCode,
      'note': instance.note,
    };

_RequisitionDto _$RequisitionDtoFromJson(Map<String, dynamic> json) =>
    _RequisitionDto(
      id: (json['id'] as num).toInt(),
      docNo: json['docNo'] as String,
      docDate: const DateOnlyConverter().fromJson(json['docDate'] as String),
      requesterLocationId: (json['requesterLocationId'] as num).toInt(),
      productType: $enumDecode(_$ProductTypeEnumMap, json['productType']),
      status: $enumDecode(_$RequisitionStatusEnumMap, json['status']),
      priority:
          $enumDecodeNullable(_$PriorityEnumMap, json['priority']) ??
          Priority.normal,
      requesterLocationName: json['requesterLocationName'] as String?,
      requiredDate: const NullableDateOnlyConverter().fromJson(
        json['requiredDate'] as String?,
      ),
      note: json['note'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      rowVersion: (json['rowVersion'] as num?)?.toInt() ?? 1,
      lines:
          (json['lines'] as List<dynamic>?)
              ?.map(
                (e) => RequisitionLineDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <RequisitionLineDto>[],
    );

Map<String, dynamic> _$RequisitionDtoToJson(_RequisitionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'docNo': instance.docNo,
      'docDate': const DateOnlyConverter().toJson(instance.docDate),
      'requesterLocationId': instance.requesterLocationId,
      'productType': _$ProductTypeEnumMap[instance.productType]!,
      'status': _$RequisitionStatusEnumMap[instance.status]!,
      'priority': _$PriorityEnumMap[instance.priority]!,
      'requesterLocationName': instance.requesterLocationName,
      'requiredDate': const NullableDateOnlyConverter().toJson(
        instance.requiredDate,
      ),
      'note': instance.note,
      'createdAt': instance.createdAt?.toIso8601String(),
      'rowVersion': instance.rowVersion,
      'lines': instance.lines.map((e) => e.toJson()).toList(),
    };

const _$ProductTypeEnumMap = {
  ProductType.food: 'FOOD',
  ProductType.nonFood: 'NON_FOOD',
};

const _$RequisitionStatusEnumMap = {
  RequisitionStatus.draft: 'DRAFT',
  RequisitionStatus.submitted: 'SUBMITTED',
  RequisitionStatus.inProcurement: 'IN_PROCUREMENT',
  RequisitionStatus.convertedToPo: 'CONVERTED_TO_PO',
  RequisitionStatus.rejected: 'REJECTED',
  RequisitionStatus.cancelled: 'CANCELLED',
  RequisitionStatus.closed: 'CLOSED',
};

const _$PriorityEnumMap = {
  Priority.low: 'LOW',
  Priority.normal: 'NORMAL',
  Priority.high: 'HIGH',
  Priority.urgent: 'URGENT',
};

_CreateRequisitionLine _$CreateRequisitionLineFromJson(
  Map<String, dynamic> json,
) => _CreateRequisitionLine(
  productId: (json['productId'] as num).toInt(),
  qty: Quantity.fromJson(json['qty'] as String),
  uomId: (json['uomId'] as num).toInt(),
  note: json['note'] as String?,
);

Map<String, dynamic> _$CreateRequisitionLineToJson(
  _CreateRequisitionLine instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'qty': instance.qty.toJson(),
  'uomId': instance.uomId,
  'note': instance.note,
};

_CreateRequisitionRequest _$CreateRequisitionRequestFromJson(
  Map<String, dynamic> json,
) => _CreateRequisitionRequest(
  docDate: const DateOnlyConverter().fromJson(json['docDate'] as String),
  requesterLocationId: (json['requesterLocationId'] as num).toInt(),
  productType: $enumDecode(_$ProductTypeEnumMap, json['productType']),
  lines: (json['lines'] as List<dynamic>)
      .map((e) => CreateRequisitionLine.fromJson(e as Map<String, dynamic>))
      .toList(),
  priority:
      $enumDecodeNullable(_$PriorityEnumMap, json['priority']) ??
      Priority.normal,
  requiredDate: const NullableDateOnlyConverter().fromJson(
    json['requiredDate'] as String?,
  ),
  note: json['note'] as String?,
);

Map<String, dynamic> _$CreateRequisitionRequestToJson(
  _CreateRequisitionRequest instance,
) => <String, dynamic>{
  'docDate': const DateOnlyConverter().toJson(instance.docDate),
  'requesterLocationId': instance.requesterLocationId,
  'productType': _$ProductTypeEnumMap[instance.productType]!,
  'lines': instance.lines.map((e) => e.toJson()).toList(),
  'priority': _$PriorityEnumMap[instance.priority]!,
  'requiredDate': const NullableDateOnlyConverter().toJson(
    instance.requiredDate,
  ),
  'note': instance.note,
};

_RfqDto _$RfqDtoFromJson(Map<String, dynamic> json) => _RfqDto(
  id: (json['id'] as num).toInt(),
  docNo: json['docNo'] as String,
  docDate: const DateOnlyConverter().fromJson(json['docDate'] as String),
  status: $enumDecode(_$RfqStatusEnumMap, json['status']),
  dueDate: const NullableDateOnlyConverter().fromJson(
    json['dueDate'] as String?,
  ),
  requisitionIds:
      (json['requisitionIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const <int>[],
  supplierIds:
      (json['supplierIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const <int>[],
  quotationCount: (json['quotationCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$RfqDtoToJson(_RfqDto instance) => <String, dynamic>{
  'id': instance.id,
  'docNo': instance.docNo,
  'docDate': const DateOnlyConverter().toJson(instance.docDate),
  'status': _$RfqStatusEnumMap[instance.status]!,
  'dueDate': const NullableDateOnlyConverter().toJson(instance.dueDate),
  'requisitionIds': instance.requisitionIds,
  'supplierIds': instance.supplierIds,
  'quotationCount': instance.quotationCount,
};

const _$RfqStatusEnumMap = {
  RfqStatus.draft: 'DRAFT',
  RfqStatus.sent: 'SENT',
  RfqStatus.closed: 'CLOSED',
  RfqStatus.cancelled: 'CANCELLED',
};

_QuotationLineDto _$QuotationLineDtoFromJson(Map<String, dynamic> json) =>
    _QuotationLineDto(
      productId: (json['productId'] as num).toInt(),
      qty: Quantity.fromJson(json['qty'] as String),
      uomId: (json['uomId'] as num).toInt(),
      unitPrice: Money.fromJson(json['unitPrice'] as String),
      lineTotal: Money.fromJson(json['lineTotal'] as String),
      productName: json['productName'] as String?,
      uomCode: json['uomCode'] as String?,
    );

Map<String, dynamic> _$QuotationLineDtoToJson(_QuotationLineDto instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'qty': instance.qty.toJson(),
      'uomId': instance.uomId,
      'unitPrice': instance.unitPrice.toJson(),
      'lineTotal': instance.lineTotal.toJson(),
      'productName': instance.productName,
      'uomCode': instance.uomCode,
    };

_QuotationDto _$QuotationDtoFromJson(Map<String, dynamic> json) =>
    _QuotationDto(
      id: (json['id'] as num).toInt(),
      supplierId: (json['supplierId'] as num).toInt(),
      quoteDate: const DateOnlyConverter().fromJson(
        json['quoteDate'] as String,
      ),
      currency: json['currency'] as String,
      rfqId: (json['rfqId'] as num?)?.toInt(),
      supplierName: json['supplierName'] as String?,
      quoteNo: json['quoteNo'] as String?,
      validUntil: const NullableDateOnlyConverter().fromJson(
        json['validUntil'] as String?,
      ),
      deliveryDays: (json['deliveryDays'] as num?)?.toInt(),
      paymentTerms: json['paymentTerms'] as String?,
      totalAmount: json['totalAmount'] == null
          ? null
          : Money.fromJson(json['totalAmount'] as String),
      totalAmountBase: json['totalAmountBase'] == null
          ? null
          : Money.fromJson(json['totalAmountBase'] as String),
      isSelected: json['isSelected'] as bool? ?? false,
      selectionNote: json['selectionNote'] as String?,
      lines:
          (json['lines'] as List<dynamic>?)
              ?.map((e) => QuotationLineDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <QuotationLineDto>[],
    );

Map<String, dynamic> _$QuotationDtoToJson(
  _QuotationDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'supplierId': instance.supplierId,
  'quoteDate': const DateOnlyConverter().toJson(instance.quoteDate),
  'currency': instance.currency,
  'rfqId': instance.rfqId,
  'supplierName': instance.supplierName,
  'quoteNo': instance.quoteNo,
  'validUntil': const NullableDateOnlyConverter().toJson(instance.validUntil),
  'deliveryDays': instance.deliveryDays,
  'paymentTerms': instance.paymentTerms,
  'totalAmount': instance.totalAmount?.toJson(),
  'totalAmountBase': instance.totalAmountBase?.toJson(),
  'isSelected': instance.isSelected,
  'selectionNote': instance.selectionNote,
  'lines': instance.lines.map((e) => e.toJson()).toList(),
};

_SelectQuotationRequest _$SelectQuotationRequestFromJson(
  Map<String, dynamic> json,
) => _SelectQuotationRequest(
  quotationId: (json['quotationId'] as num).toInt(),
  selectionNote: json['selectionNote'] as String?,
);

Map<String, dynamic> _$SelectQuotationRequestToJson(
  _SelectQuotationRequest instance,
) => <String, dynamic>{
  'quotationId': instance.quotationId,
  'selectionNote': instance.selectionNote,
};

_PurchaseOrderLineDto _$PurchaseOrderLineDtoFromJson(
  Map<String, dynamic> json,
) => _PurchaseOrderLineDto(
  lineNo: (json['lineNo'] as num).toInt(),
  productId: (json['productId'] as num).toInt(),
  qty: Quantity.fromJson(json['qty'] as String),
  uomId: (json['uomId'] as num).toInt(),
  unitPrice: Money.fromJson(json['unitPrice'] as String),
  vatRate: Decimal.fromJson(json['vatRate'] as String),
  lineTotal: Money.fromJson(json['lineTotal'] as String),
  receivedQty: Quantity.fromJson(json['receivedQty'] as String),
  requisitionLineId: (json['requisitionLineId'] as num?)?.toInt(),
  productName: json['productName'] as String?,
  uomCode: json['uomCode'] as String?,
);

Map<String, dynamic> _$PurchaseOrderLineDtoToJson(
  _PurchaseOrderLineDto instance,
) => <String, dynamic>{
  'lineNo': instance.lineNo,
  'productId': instance.productId,
  'qty': instance.qty.toJson(),
  'uomId': instance.uomId,
  'unitPrice': instance.unitPrice.toJson(),
  'vatRate': instance.vatRate.toJson(),
  'lineTotal': instance.lineTotal.toJson(),
  'receivedQty': instance.receivedQty.toJson(),
  'requisitionLineId': instance.requisitionLineId,
  'productName': instance.productName,
  'uomCode': instance.uomCode,
};

_ApprovalStepDto _$ApprovalStepDtoFromJson(Map<String, dynamic> json) =>
    _ApprovalStepDto(
      stepNo: (json['stepNo'] as num).toInt(),
      decision: $enumDecode(_$ApprovalStatusEnumMap, json['decision']),
      approverUserId: (json['approverUserId'] as num?)?.toInt(),
      approverName: json['approverName'] as String?,
      delegatedFromUserId: (json['delegatedFromUserId'] as num?)?.toInt(),
      decidedAt: json['decidedAt'] == null
          ? null
          : DateTime.parse(json['decidedAt'] as String),
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$ApprovalStepDtoToJson(_ApprovalStepDto instance) =>
    <String, dynamic>{
      'stepNo': instance.stepNo,
      'decision': _$ApprovalStatusEnumMap[instance.decision]!,
      'approverUserId': instance.approverUserId,
      'approverName': instance.approverName,
      'delegatedFromUserId': instance.delegatedFromUserId,
      'decidedAt': instance.decidedAt?.toIso8601String(),
      'comment': instance.comment,
    };

const _$ApprovalStatusEnumMap = {
  ApprovalStatus.pending: 'PENDING',
  ApprovalStatus.approved: 'APPROVED',
  ApprovalStatus.rejected: 'REJECTED',
  ApprovalStatus.cancelled: 'CANCELLED',
};

_PurchaseOrderDto _$PurchaseOrderDtoFromJson(Map<String, dynamic> json) =>
    _PurchaseOrderDto(
      id: (json['id'] as num).toInt(),
      docNo: json['docNo'] as String,
      docDate: const DateOnlyConverter().fromJson(json['docDate'] as String),
      supplierId: (json['supplierId'] as num).toInt(),
      currency: json['currency'] as String,
      fxRate: Decimal.fromJson(json['fxRate'] as String),
      subtotal: Money.fromJson(json['subtotal'] as String),
      vatAmount: Money.fromJson(json['vatAmount'] as String),
      totalAmount: Money.fromJson(json['totalAmount'] as String),
      totalAmountBase: Money.fromJson(json['totalAmountBase'] as String),
      deliveryLocationId: (json['deliveryLocationId'] as num).toInt(),
      status: $enumDecode(_$PoStatusEnumMap, json['status']),
      supplierName: json['supplierName'] as String?,
      deliveryLocationName: json['deliveryLocationName'] as String?,
      expectedDate: const NullableDateOnlyConverter().fromJson(
        json['expectedDate'] as String?,
      ),
      incoterms: json['incoterms'] as String?,
      sentAt: json['sentAt'] == null
          ? null
          : DateTime.parse(json['sentAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      createdBy: (json['createdBy'] as num?)?.toInt(),
      rowVersion: (json['rowVersion'] as num?)?.toInt() ?? 1,
      lines:
          (json['lines'] as List<dynamic>?)
              ?.map(
                (e) => PurchaseOrderLineDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <PurchaseOrderLineDto>[],
      approvalSteps:
          (json['approvalSteps'] as List<dynamic>?)
              ?.map((e) => ApprovalStepDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ApprovalStepDto>[],
    );

Map<String, dynamic> _$PurchaseOrderDtoToJson(_PurchaseOrderDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'docNo': instance.docNo,
      'docDate': const DateOnlyConverter().toJson(instance.docDate),
      'supplierId': instance.supplierId,
      'currency': instance.currency,
      'fxRate': instance.fxRate.toJson(),
      'subtotal': instance.subtotal.toJson(),
      'vatAmount': instance.vatAmount.toJson(),
      'totalAmount': instance.totalAmount.toJson(),
      'totalAmountBase': instance.totalAmountBase.toJson(),
      'deliveryLocationId': instance.deliveryLocationId,
      'status': _$PoStatusEnumMap[instance.status]!,
      'supplierName': instance.supplierName,
      'deliveryLocationName': instance.deliveryLocationName,
      'expectedDate': const NullableDateOnlyConverter().toJson(
        instance.expectedDate,
      ),
      'incoterms': instance.incoterms,
      'sentAt': instance.sentAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'createdBy': instance.createdBy,
      'rowVersion': instance.rowVersion,
      'lines': instance.lines.map((e) => e.toJson()).toList(),
      'approvalSteps': instance.approvalSteps.map((e) => e.toJson()).toList(),
    };

const _$PoStatusEnumMap = {
  PoStatus.draft: 'DRAFT',
  PoStatus.pendingApproval: 'PENDING_APPROVAL',
  PoStatus.approved: 'APPROVED',
  PoStatus.rejected: 'REJECTED',
  PoStatus.sentToSupplier: 'SENT_TO_SUPPLIER',
  PoStatus.partiallyReceived: 'PARTIALLY_RECEIVED',
  PoStatus.fullyReceived: 'FULLY_RECEIVED',
  PoStatus.closed: 'CLOSED',
  PoStatus.cancelled: 'CANCELLED',
};

_ApprovalDecisionRequest _$ApprovalDecisionRequestFromJson(
  Map<String, dynamic> json,
) => _ApprovalDecisionRequest(
  rowVersion: (json['rowVersion'] as num).toInt(),
  comment: json['comment'] as String?,
);

Map<String, dynamic> _$ApprovalDecisionRequestToJson(
  _ApprovalDecisionRequest instance,
) => <String, dynamic>{
  'rowVersion': instance.rowVersion,
  'comment': instance.comment,
};

_PriceHistoryDto _$PriceHistoryDtoFromJson(Map<String, dynamic> json) =>
    _PriceHistoryDto(
      id: (json['id'] as num).toInt(),
      productId: (json['productId'] as num).toInt(),
      supplierId: (json['supplierId'] as num).toInt(),
      priceDate: const DateOnlyConverter().fromJson(
        json['priceDate'] as String,
      ),
      unitPrice: Money.fromJson(json['unitPrice'] as String),
      currency: json['currency'] as String,
      unitPriceBase: Money.fromJson(json['unitPriceBase'] as String),
      supplierName: json['supplierName'] as String?,
      poId: (json['poId'] as num?)?.toInt(),
      poDocNo: json['poDocNo'] as String?,
      prevPriceBase: json['prevPriceBase'] == null
          ? null
          : Money.fromJson(json['prevPriceBase'] as String),
      diffAmount: json['diffAmount'] == null
          ? null
          : Money.fromJson(json['diffAmount'] as String),
      diffPct: json['diffPct'] == null
          ? null
          : Decimal.fromJson(json['diffPct'] as String),
    );

Map<String, dynamic> _$PriceHistoryDtoToJson(_PriceHistoryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'supplierId': instance.supplierId,
      'priceDate': const DateOnlyConverter().toJson(instance.priceDate),
      'unitPrice': instance.unitPrice.toJson(),
      'currency': instance.currency,
      'unitPriceBase': instance.unitPriceBase.toJson(),
      'supplierName': instance.supplierName,
      'poId': instance.poId,
      'poDocNo': instance.poDocNo,
      'prevPriceBase': instance.prevPriceBase?.toJson(),
      'diffAmount': instance.diffAmount?.toJson(),
      'diffPct': instance.diffPct?.toJson(),
    };
