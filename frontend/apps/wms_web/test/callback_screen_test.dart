import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';
import 'package:wms_web/auth/browser.dart';
import 'package:wms_web/auth/keycloak_auth_web.dart';
import 'package:wms_web/router/callback_screen.dart';

import 'test_doubles.dart';

const _issuer = 'http://localhost:8180/realms/wms';

Map<String, Object?> _discovery() => {
  'issuer': _issuer,
  'authorization_endpoint': '$_issuer/protocol/openid-connect/auth',
  'token_endpoint': '$_issuer/protocol/openid-connect/token',
  'end_session_endpoint': '$_issuer/protocol/openid-connect/logout',
  'response_types_supported': ['code'],
  'scopes_supported': ['openid', 'profile', 'email'],
  'token_endpoint_auth_methods_supported': ['none'],
};

http.Client _idp({required bool tokenOk}) => MockClient((request) async {
  if (request.url.path.endsWith('/.well-known/openid-configuration')) {
    return http.Response(
      jsonEncode(_discovery()),
      200,
      request: request,
      headers: const {'content-type': 'application/json'},
    );
  }
  if (!tokenOk) {
    return http.Response(
      jsonEncode(const {
        'error': 'invalid_grant',
        'error_description': 'Code not valid',
      }),
      400,
      request: request,
      headers: const {'content-type': 'application/json'},
    );
  }
  return http.Response(
    jsonEncode({
      'access_token': fakeJwt({
        'sub': 'kc-1',
        'preferred_username': 'admin',
        'tenant_id': 1,
        'exp': 4102444800,
      }),
      'refresh_token': 'r1',
      'token_type': 'Bearer',
      'expires_in': 900,
    }),
    200,
    request: request,
    headers: const {'content-type': 'application/json'},
  );
});

Widget host({required AuthRepository repository, required String location}) {
  final router = GoRouter(
    initialLocation: location,
    routes: [
      ...callbackRoutes(),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const Text('İdarə paneli'),
      ),
      GoRoute(
        path: '/inventory/balances',
        builder: (context, state) => const Text('Qalıqlar ekranı'),
      ),
      GoRoute(path: '/login', builder: (context, state) => const Text('Giriş')),
    ],
  );
  addTearDown(router.dispose);
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp.router(
      theme: WmsTheme.light(),
      locale: WmsL10n.defaultLocale,
      supportedLocales: WmsL10n.supportedLocales,
      localizationsDelegates: WmsL10n.delegates,
      routerConfig: router,
    ),
  );
}

KeycloakAuthWeb _repository({
  required bool tokenOk,
  required PendingAuthorizationStore pending,
}) {
  final repo = KeycloakAuthWeb(
    issuer: _issuer,
    clientId: 'wms-web',
    redirectUri: Uri.parse('http://localhost:3001/callback'),
    browser: RecordingBrowser(),
    store: InMemoryTokenStore(),
    pendingStore: pending,
    httpClient: _idp(tokenOk: tokenOk),
  );
  addTearDown(repo.dispose);
  return repo;
}

void main() {
  testWidgets('a successful exchange continues to the original location', (
    tester,
  ) async {
    final pending = InMemoryPendingAuthorizationStore();
    final repo = _repository(tokenOk: true, pending: pending);
    await repo.beginAuthorization(returnTo: '/inventory/balances');
    final state = pending.read()!.state;

    await tester.pumpWidget(
      host(repository: repo, location: '/callback?code=abc&state=$state'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Qalıqlar ekranı'), findsOneWidget);
    expect(repo.isAuthenticated, isTrue);
    // A signed-in repository arms the silent refresh timer; the widget test
    // binding refuses to finish while it is pending.
    repo.dispose();
  });

  testWidgets('without a returnTo the dashboard is the destination', (
    tester,
  ) async {
    final pending = InMemoryPendingAuthorizationStore();
    final repo = _repository(tokenOk: true, pending: pending);
    await repo.beginAuthorization();
    final state = pending.read()!.state;

    await tester.pumpWidget(
      host(repository: repo, location: '/callback?code=abc&state=$state'),
    );
    await tester.pumpAndSettle();

    expect(find.text('İdarə paneli'), findsOneWidget);
    repo.dispose();
  });

  testWidgets('a failed exchange shows the problem and a way back', (
    tester,
  ) async {
    final pending = InMemoryPendingAuthorizationStore();
    final repo = _repository(tokenOk: false, pending: pending);
    await repo.beginAuthorization();
    final state = pending.read()!.state;

    await tester.pumpWidget(
      host(repository: repo, location: '/callback?code=abc&state=$state'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WmsAlert), findsOneWidget);
    expect(find.text('Giriş səhifəsinə qayıt'), findsOneWidget);

    await tester.tap(find.text('Giriş səhifəsinə qayıt'));
    await tester.pumpAndSettle();
    expect(find.text('Giriş'), findsOneWidget);
  });

  testWidgets('a provider error is rendered verbatim with its code', (
    tester,
  ) async {
    final repo = _repository(
      tokenOk: true,
      pending: InMemoryPendingAuthorizationStore(),
    );

    await tester.pumpWidget(
      host(
        repository: repo,
        location: '/callback?error=access_denied&error_description=No',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Keycloak girişi rədd etdi'), findsOneWidget);
    expect(find.textContaining('access_denied'), findsOneWidget);
  });

  testWidgets('a non-OIDC repository simply lands on the dashboard', (
    tester,
  ) async {
    final repo = FakeAuthRepository(session: testSession());
    addTearDown(repo.dispose);

    await tester.pumpWidget(host(repository: repo, location: '/callback'));
    await tester.pumpAndSettle();

    expect(find.text('İdarə paneli'), findsOneWidget);
  });

  test('the callback route is declared once, outside the shell', () {
    expect(CallbackRoutes.path, '/callback');
    expect(callbackRoutes(), hasLength(1));
  });
}
