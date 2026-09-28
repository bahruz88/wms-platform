import 'package:freezed_annotation/freezed_annotation.dart';

part 'notifications_dtos.freezed.dart';
part 'notifications_dtos.g.dart';

/// One inbox row — `GET /notifications/inbox`.
///
/// The field names are the contract's: `eventType`, not `type`; `link`, not `deepLink`; `entityType`
/// and `entityId`, not `docType`/`docId`. The previous DTO used the other set and so could not parse
/// a notification at all, which nobody noticed while the module itself was unbuilt.
///
/// `link` is a deep link the server composed (`/inventory/goods-receipts/311`), so following a
/// notification lands on the document rather than on a search.
@freezed
abstract class NotificationDto with _$NotificationDto {
  const factory NotificationDto({
    required int id,
    required String eventType,
    required String severity,
    required String title,
    required DateTime createdAt,
    @Default(false) bool isRead,
    String? body,
    String? link,
    String? entityType,
    int? entityId,
    int? locationId,
    DateTime? readAt,
    String? eventId,
  }) = _NotificationDto;

  const NotificationDto._();

  factory NotificationDto.fromJson(Map<String, Object?> json) => _$NotificationDtoFromJson(json);

  bool get isCritical => severity == 'CRITICAL';
}

/// `GET /notifications/inbox/unread-count` — the figure behind the bell badge.
///
/// `bySeverity` always carries all three keys, zero included: a client should not have to guess at
/// an absent key. `pendingApprovals` comes from procurement, for the same badge.
@freezed
abstract class UnreadCountDto with _$UnreadCountDto {
  const factory UnreadCountDto({
    @Default(0) int total,
    @Default(<String, int>{}) Map<String, int> bySeverity,
    @Default(0) int pendingApprovals,
  }) = _UnreadCountDto;

  const UnreadCountDto._();

  factory UnreadCountDto.fromJson(Map<String, Object?> json) => _$UnreadCountDtoFromJson(json);

  int severity(String code) => bySeverity[code] ?? 0;
}
