import 'dart:async';

import 'package:test/test.dart';
import 'package:wms_core/wms_core.dart';

void main() {
  group('RecordingCrashReporter', () {
    test('keeps error, stack, context and severity', () {
      final reporter = RecordingCrashReporter();
      final stack = StackTrace.current;

      reporter.recordError(
        StateError('boom'),
        stack,
        context: 'flutter',
        library: 'widgets library',
        severity: CrashSeverity.fatal,
        extra: const {'screen': 'WasteFormScreen'},
      );

      expect(reporter.reports, hasLength(1));
      final report = reporter.reports.single;
      expect(report.error, isA<StateError>());
      expect(report.stackTrace, stack);
      expect(report.context, 'flutter');
      expect(report.library, 'widgets library');
      expect(report.severity, CrashSeverity.fatal);
      expect(report.extra['screen'], 'WasteFormScreen');
      expect(report.toString(), contains('flutter'));
    });

    test('breadcrumbs and user identity are captured', () {
      final reporter = RecordingCrashReporter()
        ..log('attachment upload failed', extra: const {'entityType': 'WASTE'})
        ..setUser(userId: 'a1b2', tenantId: 1);

      expect(reporter.messages, ['attachment upload failed']);
      expect(reporter.userId, 'a1b2');
      expect(reporter.tenantId, 1);
    });

    test('defaults to a non fatal severity', () {
      final reporter = RecordingCrashReporter()
        ..recordError(Exception('x'), null);
      expect(reporter.reports.single.severity, CrashSeverity.nonFatal);
    });
  });

  group('LoggingCrashReporter', () {
    test('is the safe default: never throws, whatever it is handed', () {
      final reporter = LoggingCrashReporter(name: 'wms-test')
        ..setUser(userId: 'u1', tenantId: 7);

      expect(
        () => reporter.recordError(
          ArgumentError('bad'),
          StackTrace.current,
          context: 'zone',
          severity: CrashSeverity.fatal,
          extra: const {'k': 'v'},
        ),
        returnsNormally,
      );
      expect(() => reporter.log('hello'), returnsNormally);
      expect(
        () => reporter.log('hello', extra: const {'a': 1}),
        returnsNormally,
      );
    });
  });

  test('NoopCrashReporter swallows everything', () {
    const reporter = NoopCrashReporter();
    expect(
      () => reporter
        ..recordError('e', null)
        ..log('m')
        ..setUser(userId: 'x'),
      returnsNormally,
    );
  });

  group('runGuardedWithReporter', () {
    test('forwards errors that escape an async gap', () async {
      final reporter = RecordingCrashReporter();

      await runGuardedWithReporter(() async {
        unawaited(
          Future<void>.delayed(Duration.zero)
              .then((_) => throw StateError('async boom')),
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }, reporter);

      expect(reporter.reports, hasLength(1));
      expect(reporter.reports.single.context, 'zone');
      expect(reporter.reports.single.severity, CrashSeverity.fatal);
      expect('${reporter.reports.single.error}', contains('async boom'));
    });

    test('a clean run reports nothing', () async {
      final reporter = RecordingCrashReporter();
      var ran = false;
      await runGuardedWithReporter(() async => ran = true, reporter);
      expect(ran, isTrue);
      expect(reporter.reports, isEmpty);
    });
  });
}
