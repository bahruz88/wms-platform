import '../errors/problem_details.dart';
import '../result/failure.dart';

/// Exception used at the transport boundary (Dio interceptors) to carry a
/// [Failure] up to `Result.guard`, which turns it back into an `Err`.
class AppException implements Exception {
  const AppException(this.failure);

  /// Convenience for interceptors: wraps a decoded [ProblemDetails].
  factory AppException.fromProblem(ProblemDetails problem) =>
      AppException(Failure.fromProblem(problem));

  /// Maps an arbitrary thrown object to an [AppException].
  factory AppException.from(Object error, [StackTrace? stackTrace]) {
    if (error is AppException) return error;
    return AppException(
      UnexpectedFailure(
        message: '$error',
        error: error,
        stackTrace: stackTrace,
      ),
    );
  }

  final Failure failure;

  String get message => failure.message;

  @override
  String toString() => 'AppException($failure)';
}
