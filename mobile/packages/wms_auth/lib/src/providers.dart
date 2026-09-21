import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_repository.dart';
import 'session.dart';

/// Must be overridden in each app's `ProviderScope`:
/// `authRepositoryProvider.overrideWithValue(KeycloakAuthMobile(...))`.
final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>(
      (ref) => throw UnimplementedError(
        'authRepositoryProvider must be overridden in the app bootstrap',
      ),
    );

/// Live session stream (null = signed out). Seeds with the current value so
/// widgets never see a spurious loading state after startup restore.
final StreamProvider<Session?> sessionStreamProvider = StreamProvider<Session?>(
  (ref) async* {
    final repo = ref.watch(authRepositoryProvider);
    yield repo.currentSession;
    yield* repo.sessionChanges;
  },
);

/// Synchronous view of the session for guards and permission checks.
final Provider<Session?> sessionProvider = Provider<Session?>((ref) {
  final async = ref.watch(sessionStreamProvider);
  return async.value ?? ref.watch(authRepositoryProvider).currentSession;
});

final Provider<bool> isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(sessionProvider) != null,
);

final Provider<Set<String>> permissionsProvider = Provider<Set<String>>(
  (ref) => ref.watch(sessionProvider)?.permissions ?? const {},
);

/// `ref.watch(hasPermissionProvider(Permissions.poApprove))`.
final hasPermissionProvider = Provider.family<bool, String>(
  (ref, code) => ref.watch(permissionsProvider).contains(code),
);
