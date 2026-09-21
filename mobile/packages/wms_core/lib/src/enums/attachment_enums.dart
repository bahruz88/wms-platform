import 'package:json_annotation/json_annotation.dart';

/// `common_attachment.entity_type` - the document an attachment belongs to
/// (documents.v1.yaml `EntityType`).
enum AttachmentEntityType {
  @JsonValue('PRODUCT')
  product('PRODUCT'),
  @JsonValue('SUPPLIER')
  supplier('SUPPLIER'),
  @JsonValue('SUPPLIER_CERTIFICATE')
  supplierCertificate('SUPPLIER_CERTIFICATE'),
  @JsonValue('GOODS_RECEIPT')
  goodsReceipt('GOODS_RECEIPT'),
  @JsonValue('ISSUE')
  issue('ISSUE'),
  @JsonValue('COUNT')
  count('COUNT'),
  @JsonValue('WASTE')
  waste('WASTE'),
  @JsonValue('SAMPLE')
  sample('SAMPLE'),
  @JsonValue('RETURN_TO_VENDOR')
  returnToVendor('RETURN_TO_VENDOR'),
  @JsonValue('REQUISITION')
  requisition('REQUISITION'),
  @JsonValue('RFQ')
  rfq('RFQ'),
  @JsonValue('QUOTATION')
  quotation('QUOTATION'),
  @JsonValue('PURCHASE_ORDER')
  purchaseOrder('PURCHASE_ORDER'),
  @JsonValue('USER')
  user('USER');

  const AttachmentEntityType(this.wire);

  final String wire;
}

/// `common_attachment.attachment_type` - content category.
enum AttachmentType {
  @JsonValue('QUOTATION')
  quotation('QUOTATION'),
  @JsonValue('INVOICE')
  invoice('INVOICE'),
  @JsonValue('DELIVERY_NOTE')
  deliveryNote('DELIVERY_NOTE'),
  @JsonValue('CERTIFICATE')
  certificate('CERTIFICATE'),
  @JsonValue('TEMP_PHOTO')
  tempPhoto('TEMP_PHOTO'),
  @JsonValue('WASTE_PHOTO')
  wastePhoto('WASTE_PHOTO'),
  @JsonValue('DISCREPANCY_PHOTO')
  discrepancyPhoto('DISCREPANCY_PHOTO'),
  @JsonValue('PRODUCT_IMAGE')
  productImage('PRODUCT_IMAGE'),
  @JsonValue('CONTRACT')
  contract('CONTRACT'),
  @JsonValue('OTHER')
  other('OTHER');

  const AttachmentType(this.wire);

  final String wire;
}

/// `common_attachment.status`: `PENDING` (presigned, object awaited),
/// `SCANNING` (ClamAV), `READY` (usable), `REJECTED` (checksum/scan failed).
/// Only `READY` attachments may be linked to a document.
enum AttachmentStatus {
  @JsonValue('PENDING')
  pending('PENDING'),
  @JsonValue('SCANNING')
  scanning('SCANNING'),
  @JsonValue('READY')
  ready('READY'),
  @JsonValue('REJECTED')
  rejected('REJECTED');

  const AttachmentStatus(this.wire);

  final String wire;

  /// The upload finished and the file may be referenced by a document.
  bool get isReady => this == AttachmentStatus.ready;

  /// The server is still working on it (`PENDING`, `SCANNING`).
  bool get isPending =>
      this == AttachmentStatus.pending || this == AttachmentStatus.scanning;
}
