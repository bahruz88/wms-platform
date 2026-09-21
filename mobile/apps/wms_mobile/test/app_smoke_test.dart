import 'package:feature_identity/feature_identity.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_mobile/app.dart';
import 'package:wms_mobile/config/flavors.dart';

import 'test_doubles.dart';

const _config = AppConfig(
  env: AppEnv(
    apiBaseUrl: 'http://localhost:5001',
    keycloakIssuer: 'http://localhost:8180/realms/wms',
    keycloakClientId: 'wms-mobile',
    flavor: 'dev',
  ),
  flavor: Flavor.dev,
);

Widget host(AuthRepository repository) => ProviderScope(
  overrides: [
    authRepositoryProvider.overrideWithValue(repository),
    apiClientProvider.overrideWithValue(fakeApiClient()),
    barcodeScannerProvider.overrideWithValue(const UnsupportedBarcodeScanner()),
  ],
  child: const WmsMobileApp(config: _config),
);

void main() {
  testWidgets('anonymous start lands on the login screen', (tester) async {
    final repository = FakeAuthRepository(session: testSession());
    addTearDown(repository.dispose);

    await tester.pumpWidget(host(repository));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Daxil ol'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('a signed-in keeper sees the bottom navigation shell', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repository = FakeAuthRepository(
      session: testSession(permissions: {Permissions.balanceView}),
    );
    addTearDown(repository.dispose);
    await repository.login();

    await tester.pumpWidget(host(repository));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Anbar'), findsWidgets);
    expect(find.text('Sənədlər'), findsOneWidget);
    expect(find.text('Bildirişlər'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
    // Warehouse keepers must never see cost data (spec §7.1, §16).
    expect(find.text('Dəyər'), findsNothing);
  });

  test('flavour and redirect configuration', () {
    expect(AppConfig.redirectScheme, 'az.wms.mobile');
    expect(AppConfig.redirectUrl, 'az.wms.mobile://callback');
    expect(Flavor.fromKey('prod'), Flavor.prod);
    expect(Flavor.fromKey('unknown'), Flavor.dev);
    expect(_config.clientId, 'wms-mobile');
    expect(_config.banner, 'dev');
  });
}
