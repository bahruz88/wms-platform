import 'package:json_annotation/json_annotation.dart';

/// `inv_movement_group.doc_type` (spec §9.3).
enum DocType {
  @JsonValue('RECEIPT')
  receipt('RECEIPT', 'GR'),
  @JsonValue('ISSUE')
  issue('ISSUE', 'IS'),
  @JsonValue('TRANSFER')
  transfer('TRANSFER', 'IS'),
  @JsonValue('COUNT_ADJUST')
  countAdjust('COUNT_ADJUST', 'IC'),
  @JsonValue('WASTE')
  waste('WASTE', 'WS'),
  @JsonValue('SAMPLE')
  sample('SAMPLE', 'SM'),
  @JsonValue('RETURN')
  returnToVendor('RETURN', 'RV'),
  @JsonValue('OPENING')
  opening('OPENING', 'OP'),

  /// Branch consumption (ADR-012): `CN-2026-00042`.
  @JsonValue('CONSUMPTION')
  consumption('CONSUMPTION', 'CN'),
  @JsonValue('REVERSAL')
  reversal('REVERSAL', 'RE');

  const DocType(this.wire, this.numberPrefix);

  /// Value on the wire (`RECEIPT`).
  final String wire;

  /// Document number prefix (spec appendix B: `GR-2026-00311`).
  final String numberPrefix;

  static DocType fromWire(String value) =>
      values.firstWhere((e) => e.wire == value);
}
