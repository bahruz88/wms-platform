import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

/// In-app notifications (`notif_*`).
abstract interface class NotificationsRepository {
  Future<Result<Page<NotificationDto>>> list({
    bool? unreadOnly,
    PageRequest page,
  });

  Future<Result<int>> unreadCount();

  Future<Result<void>> markRead(int id);

  Future<Result<void>> markAllRead();
}
