/// Route names and paths of the identity feature.
abstract final class IdentityRoutes {
  static const String loginName = 'login';
  static const String loginPath = '/login';

  static const String profileName = 'profile';
  static const String profilePath = '/profile';

  // --- Admin (web only, `iam.user.manage`) ------------------------------
  static const String adminUsersName = 'admin-users';
  static const String adminUsersPath = '/admin/users';

  static const String adminUserDetailName = 'admin-user-detail';

  /// Child path of [adminUsersPath].
  static const String adminUserDetailPath = ':userId';
  static String adminUserDetail(int id) => '$adminUsersPath/$id';

  static const String adminRolesName = 'admin-roles';
  static const String adminRolesPath = '/admin/roles';

  static const String adminRoleDetailName = 'admin-role-detail';

  /// Child path of [adminRolesPath].
  static const String adminRoleDetailPath = ':roleId';
  static String adminRoleDetail(int id) => '$adminRolesPath/$id';
}
