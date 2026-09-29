import 'dart:convert';
import 'dart:io';

import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';

/// Keycloak sign-in without a browser: the app collects the credentials and
/// exchanges them for tokens itself (OAuth 2.0 Resource Owner Password
/// Credentials, which Keycloak calls *Direct Access Grant*).
///
/// This replaces the Authorization Code + PKCE flow the app used to run through
/// `flutter_appauth`. That flow is what RFC 8252 recommends for a native app,
/// and what this one gives up with it is worth stating plainly:
///
///   * the password passes through the app rather than only through Keycloak's
///     own login page, so the app is in scope for anything that protects it;
///   * single sign-on across apps stops working — there is no browser session
///     to share;
///   * whatever the realm adds to its login page (a second factor, a consent
///     screen, an identity provider such as Google or a corporate IdP, a forced
///     password reset) can no longer run, because there is no page to show it
///     on. Keycloak answers such a login with an error instead.
///
/// The realm must have `directAccessGrantsEnabled` on the `wms-mobile` client,
/// which `deploy/keycloak/realm-wms.json` sets.
///
/// Refresh and logout use the same token and end-session endpoints as before,
/// so a session outlives the access token exactly as it did.
class KeycloakAuthNative extends BaseAuthRepository {
  KeycloakAuthNative({
    required this.issuer,
    required this.clientId,
    required super.store,
    this.scopes = defaultScopes,
    HttpClient Function()? httpClientFactory,
  }) : _newClient = httpClientFactory ?? HttpClient.new;

  /// No `offline_access`: the realm does not grant an offline token to
  /// `wms-mobile` on a password grant, and asking for one is refused outright
  /// with `Offline tokens not allowed for the user or client`. The ordinary
  /// refresh token this returns is what keeps a session alive anyway.
  static const List<String> defaultScopes = ['openid', 'profile', 'email'];

  /// Realm issuer, e.g. `http://localhost:8180/realms/wms`.
  final String issuer;
  final String clientId;
  final List<String> scopes;
  final HttpClient Function() _newClient;

  Uri get _tokenEndpoint =>
      Uri.parse('$issuer/protocol/openid-connect/token');
  Uri get _logoutEndpoint =>
      Uri.parse('$issuer/protocol/openid-connect/logout');

  @override
  Future<Session> performLogin({String? username, String? password}) async {
    if (username == null || username.isEmpty || password == null || password.isEmpty) {
      throw AppException(
        UnauthorizedFailure(
          ProblemDetails.local(
            code: ProblemCodes.unauthorized,
            title: 'İstifadəçi adı və parol tələb olunur',
            status: 401,
          ),
        ),
      );
    }
    final tokens = await _post({
      'grant_type': 'password',
      'client_id': clientId,
      'scope': scopes.join(' '),
      'username': username,
      'password': password,
    });
    return _toSession(tokens);
  }

  @override
  Future<Session> performRefresh(Session session) async {
    final tokens = await _post({
      'grant_type': 'refresh_token',
      'client_id': clientId,
      'refresh_token': session.refreshToken ?? '',
    });
    final refreshed = _toSession(tokens, fallback: session);
    // Permissions come from /identity/me, not from the token; keep them.
    return refreshed.copyWith(
      permissions: session.permissions,
      locationIds: session.locationIds,
    );
  }

  /// Ends the Keycloak session so the refresh token stops working.
  ///
  /// Failures are swallowed by `BaseAuthRepository.logout`, which clears the
  /// local session regardless: signing out must work with the IdP down.
  @override
  Future<void> performLogout(Session session) async {
    final refreshToken = session.refreshToken;
    if (refreshToken == null) return;
    await _send(_logoutEndpoint, {
      'client_id': clientId,
      'refresh_token': refreshToken,
    });
  }

  Future<Map<String, Object?>> _post(Map<String, String> form) async {
    final response = await _send(_tokenEndpoint, form);
    final body = jsonDecode(response.body);
    if (response.status != 200 || body is! Map<String, Object?>) {
      throw AppException(_failureFor(response, body));
    }
    return body;
  }

  Future<_Response> _send(Uri url, Map<String, String> form) async {
    final client = _newClient();
    try {
      final request = await client.postUrl(url);
      request.headers.contentType = ContentType(
        'application',
        'x-www-form-urlencoded',
        charset: 'utf-8',
      );
      request.write(
        form.entries
            .map(
              (e) =>
                  '${Uri.encodeQueryComponent(e.key)}='
                  '${Uri.encodeQueryComponent(e.value)}',
            )
            .join('&'),
      );
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      return _Response(response.statusCode, body);
    } on SocketException catch (error) {
      throw AppException(NetworkFailure(message: error.message));
    } finally {
      client.close(force: true);
    }
  }

  /// Keycloak answers a bad password with `401 invalid_grant`, a disabled
  /// direct access grant with `400 unauthorized_client`, and a locked account
  /// with `400 invalid_grant` plus a description. The three read very
  /// differently to whoever is standing at the terminal, so they are not
  /// collapsed into one message.
  Failure _failureFor(_Response response, Object? body) {
    final error = body is Map ? body['error']?.toString() : null;
    final description = body is Map
        ? body['error_description']?.toString()
        : null;
    final title = switch (error) {
      'invalid_grant' => description == null || description == 'Invalid user credentials'
          ? 'İstifadəçi adı və ya parol yanlışdır'
          : description,
      'unauthorized_client' =>
        'Bu klient üçün parol girişi bağlıdır (Keycloak: Direct Access Grants)',
      'invalid_client' => 'Klient tapılmadı: $clientId',
      _ => description ?? 'Giriş alınmadı (${response.status})',
    };
    final problem = ProblemDetails.local(
      code: ProblemCodes.unauthorized,
      title: title,
      status: response.status,
    );
    return response.status >= 500
        ? ServerFailure(problem)
        : UnauthorizedFailure(problem);
  }

  Session _toSession(Map<String, Object?> tokens, {Session? fallback}) {
    final accessToken = tokens['access_token'] as String?;
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
    final expiresIn = tokens['expires_in'];
    return Session.fromTokens(
      accessToken: accessToken,
      refreshToken: tokens['refresh_token'] as String? ?? fallback?.refreshToken,
      idToken: tokens['id_token'] as String? ?? fallback?.idToken,
      expiresAt: expiresIn is num
          ? DateTime.now().toUtc().add(Duration(seconds: expiresIn.toInt()))
          : null,
    );
  }
}

class _Response {
  const _Response(this.status, this.body);

  final int status;
  final String body;
}
