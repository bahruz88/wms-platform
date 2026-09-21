import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_web/auth/browser.dart';
import 'package:wms_web/auth/keycloak_auth_web.dart';

import 'test_doubles.dart';

const _issuer = 'http://localhost:8180/realms/wms';
final _redirect = Uri.parse('http://localhost:3001/callback');

Map<String, Object?> _discovery(String issuer) => {
  'issuer': issuer,
  'authorization_endpoint': '$issuer/protocol/openid-connect/auth',
  'token_endpoint': '$issuer/protocol/openid-connect/token',
  'end_session_endpoint': '$issuer/protocol/openid-connect/logout',
  'jwks_uri': '$issuer/protocol/openid-connect/certs',
  'response_types_supported': ['code', 'none', 'id_token', 'token'],
  'grant_types_supported': ['authorization_code', 'refresh_token'],
  'scopes_supported': ['openid', 'profile', 'email', 'offline_access'],
  'code_challenge_methods_supported': ['plain', 'S256'],
  'token_endpoint_auth_methods_supported': ['client_secret_post', 'none'],
  'subject_types_supported': ['public'],
  'id_token_signing_alg_values_supported': ['RS256'],
};

String _accessToken({String user = 'admin', int exp = 4102444800}) => fakeJwt({
  'sub': 'kc-sub-1',
  'preferred_username': user,
  'name': 'Administrator',
  'tenant_id': 1,
  'exp': exp,
  'aud': 'wms-api',
  'realm_access': {
    'roles': ['ADMIN'],
  },
});

/// Records every request the OIDC client makes and answers discovery plus
/// the token endpoint, so the whole exchange runs without a network.
class StubIdp {
  StubIdp({this.issuer = _issuer, Map<String, Object?>? tokenResponse})
    : tokenResponse =
          tokenResponse ??
          {
            'access_token': _accessToken(),
            'refresh_token': 'refresh-1',
            'id_token': fakeJwt({'sub': 'kc-sub-1', 'aud': 'wms-web'}),
            'token_type': 'Bearer',
            'expires_in': 900,
          };

  final String issuer;
  Map<String, Object?> tokenResponse;
  int tokenStatus = 200;

  final List<Uri> requested = [];
  final List<Map<String, String>> tokenRequests = [];

  http.Client get client => MockClient((request) async {
    requested.add(request.url);
    if (request.url.path.endsWith('/.well-known/openid-configuration')) {
      return http.Response(
        jsonEncode(_discovery(issuer)),
        200,
        request: request,
        headers: const {'content-type': 'application/json'},
      );
    }
    if (request.url.path.endsWith('/token')) {
      tokenRequests.add(Uri.splitQueryString(request.body));
      return http.Response(
        jsonEncode(tokenResponse),
        tokenStatus,
        request: request,
        headers: const {'content-type': 'application/json'},
      );
    }
    return http.Response('{}', 404, request: request);
  });
}

KeycloakAuthWeb repository({
  required StubIdp idp,
  required RecordingBrowser browser,
  PendingAuthorizationStore? pending,
  TokenStore? store,
}) {
  final repo = KeycloakAuthWeb(
    issuer: idp.issuer,
    clientId: 'wms-web',
    redirectUri: _redirect,
    browser: browser,
    store: store ?? InMemoryTokenStore(),
    pendingStore: pending ?? InMemoryPendingAuthorizationStore(),
    httpClient: idp.client,
  );
  addTearDown(repo.dispose);
  return repo;
}

