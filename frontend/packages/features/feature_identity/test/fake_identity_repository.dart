import 'package:feature_identity/feature_identity.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

/// In-memory [IdentityRepository] for the admin widget tests.
class FakeIdentityRepository implements IdentityRepository {
  FakeIdentityRepository({
    this.userRows = const [],
    this.roleRows = const [],
    this.permissionRows = const [],
    this.failure,
  });

  final List<UserDto> userRows;
  final List<RoleDto> roleRows;
  final List<PermissionDto> permissionRows;
  final Failure? failure;

  /// Search terms the list screen sent to the API.
  final List<String?> searches = [];

  Result<T> _ok<T>(T value) =>
      failure == null ? Result<T>.ok(value) : Result<T>.err(failure!);

  @override
  Future<Result<CurrentUserDto>> me() async => _ok(
    const CurrentUserDto(
      id: 1,
      tenantId: 1,
      username: 'admin',
      fullName: 'Administrator',
    ),
  );

  @override
  Future<Result<Page<UserDto>>> users({
    String? search,
    PageRequest page = const PageRequest(),
  }) async {
    searches.add(search);
    final items = search == null
        ? userRows
        : userRows
              .where(
                (u) =>
                    u.username.contains(search) || u.fullName.contains(search),
              )
              .toList();
    return _ok(
      Page<UserDto>(items: items, page: 1, size: 50, total: items.length),
    );
  }

  @override
  Future<Result<UserDto>> user(int id) async =>
      _ok(userRows.firstWhere((u) => u.id == id));

  @override
  Future<Result<List<RoleDto>>> roles() async => _ok(roleRows);

  @override
  Future<Result<RoleDto>> role(int id) async =>
      _ok(roleRows.firstWhere((r) => r.id == id));

  @override
  Future<Result<List<PermissionDto>>> permissions({String? module}) async =>
      _ok(permissionRows);
}
