import 'package:dio/dio.dart';
import 'package:wms_core/wms_core.dart';

import '../dto/identity/identity_dtos.dart';
import 'module_api.dart';

/// `/api/v1/identity/*`.
class IdentityApi extends ModuleApi {
  IdentityApi(Dio dio) : super(dio, '/identity');

  /// `GET /identity/me`
  Future<CurrentUserDto> me() =>
      getObject('me', fromJson: CurrentUserDto.fromJson);

  /// `GET /identity/users?q=&isActive=&roleCode=&locationId=`
  Future<Page<UserDto>> listUsers({
    String? search,
    bool? isActive,
    String? roleCode,
    int? locationId,
    PageRequest page = const PageRequest(),
  }) => getPage(
    'users',
    fromJson: UserDto.fromJson,
    page: page,
    query: {
      'q': search,
      'isActive': isActive,
      'roleCode': roleCode,
      'locationId': locationId,
    },
  );

  /// `GET /identity/users/{id}`
  Future<UserDto> getUser(int id) =>
      getObject('users/$id', fromJson: UserDto.fromJson);

  /// `GET /identity/roles`
  Future<List<RoleDto>> listRoles() =>
      getList('roles', fromJson: RoleDto.fromJson);

  /// `GET /identity/roles/{id}`
  Future<RoleDto> getRole(int id) =>
      getObject('roles/$id', fromJson: RoleDto.fromJson);

  /// `GET /identity/permissions?module=`
  Future<List<PermissionDto>> listPermissions({String? module}) => getList(
    'permissions',
    fromJson: PermissionDto.fromJson,
    query: {'module': module},
  );
}
