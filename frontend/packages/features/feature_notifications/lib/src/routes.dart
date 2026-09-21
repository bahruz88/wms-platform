import 'package:go_router/go_router.dart';

import 'navigation.dart';
import 'presentation/notification_list_screen.dart';

/// Routes contributed by the notifications feature.
List<RouteBase> notificationsRoutes() => [
  GoRoute(
    name: NotificationsRoutes.listName,
    path: NotificationsRoutes.listPath,
    builder: (context, state) => const NotificationListScreen(),
  ),
];
