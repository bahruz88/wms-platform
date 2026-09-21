import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_mobile/auth/keycloak_auth_mobile.dart';

import 'test_doubles.dart';

String _accessToken({int exp = 4102444800}) => fakeJwt({
  'sub': 'kc-sub-7',
  'preferred_username': 'keeper',
  'name': 'Anbardar Kamil',
  'tenant_id': 1,
  'exp': exp,
  'realm_access': {
    'roles': ['WAREHOUSE_KEEPER'],
  },
});

/// Records every AppAuth call so the OIDC request shapes can be asserted
/// without a platform channel.
class FakeAppAuth implements FlutterAppAuth {
  FakeAppAuth({this.idToken = 'id-token-1', this.refreshToken = 'refresh-1'});

  final String? idToken;
  final String? refreshToken;

  final List<AuthorizationTokenRequest> authorizations = [];
  final List<TokenRequest> tokenRequests = [];
  final List<EndSessionRequest> endSessions = [];
  Object? endSessionError;

  @override
  Future<AuthorizationTokenResponse> authorizeAndExchangeCode(
    AuthorizationTokenRequest request,
  ) async {
    authorizations.add(request);
    return AuthorizationTokenResponse(
      _accessToken(),
      refreshToken,
      DateTime.now().add(const Duration(minutes: 15)),
      idToken,
      'Bearer',
      const ['openid'],
      null,
      null,
    );
  }

  @override
  Future<TokenResponse> token(TokenRequest request) async {
    tokenRequests.add(request);
    return TokenResponse(
      _accessToken(),
      'refresh-2',
      DateTime.now().add(const Duration(minutes: 15)),
      null,
      'Bearer',
      const ['openid'],
      null,
    );
  }

  @override
  Future<EndSessionResponse> endSession(EndSessionRequest request) async {
    endSessions.add(request);
    final error = endSessionError;
    if (error != null) throw StateError('$error');
    return EndSessionResponse('state');
  }

  @override
  Future<AuthorizationResponse> authorize(AuthorizationRequest request) async =>
      throw UnimplementedError();
}

KeycloakAuthMobile repository(FakeAppAuth appAuth, {String? issuer}) =>
    KeycloakAuthMobile(
      issuer: issuer ?? 'http://localhost:8180/realms/wms',
      clientId: 'wms-mobile',
      store: InMemoryTokenStore(),
      appAuth: appAuth,
    );

void main() {
  group('login', () {
    test(
      'asks AppAuth for the registered redirect and offline access',
      () async {
        final appAuth = FakeAppAuth();
        final repo = repository(appAuth);
        addTearDown(repo.dispose);

        final result = await repo.login();

        expect(result.isOk, isTrue);
        final request = appAuth.authorizations.single;
        expect(request.clientId, 'wms-mobile');
        expect(request.redirectUrl, 'az.wms.mobile://callback');
        expect(request.issuer, 'http://localhost:8180/realms/wms');
        expect(request.scopes, contains('offline_access'));
        // Plain HTTP is only tolerated for the local dev realm.
        expect(request.allowInsecureConnections, isTrue);

        final session = result.valueOrNull!;
        expect(session.username, 'keeper');
        expect(session.tenantId, 1);
        expect(session.idToken, 'id-token-1');
      },
    );

    test('an https issuer does not allow insecure connections', () async {
      final appAuth = FakeAppAuth();
      final repo = repository(
        appAuth,
        issuer: 'https://auth.example.az/realms/wms',
      );
      addTearDown(repo.dispose);

      await repo.login();
      expect(appAuth.authorizations.single.allowInsecureConnections, isFalse);
    });
  });

  group('refresh', () {
    test('keeps the permissions and the previous id token', () async {
      final appAuth = FakeAppAuth();
      final repo = repository(appAuth);
      addTearDown(repo.dispose);
      await repo.login();
      await repo.updateSession(
        repo.currentSession!.copyWith(
          permissions: {Permissions.receiptCreate},
          locationIds: const [3],
        ),
      );

      final refreshed = await repo.refresh();

      expect(refreshed.isOk, isTrue);
      final request = appAuth.tokenRequests.single;
      expect(request.grantType, 'refresh_token');
      expect(request.refreshToken, 'refresh-1');
      final session = refreshed.valueOrNull!;
      expect(session.refreshToken, 'refresh-2');
      expect(session.permissions, {Permissions.receiptCreate});
      expect(session.locationIds, [3]);
      // The token endpoint did not return an id token; the old one survives
      // because logout needs the hint.
      expect(session.idToken, 'id-token-1');
    });
  });

  group('logout', () {
    test('ends the Keycloak session with the id token hint', () async {
      final appAuth = FakeAppAuth();
      final repo = repository(appAuth);
      addTearDown(repo.dispose);
      await repo.login();

      await repo.logout();

      final request = appAuth.endSessions.single;
      expect(request.idTokenHint, 'id-token-1');
      expect(request.postLogoutRedirectUrl, 'az.wms.mobile://callback');
      expect(request.issuer, 'http://localhost:8180/realms/wms');
      expect(request.additionalParameters, isNull);
      expect(repo.isAuthenticated, isFalse);
    });

    test('a session without an id token still ends the SSO session', () async {
      // Keycloak answers 400 to an end-session request that carries neither
      // `id_token_hint` nor `client_id`, so the client id is the fallback.
      final appAuth = FakeAppAuth(idToken: null);
      final repo = repository(appAuth);
      addTearDown(repo.dispose);
      await repo.login();

      await repo.logout();

      expect(appAuth.endSessions, hasLength(1));
      final request = appAuth.endSessions.single;
      expect(request.idTokenHint, isNull);
      expect(request.additionalParameters, {'client_id': 'wms-mobile'});
      expect(request.postLogoutRedirectUrl, 'az.wms.mobile://callback');
    });

    test('an unreachable IdP does not block the local sign-out', () async {
      final appAuth = FakeAppAuth()..endSessionError = 'network down';
      final repo = repository(appAuth);
      addTearDown(repo.dispose);
      await repo.login();

      await repo.logout();

      expect(appAuth.endSessions, hasLength(1));
      expect(repo.isAuthenticated, isFalse);
      expect(repo.currentSession, isNull);
    });
  });

  test('a token response without an access token is an auth failure', () async {
    final repo = repository(_EmptyAppAuth());
    addTearDown(repo.dispose);

    final result = await repo.login();

    expect(result.isErr, isTrue);
    expect(result.failureOrNull, isA<UnauthorizedFailure>());
  });
}

class _EmptyAppAuth extends FakeAppAuth {
  @override
  Future<AuthorizationTokenResponse> authorizeAndExchangeCode(
    AuthorizationTokenRequest request,
  ) async => AuthorizationTokenResponse(
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
  );
}
