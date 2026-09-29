import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

/// In-app notifications (`notif_*`).
abstract interface class NotificationsRepository {
  Future<Result<Page<NotificationDto>>> list({
    bool? unreadOnly,
    PageRequest page,
  });

  /// The whole counter, not just the total: the inbox shows the severity split and the pending
  /// approvals separately from the badge number.
  Future<Result<UnreadCountDto>> unreadCount();

  Future<Result<void>> markRead(int id);

  Future<Result<void>> markAllRead();

  /// Push registration. Re-registering the same [deviceId] replaces the token, and logout must
  /// unregister it or the next person on that handset receives someone else's notifications.
  Future<Result<void>> registerDevice({
    required String deviceId,
    required String platform,
    required String pushToken,
    String? appVersion,
  });

  Future<Result<void>> unregisterDevice(String deviceId);
}
