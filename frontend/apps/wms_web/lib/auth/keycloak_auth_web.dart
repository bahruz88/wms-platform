import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:openid_client/openid_client.dart' as oidc;
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';

import 'browser.dart';

/// Outcome of completing a redirect: the session plus the in-app location the
/// user was heading to before being sent to Keycloak.
@immutable
class RedirectSignIn {
  const RedirectSignIn({required this.session, this.returnTo});

  final Session session;
  final String? returnTo;
}

/// Keycloak **Authorization Code + PKCE (S256)** for the web app.
///
/// The realm's `wms-web` client is public, so there is no secret and the code
/// verifier is the only proof of possession. The flow is:
///
/// 1. [performLogin] generates `state` + verifier, stores them in
///    [PendingAuthorizationStore] (sessionStorage in the browser) and leaves
///    the page for the authorization endpoint,
/// 2. Keycloak redirects back to [redirectUri] (`/callback`) with
///    `?code=&state=`; the `/callback` route calls [completeRedirect], which
///    re-creates the flow from the stored verifier and exchanges the code,
/// 3. the session is persisted through the [TokenStore], so a page reload
///    restores it, and [SilentRefreshScheduler] renews the access token
///    shortly before it expires.
///
/// Everything browser specific sits behind [Browser], which keeps this class
/// unit testable (see `test/keycloak_auth_web_test.dart`).
class KeycloakAuthWeb extends BaseAuthRepository {
  KeycloakAuthWeb({
    required this.issuer,
    required this.clientId,
    required this.redirectUri,
    required this.browser,
    required super.store,
    required PendingAuthorizationStore pendingStore,
    this.scopes = defaultScopes,
    this.httpClient,
    Duration refreshLeeway = const Duration(minutes: 1),
  }) : _pending = pendingStore {
    _scheduler = SilentRefreshScheduler(
      onRefresh: refresh,
      leeway: refreshLeeway,
    );
    // Every published session (login, redirect completion, restore, refresh)
    // re-arms the silent refresh; a sign-out cancels it.
    _sessionSubscription = sessionChanges.listen((session) {
      if (session == null) {
        _scheduler.cancel();
      } else {
        _scheduler.schedule(session.expiresAt);
      }
    });
  }

  static const List<String> defaultScopes = ['openid', 'profile', 'email'];

  /// Realm issuer, e.g. `http://localhost:8180/realms/wms`.
  final String issuer;
  final String clientId;

  /// Registered redirect URI (`http://localhost:3001/callback`). It must not
  /// contain a fragment, which is why the app uses the path URL strategy.
  final Uri redirectUri;

  final Browser browser;
  final List<String> scopes;

  /// Injected in tests to stub discovery and the token endpoint.
  final http.Client? httpClient;

  final PendingAuthorizationStore _pending;
  late final SilentRefreshScheduler _scheduler;
  StreamSubscription<Session?>? _sessionSubscription;
  Future<oidc.Client>? _clientFuture;

  /// Where the user is sent back after an RP-initiated logout: the app root,
  /// which the realm allows through `http://localhost:3001/*`.
  Uri get postLogoutRedirectUri => originOf(redirectUri, path: '/');

  /// `http://localhost:3001/x?y` → `http://localhost:3001/callback`.
  /// The redirect URI must carry no query and no fragment (RFC 6749 §3.1.2).
  static Uri originOf(Uri uri, {String path = '/callback'}) => Uri(
    scheme: uri.scheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
    path: path,
  );

  Future<oidc.Client> _client() => _clientFuture ??= () async {
    final discovered = await oidc.Issuer.discover(
      Uri.parse(issuer),
      httpClient: httpClient,
    );
    return oidc.Client(discovered, clientId, httpClient: httpClient);
  }();

  /// Builds the flow for [pending]; the same `state` and verifier are used
  /// for the authorization request and for the exchange.
  Future<oidc.Flow> _flow(PendingAuthorization pending) async =>
      oidc.Flow.authorizationCodeWithPKCE(
        await _client(),
        state: pending.state,
        codeVerifier: pending.codeVerifier,
        scopes: scopes,
      )..redirectUri = pending.redirectUri;

  /// Starts the redirect and returns the authorization URI it navigated to.
  ///
  /// [returnTo] is the in-app location to restore afterwards; anything that
  /// is not an app-internal path is ignored (open redirect protection).
  Future<Uri> beginAuthorization({String? returnTo}) async {
    final pending = PendingAuthorization.start(
      redirectUri: redirectUri,
      returnTo: _safeReturnTo(returnTo),
    );
    final uri = (await _flow(pending)).authenticationUri;
    _pending.write(pending);
    browser.assign(uri.toString());
    return uri;
  }

