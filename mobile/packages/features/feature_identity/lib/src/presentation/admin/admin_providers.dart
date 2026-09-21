import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

import '../identity_providers.dart';

/// Free text filter of the admin user list (`q` on `GET /identity/users`).
final userSearchProvider = NotifierProvider<UserSearchNotifier, String>(
  UserSearchNotifier.new,
);

class UserSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  // ignore: use_setters_to_change_properties
  void setSearch(String value) => state = value;
}

/// Paged `iam_user` list; re-runs when the search text changes.
final userListProvider = AsyncNotifierProvider<UserListNotifier, Page<UserDto>>(
  UserListNotifier.new,
);

class UserListNotifier extends AsyncNotifier<Page<UserDto>> {
  @override
  Future<Page<UserDto>> build() => _load(1);

  Future<Page<UserDto>> _load(int page) async {
    final search = ref.watch(userSearchProvider);
    final result = await ref
        .watch(identityRepositoryProvider)
        .users(
          search: search.isEmpty ? null : search,
          page: PageRequest(page: page),
        );
    return result.getOrThrow();
  }

  Future<void> loadPage(int page) async {
    state = const AsyncValue<Page<UserDto>>.loading();
    state = await AsyncValue.guard(() => _load(page));
  }
}

final userDetailProvider = FutureProvider.family<UserDto, int>((ref, id) async {
  final result = await ref.watch(identityRepositoryProvider).user(id);
  return result.getOrThrow();
});

final roleListProvider = FutureProvider<List<RoleDto>>((ref) async {
  final result = await ref.watch(identityRepositoryProvider).roles();
  return result.getOrThrow();
});

final roleDetailProvider = FutureProvider.family<RoleDto, int>((ref, id) async {
  final result = await ref.watch(identityRepositoryProvider).role(id);
  return result.getOrThrow();
});

/// `iam_permission` catalogue, used to describe a role's permission codes.
final permissionCatalogueProvider = FutureProvider<List<PermissionDto>>((
  ref,
) async {
  final result = await ref.watch(identityRepositoryProvider).permissions();
  return result.getOrThrow();
});
