import 'package:feature_identity/feature_identity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_web/app.dart';
import 'package:wms_web/config/flavors.dart';
import 'package:wms_web/router/admin_screen.dart';
import 'package:wms_web/router/callback_screen.dart';

import 'test_doubles.dart';

const _config = AppConfig(
  env: AppEnv(
    apiBaseUrl: 'http://localhost:5001',
    keycloakIssuer: 'http://localhost:8180/realms/wms',
    keycloakClientId: 'wms-web',
    flavor: 'dev',
  ),
  flavor: Flavor.dev,
);

Widget host(AuthRepository repository) => ProviderScope(
  overrides: [
    authRepositoryProvider.overrideWithValue(repository),
    apiClientProvider.overrideWithValue(fakeApiClient()),
  ],
  child: const WmsWebApp(config: _config),
);

void main() {
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
          ..physicalSize = const Size(1440, 900)
          ..devicePixelRatio = 1;
    addTearDown(view.reset);
  });

  testWidgets('anonymous start lands on the login screen', (tester) async {
    final repository = FakeAuthRepository(session: testSession());
    addTearDown(repository.dispose);

    await tester.pumpWidget(host(repository));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('a signed-in manager sees the navigation rail shell', (
    tester,
  ) async {
    final repository = FakeAuthRepository(
      session: testSession(
        roles: const ['PROCUREMENT_MANAGER'],
        permissions: {Permissions.poApprove, Permissions.reportView},
      ),
    );
    addTearDown(repository.dispose);
    await repository.login();

    await tester.pumpWidget(host(repository));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    for (final label in [
      'İdarə paneli',
      'Satınalma',
      'Anbar',
      'Master Data',
      'Hesabatlar',
      'Admin',
      'Bildirişlər',
    ]) {
      expect(find.text(label), findsWidgets, reason: 'rail item $label');
    }
  });

  testWidgets('admin section is permission gated', (tester) async {
    final repository = FakeAuthRepository(
      session: testSession(roles: const ['AUDITOR']),
    );
    addTearDown(repository.dispose);
    await repository.login();

    await tester.pumpWidget(host(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Admin').first);
    await tester.pumpAndSettle();

    expect(find.byType(AdminScreen), findsOneWidget);
    expect(find.text('Bu bölmə üçün icazəniz yoxdur'), findsOneWidget);
    expect(find.text('İstifadəçilər'), findsNothing);
  });

  testWidgets('an admin reaches the users, roles and settings screens', (
    tester,
  ) async {
    final repository = FakeAuthRepository(
      session: testSession(
        roles: const ['ADMIN'],
        permissions: {Permissions.userManage},
      ),
    );
    addTearDown(repository.dispose);
    await repository.login();

    await tester.pumpWidget(host(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Admin').first);
    await tester.pumpAndSettle();

    expect(find.byType(AdminScreen), findsOneWidget);
    expect(find.text('İstifadəçilər'), findsOneWidget);
    expect(find.text('Rollar'), findsOneWidget);
    expect(find.text('Parametrlər'), findsOneWidget);

    // Every card opens a real screen inside the admin branch.
    await tester.tap(find.widgetWithText(WmsButton, 'Aç').first);
    await tester.pumpAndSettle();
    expect(find.byType(AdminUserListScreen), findsOneWidget);
    expect(find.text('Bu filtrə uyğun istifadəçi yoxdur.'), findsOneWidget);
  });

  testWidgets('the OIDC callback route is public', (tester) async {
    final repository = FakeAuthRepository(session: testSession());
    addTearDown(repository.dispose);

    await tester.pumpWidget(host(repository));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    // An anonymous visit to /callback must not be bounced to /login, or the
    // authorization code would be lost.
    final guard = AuthGuard(
      repository: repository,
      publicPaths: const {CallbackRoutes.path},
    );
    addTearDown(guard.dispose);
    expect(
      guard.resolve(
        authenticated: false,
        location: '/callback?code=a&state=b',
        matchedLocation: '/callback',
      ),
      isNull,
    );
  });

  test('flavour configuration', () {
    expect(_config.clientId, 'wms-web');
    expect(Flavor.fromKey('stg'), Flavor.stg);
    expect(_config.flavor.appTitle, contains('dev'));
  });
}
