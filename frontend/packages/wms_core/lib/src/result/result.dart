import 'dart:async';

import 'package:meta/meta.dart';

import '../errors/app_exception.dart';
import 'failure.dart';

/// Either a successful [Ok] value or an [Err] carrying a [Failure].
@immutable
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;

  const factory Result.err(Failure failure) = Err<T>;

  /// Runs [body], converting a thrown [AppException] into [Err] and any other
  /// error into an [UnexpectedFailure]. This is the bridge between the
  /// exception-based transport layer and the value-based domain layer.
  static Future<Result<T>> guard<T>(FutureOr<T> Function() body) async {
    try {
      return Ok<T>(await body());
    } on AppException catch (e) {
      return Err<T>(e.failure);
    } catch (e, st) {
      return Err<T>(UnexpectedFailure(message: '$e', error: e, stackTrace: st));
    }
  }

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  T? get valueOrNull => switch (this) {
    Ok<T>(:final value) => value,
    Err<T>() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Ok<T>() => null,
    Err<T>(:final failure) => failure,
  };

  R fold<R>(R Function(T value) onOk, R Function(Failure failure) onErr) =>
      switch (this) {
        Ok<T>(:final value) => onOk(value),
        Err<T>(:final failure) => onErr(failure),
      };

  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Ok<T>(:final value) => Ok<R>(transform(value)),
    Err<T>(:final failure) => Err<R>(failure),
  };

  Result<R> flatMap<R>(Result<R> Function(T value) transform) => switch (this) {
    Ok<T>(:final value) => transform(value),
    Err<T>(:final failure) => Err<R>(failure),
  };

  T getOrElse(T Function(Failure failure) orElse) => switch (this) {
    Ok<T>(:final value) => value,
    Err<T>(:final failure) => orElse(failure),
  };

  /// Returns the value or throws an [AppException] wrapping the failure.
  T getOrThrow() => switch (this) {
    Ok<T>(:final value) => value,
    Err<T>(:final failure) => throw AppException(failure),
  };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;

  @override
  bool operator ==(Object other) => other is Ok<T> && other.value == value;

  @override
  int get hashCode => Object.hash(Ok, value);

  @override
  String toString() => 'Ok($value)';
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;

  @override
  bool operator ==(Object other) => other is Err<T> && other.failure == failure;

  @override
  int get hashCode => Object.hash(Err, failure);

  @override
  String toString() => 'Err($failure)';
}
