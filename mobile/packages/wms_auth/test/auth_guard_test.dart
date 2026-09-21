import 'package:flutter_test/flutter_test.dart';
import 'package:wms_auth/wms_auth.dart';

import 'test_jwt.dart';

void main() {
  late FakeAuthRepository repo;
  late AuthGuard guard;

  setUp(() {
    repo = FakeAuthRepository(
      session: Session.fromTokens(accessToken: fakeJwt(keeperClaims())),
    );
    guard = AuthGuard(
      repository: repo,
      homePath: '/warehouse',
      publicPaths: const {'/about'},
    );
  });

  tearDown(() {
    guard.dispose();
    repo.dispose();
  });

  test('anonymous users are sent to login with the original location', () {
    expect(
      guard.resolve(
        authenticated: false,
        location: '/inventory/receipts/5',
        matchedLocation: '/inventory/receipts/:id',
      ),
      '/login?from=%2Finventory%2Freceipts%2F5',
    );
    expect(
      guard.resolve(
        authenticated: false,
        location: '/login',
        matchedLocation: '/login',
      ),
      isNull,
    );
    expect(
      guard.resolve(
        authenticated: false,
        location: '/about',
        matchedLocation: '/about',
      ),
      isNull,
    );
  });

  test(
    'authenticated users skip login and return to the original location',
    () {
      expect(
        guard.resolve(
          authenticated: true,
          location: '/login?from=%2Fproc%2Fpo%2F1',
          matchedLocation: '/login',
          queryParameters: const {'from': '%2Fproc%2Fpo%2F1'},
        ),
        '/proc/po/1',
      );
      expect(
        guard.resolve(
          authenticated: true,
          location: '/login',
          matchedLocation: '/login',
        ),
        '/warehouse',
      );
      expect(
        guard.resolve(
          authenticated: true,
          location: '/x',
          matchedLocation: '/x',
        ),
        isNull,
      );
    },
  );

  test('guard notifies listeners on session changes', () async {
    var notified = 0;
    guard.addListener(() => notified++);
    await repo.login();
    await Future<void>.delayed(Duration.zero);
    expect(notified, 1);
  });
}
