import 'dart:async';

import 'package:meta/meta.dart';
import 'package:wms_core/wms_core.dart';

import 'session.dart';
import 'token_store.dart';

/// Authentication boundary used by features. Concrete OIDC flows live in the
/// apps (`KeycloakAuthMobile`, `KeycloakAuthWeb`).
abstract interface class AuthRepository {
  /// Emits on login, refresh, permission enrichment and logout (`null`).
  Stream<Session?> get sessionChanges;

  Session? get currentSession;

  bool get isAuthenticated;

  /// Restores a persisted session (call once at startup).
  Future<Session?> restore();

  /// Starts the interactive login (Authorization Code + PKCE).
  Future<Result<Session>> login();

  /// Refreshes the access token using the refresh token.
  Future<Result<Session>> refresh();

  /// Replaces the session's permissions/locations (from `/identity/me`).
  Future<void> updateSession(Session session);

  Future<void> logout();

  void dispose();
}

/// Plumbing shared by concrete repositories: persistence, broadcast stream and
/// the state machine. Subclasses implement the three OIDC primitives.
abstract class BaseAuthRepository implements AuthRepository {
  BaseAuthRepository({required this.store});

  /// Persistence used for the session.
  @protected
  final TokenStore store;
  final StreamController<Session?> _controller =
      StreamController<Session?>.broadcast();
  Session? _current;
  Future<Result<Session>>? _inflightRefresh;

  @override
  Stream<Session?> get sessionChanges => _controller.stream;

  @override
  Session? get currentSession => _current;

  @override
  bool get isAuthenticated => _current != null;

  /// Interactive login; returns the new session.
  Future<Session> performLogin();

  /// Token refresh; returns the new session.
  Future<Session> performRefresh(Session session);

  /// Provider side logout (end-session), best effort.
  Future<void> performLogout(Session session);

  @override
  Future<Session?> restore() async {
    final stored = await store.read();
    if (stored == null) return null;
    await _publish(stored, persist: false);
    return stored;
  }

  @override
  Future<Result<Session>> login() => Result.guard(() async {
    final session = await performLogin();
    await _publish(session);
    return session;
  });

  @override
  Future<Result<Session>> refresh() {
    // De-duplicate concurrent refreshes (several 401s at once).
    final inflight = _inflightRefresh;
    if (inflight != null) return inflight;
    final future = Result.guard(() async {
      final current = _current;
      if (current == null || current.refreshToken == null) {
        throw AppException(
          UnauthorizedFailure(
            ProblemDetails.local(
              code: ProblemCodes.unauthorized,
              title: 'No refresh token',
              status: 401,
            ),
          ),
        );
      }
      final session = await performRefresh(current);
      await _publish(session);
      return session;
    }).whenComplete(() => _inflightRefresh = null);
    _inflightRefresh = future;
    return future;
  }

  @override
  Future<void> updateSession(Session session) => _publish(session);

  @override
  Future<void> logout() async {
    final current = _current;
    if (current != null) {
      try {
        await performLogout(current);
      } on Object {
        // Best effort: local sign-out must succeed even when the IdP is down.
      }
    }
    _current = null;
    await store.clear();
    _controller.add(null);
  }

  Future<void> _publish(Session session, {bool persist = true}) async {
    _current = session;
    if (persist) await store.write(session);
    _controller.add(session);
  }

  @override
  void dispose() {
    unawaited(_controller.close());
  }
}

/// Repository for tests and local development without Keycloak: `login()`
/// immediately yields [session].
class FakeAuthRepository extends BaseAuthRepository {
  FakeAuthRepository({required this.session, TokenStore? store})
    : super(store: store ?? InMemoryTokenStore());

  final Session session;
  int refreshCount = 0;

  @override
  Future<Session> performLogin() async => session;

  @override
  Future<Session> performRefresh(Session current) async {
    refreshCount++;
    return current.copyWith(
      accessToken: current.accessToken,
      expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 15)),
    );
  }

  @override
  Future<void> performLogout(Session current) async {}
}
