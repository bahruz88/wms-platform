import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

import '../domain/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._api);

  final NotificationsApi _api;

  @override
  Future<Result<Page<NotificationDto>>> list({
    bool? unreadOnly,
    PageRequest page = const PageRequest(),
  }) => Result.guard(() => _api.list(unreadOnly: unreadOnly, page: page));

  @override
  Future<Result<UnreadCountDto>> unreadCount() => Result.guard(_api.unreadCount);

  @override
  Future<Result<void>> markRead(int id) =>
      Result.guard(() => _api.markRead(id));

  @override
  Future<Result<void>> markAllRead() => Result.guard(_api.markAllRead);

  @override
  Future<Result<void>> registerDevice({
    required String deviceId,
    required String platform,
    required String pushToken,
    String? appVersion,
  }) => Result.guard(
    () => _api.registerDevice(
      deviceId: deviceId,
      platform: platform,
      pushToken: pushToken,
      appVersion: appVersion,
    ),
  );

  @override
  Future<Result<void>> unregisterDevice(String deviceId) =>
      Result.guard(() => _api.unregisterDevice(deviceId));
}
