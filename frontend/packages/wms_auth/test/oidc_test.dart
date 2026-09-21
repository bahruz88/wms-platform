import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:wms_auth/wms_auth.dart';

void main() {
  group('Pkce', () {
    test('RFC 7636 appendix B test vector', () {
      // The single normative example of the spec; if this drifts, Keycloak
      // will answer `invalid_grant` and nobody can sign in.
      const verifier = 'dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk';
      expect(
        Pkce.challengeFor(verifier),
        'E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM',
      );
    });

    test('generated verifier uses only unreserved characters', () {
      final pkce = Pkce.generate();
      expect(pkce.verifier, matches(RegExp(r'^[A-Za-z0-9\-._~]{64}$')));
      expect(pkce.challenge, isNot(contains('=')));
      expect(pkce.challenge, isNot(contains('+')));
      expect(pkce.challenge, isNot(contains('/')));
      expect(pkce.isValid, isTrue);
    });

    test('length is validated against RFC 7636 bounds', () {
      expect(Pkce.generate(length: 43).verifier, hasLength(43));
      expect(Pkce.generate(length: 128).verifier, hasLength(128));
      expect(() => Pkce.generate(length: 42), throwsArgumentError);
      expect(() => Pkce.generate(length: 129), throwsArgumentError);
    });

    test('two generated pairs differ', () {
      final a = Pkce.generate();
      final b = Pkce.generate();
      expect(a.verifier, isNot(b.verifier));
      expect(a.challenge, isNot(b.challenge));
      expect(a, isNot(b));
    });

    test('generation is reproducible for a seeded random (test only)', () {
      final a = Pkce.generate(random: Random(7));
      final b = Pkce.generate(random: Random(7));
      expect(a, b);
      expect(a.challenge, Pkce.challengeFor(b.verifier));
    });

    test('state is random and long enough to resist guessing', () {
      final state = Pkce.randomState();
      expect(state, matches(RegExp(r'^[A-Za-z0-9\-._~]{32}$')));
      expect(state, isNot(Pkce.randomState()));
    });

    test('tampered challenge fails validation', () {
      final pkce = Pkce.generate();
      expect(
        Pkce(verifier: pkce.verifier, challenge: 'wrong').isValid,
        isFalse,
      );
    });
  });

  group('AuthorizationCallback.parse', () {
    test('reads the Keycloak success query', () {
      final callback = AuthorizationCallback.parse(
        Uri.parse(
          'http://localhost:3001/callback?code=abc123&state=s1'
          '&iss=http%3A%2F%2Flocalhost%3A8180%2Frealms%2Fwms'
          '&session_state=99',
        ),
      );
      expect(callback, isA<AuthorizationCode>());
      final code = callback as AuthorizationCode;
      expect(code.code, 'abc123');
      expect(code.state, 's1');
      expect(code.issuer, 'http://localhost:8180/realms/wms');
      expect(code.sessionState, '99');
      expect(code.isRedirectResponse, isTrue);
    });

    test('state and issuer checks', () {
      final code = AuthorizationCallback.parse(
        Uri.parse('/callback?code=c&state=expected'),
      ) as AuthorizationCode;
      expect(code.matchesState('expected'), isTrue);
      expect(code.matchesState('other'), isFalse);
      expect(code.matchesState(null), isFalse);
      expect(code.matchesState(''), isFalse);
      expect(code.matchesIssuer('http://localhost:8180/realms/wms'), isTrue);
    });

    test('issuer mismatch is detected (RFC 9207)', () {
      final code = AuthorizationCallback.parse(
        Uri.parse('/callback?code=c&state=s&iss=https://evil.example'),
      ) as AuthorizationCode;
      expect(code.matchesIssuer('http://localhost:8180/realms/wms'), isFalse);
    });

    test('reads an error response and decodes the description', () {
      final callback = AuthorizationCallback.parse(
        Uri.parse(
          '/callback?error=access_denied'
          '&error_description=User+cancelled&state=s1',
        ),
      );
      expect(callback, isA<AuthorizationError>());
      final error = callback as AuthorizationError;
      expect(error.error, 'access_denied');
      expect(error.description, 'User cancelled');
      expect(error.state, 's1');
    });

    test('an ordinary page load is not a redirect response', () {
      final callback = AuthorizationCallback.parse(
        Uri.parse('http://localhost:3001/inventory/balances'),
      );
      expect(callback, const NoAuthorizationResponse());
      expect(callback.isRedirectResponse, isFalse);
    });

    test('fragment responses are parsed too', () {
      final callback = AuthorizationCallback.parse(
        Uri.parse('http://localhost:3001/#code=frag&state=s2'),
      );
      expect((callback as AuthorizationCode).code, 'frag');
      expect(callback.state, 's2');
    });
  });

  group('PendingAuthorization', () {
    test('survives a JSON round trip', () {
      final pending = PendingAuthorization.start(
        redirectUri: Uri.parse('http://localhost:3001/callback'),
        returnTo: '/inventory/balances',
      );
      final decoded = PendingAuthorization.tryDecode(pending.encode())!;
      expect(decoded.state, pending.state);
      expect(decoded.codeVerifier, pending.codeVerifier);
      expect(decoded.redirectUri, pending.redirectUri);
      expect(decoded.returnTo, '/inventory/balances');
      expect(decoded.codeChallenge, pending.codeChallenge);
    });

    test('garbage in browser storage decodes to null instead of throwing', () {
      expect(PendingAuthorization.tryDecode(null), isNull);
      expect(PendingAuthorization.tryDecode(''), isNull);
      expect(PendingAuthorization.tryDecode('not json'), isNull);
      expect(PendingAuthorization.tryDecode('{"state":"s"}'), isNull);
    });

    test('expires after 15 minutes', () {
      final now = DateTime.utc(2026, 9, 21, 10);
      final pending = PendingAuthorization.start(
        redirectUri: Uri.parse('http://localhost:3001/callback'),
        now: now,
      );
      expect(pending.isExpired(now: now), isFalse);
      expect(
        pending.isExpired(now: now.add(const Duration(minutes: 14))),
        isFalse,
      );
      expect(
        pending.isExpired(now: now.add(const Duration(minutes: 16))),
        isTrue,
      );
    });

    test('in-memory store reads back what was written', () {
      final store = InMemoryPendingAuthorizationStore();
      expect(store.read(), isNull);
      final pending = PendingAuthorization.start(
        redirectUri: Uri.parse('http://localhost:3001/callback'),
      );
      store.write(pending);
      expect(store.read()?.state, pending.state);
      store.clear();
      expect(store.read(), isNull);
    });
  });

  group('refreshDelay', () {
    final now = DateTime.utc(2026, 9, 21, 12);

    test('unknown expiry falls back to a fixed period', () {
      expect(
        refreshDelay(expiresAt: null, now: now),
        const Duration(minutes: 4),
      );
    });

    test('refreshes one minute before a 15 minute token expires', () {
      expect(
        refreshDelay(expiresAt: now.add(const Duration(minutes: 15)), now: now),
        const Duration(minutes: 14),
      );
    });

    test('an expired token is refreshed immediately, never in the past', () {
      final delay = refreshDelay(
        expiresAt: now.subtract(const Duration(minutes: 5)),
        now: now,
      );
      expect(delay, const Duration(seconds: 5));
      expect(delay.isNegative, isFalse);
    });

    test('inside the leeway window clamps to the minimum', () {
      expect(
        refreshDelay(expiresAt: now.add(const Duration(seconds: 30)), now: now),
        const Duration(seconds: 5),
      );
    });

    test('local expiry timestamps are compared in UTC', () {
      final local = now.add(const Duration(minutes: 10)).toLocal();
      expect(
        refreshDelay(expiresAt: local, now: now),
        const Duration(minutes: 9),
      );
    });
  });

  group('SilentRefreshScheduler', () {
    test('fires shortly before the token expires', () async {
      var calls = 0;
      final scheduler = SilentRefreshScheduler(
        onRefresh: () async => calls++,
        leeway: const Duration(milliseconds: 40),
        minimum: Duration.zero,
      );
      addTearDown(scheduler.dispose);

      scheduler.schedule(
        DateTime.now().toUtc().add(const Duration(milliseconds: 60)),
      );
      expect(scheduler.isScheduled, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(calls, 1);
      expect(scheduler.isScheduled, isFalse);
    });

    test('cancel stops a pending refresh (sign-out)', () async {
      var calls = 0;
      final scheduler = SilentRefreshScheduler(
        onRefresh: () async => calls++,
        leeway: Duration.zero,
        minimum: const Duration(milliseconds: 20),
      );
      addTearDown(scheduler.dispose);

      scheduler.schedule(DateTime.now().toUtc());
      scheduler.cancel();
      expect(scheduler.isScheduled, isFalse);
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(calls, 0);
    });

    test('re-scheduling replaces the previous timer', () async {
      var calls = 0;
      final scheduler = SilentRefreshScheduler(
        onRefresh: () async => calls++,
        leeway: Duration.zero,
        minimum: const Duration(milliseconds: 20),
      );
      addTearDown(scheduler.dispose);

      scheduler
        ..schedule(DateTime.now().toUtc())
        ..schedule(DateTime.now().toUtc());
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(calls, 1, reason: 'only the last schedule may fire');
    });

    test('delayFor exposes the computed delay', () {
      final scheduler = SilentRefreshScheduler(onRefresh: () async {});
      addTearDown(scheduler.dispose);
      final now = DateTime.utc(2026, 9, 21, 12);
      expect(
        scheduler.delayFor(now.add(const Duration(minutes: 15)), now: now),
        const Duration(minutes: 14),
      );
    });
  });
}
