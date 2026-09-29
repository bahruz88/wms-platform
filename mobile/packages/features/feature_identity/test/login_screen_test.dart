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
  Future<Session> performLogin({String? username, String? password}) async =>
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

/// Fills the two fields the way a keeper would.
Future<void> enterCredentials(
  WidgetTester tester, {
  String username = 'admin',
  String password = 'admin',
}) async {
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), username);
  await tester.enterText(fields.at(1), password);
  await tester.pump();
}

void main() {
  testWidgets('signs in with the credentials typed into the form', (
    tester,
  ) async {
    final repository = FakeAuthRepository(session: testSession());
    addTearDown(repository.dispose);
    await tester.pumpWidget(host(repository));
    await tester.pumpAndSettle();

    await enterCredentials(tester);
    await tester.tap(find.text('Daxil ol'));
    await tester.pumpAndSettle();
    expect(repository.isAuthenticated, isTrue);
  });

  testWidgets('will not submit an incomplete form', (tester) async {
    final repository = FakeAuthRepository(session: testSession());
    addTearDown(repository.dispose);
    await tester.pumpWidget(host(repository));
    await tester.pumpAndSettle();

    // A username with no password: the button stays disabled rather than
    // sending a request that can only come back 401.
    await tester.enterText(find.byType(TextField).at(0), 'admin');
    await tester.pump();
    await tester.tap(find.text('Daxil ol'));
    await tester.pumpAndSettle();
    expect(repository.isAuthenticated, isFalse);
  });

  testWidgets('shows the failure as a WmsAlert', (tester) async {
    final repository = _FailingAuthRepository();
    addTearDown(repository.dispose);
    await tester.pumpWidget(host(repository));
    await tester.pumpAndSettle();

    await enterCredentials(tester);
    await tester.tap(find.text('Daxil ol'));
    await tester.pumpAndSettle();
    expect(find.byType(WmsAlert), findsOneWidget);
    expect(find.text('Şəbəkə xətası'), findsOneWidget);
    expect(repository.isAuthenticated, isFalse);
  });

  testWidgets('the password is masked', (tester) async {
    final repository = FakeAuthRepository(session: testSession());
    addTearDown(repository.dispose);
    await tester.pumpWidget(host(repository));
    await tester.pumpAndSettle();

    final password = tester.widget<TextField>(find.byType(TextField).at(1));
    expect(password.obscureText, isTrue);
    // A masked field must not feed the keyboard's dictionary.
    expect(password.enableSuggestions, isFalse);
    expect(password.autocorrect, isFalse);
  });
}
