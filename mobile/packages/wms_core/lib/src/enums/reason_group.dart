import 'package:json_annotation/json_annotation.dart';

/// `master_reason_code.reason_group` (spec §8).
enum ReasonGroup {
  @JsonValue('WASTE')
  waste('WASTE'),
  @JsonValue('ADJUSTMENT')
  adjustment('ADJUSTMENT'),
  @JsonValue('RETURN')
  returnToVendor('RETURN'),
  @JsonValue('SAMPLE')
  sample('SAMPLE'),
  @JsonValue('TRANSFER')
  transfer('TRANSFER');

  const ReasonGroup(this.wire);

  final String wire;

  static ReasonGroup fromWire(String value) =>
      values.firstWhere((e) => e.wire == value);
}
