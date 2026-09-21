import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_mobile/observability/error_handlers.dart';

void main() {
  FlutterExceptionHandler? previousOnError;
  bool Function(Object, StackTrace)? previousPlatformOnError;

  setUp(() {
    previousOnError = FlutterError.onError;
    previousPlatformOnError = PlatformDispatcher.instance.onError;
  });

  tearDown(() {
    FlutterError.onError = previousOnError;
    PlatformDispatcher.instance.onError = previousPlatformOnError;
  });

  test('FlutterError.onError forwards to the injected reporter', () {
    final reporter = RecordingCrashReporter();
    installErrorHandlers(reporter);

    FlutterError.reportError(
      FlutterErrorDetails(
        exception: StateError('render boom'),
        stack: StackTrace.current,
        library: 'widgets library',
        context: ErrorDescription('building WasteFormScreen'),
      ),
    );

    expect(reporter.reports, hasLength(1));
    final report = reporter.reports.single;
    expect(report.error, isA<StateError>());
    expect(report.library, 'widgets library');
    expect(report.context, contains('WasteFormScreen'));
    expect(report.severity, CrashSeverity.fatal);
    expect(report.stackTrace, isNotNull);
  });

  test('PlatformDispatcher errors are reported and marked handled', () {
    final reporter = RecordingCrashReporter();
    installErrorHandlers(reporter);

    final handled = PlatformDispatcher.instance.onError!(
      ArgumentError('platform boom'),
      StackTrace.current,
    );

    expect(handled, isTrue);
    expect(reporter.reports.single.context, 'platform');
  });

  test('swapping the reporter needs no change at the call sites', () {
    final first = RecordingCrashReporter();
    final second = RecordingCrashReporter();

    installErrorHandlers(first);
    FlutterError.reportError(FlutterErrorDetails(exception: Exception('a')));
    installErrorHandlers(second);
    FlutterError.reportError(FlutterErrorDetails(exception: Exception('b')));

    expect(first.reports, hasLength(1));
    expect(second.reports, hasLength(1));
  });
}
