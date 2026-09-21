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
  Future<Result<int>> unreadCount() =>
      Result.guard(() async => (await _api.unreadCount()).count);

  @override
  Future<Result<void>> markRead(int id) =>
      Result.guard(() => _api.markRead(id));

  @override
  Future<Result<void>> markAllRead() => Result.guard(_api.markAllRead);
}
