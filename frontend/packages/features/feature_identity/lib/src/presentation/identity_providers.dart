import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';

import '../data/identity_repository_impl.dart';
import '../domain/identity_repository.dart';

/// Overridden in the app bootstrap with the configured [WmsApiClient].
final apiClientProvider = Provider<WmsApiClient>(
  (ref) => throw UnimplementedError(
    'apiClientProvider must be overridden in the app bootstrap',
  ),
);

/// Application wide error sink. Overridden in the app bootstrap with the
/// same [CrashReporter] that `FlutterError.onError` and the guarded zone
/// use, so a screen can report a handled failure through one seam.
final crashReporterProvider = Provider<CrashReporter>(
  (ref) => LoggingCrashReporter(),
);

final identityRepositoryProvider = Provider<IdentityRepository>(
  (ref) => IdentityRepositoryImpl(ref.watch(apiClientProvider).identity),
);

/// `GET /identity/me`, refreshed whenever the session changes. The result is
/// pushed back into the session so `hasPermissionProvider` sees the
/// effective permissions (the JWT alone does not carry them).
final currentUserProvider = FutureProvider<CurrentUserDto?>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session == null) return null;
  final result = await ref.watch(identityRepositoryProvider).me();
  final user = result.valueOrNull;
  if (user != null) {
    final repository = ref.read(authRepositoryProvider);
    final current = repository.currentSession;
    if (current != null) {
      await repository.updateSession(
        current.copyWith(
          permissions: user.permissions.toSet(),
          roles: user.roles,
          locationIds: user.locationIds,
          fullName: user.fullName,
          email: user.email,
        ),
      );
    }
  }
  return user;
});

/// Sign-in action state for the login screen.
final loginControllerProvider = AsyncNotifierProvider<LoginController, void>(
  LoginController.new,
);

class LoginController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Runs the interactive OIDC flow; the failure is surfaced through
  /// [AsyncValue.error] so the screen can show a `WmsAlert`.
  Future<bool> login() async {
    state = const AsyncValue<void>.loading();
    final result = await ref.read(authRepositoryProvider).login();
    return result.fold(
      (_) {
        state = const AsyncValue<void>.data(null);
        return true;
      },
      (failure) {
        state = AsyncValue<void>.error(
          AppException(failure),
          StackTrace.current,
        );
        return false;
      },
    );
  }

  Future<void> logout() async {
    state = const AsyncValue<void>.loading();
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncValue<void>.data(null);
  }
}
