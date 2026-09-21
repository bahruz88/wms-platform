import 'package:json_annotation/json_annotation.dart';

/// `inv_batch.status` (spec §9.2).
enum BatchStatus {
  @JsonValue('ACTIVE')
  active('ACTIVE'),
  @JsonValue('BLOCKED')
  blocked('BLOCKED'),
  @JsonValue('EXPIRED')
  expired('EXPIRED'),
  @JsonValue('QUARANTINE')
  quarantine('QUARANTINE');

  const BatchStatus(this.wire);

  final String wire;

  /// Only active batches take part in FEFO/FIFO allocation (spec §12.4).
  bool get isAllocatable => this == BatchStatus.active;

  static BatchStatus fromWire(String value) =>
      values.firstWhere((e) => e.wire == value);
}
