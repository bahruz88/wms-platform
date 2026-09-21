import 'package:test/test.dart';
import 'package:wms_core/wms_core.dart';

void main() {
  group('Result', () {
    test('ok / err basics', () {
      const ok = Result<int>.ok(1);
      const err = Result<int>.err(NetworkFailure());
      expect(ok.isOk, isTrue);
      expect(ok.valueOrNull, 1);
      expect(err.isErr, isTrue);
      expect(err.failureOrNull, isA<NetworkFailure>());
      expect(ok.fold((v) => 'v$v', (f) => 'f'), 'v1');
      expect(err.fold((v) => 'v$v', (f) => 'f'), 'f');
    });

    test('map / flatMap / getOrElse', () {
      const ok = Result<int>.ok(2);
      expect(ok.map((v) => v * 2).valueOrNull, 4);
      expect(ok.flatMap((v) => Result<String>.ok('$v')).valueOrNull, '2');
      const err = Result<int>.err(CancelledFailure());
      expect(err.map((v) => v * 2).isErr, isTrue);
      expect(err.getOrElse((_) => -1), -1);
      expect(err.getOrThrow, throwsA(isA<AppException>()));
    });

    test(
      'guard converts AppException into Err and others into Unexpected',
      () async {
        final problem = ProblemDetails.fromJson(const {
          'status': 409,
          'code': 'INSUFFICIENT_STOCK',
          'title': 'Kifayət qədər stok yoxdur',
        });
        final r1 = await Result.guard<int>(
          () => throw AppException.fromProblem(problem),
        );
        expect(r1.failureOrNull, isA<ConflictFailure>());
        expect(
          (r1.failureOrNull! as ConflictFailure).isInsufficientStock,
          isTrue,
        );

        final r2 = await Result.guard<int>(() => throw StateError('boom'));
        expect(r2.failureOrNull, isA<UnexpectedFailure>());

        final r3 = await Result.guard(() async => 42);
        expect(r3.valueOrNull, 42);
      },
    );
  });

  group('Failure.fromProblem', () {
    ProblemDetails p(int status, [String? code]) =>
        ProblemDetails(status: status, code: code);

    test('maps status codes', () {
      expect(Failure.fromProblem(p(400)), isA<ValidationFailure>());
      expect(Failure.fromProblem(p(422)), isA<ValidationFailure>());
      expect(Failure.fromProblem(p(401)), isA<UnauthorizedFailure>());
      expect(Failure.fromProblem(p(403)), isA<ForbiddenFailure>());
      expect(Failure.fromProblem(p(404)), isA<NotFoundFailure>());
      expect(
        Failure.fromProblem(p(409, 'STALE_VERSION')),
        isA<ConflictFailure>(),
      );
      expect(Failure.fromProblem(p(500)), isA<ServerFailure>());
      final conflict =
          Failure.fromProblem(p(409, 'STALE_VERSION')) as ConflictFailure;
      expect(conflict.isStaleVersion, isTrue);
    });
  });
}
