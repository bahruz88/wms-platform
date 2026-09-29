import 'dart:async';

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
///
/// Subscribes *before* it seeds, and does both without an await in between.
/// `sessionChanges` is a broadcast stream, so anything published while nobody is
/// listening is gone for good — and the obvious `yield current; yield* changes;`
/// leaves exactly such a gap. `/identity/me` writes the effective permissions
/// into the session in that window, so they were dropped: the stream kept
/// serving the seed, `sessionProvider` preferred it over the repository's newer
/// value, and every permission in the app read as denied. The task list came
/// back empty and permission-gated navigation never appeared — unless someone
/// happened to open the profile, whose own watch made the timing work.
final StreamProvider<Session?> sessionStreamProvider = StreamProvider<Session?>((
  ref,
) {
  final repo = ref.watch(authRepositoryProvider);
  final controller = StreamController<Session?>();
  final subscription = repo.sessionChanges.listen(
    controller.add,
    onError: controller.addError,
  );
  controller.add(repo.currentSession);
  ref.onDispose(() {
    unawaited(subscription.cancel());
    unawaited(controller.close());
  });
  return controller.stream;
});

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
