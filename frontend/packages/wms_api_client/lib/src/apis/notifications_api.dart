import 'package:dio/dio.dart';
import 'package:wms_core/wms_core.dart';

import '../dto/notifications/notifications_dtos.dart';
import 'module_api.dart';

/// `/api/v1/notifications/*`.
class NotificationsApi extends ModuleApi {
  NotificationsApi(Dio dio) : super(dio, '/notifications');

  Future<Page<NotificationDto>> list({
    bool? unreadOnly,
    PageRequest page = const PageRequest(),
  }) => getPage(
    '',
    fromJson: NotificationDto.fromJson,
    page: page,
    query: {'unreadOnly': unreadOnly},
  );

  Future<UnreadCountDto> unreadCount() =>
      getObject('unread-count', fromJson: UnreadCountDto.fromJson);

  Future<void> markRead(int id) => postVoid('$id/read');

  Future<void> markAllRead() => postVoid('read-all');
}
