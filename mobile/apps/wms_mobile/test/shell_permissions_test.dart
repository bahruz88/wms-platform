import 'package:feature_identity/feature_identity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_l10n/wms_l10n.dart';
import 'package:wms_mobile/router/app_router.dart';

/// `/identity/me` answering with one permission the JWT does not carry.
class _Me implements IdentityRepository {
  _Me(this.granted);

  final Set<String> granted;
  int calls = 0;

  @override
  Future<Result<CurrentUserDto>> me() async {
    calls++;
    return Result.ok(
      CurrentUserDto(
        user: const UserSummaryDto(id: 1, username: 'admin', fullName: 'Admin'),
        tenant: const TenantDto(id: 1, code: 't', name: 'Tenant'),
        permissions: granted.toList(),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'the shell loads the permissions instead of waiting for the profile',
    (tester) async {
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      // The token carries no permissions at all, which is the real shape: they
      // live in `iam_role_permission`, not in the JWT.
      final repository = FakeAuthRepository(
        session: const Session(
          accessToken: 'token',
          userId: 'u1',
          username: 'admin',
          tenantId: 1,
        ),
      );
      addTearDown(repository.dispose);
      await repository.login();
      final identity = _Me({Permissions.salesImport});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(repository),
            identityRepositoryProvider.overrideWithValue(identity),
            // The task list's own calls go nowhere in a test; the list shows an
            // error, which is not what this test is about.
            apiClientProvider.overrideWithValue(
              WmsApiClient(
                baseUrl: 'http://localhost:1',
                tokenProvider: SessionTokenProvider(repository),
              ),
            ),
          ],
          child: Consumer(
            builder: (context, ref, _) => MaterialApp.router(
              routerConfig: ref.watch(goRouterProvider),
              locale: WmsL10n.defaultLocale,
              supportedLocales: WmsL10n.supportedLocales,
              localizationsDelegates: WmsL10n.delegates,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Exactly once: the provider writes the permissions back into the
      // session, and if it watched the session it would re-run its own fetch.
      expect(identity.calls, 1);
      // The branch tab is permission-gated, so it can only be here if the
      // permission arrived from `/identity/me`.
      expect(find.text('Filial'), findsOneWidget);
    },
  );
}
