import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

/// Reads the caller's profile (`GET /identity/me`) and the admin lists.
abstract interface class IdentityRepository {
  /// Effective permissions/roles/locations of the signed-in user.
  Future<Result<CurrentUserDto>> me();

  Future<Result<Page<UserDto>>> users({String? search, PageRequest page});

  Future<Result<UserDto>> user(int id);

  Future<Result<List<RoleDto>>> roles();

  Future<Result<RoleDto>> role(int id);

  /// Permission catalogue (`iam_permission`), optionally one module only.
  Future<Result<List<PermissionDto>>> permissions({String? module});
}
