import 'package:freezed_annotation/freezed_annotation.dart';

part 'notifications_dtos.freezed.dart';
part 'notifications_dtos.g.dart';

/// In-app notification (`notif_*`).
@freezed
abstract class NotificationDto with _$NotificationDto {
  const factory NotificationDto({
    required int id,
    required String type,
    required String title,
    required DateTime createdAt,
    String? body,
    @Default(false) bool isRead,
    String? docType,
    int? docId,
    String? deepLink,
  }) = _NotificationDto;

  factory NotificationDto.fromJson(Map<String, Object?> json) =>
      _$NotificationDtoFromJson(json);
}

/// `GET /notifications/unread-count`.
@freezed
abstract class UnreadCountDto with _$UnreadCountDto {
  const factory UnreadCountDto({@Default(0) int count}) = _UnreadCountDto;

  factory UnreadCountDto.fromJson(Map<String, Object?> json) =>
      _$UnreadCountDtoFromJson(json);
}
