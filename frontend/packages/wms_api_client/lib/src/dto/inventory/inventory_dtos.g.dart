// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BalanceDto _$BalanceDtoFromJson(Map<String, dynamic> json) => _BalanceDto(
  productId: (json['productId'] as num).toInt(),
  locationId: (json['locationId'] as num).toInt(),
  qtyOnHand: Quantity.fromJson(json['qtyOnHand'] as String),
  qtyReserved: Quantity.fromJson(json['qtyReserved'] as String),
  batchId: (json['batchId'] as num?)?.toInt() ?? 0,
  productSku: json['productSku'] as String?,
  productName: json['productName'] as String?,
  locationCode: json['locationCode'] as String?,
  locationName: json['locationName'] as String?,
  batchNo: json['batchNo'] as String?,
  expiryDate: const NullableDateOnlyConverter().fromJson(
    json['expiryDate'] as String?,
  ),
  baseUomCode: json['baseUomCode'] as String?,
  avgUnitCost: json['avgUnitCost'] == null
      ? null
      : Money.fromJson(json['avgUnitCost'] as String),
  totalValue: json['totalValue'] == null
      ? null
      : Money.fromJson(json['totalValue'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$BalanceDtoToJson(
  _BalanceDto instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'locationId': instance.locationId,
  'qtyOnHand': instance.qtyOnHand.toJson(),
  'qtyReserved': instance.qtyReserved.toJson(),
  'batchId': instance.batchId,
  'productSku': instance.productSku,
  'productName': instance.productName,
  'locationCode': instance.locationCode,
  'locationName': instance.locationName,
  'batchNo': instance.batchNo,
  'expiryDate': const NullableDateOnlyConverter().toJson(instance.expiryDate),
  'baseUomCode': instance.baseUomCode,
  'avgUnitCost': instance.avgUnitCost?.toJson(),
  'totalValue': instance.totalValue?.toJson(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

_BatchDto _$BatchDtoFromJson(Map<String, dynamic> json) => _BatchDto(
  id: (json['id'] as num).toInt(),
  productId: (json['productId'] as num).toInt(),
  batchNo: json['batchNo'] as String,
  receivedAt: DateTime.parse(json['receivedAt'] as String),
  status: $enumDecode(_$BatchStatusEnumMap, json['status']),
  productionDate: const NullableDateOnlyConverter().fromJson(
    json['productionDate'] as String?,
  ),
  expiryDate: const NullableDateOnlyConverter().fromJson(
    json['expiryDate'] as String?,
  ),
  supplierId: (json['supplierId'] as num?)?.toInt(),
);

Map<String, dynamic> _$BatchDtoToJson(_BatchDto instance) => <String, dynamic>{
  'id': instance.id,
  'productId': instance.productId,
  'batchNo': instance.batchNo,
  'receivedAt': instance.receivedAt.toIso8601String(),
  'status': _$BatchStatusEnumMap[instance.status]!,
  'productionDate': const NullableDateOnlyConverter().toJson(
    instance.productionDate,
  ),
  'expiryDate': const NullableDateOnlyConverter().toJson(instance.expiryDate),
  'supplierId': instance.supplierId,
};

const _$BatchStatusEnumMap = {
  BatchStatus.active: 'ACTIVE',
  BatchStatus.blocked: 'BLOCKED',
  BatchStatus.expired: 'EXPIRED',
  BatchStatus.quarantine: 'QUARANTINE',
};

_GoodsReceiptLineDto _$GoodsReceiptLineDtoFromJson(Map<String, dynamic> json) =>
    _GoodsReceiptLineDto(
      lineNo: (json['lineNo'] as num).toInt(),
      productId: (json['productId'] as num).toInt(),
      receivedQty: Quantity.fromJson(json['receivedQty'] as String),
      uomId: (json['uomId'] as num).toInt(),
      rejectedQty: Quantity.fromJson(json['rejectedQty'] as String),
      id: (json['id'] as num?)?.toInt(),
      productName: json['productName'] as String?,
      poLineId: (json['poLineId'] as num?)?.toInt(),
      orderedQty: json['orderedQty'] == null
          ? null
          : Quantity.fromJson(json['orderedQty'] as String),
      uomCode: json['uomCode'] as String?,
      batchNo: json['batchNo'] as String?,
      productionDate: const NullableDateOnlyConverter().fromJson(
        json['productionDate'] as String?,
      ),
      expiryDate: const NullableDateOnlyConverter().fromJson(
        json['expiryDate'] as String?,
      ),
      unitPrice: json['unitPrice'] == null
          ? null
          : Money.fromJson(json['unitPrice'] as String),
      currency: json['currency'] as String?,
      varianceNote: json['varianceNote'] as String?,
    );

Map<String, dynamic> _$GoodsReceiptLineDtoToJson(
  _GoodsReceiptLineDto instance,
) => <String, dynamic>{
  'lineNo': instance.lineNo,
  'productId': instance.productId,
  'receivedQty': instance.receivedQty.toJson(),
  'uomId': instance.uomId,
  'rejectedQty': instance.rejectedQty.toJson(),
  'id': instance.id,
  'productName': instance.productName,
  'poLineId': instance.poLineId,
  'orderedQty': instance.orderedQty?.toJson(),
  'uomCode': instance.uomCode,
  'batchNo': instance.batchNo,
  'productionDate': const NullableDateOnlyConverter().toJson(
    instance.productionDate,
  ),
  'expiryDate': const NullableDateOnlyConverter().toJson(instance.expiryDate),
  'unitPrice': instance.unitPrice?.toJson(),
  'currency': instance.currency,
  'varianceNote': instance.varianceNote,
};

_GoodsReceiptDto _$GoodsReceiptDtoFromJson(Map<String, dynamic> json) =>
    _GoodsReceiptDto(
      id: (json['id'] as num).toInt(),
      docNo: json['docNo'] as String,
      docDate: const DateOnlyConverter().fromJson(json['docDate'] as String),
      supplierId: (json['supplierId'] as num).toInt(),
      locationId: (json['locationId'] as num).toInt(),
      qualityStatus: $enumDecode(_$QualityStatusEnumMap, json['qualityStatus']),
      status: $enumDecode(_$ReceiptStatusEnumMap, json['status']),
      poId: (json['poId'] as num?)?.toInt(),
      poDocNo: json['poDocNo'] as String?,
      supplierName: json['supplierName'] as String?,
      locationName: json['locationName'] as String?,
      temperatureC: json['temperatureC'] == null
          ? null
          : Decimal.fromJson(json['temperatureC'] as String),
      packagingNote: json['packagingNote'] as String?,
      movementGroupId: (json['movementGroupId'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      rowVersion: (json['rowVersion'] as num?)?.toInt() ?? 1,
      lines:
          (json['lines'] as List<dynamic>?)
              ?.map(
                (e) => GoodsReceiptLineDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <GoodsReceiptLineDto>[],
    );

Map<String, dynamic> _$GoodsReceiptDtoToJson(_GoodsReceiptDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'docNo': instance.docNo,
      'docDate': const DateOnlyConverter().toJson(instance.docDate),
      'supplierId': instance.supplierId,
      'locationId': instance.locationId,
      'qualityStatus': _$QualityStatusEnumMap[instance.qualityStatus]!,
      'status': _$ReceiptStatusEnumMap[instance.status]!,
      'poId': instance.poId,
      'poDocNo': instance.poDocNo,
      'supplierName': instance.supplierName,
      'locationName': instance.locationName,
      'temperatureC': instance.temperatureC?.toJson(),
      'packagingNote': instance.packagingNote,
      'movementGroupId': instance.movementGroupId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'rowVersion': instance.rowVersion,
      'lines': instance.lines.map((e) => e.toJson()).toList(),
    };

const _$QualityStatusEnumMap = {
  QualityStatus.accepted: 'ACCEPTED',
  QualityStatus.partiallyAccepted: 'PARTIALLY_ACCEPTED',
  QualityStatus.rejected: 'REJECTED',
};

const _$ReceiptStatusEnumMap = {
  ReceiptStatus.draft: 'DRAFT',
  ReceiptStatus.posted: 'POSTED',
  ReceiptStatus.cancelled: 'CANCELLED',
};

_CreateGoodsReceiptLine _$CreateGoodsReceiptLineFromJson(
  Map<String, dynamic> json,
) => _CreateGoodsReceiptLine(
  productId: (json['productId'] as num).toInt(),
  receivedQty: Quantity.fromJson(json['receivedQty'] as String),
  uomId: (json['uomId'] as num).toInt(),
  poLineId: (json['poLineId'] as num?)?.toInt(),
  orderedQty: json['orderedQty'] == null
      ? null
      : Quantity.fromJson(json['orderedQty'] as String),
  rejectedQty: json['rejectedQty'] == null
      ? null
      : Quantity.fromJson(json['rejectedQty'] as String),
  batchNo: json['batchNo'] as String?,
  productionDate: const NullableDateOnlyConverter().fromJson(
    json['productionDate'] as String?,
  ),
  expiryDate: const NullableDateOnlyConverter().fromJson(
    json['expiryDate'] as String?,
  ),
  unitPrice: json['unitPrice'] == null
      ? null
      : Money.fromJson(json['unitPrice'] as String),
  currency: json['currency'] as String?,
  varianceNote: json['varianceNote'] as String?,
);

Map<String, dynamic> _$CreateGoodsReceiptLineToJson(
  _CreateGoodsReceiptLine instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'receivedQty': instance.receivedQty.toJson(),
  'uomId': instance.uomId,
  'poLineId': instance.poLineId,
  'orderedQty': instance.orderedQty?.toJson(),
  'rejectedQty': instance.rejectedQty?.toJson(),
  'batchNo': instance.batchNo,
  'productionDate': const NullableDateOnlyConverter().toJson(
    instance.productionDate,
  ),
  'expiryDate': const NullableDateOnlyConverter().toJson(instance.expiryDate),
  'unitPrice': instance.unitPrice?.toJson(),
  'currency': instance.currency,
  'varianceNote': instance.varianceNote,
};

_CreateGoodsReceiptRequest _$CreateGoodsReceiptRequestFromJson(
  Map<String, dynamic> json,
) => _CreateGoodsReceiptRequest(
  docDate: const DateOnlyConverter().fromJson(json['docDate'] as String),
  supplierId: (json['supplierId'] as num).toInt(),
  locationId: (json['locationId'] as num).toInt(),
  qualityStatus: $enumDecode(_$QualityStatusEnumMap, json['qualityStatus']),
  lines: (json['lines'] as List<dynamic>)
      .map((e) => CreateGoodsReceiptLine.fromJson(e as Map<String, dynamic>))
      .toList(),
  poId: (json['poId'] as num?)?.toInt(),
  temperatureC: json['temperatureC'] == null
      ? null
      : Decimal.fromJson(json['temperatureC'] as String),
  packagingNote: json['packagingNote'] as String?,
);

Map<String, dynamic> _$CreateGoodsReceiptRequestToJson(
  _CreateGoodsReceiptRequest instance,
) => <String, dynamic>{
  'docDate': const DateOnlyConverter().toJson(instance.docDate),
  'supplierId': instance.supplierId,
  'locationId': instance.locationId,
  'qualityStatus': _$QualityStatusEnumMap[instance.qualityStatus]!,
  'lines': instance.lines.map((e) => e.toJson()).toList(),
  'poId': instance.poId,
  'temperatureC': instance.temperatureC?.toJson(),
  'packagingNote': instance.packagingNote,
};

_StockRequestLineDto _$StockRequestLineDtoFromJson(Map<String, dynamic> json) =>
    _StockRequestLineDto(
      lineNo: (json['lineNo'] as num).toInt(),
      productId: (json['productId'] as num).toInt(),
      qty: Quantity.fromJson(json['qty'] as String),
      uomId: (json['uomId'] as num).toInt(),
      issuedQty: Quantity.fromJson(json['issuedQty'] as String),
      productName: json['productName'] as String?,
      uomCode: json['uomCode'] as String?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$StockRequestLineDtoToJson(
  _StockRequestLineDto instance,
) => <String, dynamic>{
  'lineNo': instance.lineNo,
  'productId': instance.productId,
  'qty': instance.qty.toJson(),
  'uomId': instance.uomId,
  'issuedQty': instance.issuedQty.toJson(),
  'productName': instance.productName,
  'uomCode': instance.uomCode,
  'note': instance.note,
};

_StockRequestDto _$StockRequestDtoFromJson(Map<String, dynamic> json) =>
    _StockRequestDto(
      id: (json['id'] as num).toInt(),
      docNo: json['docNo'] as String,
      docDate: const DateOnlyConverter().fromJson(json['docDate'] as String),
      fromLocationId: (json['fromLocationId'] as num).toInt(),
      toLocationId: (json['toLocationId'] as num).toInt(),
      status: $enumDecode(_$StockRequestStatusEnumMap, json['status']),
      fromLocationName: json['fromLocationName'] as String?,
      toLocationName: json['toLocationName'] as String?,
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
                (e) => StockRequestLineDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <StockRequestLineDto>[],
    );

Map<String, dynamic> _$StockRequestDtoToJson(_StockRequestDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'docNo': instance.docNo,
      'docDate': const DateOnlyConverter().toJson(instance.docDate),
      'fromLocationId': instance.fromLocationId,
      'toLocationId': instance.toLocationId,
      'status': _$StockRequestStatusEnumMap[instance.status]!,
      'fromLocationName': instance.fromLocationName,
      'toLocationName': instance.toLocationName,
      'requiredDate': const NullableDateOnlyConverter().toJson(
        instance.requiredDate,
      ),
      'note': instance.note,
      'createdAt': instance.createdAt?.toIso8601String(),
      'rowVersion': instance.rowVersion,
      'lines': instance.lines.map((e) => e.toJson()).toList(),
    };

const _$StockRequestStatusEnumMap = {
  StockRequestStatus.draft: 'DRAFT',
  StockRequestStatus.submitted: 'SUBMITTED',
  StockRequestStatus.picking: 'PICKING',
  StockRequestStatus.partiallyIssued: 'PARTIALLY_ISSUED',
  StockRequestStatus.issued: 'ISSUED',
  StockRequestStatus.cancelled: 'CANCELLED',
  StockRequestStatus.closed: 'CLOSED',
};

_CreateStockRequestLine _$CreateStockRequestLineFromJson(
  Map<String, dynamic> json,
) => _CreateStockRequestLine(
  productId: (json['productId'] as num).toInt(),
  qty: Quantity.fromJson(json['qty'] as String),
  uomId: (json['uomId'] as num).toInt(),
  note: json['note'] as String?,
);

Map<String, dynamic> _$CreateStockRequestLineToJson(
  _CreateStockRequestLine instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'qty': instance.qty.toJson(),
  'uomId': instance.uomId,
  'note': instance.note,
};

_CreateStockRequestRequest _$CreateStockRequestRequestFromJson(
  Map<String, dynamic> json,
) => _CreateStockRequestRequest(
  docDate: const DateOnlyConverter().fromJson(json['docDate'] as String),
  fromLocationId: (json['fromLocationId'] as num).toInt(),
  toLocationId: (json['toLocationId'] as num).toInt(),
  lines: (json['lines'] as List<dynamic>)
      .map((e) => CreateStockRequestLine.fromJson(e as Map<String, dynamic>))
      .toList(),
  requiredDate: const NullableDateOnlyConverter().fromJson(
    json['requiredDate'] as String?,
  ),
  note: json['note'] as String?,
);

Map<String, dynamic> _$CreateStockRequestRequestToJson(
  _CreateStockRequestRequest instance,
) => <String, dynamic>{
  'docDate': const DateOnlyConverter().toJson(instance.docDate),
  'fromLocationId': instance.fromLocationId,
  'toLocationId': instance.toLocationId,
  'lines': instance.lines.map((e) => e.toJson()).toList(),
  'requiredDate': const NullableDateOnlyConverter().toJson(
    instance.requiredDate,
  ),
  'note': instance.note,
};

_IssueLineDto _$IssueLineDtoFromJson(Map<String, dynamic> json) =>
    _IssueLineDto(
      lineNo: (json['lineNo'] as num).toInt(),
      productId: (json['productId'] as num).toInt(),
      qty: Quantity.fromJson(json['qty'] as String),
      uomId: (json['uomId'] as num).toInt(),
      productName: json['productName'] as String?,
      batchId: (json['batchId'] as num?)?.toInt(),
      batchNo: json['batchNo'] as String?,
      uomCode: json['uomCode'] as String?,
      receivedQty: json['receivedQty'] == null
          ? null
          : Quantity.fromJson(json['receivedQty'] as String),
      reasonCodeId: (json['reasonCodeId'] as num?)?.toInt(),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$IssueLineDtoToJson(_IssueLineDto instance) =>
    <String, dynamic>{
      'lineNo': instance.lineNo,
      'productId': instance.productId,
      'qty': instance.qty.toJson(),
      'uomId': instance.uomId,
      'productName': instance.productName,
      'batchId': instance.batchId,
      'batchNo': instance.batchNo,
      'uomCode': instance.uomCode,
      'receivedQty': instance.receivedQty?.toJson(),
      'reasonCodeId': instance.reasonCodeId,
      'note': instance.note,
    };

_IssueDto _$IssueDtoFromJson(Map<String, dynamic> json) => _IssueDto(
  id: (json['id'] as num).toInt(),
  docNo: json['docNo'] as String,
  docDate: const DateOnlyConverter().fromJson(json['docDate'] as String),
  issueType: $enumDecode(_$IssueTypeEnumMap, json['issueType']),
  fromLocationId: (json['fromLocationId'] as num).toInt(),
  toLocationId: (json['toLocationId'] as num).toInt(),
  status: $enumDecode(_$IssueStatusEnumMap, json['status']),
  fromLocationName: json['fromLocationName'] as String?,
  toLocationName: json['toLocationName'] as String?,
  requestId: (json['requestId'] as num?)?.toInt(),
  dispatchGroupId: (json['dispatchGroupId'] as num?)?.toInt(),
  receiptGroupId: (json['receiptGroupId'] as num?)?.toInt(),
  dispatchedAt: json['dispatchedAt'] == null
      ? null
      : DateTime.parse(json['dispatchedAt'] as String),
  receivedAt: json['receivedAt'] == null
      ? null
      : DateTime.parse(json['receivedAt'] as String),
  receivedBy: (json['receivedBy'] as num?)?.toInt(),
  rowVersion: (json['rowVersion'] as num?)?.toInt() ?? 1,
  lines:
      (json['lines'] as List<dynamic>?)
          ?.map((e) => IssueLineDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <IssueLineDto>[],
);

Map<String, dynamic> _$IssueDtoToJson(_IssueDto instance) => <String, dynamic>{
  'id': instance.id,
  'docNo': instance.docNo,
  'docDate': const DateOnlyConverter().toJson(instance.docDate),
  'issueType': _$IssueTypeEnumMap[instance.issueType]!,
  'fromLocationId': instance.fromLocationId,
  'toLocationId': instance.toLocationId,
  'status': _$IssueStatusEnumMap[instance.status]!,
  'fromLocationName': instance.fromLocationName,
  'toLocationName': instance.toLocationName,
  'requestId': instance.requestId,
  'dispatchGroupId': instance.dispatchGroupId,
  'receiptGroupId': instance.receiptGroupId,
  'dispatchedAt': instance.dispatchedAt?.toIso8601String(),
  'receivedAt': instance.receivedAt?.toIso8601String(),
  'receivedBy': instance.receivedBy,
  'rowVersion': instance.rowVersion,
  'lines': instance.lines.map((e) => e.toJson()).toList(),
};

const _$IssueTypeEnumMap = {
  IssueType.branchIssue: 'BRANCH_ISSUE',
  IssueType.whTransfer: 'WH_TRANSFER',
  IssueType.branchTransfer: 'BRANCH_TRANSFER',
};

const _$IssueStatusEnumMap = {
  IssueStatus.draft: 'DRAFT',
  IssueStatus.dispatched: 'DISPATCHED',
  IssueStatus.received: 'RECEIVED',
  IssueStatus.discrepancy: 'DISCREPANCY',
  IssueStatus.cancelled: 'CANCELLED',
};

_CreateIssueLine _$CreateIssueLineFromJson(Map<String, dynamic> json) =>
    _CreateIssueLine(
      productId: (json['productId'] as num).toInt(),
      qty: Quantity.fromJson(json['qty'] as String),
      uomId: (json['uomId'] as num).toInt(),
      batchId: (json['batchId'] as num?)?.toInt(),
      reasonCodeId: (json['reasonCodeId'] as num?)?.toInt(),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$CreateIssueLineToJson(_CreateIssueLine instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'qty': instance.qty.toJson(),
      'uomId': instance.uomId,
      'batchId': instance.batchId,
      'reasonCodeId': instance.reasonCodeId,
      'note': instance.note,
    };

_CreateIssueRequest _$CreateIssueRequestFromJson(Map<String, dynamic> json) =>
    _CreateIssueRequest(
      docDate: const DateOnlyConverter().fromJson(json['docDate'] as String),
      issueType: $enumDecode(_$IssueTypeEnumMap, json['issueType']),
      fromLocationId: (json['fromLocationId'] as num).toInt(),
      toLocationId: (json['toLocationId'] as num).toInt(),
      lines: (json['lines'] as List<dynamic>)
          .map((e) => CreateIssueLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      requestId: (json['requestId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CreateIssueRequestToJson(_CreateIssueRequest instance) =>
    <String, dynamic>{
      'docDate': const DateOnlyConverter().toJson(instance.docDate),
      'issueType': _$IssueTypeEnumMap[instance.issueType]!,
      'fromLocationId': instance.fromLocationId,
      'toLocationId': instance.toLocationId,
      'lines': instance.lines.map((e) => e.toJson()).toList(),
      'requestId': instance.requestId,
    };

_ConfirmIssueLine _$ConfirmIssueLineFromJson(Map<String, dynamic> json) =>
    _ConfirmIssueLine(
      lineNo: (json['lineNo'] as num).toInt(),
      receivedQty: Quantity.fromJson(json['receivedQty'] as String),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$ConfirmIssueLineToJson(_ConfirmIssueLine instance) =>
    <String, dynamic>{
      'lineNo': instance.lineNo,
      'receivedQty': instance.receivedQty.toJson(),
      'note': instance.note,
    };

_ConfirmIssueRequest _$ConfirmIssueRequestFromJson(Map<String, dynamic> json) =>
    _ConfirmIssueRequest(
      lines: (json['lines'] as List<dynamic>)
          .map((e) => ConfirmIssueLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      rowVersion: (json['rowVersion'] as num).toInt(),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$ConfirmIssueRequestToJson(
  _ConfirmIssueRequest instance,
) => <String, dynamic>{
  'lines': instance.lines.map((e) => e.toJson()).toList(),
  'rowVersion': instance.rowVersion,
  'note': instance.note,
};

_CountLineDto _$CountLineDtoFromJson(Map<String, dynamic> json) =>
    _CountLineDto(
      id: (json['id'] as num).toInt(),
      productId: (json['productId'] as num).toInt(),
      bookQty: Quantity.fromJson(json['bookQty'] as String),
      productName: json['productName'] as String?,
      baseUomCode: json['baseUomCode'] as String?,
      batchId: (json['batchId'] as num?)?.toInt(),
      batchNo: json['batchNo'] as String?,
      countedQty: json['countedQty'] == null
          ? null
          : Quantity.fromJson(json['countedQty'] as String),
      varianceQty: json['varianceQty'] == null
          ? null
          : Quantity.fromJson(json['varianceQty'] as String),
      variancePct: json['variancePct'] == null
          ? null
          : Decimal.fromJson(json['variancePct'] as String),
      reasonCodeId: (json['reasonCodeId'] as num?)?.toInt(),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$CountLineDtoToJson(_CountLineDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'bookQty': instance.bookQty.toJson(),
      'productName': instance.productName,
      'baseUomCode': instance.baseUomCode,
      'batchId': instance.batchId,
      'batchNo': instance.batchNo,
      'countedQty': instance.countedQty?.toJson(),
      'varianceQty': instance.varianceQty?.toJson(),
      'variancePct': instance.variancePct?.toJson(),
      'reasonCodeId': instance.reasonCodeId,
      'note': instance.note,
    };

_CountDto _$CountDtoFromJson(Map<String, dynamic> json) => _CountDto(
  id: (json['id'] as num).toInt(),
  docNo: json['docNo'] as String,
  locationId: (json['locationId'] as num).toInt(),
  countType: $enumDecode(_$CountTypeEnumMap, json['countType']),
  status: $enumDecode(_$CountStatusEnumMap, json['status']),
  locationName: json['locationName'] as String?,
  frozenAt: json['frozenAt'] == null
      ? null
      : DateTime.parse(json['frozenAt'] as String),
  approvedBy: (json['approvedBy'] as num?)?.toInt(),
  approvedAt: json['approvedAt'] == null
      ? null
      : DateTime.parse(json['approvedAt'] as String),
  adjustGroupId: (json['adjustGroupId'] as num?)?.toInt(),
  rowVersion: (json['rowVersion'] as num?)?.toInt() ?? 1,
  lines:
      (json['lines'] as List<dynamic>?)
          ?.map((e) => CountLineDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CountLineDto>[],
);

Map<String, dynamic> _$CountDtoToJson(_CountDto instance) => <String, dynamic>{
  'id': instance.id,
  'docNo': instance.docNo,
  'locationId': instance.locationId,
  'countType': _$CountTypeEnumMap[instance.countType]!,
  'status': _$CountStatusEnumMap[instance.status]!,
  'locationName': instance.locationName,
  'frozenAt': instance.frozenAt?.toIso8601String(),
  'approvedBy': instance.approvedBy,
  'approvedAt': instance.approvedAt?.toIso8601String(),
  'adjustGroupId': instance.adjustGroupId,
  'rowVersion': instance.rowVersion,
  'lines': instance.lines.map((e) => e.toJson()).toList(),
};

const _$CountTypeEnumMap = {
  CountType.full: 'FULL',
  CountType.cycle: 'CYCLE',
  CountType.spot: 'SPOT',
};

const _$CountStatusEnumMap = {
  CountStatus.draft: 'DRAFT',
  CountStatus.frozen: 'FROZEN',
  CountStatus.counting: 'COUNTING',
  CountStatus.review: 'REVIEW',
  CountStatus.approved: 'APPROVED',
  CountStatus.posted: 'POSTED',
  CountStatus.cancelled: 'CANCELLED',
};

_CreateCountRequest _$CreateCountRequestFromJson(Map<String, dynamic> json) =>
    _CreateCountRequest(
      locationId: (json['locationId'] as num).toInt(),
      countType: $enumDecode(_$CountTypeEnumMap, json['countType']),
    );

Map<String, dynamic> _$CreateCountRequestToJson(_CreateCountRequest instance) =>
    <String, dynamic>{
      'locationId': instance.locationId,
      'countType': _$CountTypeEnumMap[instance.countType]!,
    };

_EnterCountLine _$EnterCountLineFromJson(Map<String, dynamic> json) =>
    _EnterCountLine(
      lineId: (json['lineId'] as num).toInt(),
      countedQty: Quantity.fromJson(json['countedQty'] as String),
      reasonCodeId: (json['reasonCodeId'] as num?)?.toInt(),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$EnterCountLineToJson(_EnterCountLine instance) =>
    <String, dynamic>{
      'lineId': instance.lineId,
      'countedQty': instance.countedQty.toJson(),
      'reasonCodeId': instance.reasonCodeId,
      'note': instance.note,
    };

_EnterCountRequest _$EnterCountRequestFromJson(Map<String, dynamic> json) =>
    _EnterCountRequest(
      lines: (json['lines'] as List<dynamic>)
          .map((e) => EnterCountLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      rowVersion: (json['rowVersion'] as num).toInt(),
    );

Map<String, dynamic> _$EnterCountRequestToJson(_EnterCountRequest instance) =>
    <String, dynamic>{
      'lines': instance.lines.map((e) => e.toJson()).toList(),
      'rowVersion': instance.rowVersion,
    };

_WasteLineDto _$WasteLineDtoFromJson(Map<String, dynamic> json) =>
    _WasteLineDto(
      lineNo: (json['lineNo'] as num).toInt(),
      productId: (json['productId'] as num).toInt(),
      qty: Quantity.fromJson(json['qty'] as String),
      uomId: (json['uomId'] as num).toInt(),
      productName: json['productName'] as String?,
      batchId: (json['batchId'] as num?)?.toInt(),
      batchNo: json['batchNo'] as String?,
      uomCode: json['uomCode'] as String?,
      unitCost: json['unitCost'] == null
          ? null
          : Money.fromJson(json['unitCost'] as String),
      lineValue: json['lineValue'] == null
          ? null
          : Money.fromJson(json['lineValue'] as String),
    );

Map<String, dynamic> _$WasteLineDtoToJson(_WasteLineDto instance) =>
    <String, dynamic>{
      'lineNo': instance.lineNo,
      'productId': instance.productId,
      'qty': instance.qty.toJson(),
      'uomId': instance.uomId,
      'productName': instance.productName,
      'batchId': instance.batchId,
      'batchNo': instance.batchNo,
      'uomCode': instance.uomCode,
      'unitCost': instance.unitCost?.toJson(),
      'lineValue': instance.lineValue?.toJson(),
    };

_WasteDto _$WasteDtoFromJson(Map<String, dynamic> json) => _WasteDto(
  id: (json['id'] as num).toInt(),
  docNo: json['docNo'] as String,
  docDate: const DateOnlyConverter().fromJson(json['docDate'] as String),
  locationId: (json['locationId'] as num).toInt(),
  reasonCodeId: (json['reasonCodeId'] as num).toInt(),
  status: $enumDecode(_$WasteStatusEnumMap, json['status']),
  locationName: json['locationName'] as String?,
  reasonCodeName: json['reasonCodeName'] as String?,
  note: json['note'] as String?,
  approvedBy: (json['approvedBy'] as num?)?.toInt(),
  approvedAt: json['approvedAt'] == null
      ? null
      : DateTime.parse(json['approvedAt'] as String),
  movementGroupId: (json['movementGroupId'] as num?)?.toInt(),
  attachmentIds:
      (json['attachmentIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const <int>[],
  rowVersion: (json['rowVersion'] as num?)?.toInt() ?? 1,
  lines:
      (json['lines'] as List<dynamic>?)
          ?.map((e) => WasteLineDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <WasteLineDto>[],
);

Map<String, dynamic> _$WasteDtoToJson(_WasteDto instance) => <String, dynamic>{
  'id': instance.id,
  'docNo': instance.docNo,
  'docDate': const DateOnlyConverter().toJson(instance.docDate),
  'locationId': instance.locationId,
  'reasonCodeId': instance.reasonCodeId,
  'status': _$WasteStatusEnumMap[instance.status]!,
  'locationName': instance.locationName,
  'reasonCodeName': instance.reasonCodeName,
  'note': instance.note,
  'approvedBy': instance.approvedBy,
  'approvedAt': instance.approvedAt?.toIso8601String(),
  'movementGroupId': instance.movementGroupId,
  'attachmentIds': instance.attachmentIds,
  'rowVersion': instance.rowVersion,
  'lines': instance.lines.map((e) => e.toJson()).toList(),
};

const _$WasteStatusEnumMap = {
  WasteStatus.draft: 'DRAFT',
  WasteStatus.pendingApproval: 'PENDING_APPROVAL',
  WasteStatus.approved: 'APPROVED',
  WasteStatus.posted: 'POSTED',
  WasteStatus.rejected: 'REJECTED',
};

_CreateWasteLine _$CreateWasteLineFromJson(Map<String, dynamic> json) =>
    _CreateWasteLine(
      productId: (json['productId'] as num).toInt(),
      qty: Quantity.fromJson(json['qty'] as String),
      uomId: (json['uomId'] as num).toInt(),
      batchId: (json['batchId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CreateWasteLineToJson(_CreateWasteLine instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'qty': instance.qty.toJson(),
      'uomId': instance.uomId,
      'batchId': instance.batchId,
    };

_CreateWasteRequest _$CreateWasteRequestFromJson(Map<String, dynamic> json) =>
    _CreateWasteRequest(
      docDate: const DateOnlyConverter().fromJson(json['docDate'] as String),
      locationId: (json['locationId'] as num).toInt(),
      reasonCodeId: (json['reasonCodeId'] as num).toInt(),
      lines: (json['lines'] as List<dynamic>)
          .map((e) => CreateWasteLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      note: json['note'] as String?,
      attachmentIds:
          (json['attachmentIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const <int>[],
    );

Map<String, dynamic> _$CreateWasteRequestToJson(_CreateWasteRequest instance) =>
    <String, dynamic>{
      'docDate': const DateOnlyConverter().toJson(instance.docDate),
      'locationId': instance.locationId,
      'reasonCodeId': instance.reasonCodeId,
      'lines': instance.lines.map((e) => e.toJson()).toList(),
      'note': instance.note,
      'attachmentIds': instance.attachmentIds,
    };

_SampleLineDto _$SampleLineDtoFromJson(Map<String, dynamic> json) =>
    _SampleLineDto(
      lineNo: (json['lineNo'] as num).toInt(),
      productId: (json['productId'] as num).toInt(),
      qty: Quantity.fromJson(json['qty'] as String),
      uomId: (json['uomId'] as num).toInt(),
      productName: json['productName'] as String?,
      batchId: (json['batchId'] as num?)?.toInt(),
      batchNo: json['batchNo'] as String?,
      uomCode: json['uomCode'] as String?,
    );

Map<String, dynamic> _$SampleLineDtoToJson(_SampleLineDto instance) =>
    <String, dynamic>{
      'lineNo': instance.lineNo,
      'productId': instance.productId,
      'qty': instance.qty.toJson(),
      'uomId': instance.uomId,
      'productName': instance.productName,
      'batchId': instance.batchId,
      'batchNo': instance.batchNo,
      'uomCode': instance.uomCode,
    };

_SampleDto _$SampleDtoFromJson(Map<String, dynamic> json) => _SampleDto(
  id: (json['id'] as num).toInt(),
  docNo: json['docNo'] as String,
  docDate: const DateOnlyConverter().fromJson(json['docDate'] as String),
  locationId: (json['locationId'] as num).toInt(),
  authority: json['authority'] as String? ?? 'AQTA',
  locationName: json['locationName'] as String?,
  purpose: json['purpose'] as String?,
  movementGroupId: (json['movementGroupId'] as num?)?.toInt(),
  lines:
      (json['lines'] as List<dynamic>?)
          ?.map((e) => SampleLineDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SampleLineDto>[],
);

Map<String, dynamic> _$SampleDtoToJson(_SampleDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'docNo': instance.docNo,
      'docDate': const DateOnlyConverter().toJson(instance.docDate),
      'locationId': instance.locationId,
      'authority': instance.authority,
      'locationName': instance.locationName,
      'purpose': instance.purpose,
      'movementGroupId': instance.movementGroupId,
      'lines': instance.lines.map((e) => e.toJson()).toList(),
    };

_CreateSampleLine _$CreateSampleLineFromJson(Map<String, dynamic> json) =>
    _CreateSampleLine(
      productId: (json['productId'] as num).toInt(),
      qty: Quantity.fromJson(json['qty'] as String),
      uomId: (json['uomId'] as num).toInt(),
      batchId: (json['batchId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CreateSampleLineToJson(_CreateSampleLine instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'qty': instance.qty.toJson(),
      'uomId': instance.uomId,
      'batchId': instance.batchId,
    };

_CreateSampleRequest _$CreateSampleRequestFromJson(Map<String, dynamic> json) =>
    _CreateSampleRequest(
      docDate: const DateOnlyConverter().fromJson(json['docDate'] as String),
      locationId: (json['locationId'] as num).toInt(),
      lines: (json['lines'] as List<dynamic>)
          .map((e) => CreateSampleLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      authority: json['authority'] as String? ?? 'AQTA',
      purpose: json['purpose'] as String?,
    );

Map<String, dynamic> _$CreateSampleRequestToJson(
  _CreateSampleRequest instance,
) => <String, dynamic>{
  'docDate': const DateOnlyConverter().toJson(instance.docDate),
  'locationId': instance.locationId,
  'lines': instance.lines.map((e) => e.toJson()).toList(),
  'authority': instance.authority,
  'purpose': instance.purpose,
};

_VersionedActionRequest _$VersionedActionRequestFromJson(
  Map<String, dynamic> json,
) => _VersionedActionRequest(
  rowVersion: (json['rowVersion'] as num).toInt(),
  comment: json['comment'] as String?,
);

Map<String, dynamic> _$VersionedActionRequestToJson(
  _VersionedActionRequest instance,
) => <String, dynamic>{
  'rowVersion': instance.rowVersion,
  'comment': instance.comment,
};

_InventorySettingDto _$InventorySettingDtoFromJson(Map<String, dynamic> json) =>
    _InventorySettingDto(
      key: json['key'] as String,
      value: json['value'] as String,
      valueType: $enumDecode(_$SettingValueTypeEnumMap, json['valueType']),
      allowedValues:
          (json['allowedValues'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      description: json['description'] as String?,
    );

Map<String, dynamic> _$InventorySettingDtoToJson(
  _InventorySettingDto instance,
) => <String, dynamic>{
  'key': instance.key,
  'value': instance.value,
  'valueType': _$SettingValueTypeEnumMap[instance.valueType]!,
  'allowedValues': instance.allowedValues,
  'description': instance.description,
};

const _$SettingValueTypeEnumMap = {
  SettingValueType.intValue: 'INT',
  SettingValueType.decimalValue: 'DECIMAL',
  SettingValueType.boolValue: 'BOOL',
  SettingValueType.enumValue: 'ENUM',
};

_UpdateInventorySettingRequest _$UpdateInventorySettingRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateInventorySettingRequest(value: json['value'] as String);

Map<String, dynamic> _$UpdateInventorySettingRequestToJson(
  _UpdateInventorySettingRequest instance,
) => <String, dynamic>{'value': instance.value};
