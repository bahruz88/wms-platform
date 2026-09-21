import 'dart:async';

/// Time to wait before refreshing an access token that expires at
/// [expiresAt]. The refresh is pulled [leeway] ahead of the real expiry so a
/// request never travels with a token that dies in flight.
///
/// * unknown expiry → `fallback` (Keycloak's access tokens live 15 minutes;
///   the fallback stays well inside that window),
/// * already expired or about to → `minimum`, never a negative delay.
Duration refreshDelay({
  required DateTime? expiresAt,
  DateTime? now,
  Duration leeway = const Duration(minutes: 1),
  Duration minimum = const Duration(seconds: 5),
  Duration fallback = const Duration(minutes: 4),
}) {
  if (expiresAt == null) return fallback;
  final reference = (now ?? DateTime.now()).toUtc();
  final delay = expiresAt.toUtc().difference(reference) - leeway;
  return delay < minimum ? minimum : delay;
}

/// Keeps a single pending timer that triggers [onRefresh] shortly before the
/// access token expires, so the session is renewed without the user noticing
/// and without waiting for a 401.
///
/// The scheduler is deliberately dumb: it fires once per [schedule] call and
/// the owner re-schedules from the refreshed session. Overlapping refreshes
/// are impossible because `BaseAuthRepository.refresh` de-duplicates them.
class SilentRefreshScheduler {
  SilentRefreshScheduler({
    required this.onRefresh,
    this.leeway = const Duration(minutes: 1),
    this.minimum = const Duration(seconds: 5),
    this.fallback = const Duration(minutes: 4),
  });

  /// Called when the timer fires; normally `AuthRepository.refresh`.
  final Future<void> Function() onRefresh;
  final Duration leeway;
  final Duration minimum;
  final Duration fallback;

  Timer? _timer;

  bool get isScheduled => _timer?.isActive ?? false;

  /// Delay the next run would use (exposed for tests and diagnostics).
  Duration delayFor(DateTime? expiresAt, {DateTime? now}) => refreshDelay(
    expiresAt: expiresAt,
    now: now,
    leeway: leeway,
    minimum: minimum,
    fallback: fallback,
  );

  /// Arms the timer for the token expiring at [expiresAt], replacing any
  /// previously scheduled refresh.
  void schedule(DateTime? expiresAt, {DateTime? now}) {
    cancel();
    _timer = Timer(delayFor(expiresAt, now: now), () {
      unawaited(onRefresh());
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() => cancel();
}
