import 'package:json_annotation/json_annotation.dart';

/// `SimpleDocStatus` — the status of a document that has no status column of its own.
///
/// A sample is the only one: its state is derived from whether a movement group was written, so it
/// is never PENDING_APPROVAL or REJECTED the way a write-off can be.
enum SimpleDocStatus {
  @JsonValue('DRAFT')
  draft('DRAFT'),
  @JsonValue('POSTED')
  posted('POSTED'),
  @JsonValue('CANCELLED')
  cancelled('CANCELLED');

  const SimpleDocStatus(this.wire);

  final String wire;

  bool get isDraft => this == SimpleDocStatus.draft;
  bool get isPosted => this == SimpleDocStatus.posted;
}
