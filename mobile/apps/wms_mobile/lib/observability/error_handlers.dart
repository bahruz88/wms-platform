import 'package:flutter/foundation.dart';
import 'package:wms_core/wms_core.dart';

/// Routes the framework's error channels into [reporter].
///
/// `FlutterError.onError` catches build/layout/paint errors,
/// `PlatformDispatcher.onError` catches errors that escape an async gap
/// outside the guarded zone. Both keep the default console presentation so
/// `flutter run` output does not get quieter.
///
/// Swapping Sentry/Crashlytics in means constructing a different
/// [CrashReporter] in `bootstrap()`; these handlers stay untouched.
void installErrorHandlers(CrashReporter reporter) {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    reporter.recordError(
      details.exception,
      details.stack,
      context: details.context?.toString() ?? 'flutter',
      library: details.library,
      severity: CrashSeverity.fatal,
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    reporter.recordError(error, stack, context: 'platform');
    return true;
  };
}
