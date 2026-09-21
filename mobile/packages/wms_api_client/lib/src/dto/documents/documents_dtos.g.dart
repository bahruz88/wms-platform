// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'documents_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttachmentDto _$AttachmentDtoFromJson(
  Map<String, dynamic> json,
) => _AttachmentDto(
  id: (json['id'] as num).toInt(),
  entityType: $enumDecode(_$AttachmentEntityTypeEnumMap, json['entityType']),
  attachmentType: $enumDecode(_$AttachmentTypeEnumMap, json['attachmentType']),
  fileName: json['fileName'] as String,
  contentType: json['contentType'] as String,
  sizeBytes: (json['sizeBytes'] as num).toInt(),
  status: $enumDecode(_$AttachmentStatusEnumMap, json['status']),
  uploadedBy: (json['uploadedBy'] as num).toInt(),
  uploadedAt: DateTime.parse(json['uploadedAt'] as String),
  entityId: (json['entityId'] as num?)?.toInt(),
  checksumSha256: json['checksumSha256'] as String?,
  scanResult: json['scanResult'] as String?,
  thumbnailAvailable: json['thumbnailAvailable'] as bool? ?? false,
);

Map<String, dynamic> _$AttachmentDtoToJson(_AttachmentDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'entityType': _$AttachmentEntityTypeEnumMap[instance.entityType]!,
      'attachmentType': _$AttachmentTypeEnumMap[instance.attachmentType]!,
      'fileName': instance.fileName,
      'contentType': instance.contentType,
      'sizeBytes': instance.sizeBytes,
      'status': _$AttachmentStatusEnumMap[instance.status]!,
      'uploadedBy': instance.uploadedBy,
      'uploadedAt': instance.uploadedAt.toIso8601String(),
      'entityId': instance.entityId,
      'checksumSha256': instance.checksumSha256,
      'scanResult': instance.scanResult,
      'thumbnailAvailable': instance.thumbnailAvailable,
    };

const _$AttachmentEntityTypeEnumMap = {
  AttachmentEntityType.product: 'PRODUCT',
  AttachmentEntityType.supplier: 'SUPPLIER',
  AttachmentEntityType.supplierCertificate: 'SUPPLIER_CERTIFICATE',
  AttachmentEntityType.goodsReceipt: 'GOODS_RECEIPT',
  AttachmentEntityType.issue: 'ISSUE',
  AttachmentEntityType.count: 'COUNT',
  AttachmentEntityType.waste: 'WASTE',
  AttachmentEntityType.sample: 'SAMPLE',
  AttachmentEntityType.returnToVendor: 'RETURN_TO_VENDOR',
  AttachmentEntityType.requisition: 'REQUISITION',
  AttachmentEntityType.rfq: 'RFQ',
  AttachmentEntityType.quotation: 'QUOTATION',
  AttachmentEntityType.purchaseOrder: 'PURCHASE_ORDER',
  AttachmentEntityType.user: 'USER',
};

const _$AttachmentTypeEnumMap = {
  AttachmentType.quotation: 'QUOTATION',
  AttachmentType.invoice: 'INVOICE',
  AttachmentType.deliveryNote: 'DELIVERY_NOTE',
  AttachmentType.certificate: 'CERTIFICATE',
  AttachmentType.tempPhoto: 'TEMP_PHOTO',
  AttachmentType.wastePhoto: 'WASTE_PHOTO',
  AttachmentType.discrepancyPhoto: 'DISCREPANCY_PHOTO',
  AttachmentType.productImage: 'PRODUCT_IMAGE',
  AttachmentType.contract: 'CONTRACT',
  AttachmentType.other: 'OTHER',
};

const _$AttachmentStatusEnumMap = {
  AttachmentStatus.pending: 'PENDING',
  AttachmentStatus.scanning: 'SCANNING',
  AttachmentStatus.ready: 'READY',
  AttachmentStatus.rejected: 'REJECTED',
};

_PresignAttachmentRequest _$PresignAttachmentRequestFromJson(
  Map<String, dynamic> json,
) => _PresignAttachmentRequest(
  entityType: $enumDecode(_$AttachmentEntityTypeEnumMap, json['entityType']),
  attachmentType: $enumDecode(_$AttachmentTypeEnumMap, json['attachmentType']),
  fileName: json['fileName'] as String,
  contentType: json['contentType'] as String,
  sizeBytes: (json['sizeBytes'] as num).toInt(),
  entityId: (json['entityId'] as num?)?.toInt(),
  checksumSha256: json['checksumSha256'] as String?,
);

Map<String, dynamic> _$PresignAttachmentRequestToJson(
  _PresignAttachmentRequest instance,
) => <String, dynamic>{
  'entityType': _$AttachmentEntityTypeEnumMap[instance.entityType]!,
  'attachmentType': _$AttachmentTypeEnumMap[instance.attachmentType]!,
  'fileName': instance.fileName,
  'contentType': instance.contentType,
  'sizeBytes': instance.sizeBytes,
  'entityId': instance.entityId,
  'checksumSha256': instance.checksumSha256,
};

_PresignAttachmentResponse _$PresignAttachmentResponseFromJson(
  Map<String, dynamic> json,
) => _PresignAttachmentResponse(
  attachmentId: (json['attachmentId'] as num).toInt(),
  uploadUrl: json['uploadUrl'] as String,
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  maxSizeBytes: (json['maxSizeBytes'] as num).toInt(),
  method: json['method'] as String? ?? 'PUT',
  uploadHeaders:
      (json['uploadHeaders'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
);

Map<String, dynamic> _$PresignAttachmentResponseToJson(
  _PresignAttachmentResponse instance,
) => <String, dynamic>{
  'attachmentId': instance.attachmentId,
  'uploadUrl': instance.uploadUrl,
  'expiresAt': instance.expiresAt.toIso8601String(),
  'maxSizeBytes': instance.maxSizeBytes,
  'method': instance.method,
  'uploadHeaders': instance.uploadHeaders,
};

_CompleteAttachmentRequest _$CompleteAttachmentRequestFromJson(
  Map<String, dynamic> json,
) => _CompleteAttachmentRequest(
  checksumSha256: json['checksumSha256'] as String,
  etag: json['etag'] as String?,
);

Map<String, dynamic> _$CompleteAttachmentRequestToJson(
  _CompleteAttachmentRequest instance,
) => <String, dynamic>{
  'checksumSha256': instance.checksumSha256,
  'etag': instance.etag,
};

_AttachmentDownloadUrlDto _$AttachmentDownloadUrlDtoFromJson(
  Map<String, dynamic> json,
) => _AttachmentDownloadUrlDto(
  downloadUrl: json['downloadUrl'] as String,
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  fileName: json['fileName'] as String,
  contentType: json['contentType'] as String,
  sizeBytes: (json['sizeBytes'] as num).toInt(),
);

Map<String, dynamic> _$AttachmentDownloadUrlDtoToJson(
  _AttachmentDownloadUrlDto instance,
) => <String, dynamic>{
  'downloadUrl': instance.downloadUrl,
  'expiresAt': instance.expiresAt.toIso8601String(),
  'fileName': instance.fileName,
  'contentType': instance.contentType,
  'sizeBytes': instance.sizeBytes,
};
