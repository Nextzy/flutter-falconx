import 'package:falmodel/lib.dart';

class Result<T> {

  /// Creates a successful result.
  factory Result.success(T value) => Result._success(value);

  /// Creates a failed result.
  factory Result.failure(Object error, [StackTrace? stackTrace]) =>
      Result._failure(error, stackTrace ?? StackTrace.current);

  const Result._success(T value)
      : _value = value,
        _error = null,
        _stackTrace = null,
        _isSuccess = true;

  const Result._failure(Object error, StackTrace stackTrace)
      : _value = null,
        _error = error,
        _stackTrace = stackTrace,
        _isSuccess = false;
  final T? _value;
  final Object? _error;
  final StackTrace? _stackTrace;
  final bool _isSuccess;

  /// True if the result is successful.
  bool get isSuccess => _isSuccess;

  /// True if the result is a failure.
  bool get isFailure => !_isSuccess;

  /// Gets the value if successful, throws if failure.
  T get value {
    if (_isSuccess) return _value as T;
    throw StateError('Cannot get value from failed Result');
  }

  /// Gets the error if failed, throws if successful.
  Object get error {
    if (!_isSuccess) return _error!;
    throw StateError('Cannot get error from successful Result');
  }

  /// Gets the stack trace if failed.
  StackTrace? get stackTrace => _stackTrace;

  /// Gets the value or null if failed.
  T? get valueOrNull => _isSuccess ? _value : null;

  /// Gets the value or the provided default if failed.
  T valueOr(T defaultValue) => _isSuccess ? _value as T : defaultValue;

  /// Transforms the value if successful.
  Result<R> map<R>(R Function(T value) transform) {
    if (_isSuccess) {
      try {
        return Result.success(transform(_value as T));
      } catch (error, stackTrace) {
        return Result.failure(error, stackTrace);
      }
    }
    return Result.failure(_error!, _stackTrace);
  }

  /// Transforms the error if failed.
  Result<T> mapError(Object Function(Object error) transform) {
    if (!_isSuccess) {
      return Result.failure(transform(_error!), _stackTrace);
    }
    return this;
  }

  /// Folds the result into a single value.
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Object error, StackTrace? stackTrace) onFailure,
  }) {
    if (_isSuccess) {
      return onSuccess(_value as T);
    }
    return onFailure(_error!, _stackTrace);
  }

  /// Executes a callback based on the result.
  void when({
    required void Function(T value) onSuccess,
    required void Function(Object error, StackTrace? stackTrace) onFailure,
  }) {
    if (_isSuccess) {
      onSuccess(_value as T);
    } else {
      onFailure(_error!, _stackTrace);
    }
  }
}
