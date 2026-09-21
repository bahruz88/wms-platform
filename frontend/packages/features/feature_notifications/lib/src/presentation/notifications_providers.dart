import 'package:feature_identity/feature_identity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

import '../data/notifications_repository_impl.dart';
import '../domain/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) =>
      NotificationsRepositoryImpl(ref.watch(apiClientProvider).notifications),
);

/// Whether the list is filtered to unread items.
final unreadOnlyProvider = NotifierProvider<UnreadOnlyNotifier, bool>(
  UnreadOnlyNotifier.new,
);

class UnreadOnlyNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final notificationListProvider =
    AsyncNotifierProvider<NotificationListNotifier, Page<NotificationDto>>(
      NotificationListNotifier.new,
    );

class NotificationListNotifier extends AsyncNotifier<Page<NotificationDto>> {
  @override
  Future<Page<NotificationDto>> build() async {
    final unreadOnly = ref.watch(unreadOnlyProvider);
    final result = await ref
        .watch(notificationsRepositoryProvider)
        .list(unreadOnly: unreadOnly ? true : null);
    return result.getOrThrow();
  }

  Future<void> markRead(int id) async {
    await ref.read(notificationsRepositoryProvider).markRead(id);
    ref.invalidate(unreadCountProvider);
    ref.invalidateSelf();
  }

  Future<void> markAllRead() async {
    await ref.read(notificationsRepositoryProvider).markAllRead();
    ref.invalidate(unreadCountProvider);
    ref.invalidateSelf();
  }
}

/// Unread counter behind the navigation badge. Returns `0` while loading or
/// on error, so a transport hiccup never blocks navigation.
final unreadCountProvider = FutureProvider<int>((ref) async {
  final result = await ref.watch(notificationsRepositoryProvider).unreadCount();
  return result.getOrElse((_) => 0);
});

/// Synchronous badge value for the navigation shells.
final unreadBadgeProvider = Provider<int>(
  (ref) => ref.watch(unreadCountProvider).value ?? 0,
);
