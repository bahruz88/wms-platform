import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';

/// Keycloak Authorization Code + PKCE for Android/iOS via `flutter_appauth`.
///
/// Redirect: `az.wms.mobile://callback` — the scheme is declared in
/// `android/app/build.gradle.kts` (`manifestPlaceholders`) and in
/// `ios/Runner/Info.plist` (`CFBundleURLTypes`).
///
/// The same URI is the RP-initiated logout target; the realm registers it as
/// `post.logout.redirect.uris` for `wms-mobile`.
class KeycloakAuthMobile extends BaseAuthRepository {
  KeycloakAuthMobile({
    required this.issuer,
    required this.clientId,
    required super.store,
    this.redirectUrl = defaultRedirectUrl,
    this.scopes = defaultScopes,
    FlutterAppAuth? appAuth,
  }) : _appAuth = appAuth ?? const FlutterAppAuth();

  static const String defaultRedirectUrl = 'az.wms.mobile://callback';
  static const List<String> defaultScopes = [
    'openid',
    'profile',
    'email',
    'offline_access',
  ];

  /// Realm issuer, e.g. `http://localhost:8180/realms/wms`.
  final String issuer;
  final String clientId;
  final String redirectUrl;
  final List<String> scopes;
  final FlutterAppAuth _appAuth;

  /// Plain HTTP is allowed for the local dev realm only.
  bool get _allowInsecure => issuer.startsWith('http://');

  @override
  Future<Session> performLogin() async {
    final response = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        clientId,
        redirectUrl,
        issuer: issuer,
        scopes: scopes,
        allowInsecureConnections: _allowInsecure,
      ),
    );
    return _toSession(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      idToken: response.idToken,
      expiresAt: response.accessTokenExpirationDateTime,
    );
  }

  @override
  Future<Session> performRefresh(Session session) async {
    final response = await _appAuth.token(
      TokenRequest(
        clientId,
        redirectUrl,
        issuer: issuer,
        refreshToken: session.refreshToken,
        grantType: 'refresh_token',
        scopes: scopes,
        allowInsecureConnections: _allowInsecure,
      ),
    );
    final refreshed = _toSession(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken ?? session.refreshToken,
      idToken: response.idToken ?? session.idToken,
      expiresAt: response.accessTokenExpirationDateTime,
    );
    // Permissions come from /identity/me, keep them across a refresh.
    return refreshed.copyWith(
      permissions: session.permissions,
      locationIds: session.locationIds,
    );
  }

  /// RP-initiated logout (OpenID Connect RP-Initiated Logout 1.0).
  ///
  /// The Keycloak end-session endpoint needs either `id_token_hint` or
  /// `client_id` next to `post_logout_redirect_uri`; without one of them it
  /// answers `400` and the SSO cookie survives, so the next sign-in silently
  /// reuses the old session. The id token is normally there, but a session
  /// restored from an older build (or a refresh that did not return one) has
  /// none - that case falls back to `client_id` instead of skipping the call.
  ///
  /// Failures are swallowed by `BaseAuthRepository.logout`, which clears the
  /// local session regardless: signing out must work with the IdP down.
  @override
  Future<void> performLogout(Session session) async {
    final idToken = session.idToken;
    await _appAuth.endSession(
      EndSessionRequest(
        idTokenHint: idToken,
        postLogoutRedirectUrl: redirectUrl,
        issuer: issuer,
        allowInsecureConnections: _allowInsecure,
        additionalParameters: idToken == null
            ? <String, String>{'client_id': clientId}
            : null,
      ),
    );
  }

  Session _toSession({
    required String? accessToken,
    required String? refreshToken,
    required String? idToken,
    required DateTime? expiresAt,
  }) {
    if (accessToken == null) {
      throw AppException(
        UnauthorizedFailure(
          ProblemDetails.local(
            code: ProblemCodes.unauthorized,
            title: 'Keycloak access token qaytarmadı',
            status: 401,
          ),
        ),
      );
    }
    return Session.fromTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      idToken: idToken,
      expiresAt: expiresAt?.toUtc(),
    );
  }
}