  /// Completes the redirect described by [uri] (the `/callback` location).
  ///
  /// Throws [AppException] when the provider reported an error, when the
  /// `state` does not match the stored one (CSRF / stale tab) or when the
  /// token exchange fails.
  Future<RedirectSignIn> completeRedirect(Uri uri) async {
    final callback = AuthorizationCallback.parse(uri);
    final pending = _pending.read();
    switch (callback) {
      case NoAuthorizationResponse():
        _pending.clear();
        throw _failure(
          code: ProblemCodes.unauthorized,
          title: 'Giriş cavabı tapılmadı',
          detail:
              'Bu ünvanda Keycloak-dan gələn kod yoxdur. '
              'Yenidən «Daxil ol» düyməsini basın.',
        );
      case AuthorizationError(:final error, :final description):
        _pending.clear();
        throw _failure(
          // The provider's own OAuth error code, verbatim: support looks it
          // up as-is and the design rules forbid case folding.
          code: error,
          title: 'Keycloak girişi rədd etdi',
          detail: description ?? 'Kimlik serveri $error qaytardı.',
        );
      case AuthorizationCode():
        if (pending == null) {
          throw _failure(
            code: ProblemCodes.unauthorized,
            title: 'Giriş sorğusu tapılmadı',
            detail:
                'Brauzer bu tabda başlanmış girişi xatırlamır. '
                'Yenidən «Daxil ol» düyməsini basın.',
          );
        }
        if (pending.isExpired()) {
          _pending.clear();
          throw _failure(
            code: ProblemCodes.unauthorized,
            title: 'Giriş sorğusunun vaxtı keçdi',
            detail: 'Giriş 15 dəqiqədən çox çəkdi, yenidən cəhd edin.',
          );
        }
        if (!callback.matchesState(pending.state)) {
          _pending.clear();
          throw _failure(
            code: 'STATE_MISMATCH',
            title: 'Giriş cavabı uyğun gəlmir',
            detail:
                'Cavabdakı state saxlanılan dəyərdən fərqlidir; '
                'təhlükəsizlik üçün giriş dayandırıldı.',
          );
        }
        if (!callback.matchesIssuer(issuer)) {
          _pending.clear();
          throw _failure(
            code: 'ISSUER_MISMATCH',
            title: 'Giriş cavabı başqa serverdən gəldi',
            detail: 'Gözlənilən issuer: $issuer.',
          );
        }
        final flow = await _flow(pending);
        final credential = await flow.callback({
          'code': callback.code,
          'state': callback.state ?? pending.state,
        });
        final response = await credential.getTokenResponse();
        _pending.clear();
        final session = _sessionFromToken(response);
        await updateSession(session);
        return RedirectSignIn(session: session, returnTo: pending.returnTo);
    }
  }

  @override
  Future<Session> performLogin() async {
    await beginAuthorization(returnTo: _currentLocation());
    // The browser is leaving the page; surfacing this as a failure keeps the
    // login button honest if the navigation is blocked.
    throw _failure(
      code: ProblemCodes.unauthorized,
      title: 'Keycloak-a yönləndirilirsiniz',
      detail: 'Giriş səhifəsi açılır, bir az gözləyin.',
    );
  }

  @override
  Future<Session> performRefresh(Session session) async {
    final refreshToken = session.refreshToken;
    if (refreshToken == null) {
      throw _failure(
        code: ProblemCodes.unauthorized,
        title: 'Sessiya yenilənə bilmədi',
        detail: 'Refresh token yoxdur, yenidən daxil olun.',
      );
    }
    // A page reload loses the in-memory credential; rebuilding it from the
    // persisted refresh token is what keeps the session alive.
    final credential = (await _client()).createCredential(
      accessToken: session.accessToken,
      refreshToken: refreshToken,
      idToken: session.idToken,
      expiresAt: session.expiresAt,
    );
    final response = await credential.getTokenResponse(true);
    final refreshed = _sessionFromToken(response, fallback: session);
    // Permissions come from /identity/me, keep them across a refresh.
    return refreshed.copyWith(
      permissions: session.permissions,
      locationIds: session.locationIds,
    );
  }

  @override
  Future<void> performLogout(Session session) async {
    _scheduler.cancel();
    final endSession = (await _client()).issuer.metadata.endSessionEndpoint;
    if (endSession == null) return;
    final idToken = session.idToken;
    final url = endSession.replace(
      queryParameters: <String, String>{
        if (idToken != null)
          'id_token_hint': idToken
        // Keycloak rejects a logout that carries neither hint nor client id.
        else
          'client_id': clientId,
        'post_logout_redirect_uri': postLogoutRedirectUri.toString(),
      },
    );
    // Leaving the page ends the Keycloak SSO session as well.
    browser.assign(url.toString());
  }

  @override
  void dispose() {
    _scheduler.dispose();
    unawaited(_sessionSubscription?.cancel());
    _sessionSubscription = null;
    super.dispose();
  }

  /// In-app location of the current page, used as `returnTo`.
  String? _currentLocation() {
    final uri = browser.currentUri;
    final path = uri.path.isEmpty ? '/' : uri.path;
    final query = uri.query.isEmpty ? '' : '?${uri.query}';
    return _safeReturnTo('$path$query');
  }

  /// Only app-internal paths are restored, never an absolute URL and never
  /// the callback or login pages.
  static String? _safeReturnTo(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!value.startsWith('/') || value.startsWith('//')) return null;
    final path = Uri.parse(value).path;
    if (path == '/callback' || path == '/login' || path == '/') return null;
    return value;
  }

  Session _sessionFromToken(oidc.TokenResponse response, {Session? fallback}) {
    final accessToken = response.accessToken;
    if (accessToken == null) {
      throw _failure(
        code: ProblemCodes.unauthorized,
        title: 'Keycloak access token qaytarmadı',
        detail: 'Token cavabında access_token sahəsi yoxdur.',
      );
    }
    final rawIdToken = response['id_token'];
    return Session.fromTokens(
      accessToken: accessToken,
      refreshToken: response.refreshToken ?? fallback?.refreshToken,
      idToken: rawIdToken is String ? rawIdToken : fallback?.idToken,
      expiresAt: response.expiresAt?.toUtc(),
    );
  }

  static AppException _failure({
    required String code,
    required String title,
    String? detail,
    int status = 401,
  }) => AppException(
    UnauthorizedFailure(
      ProblemDetails.local(
        code: code,
        title: title,
        detail: detail,
        status: status,
      ),
    ),
  );
}
