import 'package:dio/dio.dart';
import 'package:wms_core/wms_core.dart';

import '../dto/notifications/notifications_dtos.dart';
import 'module_api.dart';

/// `/api/v1/notifications/*`.
///
/// The inbox lives under `/inbox`, not at the module root — the module root also carries `/rules`
/// and `/devices`, so an unprefixed list answers 404.
class NotificationsApi extends ModuleApi {
  NotificationsApi(Dio dio) : super(dio, '/notifications');

  /// `GET /notifications/inbox?unreadOnly=`
  Future<Page<NotificationDto>> list({
    bool? unreadOnly,
    PageRequest page = const PageRequest(),
  }) => getPage(
    'inbox',
    fromJson: NotificationDto.fromJson,
    page: page,
    query: {'unreadOnly': unreadOnly},
  );

  /// `GET /notifications/inbox/unread-count` — feeds the badge.
  Future<UnreadCountDto> unreadCount() =>
      getObject('inbox/unread-count', fromJson: UnreadCountDto.fromJson);

  /// `GET /notifications/inbox/{id}`
  Future<NotificationDto> get(int id) =>
      getObject('inbox/$id', fromJson: NotificationDto.fromJson);

  Future<void> markRead(int id) => postVoid('inbox/$id/read');

  Future<void> markAllRead() => postVoid('inbox/read-all');

  /// `POST /notifications/devices` — re-registering the same `deviceId` replaces the token.
  Future<void> registerDevice({
    required String deviceId,
    required String platform,
    required String pushToken,
    String? appVersion,
  }) => postVoid(
    'devices',
    body: {
      'deviceId': deviceId,
      'platform': platform,
      'pushToken': pushToken,
      'appVersion': ?appVersion,
    },
  );

  /// `DELETE /notifications/devices/{deviceId}` — must be called on logout.
  Future<void> unregisterDevice(String deviceId) =>
      deleteVoid('devices/$deviceId');
}
