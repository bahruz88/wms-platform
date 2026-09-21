import 'package:flutter_test/flutter_test.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';

import 'test_jwt.dart';

void main() {
  test('Session.fromTokens parses tenant, roles and expiry', () {
    final session = Session.fromTokens(
      accessToken: fakeJwt(keeperClaims()),
      refreshToken: 'r',
    );
    expect(session.tenantId, 1);
    expect(session.username, 'keeper');
    expect(session.displayName, 'Anbardar Kamil');
    expect(session.hasRole(Roles.warehouseKeeper), isTrue);
    expect(session.isExpired(), isFalse);
    expect(session.hasPermission(Permissions.productViewCost), isFalse);
  });

  test('missing tenant_id is rejected', () {
    final claims = keeperClaims()..remove('tenant_id');
    expect(
      () => Session.fromTokens(accessToken: fakeJwt(claims)),
      throwsFormatException,
    );
  });

  test('isExpired honours leeway', () {
    final soon = DateTime.now().toUtc().add(const Duration(seconds: 10));
    final session = Session.fromTokens(
      accessToken: fakeJwt(keeperClaims()),
      expiresAt: soon,
    );
    expect(session.isExpired(), isTrue);
    expect(session.isExpired(leeway: Duration.zero), isFalse);
  });

  test('JSON round trip keeps permissions', () {
    final session = Session.fromTokens(accessToken: fakeJwt(keeperClaims()))
        .copyWith(permissions: {Permissions.receiptCreate}, locationIds: [3]);
    final restored = Session.fromJson(session.toJson());
    expect(restored, session);
    expect(restored.permissions, {Permissions.receiptCreate});
    expect(restored.locationIds, [3]);
  });

  test('InMemoryTokenStore and FakeAuthRepository flow', () async {
    final store = InMemoryTokenStore();
    final repo = FakeAuthRepository(
      session: Session.fromTokens(
        accessToken: fakeJwt(keeperClaims()),
        refreshToken: 'refresh-token',
      ),
      store: store,
    );
    final events = <Session?>[];
    final sub = repo.sessionChanges.listen(events.add);

    expect(await repo.restore(), isNull);
    final login = await repo.login();
    expect(login.isOk, isTrue);
    expect(repo.isAuthenticated, isTrue);
    expect(await store.read(), isNotNull);

    final refresh = await repo.refresh();
    expect(refresh.isOk, isTrue);
    expect(repo.refreshCount, 1);

    // Without a refresh token the repository fails instead of looping.
    final noToken = FakeAuthRepository(
      session: Session.fromTokens(accessToken: fakeJwt(keeperClaims())),
    );
    await noToken.login();
    expect((await noToken.refresh()).failureOrNull, isA<UnauthorizedFailure>());
    noToken.dispose();

    await repo.logout();
    expect(repo.isAuthenticated, isFalse);
    expect(await store.read(), isNull);
    await Future<void>.delayed(Duration.zero);
    expect(events.last, isNull);
    await sub.cancel();
    repo.dispose();
  });

  test('SessionTokenProvider refreshes expired sessions', () async {
    final expired = Session.fromTokens(
      accessToken: fakeJwt(keeperClaims()),
      refreshToken: 'r',
      expiresAt: DateTime.now().toUtc().subtract(const Duration(minutes: 1)),
    );
    final repo = FakeAuthRepository(session: expired);
    await repo.login();
    final provider = SessionTokenProvider(repo);
    expect(await provider.getAccessToken(), isNotNull);
    expect(repo.refreshCount, 1);
    expect(await provider.refresh(), isTrue);
    await provider.onUnauthorized();
    expect(repo.isAuthenticated, isFalse);
    repo.dispose();
  });
}
