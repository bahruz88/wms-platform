import 'package:json_annotation/json_annotation.dart';

/// `inv_count.status` (spec §9.6).
enum CountStatus {
  @JsonValue('DRAFT')
  draft('DRAFT'),
  @JsonValue('FROZEN')
  frozen('FROZEN'),
  @JsonValue('COUNTING')
  counting('COUNTING'),
  @JsonValue('REVIEW')
  review('REVIEW'),
  @JsonValue('APPROVED')
  approved('APPROVED'),
  @JsonValue('POSTED')
  posted('POSTED'),
  @JsonValue('CANCELLED')
  cancelled('CANCELLED');

  const CountStatus(this.wire);

  final String wire;

  /// While frozen/counting the location rejects movements (spec §12.7).
  bool get blocksLocation =>
      this == CountStatus.frozen ||
      this == CountStatus.counting ||
      this == CountStatus.review;

  bool get canEnterCounts =>
      this == CountStatus.frozen || this == CountStatus.counting;

  static CountStatus fromWire(String value) =>
      values.firstWhere((e) => e.wire == value);
}
