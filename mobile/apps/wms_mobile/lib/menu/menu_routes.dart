import 'package:go_router/go_router.dart';

import 'menu_screen.dart';

/// Route of the home menu.
abstract final class MenuRoutes {
  static const String menuName = 'menu';
  static const String menuPath = '/menu';
}

List<RouteBase> menuRoutes() => [
  GoRoute(
    name: MenuRoutes.menuName,
    path: MenuRoutes.menuPath,
    builder: (context, state) => const MenuScreen(),
  ),
];
