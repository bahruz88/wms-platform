import 'dart:async';
import 'dart:developer' as developer;

import 'package:meta/meta.dart';

/// Severity attached to a reported error.
enum CrashSeverity {
  /// Recoverable: the user saw a message and the app kept working.
  nonFatal,

  /// The app (or the current screen) could not continue.
  fatal,
}

/// Sink for uncaught errors and diagnostic breadcrumbs.
///
/// The apps install exactly one instance in `bootstrap()` and hand it to
/// `FlutterError.onError`, `PlatformDispatcher.onError` and the guarded zone.
/// Swapping in Sentry/Crashlytics later means constructing a different
/// implementation in the composition root - no call site changes.
abstract interface class CrashReporter {
  /// Reports an error with its stack trace.
  ///
  /// [context] is a short human readable origin (`zone`, `flutter`,
  /// `GoodsReceiptFormScreen`), [library] the Flutter error library when
  /// known and [extra] arbitrary key/value diagnostics.
  void recordError(
    Object error,
    StackTrace? stackTrace, {
    String? context,
    String? library,
    CrashSeverity severity = CrashSeverity.nonFatal,
    Map<String, Object?> extra = const {},
  });

  /// Records a breadcrumb; never user data (tokens, names, quantities).
  void log(String message, {Map<String, Object?> extra = const {}});

  /// Associates the following reports with a signed-in user.
  void setUser({String? userId, int? tenantId});
}

/// Default reporter: everything goes to `dart:developer`, which shows up in
/// `flutter run`, DevTools and `adb logcat` without pulling a vendor SDK in.
class LoggingCrashReporter implements CrashReporter {
  LoggingCrashReporter({this.name = 'wms'});

  /// Logger name shown in DevTools.
  final String name;

  String? _userId;
  int? _tenantId;

  @override
  void recordError(
    Object error,
    StackTrace? stackTrace, {
    String? context,
    String? library,
    CrashSeverity severity = CrashSeverity.nonFatal,
    Map<String, Object?> extra = const {},
  }) {
    developer.log(
      _describe(
        severity == CrashSeverity.fatal ? 'fatal' : 'error',
        context: context,
        library: library,
        extra: extra,
      ),
      name: name,
      level: severity == CrashSeverity.fatal ? 1200 : 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void log(String message, {Map<String, Object?> extra = const {}}) {
    developer.log(
      extra.isEmpty ? message : '$message ${_format(extra)}',
      name: name,
      level: 800,
    );
  }

  @override
  void setUser({String? userId, int? tenantId}) {
    _userId = userId;
    _tenantId = tenantId;
  }

  String _describe(
    String kind, {
    String? context,
    String? library,
    Map<String, Object?> extra = const {},
  }) {
    final parts = <String>[
      kind,
      if (context != null) 'context=$context',
      if (library != null) 'library=$library',
      if (_userId != null) 'user=$_userId',
      if (_tenantId != null) 'tenant=$_tenantId',
      if (extra.isNotEmpty) _format(extra),
    ];
    return parts.join(' ');
  }

  static String _format(Map<String, Object?> extra) =>
      extra.entries.map((e) => '${e.key}=${e.value}').join(' ');
}

/// Discards everything. Useful for tests that assert on other behaviour.
class NoopCrashReporter implements CrashReporter {
  const NoopCrashReporter();

  @override
  void recordError(
    Object error,
    StackTrace? stackTrace, {
    String? context,
    String? library,
    CrashSeverity severity = CrashSeverity.nonFatal,
    Map<String, Object?> extra = const {},
  }) {}

  @override
  void log(String message, {Map<String, Object?> extra = const {}}) {}

  @override
  void setUser({String? userId, int? tenantId}) {}
}

/// A single captured report.
@immutable
class CrashReport {
  const CrashReport({
    required this.error,
    this.stackTrace,
    this.context,
    this.library,
    this.severity = CrashSeverity.nonFatal,
    this.extra = const {},
  });

  final Object error;
  final StackTrace? stackTrace;
  final String? context;
  final String? library;
  final CrashSeverity severity;
  final Map<String, Object?> extra;

  @override
  String toString() => 'CrashReport($context: $error)';
}

/// In-memory reporter for tests: asserts that a handler actually forwarded.
class RecordingCrashReporter implements CrashReporter {
  final List<CrashReport> reports = <CrashReport>[];
  final List<String> messages = <String>[];
  String? userId;
  int? tenantId;

  @override
  void recordError(
    Object error,
    StackTrace? stackTrace, {
    String? context,
    String? library,
    CrashSeverity severity = CrashSeverity.nonFatal,
    Map<String, Object?> extra = const {},
  }) => reports.add(
    CrashReport(
      error: error,
      stackTrace: stackTrace,
      context: context,
      library: library,
      severity: severity,
      extra: extra,
    ),
  );

  @override
  void log(String message, {Map<String, Object?> extra = const {}}) =>
      messages.add(message);

  @override
  void setUser({String? userId, int? tenantId}) {
    this.userId = userId;
    this.tenantId = tenantId;
  }
}

/// Runs [body] in a zone whose uncaught errors go to [reporter].
///
/// Used by both `bootstrap()` entry points; the zone catches everything that
/// escapes the framework's own handlers (async gaps, isolate callbacks).
Future<void> runGuardedWithReporter(
  Future<void> Function() body,
  CrashReporter reporter, {
  String context = 'zone',
}) async {
  await runZonedGuarded(body, (error, stack) {
    reporter.recordError(
      error,
      stack,
      context: context,
      severity: CrashSeverity.fatal,
    );
  });
}
