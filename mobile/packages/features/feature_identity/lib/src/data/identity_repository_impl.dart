import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

import '../domain/identity_repository.dart';

/// [IdentityRepository] backed by the HTTP API.
class IdentityRepositoryImpl implements IdentityRepository {
  IdentityRepositoryImpl(this._api);

  final IdentityApi _api;

  @override
  Future<Result<CurrentUserDto>> me() => Result.guard(_api.me);

  @override
  Future<Result<Page<UserDto>>> users({
    String? search,
    PageRequest page = const PageRequest(),
  }) => Result.guard(() => _api.listUsers(search: search, page: page));

  @override
  Future<Result<UserDto>> user(int id) => Result.guard(() => _api.getUser(id));

  @override
  Future<Result<List<RoleDto>>> roles() => Result.guard(_api.listRoles);

  @override
  Future<Result<RoleDto>> role(int id) => Result.guard(() => _api.getRole(id));

  @override
  Future<Result<List<PermissionDto>>> permissions({String? module}) =>
      Result.guard(() => _api.listPermissions(module: module));
}
