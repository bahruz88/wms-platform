import 'package:go_router/go_router.dart';

import 'navigation.dart';
import 'presentation/admin/role_detail_screen.dart';
import 'presentation/admin/role_list_screen.dart';
import 'presentation/admin/user_detail_screen.dart';
import 'presentation/admin/user_list_screen.dart';
import 'presentation/login_screen.dart';
import 'presentation/profile_screen.dart';

/// Routes contributed by the identity feature.
List<RouteBase> identityRoutes() => [
  GoRoute(
    name: IdentityRoutes.loginName,
    path: IdentityRoutes.loginPath,
    builder: (context, state) => const LoginScreen(),
  ),
];

/// Profile route; mounted inside the shell so the navigation stays visible.
List<RouteBase> identityShellRoutes() => [
  GoRoute(
    name: IdentityRoutes.profileName,
    path: IdentityRoutes.profilePath,
    builder: (context, state) => const ProfileScreen(),
  ),
];

/// Admin routes contributed by the identity feature (web only): the user and
/// role screens under `/admin`. Every screen gates on `iam.user.manage`.
List<RouteBase> identityAdminRoutes() => [
  GoRoute(
    name: IdentityRoutes.adminUsersName,
    path: IdentityRoutes.adminUsersPath,
    builder: (context, state) => const AdminUserListScreen(),
    routes: [
      GoRoute(
        name: IdentityRoutes.adminUserDetailName,
        path: IdentityRoutes.adminUserDetailPath,
        builder: (context, state) => AdminUserDetailScreen(
          userId: int.parse(state.pathParameters['userId']!),
        ),
      ),
    ],
  ),
  GoRoute(
    name: IdentityRoutes.adminRolesName,
    path: IdentityRoutes.adminRolesPath,
    builder: (context, state) => const AdminRoleListScreen(),
    routes: [
      GoRoute(
        name: IdentityRoutes.adminRoleDetailName,
        path: IdentityRoutes.adminRoleDetailPath,
        builder: (context, state) => AdminRoleDetailScreen(
          roleId: int.parse(state.pathParameters['roleId']!),
        ),
      ),
    ],
  ),
];
