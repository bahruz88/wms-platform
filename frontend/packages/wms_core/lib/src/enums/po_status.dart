import 'package:json_annotation/json_annotation.dart';

/// `proc_purchase_order.status` (spec §10).
enum PoStatus {
  @JsonValue('DRAFT')
  draft('DRAFT'),
  @JsonValue('PENDING_APPROVAL')
  pendingApproval('PENDING_APPROVAL'),
  @JsonValue('APPROVED')
  approved('APPROVED'),
  @JsonValue('REJECTED')
  rejected('REJECTED'),
  @JsonValue('SENT_TO_SUPPLIER')
  sentToSupplier('SENT_TO_SUPPLIER'),
  @JsonValue('PARTIALLY_RECEIVED')
  partiallyReceived('PARTIALLY_RECEIVED'),
  @JsonValue('FULLY_RECEIVED')
  fullyReceived('FULLY_RECEIVED'),
  @JsonValue('CLOSED')
  closed('CLOSED'),
  @JsonValue('CANCELLED')
  cancelled('CANCELLED');

  const PoStatus(this.wire);

  final String wire;

  bool get canApprove => this == PoStatus.pendingApproval;
  bool get canReceive =>
      this == PoStatus.sentToSupplier || this == PoStatus.partiallyReceived;

  static PoStatus fromWire(String value) =>
      values.firstWhere((e) => e.wire == value);
}
