import 'package:feature_identity/feature_identity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import 'test_session.dart';

class _FailingAuthRepository extends FakeAuthRepository {
  _FailingAuthRepository() : super(session: testSession());

  @override
  Future<Session> performLogin() async =>
      throw const AppException(NetworkFailure());
}

Widget host(AuthRepository repository) => ProviderScope(
  overrides: [authRepositoryProvider.overrideWithValue(repository)],
  child: MaterialApp(
    theme: WmsTheme.light(),
    locale: WmsL10n.defaultLocale,
    supportedLocales: WmsL10n.supportedLocales,
    localizationsDelegates: WmsL10n.delegates,
    home: const LoginScreen(),
  ),
);

void main() {
  testWidgets('delegates the flow to AuthRepository', (tester) async {
    final repository = FakeAuthRepository(session: testSession());
    addTearDown(repository.dispose);
    await tester.pumpWidget(host(repository));
    await tester.pumpAndSettle();

    expect(find.text('Daxil ol'), findsOneWidget);
    await tester.tap(find.text('Daxil ol'));
    await tester.pumpAndSettle();
    expect(repository.isAuthenticated, isTrue);
  });

  testWidgets('shows the failure as a WmsAlert', (tester) async {
    final repository = _FailingAuthRepository();
    addTearDown(repository.dispose);
    await tester.pumpWidget(host(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Daxil ol'));
    await tester.pumpAndSettle();
    expect(find.byType(WmsAlert), findsOneWidget);
    expect(find.text('Şəbəkə xətası'), findsOneWidget);
    expect(repository.isAuthenticated, isFalse);
  });
}
