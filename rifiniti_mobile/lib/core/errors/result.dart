import 'failure.dart';

/// A simple Result type for handling success/failure cases.
/// Similar to Either<Failure, T> but simpler and more idiomatic.
sealed class Result<T> {
  const Result();

  /// Creates a successful result.
  const factory Result.success(T data) = Success<T>;

  /// Creates a failure result.
  const factory Result.failure(Failure failure) = ResultFailure<T>;

  /// Whether this result is a success.
  bool get isSuccess => this is Success<T>;

  /// Whether this result is a failure.
  bool get isFailure => this is ResultFailure<T>;

  /// Gets the data if success, throws if failure.
  T get data {
    return switch (this) {
      Success(:final data) => data,
      ResultFailure(:final failure) => throw Exception(failure.message),
    };
  }

  /// Gets the failure if failure, null if success.
  Failure? get failure {
    return switch (this) {
      Success() => null,
      ResultFailure(:final failure) => failure,
    };
  }

  /// Gets the data if success, null if failure.
  T? get dataOrNull {
    return switch (this) {
      Success(:final data) => data,
      ResultFailure() => null,
    };
  }

  /// Maps the success value to a new type.
  Result<R> map<R>(R Function(T data) mapper) {
    return switch (this) {
      Success(:final data) => Result.success(mapper(data)),
      ResultFailure(:final failure) => Result.failure(failure),
    };
  }

  /// Maps the success value to a new Result.
  Result<R> flatMap<R>(Result<R> Function(T data) mapper) {
    return switch (this) {
      Success(:final data) => mapper(data),
      ResultFailure(:final failure) => Result.failure(failure),
    };
  }

  /// Folds the result into a single value.
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return switch (this) {
      Success(:final data) => onSuccess(data),
      ResultFailure(:final failure) => onFailure(failure),
    };
  }

  /// Executes callback on success.
  Result<T> onSuccess(void Function(T data) callback) {
    if (this case Success(:final data)) {
      callback(data);
    }
    return this;
  }

  /// Executes callback on failure.
  Result<T> onFailure(void Function(Failure failure) callback) {
    if (this case ResultFailure(:final failure)) {
      callback(failure);
    }
    return this;
  }
}

/// Represents a successful result.
final class Success<T> extends Result<T> {
  @override
  final T data;

  const Success(this.data);

  @override
  String toString() => 'Success($data)';
}

/// Represents a failure result.
final class ResultFailure<T> extends Result<T> {
  @override
  final Failure failure;

  const ResultFailure(this.failure);

  @override
  String toString() => 'Failure(${failure.message})';
}