void main() {
  group('redirect URI derivation', () {
    test('drops query and fragment, keeps the origin', () {
      expect(
        KeycloakAuthWeb.originOf(
          Uri.parse('http://localhost:3001/inventory/balances?x=1#y'),
        ).toString(),
        'http://localhost:3001/callback',
      );
      expect(
        KeycloakAuthWeb.originOf(
          Uri.parse('https://wms.example.az/admin/users'),
        ).toString(),
        'https://wms.example.az/callback',
      );
    });

    test('post logout target is the app root', () {
      final repo = repository(idp: StubIdp(), browser: RecordingBrowser());
      expect(repo.postLogoutRedirectUri.toString(), 'http://localhost:3001/');
    });
  });

  group('beginAuthorization', () {
    test('builds an Authorization Code + PKCE (S256) request', () async {
      final idp = StubIdp();
      final browser = RecordingBrowser();
      final pending = InMemoryPendingAuthorizationStore();
      final repo = repository(idp: idp, browser: browser, pending: pending);

      final uri = await repo.beginAuthorization(
        returnTo: '/inventory/balances',
      );

      expect(uri.origin, 'http://localhost:8180');
      expect(uri.path, '/realms/wms/protocol/openid-connect/auth');
      final q = uri.queryParameters;
      expect(q['response_type'], 'code');
      expect(q['client_id'], 'wms-web');
      expect(q['redirect_uri'], 'http://localhost:3001/callback');
      expect(q['code_challenge_method'], 'S256');
      expect(q['scope'], contains('openid'));

      // The challenge on the wire must match the stored verifier.
      final stored = pending.read()!;
      expect(q['state'], stored.state);
      expect(q['code_challenge'], Pkce.challengeFor(stored.codeVerifier));
      expect(stored.codeVerifier.length, greaterThanOrEqualTo(43));
      expect(stored.returnTo, '/inventory/balances');

      // And the browser actually left for it.
      expect(browser.navigations.single, uri.toString());
    });

    test('an off-site returnTo is refused (open redirect)', () async {
      final pending = InMemoryPendingAuthorizationStore();
      final repo = repository(
        idp: StubIdp(),
        browser: RecordingBrowser(),
        pending: pending,
      );

      await repo.beginAuthorization(returnTo: 'https://evil.example/steal');
      expect(pending.read()!.returnTo, isNull);

      await repo.beginAuthorization(returnTo: '//evil.example');
      expect(pending.read()!.returnTo, isNull);

      await repo.beginAuthorization(returnTo: '/callback?code=x');
      expect(pending.read()!.returnTo, isNull);

      await repo.beginAuthorization(returnTo: '/admin/users');
      expect(pending.read()!.returnTo, '/admin/users');
    });

    test('performLogin derives returnTo from the current page', () async {
      final browser = RecordingBrowser(
        initialUri: Uri.parse('http://localhost:3001/admin/roles?q=a'),
      );
      final pending = InMemoryPendingAuthorizationStore();
      final repo = repository(
        idp: StubIdp(),
        browser: browser,
        pending: pending,
      );

      await expectLater(repo.performLogin(), throwsA(isA<AppException>()));
      expect(pending.read()!.returnTo, '/admin/roles?q=a');
      expect(browser.navigations, hasLength(1));
    });
  });

  group('completeRedirect', () {
    test('exchanges the code with the stored verifier', () async {
      final idp = StubIdp();
      final browser = RecordingBrowser();
      final pending = InMemoryPendingAuthorizationStore();
      final repo = repository(idp: idp, browser: browser, pending: pending);

      await repo.beginAuthorization(returnTo: '/inventory/balances');
      final stored = pending.read()!;

      final result = await repo.completeRedirect(
        Uri.parse(
          'http://localhost:3001/callback?code=auth-code-1'
          '&state=${stored.state}&iss=${Uri.encodeComponent(_issuer)}',
        ),
      );

      final body = idp.tokenRequests.single;
      expect(body['grant_type'], 'authorization_code');
      expect(body['code'], 'auth-code-1');
      expect(body['client_id'], 'wms-web');
      expect(body['redirect_uri'], 'http://localhost:3001/callback');
      expect(body['code_verifier'], stored.codeVerifier);

      expect(result.returnTo, '/inventory/balances');
      expect(result.session.username, 'admin');
      expect(result.session.tenantId, 1);
      expect(result.session.refreshToken, 'refresh-1');
      expect(result.session.idToken, isNotNull);
      expect(repo.isAuthenticated, isTrue);
      // The one-shot request must not be replayable.
      expect(pending.read(), isNull);
    });

    test('persists the session so a reload keeps it', () async {
      final store = InMemoryTokenStore();
      final idp = StubIdp();
      final pending = InMemoryPendingAuthorizationStore();
      final repo = repository(
        idp: idp,
        browser: RecordingBrowser(),
        pending: pending,
        store: store,
      );
      await repo.beginAuthorization();
      final stored = pending.read()!;
      await repo.completeRedirect(
        Uri.parse('/callback?code=c&state=${stored.state}'),
      );

      final persisted = await store.read();
      expect(persisted?.username, 'admin');

      // A "new page load" restores it without touching Keycloak.
      final reloaded = repository(
        idp: idp,
        browser: RecordingBrowser(),
        store: store,
      );
      expect((await reloaded.restore())?.username, 'admin');
      expect(reloaded.isAuthenticated, isTrue);
    });

    test('a forged state is refused before the token request', () async {
      final idp = StubIdp();
      final pending = InMemoryPendingAuthorizationStore();
      final repo = repository(
        idp: idp,
        browser: RecordingBrowser(),
        pending: pending,
      );
      await repo.beginAuthorization();

      await expectLater(
        repo.completeRedirect(Uri.parse('/callback?code=c&state=not-mine')),
        throwsA(
          isA<AppException>().having(
            (e) => (e.failure as ServerFailure).code,
            'code',
            'STATE_MISMATCH',
          ),
        ),
      );
      expect(idp.tokenRequests, isEmpty);
      expect(pending.read(), isNull);
    });

    test('a callback from another issuer is refused (RFC 9207)', () async {
      final idp = StubIdp();
      final pending = InMemoryPendingAuthorizationStore();
      final repo = repository(
        idp: idp,
        browser: RecordingBrowser(),
        pending: pending,
      );
      await repo.beginAuthorization();
      final state = pending.read()!.state;

      await expectLater(
        repo.completeRedirect(
          Uri.parse('/callback?code=c&state=$state&iss=https://evil.example'),
        ),
        throwsA(
          isA<AppException>().having(
            (e) => (e.failure as ServerFailure).code,
            'code',
            'ISSUER_MISMATCH',
          ),
        ),
      );
      expect(idp.tokenRequests, isEmpty);
    });

    test('an expired request is refused', () async {
      final idp = StubIdp();
      final pending = InMemoryPendingAuthorizationStore()
        ..write(
          PendingAuthorization.start(
            redirectUri: _redirect,
            state: 'old-state',
            now: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
        );
      final repo = repository(
        idp: idp,
        browser: RecordingBrowser(),
        pending: pending,
      );

      await expectLater(
        repo.completeRedirect(Uri.parse('/callback?code=c&state=old-state')),
        throwsA(isA<AppException>()),
      );
      expect(idp.tokenRequests, isEmpty);
    });

    test('a provider error keeps its own OAuth code', () async {
      final repo = repository(idp: StubIdp(), browser: RecordingBrowser());

      await expectLater(
        repo.completeRedirect(
          Uri.parse(
            '/callback?error=access_denied&error_description=User+said+no',
          ),
        ),
        throwsA(
          isA<AppException>()
              .having(
                (e) => (e.failure as ServerFailure).code,
                'code',
                'access_denied',
              )
              .having(
                (e) => (e.failure as ServerFailure).problem.detail,
                'detail',
                'User said no',
              ),
        ),
      );
    });

    test('a URL without a code says so instead of hanging', () async {
      final repo = repository(idp: StubIdp(), browser: RecordingBrowser());
      await expectLater(
        repo.completeRedirect(Uri.parse('/callback')),
        throwsA(isA<AppException>()),
      );
    });

    test('a callback with no pending request is refused', () async {
      final idp = StubIdp();
      final repo = repository(idp: idp, browser: RecordingBrowser());
      await expectLater(
        repo.completeRedirect(Uri.parse('/callback?code=c&state=s')),
        throwsA(isA<AppException>()),
      );
      expect(idp.tokenRequests, isEmpty);
    });
  });

  group('refresh', () {
    test('uses the refresh_token grant and keeps the permissions', () async {
      final idp = StubIdp();
      final pending = InMemoryPendingAuthorizationStore();
      final repo = repository(
        idp: idp,
        browser: RecordingBrowser(),
        pending: pending,
      );
      await repo.beginAuthorization();
      final signIn = await repo.completeRedirect(
        Uri.parse('/callback?code=c&state=${pending.read()!.state}'),
      );
      await repo.updateSession(
        signIn.session.copyWith(
          permissions: {Permissions.userManage},
          locationIds: const [3],
        ),
      );

      idp.tokenResponse = {
        'access_token': _accessToken(),
        'refresh_token': 'refresh-2',
        'token_type': 'Bearer',
        'expires_in': 900,
      };
      final refreshed = await repo.refresh();

      expect(refreshed.isOk, isTrue);
      final body = idp.tokenRequests.last;
      expect(body['grant_type'], 'refresh_token');
      expect(body['refresh_token'], 'refresh-1');
      expect(body['client_id'], 'wms-web');

      final session = refreshed.valueOrNull!;
      expect(session.refreshToken, 'refresh-2');
      expect(session.permissions, {Permissions.userManage});
      expect(session.locationIds, [3]);
      // The id token survives a response that omits it (needed for logout).
      expect(session.idToken, isNotNull);
    });

    test('a session without a refresh token cannot be renewed', () async {
      final repo = repository(idp: StubIdp(), browser: RecordingBrowser());
      await expectLater(
        repo.performRefresh(Session.fromTokens(accessToken: _accessToken())),
        throwsA(isA<AppException>()),
      );
    });

    test(
      'refreshing after a reload works from the stored token alone',
      () async {
        final idp = StubIdp();
        final store = InMemoryTokenStore();
        await store.write(
          Session.fromTokens(
            accessToken: _accessToken(),
            refreshToken: 'refresh-from-storage',
          ),
        );
        final repo = repository(
          idp: idp,
          browser: RecordingBrowser(),
          store: store,
        );
        await repo.restore();

        final result = await repo.refresh();

        expect(result.isOk, isTrue);
        expect(idp.tokenRequests.single['grant_type'], 'refresh_token');
        expect(
          idp.tokenRequests.single['refresh_token'],
          'refresh-from-storage',
        );
      },
    );
  });

  group('logout', () {
    test('ends the Keycloak session with the id token hint', () async {
      final idp = StubIdp();
      final browser = RecordingBrowser();
      final pending = InMemoryPendingAuthorizationStore();
      final repo = repository(idp: idp, browser: browser, pending: pending);
      await repo.beginAuthorization();
      await repo.completeRedirect(
        Uri.parse('/callback?code=c&state=${pending.read()!.state}'),
      );

      await repo.logout();

      final url = Uri.parse(browser.navigations.last);
      expect(url.path, '/realms/wms/protocol/openid-connect/logout');
      expect(url.queryParameters['id_token_hint'], isNotNull);
      expect(
        url.queryParameters['post_logout_redirect_uri'],
        'http://localhost:3001/',
      );
      expect(repo.isAuthenticated, isFalse);
    });

    test('falls back to client_id when there is no id token', () async {
      final browser = RecordingBrowser();
      final repo = repository(idp: StubIdp(), browser: browser);

      await repo.performLogout(Session.fromTokens(accessToken: _accessToken()));

      final url = Uri.parse(browser.navigations.last);
      expect(url.queryParameters['client_id'], 'wms-web');
      expect(url.queryParameters.containsKey('id_token_hint'), isFalse);
      expect(
        url.queryParameters['post_logout_redirect_uri'],
        'http://localhost:3001/',
      );
    });

    test(
      'a local sign-out still succeeds when the IdP is unreachable',
      () async {
        final idp = StubIdp(issuer: 'http://localhost:9/realms/none');
        final repo = KeycloakAuthWeb(
          issuer: idp.issuer,
          clientId: 'wms-web',
          redirectUri: _redirect,
          browser: RecordingBrowser(),
          store: InMemoryTokenStore(),
          pendingStore: InMemoryPendingAuthorizationStore(),
          httpClient: MockClient(
            (request) async => http.Response('boom', 500, request: request),
          ),
        );
        addTearDown(repo.dispose);
        await repo.updateSession(
          Session.fromTokens(accessToken: _accessToken()),
        );

        await repo.logout();
        expect(repo.isAuthenticated, isFalse);
      },
    );
  });

  group('RecordingBrowser', () {
    test('tracks navigations and history rewrites', () {
      final browser = RecordingBrowser()
        ..assign('http://localhost:3001/callback?code=1')
        ..replaceUrl('http://localhost:3001/inventory/balances');
      expect(browser.navigations, hasLength(1));
      expect(browser.replacements, hasLength(1));
      expect(browser.currentUri.path, '/inventory/balances');
    });
  });
}
