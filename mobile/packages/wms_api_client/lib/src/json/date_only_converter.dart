import 'package:json_annotation/json_annotation.dart';

/// Serialises `DATE` columns as `yyyy-MM-dd` (no time component, no zone),
/// which is how the backend exposes `doc_date`, `expiry_date` etc.
class DateOnlyConverter implements JsonConverter<DateTime, String> {
  const DateOnlyConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) {
    final y = object.year.toString().padLeft(4, '0');
    final m = object.month.toString().padLeft(2, '0');
    final d = object.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

/// Nullable variant of [DateOnlyConverter].
class NullableDateOnlyConverter implements JsonConverter<DateTime?, String?> {
  const NullableDateOnlyConverter();

  @override
  DateTime? fromJson(String? json) =>
      json == null || json.isEmpty ? null : DateTime.parse(json);

  @override
  String? toJson(DateTime? object) =>
      object == null ? null : const DateOnlyConverter().toJson(object);
}
