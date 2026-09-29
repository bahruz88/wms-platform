import 'package:feature_consumption/feature_consumption.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wms_auth/wms_auth.dart';

Session sessionWith(List<int> locationIds) => Session(
  accessToken: 'token',
  userId: 'user-1',
  username: 'admin',
  tenantId: 1,
  locationIds: locationIds,
);

ProviderContainer containerFor(Session? session) {
  final repository = FakeAuthRepository(
    session:
        session ??
        Session(
          accessToken: 'token',
          userId: 'user-1',
          username: 'admin',
          tenantId: 1,
        ),
  );
  final container = ProviderContainer(
    overrides: [authRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  addTearDown(repository.dispose);
  return container;
}

void main() {
  test('one assigned location is used without asking', () async {
    final container = containerFor(sessionWith([7]));
    await container.read(authRepositoryProvider).login();

    expect(container.read(branchLocationIdProvider), 7);
  });

  test('an unrestricted account is asked which branch, not refused', () async {
    // The contract: "Görünən lokasiyalar. Boş = məhdudiyyət yoxdur." An empty
    // list is an administrator who sees every branch, and the screens used to
    // read it as "no branch assigned" and lock them out.
    final container = containerFor(sessionWith(const []));
    await container.read(authRepositoryProvider).login();

    expect(container.read(branchLocationIdProvider), isNull);

    container.read(chosenBranchLocationIdProvider.notifier).choose(3);
    expect(container.read(branchLocationIdProvider), 3);
  });

  test('several assigned locations are asked about too', () async {
    final container = containerFor(sessionWith([4, 9]));
    await container.read(authRepositoryProvider).login();

    expect(container.read(branchLocationIdProvider), isNull);

    container.read(chosenBranchLocationIdProvider.notifier).choose(9);
    expect(container.read(branchLocationIdProvider), 9);
  });
}
