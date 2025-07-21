import 'package:faltool/lib.dart';

/// Extension methods for Future type with enhanced functionality.
/// 
/// Provides comprehensive utilities for Future operations including
/// error handling, timeout management, retries, and transformations.
extension FalconToolFutureExtensions<T> on Future<T> {
  /// Executes the future with a timeout, returning a default value on timeout.
  /// 
  /// Example:
  /// ```dart
  /// final result = await fetchData()
  ///     .timeoutWithDefault(Duration(seconds: 5), 'default');
  /// ```
  Future<T> timeoutWithDefault(Duration duration, T defaultValue) {
    return timeout(duration, onTimeout: () => defaultValue);
  }

  /// Executes the future with a timeout, calling a callback on timeout.
  /// 
  /// Example:
  /// ```dart
  /// final result = await fetchData()
  ///     .timeoutWithCallback(
  ///       Duration(seconds: 5),
  ///       onTimeout: () => print('Operation timed out'),
  ///     );
  /// ```
  Future<T> timeoutWithCallback(
    Duration duration, {
    required FutureOr<T> Function() onTimeout,
  }) {
    return timeout(duration, onTimeout: onTimeout);
  }

  /// Retries the future operation with exponential backoff.
  /// 
  /// [maxAttempts] - Maximum number of retry attempts (default: 3)
  /// [delay] - Initial delay between retries (default: 1 second)
  /// [maxDelay] - Maximum delay between retries (default: 30 seconds)
  /// [retryIf] - Optional condition to determine if retry should occur
  /// 
  /// Example:
  /// ```dart
  /// final result = await apiCall().retryWithBackoff(
  ///   maxAttempts: 5,
  ///   delay: Duration(seconds: 2),
  ///   retryIf: (error) => error is SocketException,
  /// );
  /// ```
  Future<T> retryWithBackoff({
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
    Duration maxDelay = const Duration(seconds: 30),
    bool Function(Object error)? retryIf,
  }) async {
    var attempt = 0;
    var currentDelay = delay;

    while (true) {
      try {
        return await this;
      } catch (error) {
        attempt++;
        
        if (attempt >= maxAttempts || 
            (retryIf != null && !retryIf(error))) {
          rethrow;
        }

        await Future.delayed(currentDelay);
        
        // Exponential backoff with max delay
        currentDelay = Duration(
          milliseconds: (currentDelay.inMilliseconds * 2)
              .clamp(0, maxDelay.inMilliseconds),
        );
      }
    }
  }

  /// Executes the future and ignores any errors.
  /// 
  /// Example:
  /// ```dart
  /// await saveToCache(data).ignoreErrors();
  /// ```
  Future<void> ignoreErrors() async {
    try {
      await this;
    } catch (_) {
      // Errors are intentionally ignored
    }
  }

  /// Executes the future and calls a callback on error.
  /// 
  /// Example:
  /// ```dart
  /// final result = await fetchData()
  ///     .onError((error, stack) => print('Error: $error'));
  /// ```
  Future<T> onErrorDo(
    void Function(Object error, StackTrace stackTrace) callback,
  ) {
    return catchError((Object error, StackTrace stackTrace) {
      callback(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    });
  }

  /// Transforms the result of the future if successful.
  /// 
  /// Example:
  /// ```dart
  /// final userName = await fetchUser()
  ///     .mapSuccess((user) => user.name);
  /// ```
  Future<R> mapSuccess<R>(R Function(T value) transform) {
    return then(transform);
  }

  /// Transforms errors from the future.
  /// 
  /// Example:
  /// ```dart
  /// final result = await riskyOperation()
  ///     .mapError((error) => CustomException(error.toString()));
  /// ```
  Future<T> mapError(Object Function(Object error) transform) {
    return catchError((Object error) => Error.throwWithStackTrace(transform(error), StackTrace.current));
  }

  /// Executes a callback regardless of success or failure.
  /// 
  /// Example:
  /// ```dart
  /// final result = await fetchData()
  ///     .whenComplete(() => hideLoadingIndicator());
  /// ```
  Future<T> whenCompleteDo(FutureOr<void> Function() action) {
    return whenComplete(action);
  }

  /// Guards the future execution with a condition.
  /// 
  /// Example:
  /// ```dart
  /// final result = await expensiveOperation()
  ///     .guard(() => isNetworkAvailable, 
  ///            fallback: cachedData);
  /// ```
  Future<T> guard(
    bool Function() condition, {
    required T fallback,
  }) {
    if (!condition()) {
      return Future.value(fallback);
    }
    return this;
  }

  /// Wraps the future result in a Result type for better error handling.
  /// 
  /// Example:
  /// ```dart
  /// final result = await fetchData().toResult();
  /// result.fold(
  ///   onSuccess: (data) => print('Success: $data'),
  ///   onFailure: (error) => print('Error: $error'),
  /// );
  /// ```
  Future<Result<T>> toResult() async {
    try {
      final value = await this;
      return Result.success(value);
    } catch (error, stackTrace) {
      return Result.failure(error, stackTrace);
    }
  }

  /// Delays the execution of the future.
  /// 
  /// Example:
  /// ```dart
  /// final result = await fetchData()
  ///     .delayed(Duration(seconds: 2));
  /// ```
  Future<T> delayed(Duration duration) {
    return Future.delayed(duration).then((_) => this);
  }

  /// Cancels the future if it takes longer than the specified duration.
  /// 
  /// Unlike timeout, this returns null instead of throwing.
  /// 
  /// Example:
  /// ```dart
  /// final result = await longRunningOperation()
  ///     .cancelAfter(Duration(seconds: 10));
  /// ```
  Future<T?> cancelAfter(Duration duration) {
    return timeout(duration).then<T?>((value) => value).catchError(
      (Object error) => null,
      test: (error) => error is TimeoutException,
    );
  }

  /// Measures the execution time of the future.
  /// 
  /// Example:
  /// ```dart
  /// final result = await fetchData().timed((duration) {
  ///   print('Operation took: ${duration.inMilliseconds}ms');
  /// });
  /// ```
  Future<T> timed(void Function(Duration duration) onComplete) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await this;
      stopwatch.stop();
      onComplete(stopwatch.elapsed);
      return result;
    } catch (error) {
      stopwatch.stop();
      onComplete(stopwatch.elapsed);
      rethrow;
    }
  }

  /// Converts the future to a stream that emits once.
  /// 
  /// Example:
  /// ```dart
  /// final stream = fetchData().asStream();
  /// ```
  Stream<T> toStream() => Stream.fromFuture(this);
}

/// Extension methods for Future with Either type integration.
extension FalconToolEitherFutureExtensions<L, R> on Future<R> {
  /// Wraps the successful result in a Right.
  /// 
  /// Example:
  /// ```dart
  /// final either = await fetchData().right;
  /// ```
  Future<Either<L, R>> get right => then(Right.new);

  /// Wraps the successful result in a Right with a specific left type.
  /// 
  /// Example:
  /// ```dart
  /// final either = await fetchData().toRight<String>();
  /// ```
  Future<Either<L, R>> toRight() => then(Right<L, R>.new);

  /// Converts the future to an Either, catching errors as Left.
  /// 
  /// Example:
  /// ```dart
  /// final either = await riskyOperation()
  ///     .toEither((error) => error.toString());
  /// ```
  Future<Either<L, R>> toEither(L Function(Object error) onError) async {
    try {
      final value = await this;
      return Right(value);
    } catch (error) {
      return Left(onError(error));
    }
  }
}

/// Extension methods for nullable Future type.
extension FalconToolFutureNullExtensions<T> on Future<T>? {
  /// Returns a future that completes with the default value if null.
  /// 
  /// Example:
  /// ```dart
  /// Future<String>? maybeFetch;
  /// final result = await maybeFetch.orDefault('default');
  /// ```
  Future<T> orDefault(T defaultValue) {
    return this ?? Future.value(defaultValue);
  }

  /// Returns a future that completes with null if the original is null.
  /// 
  /// Example:
  /// ```dart
  /// Future<String>? maybeFetch;
  /// final result = await maybeFetch.orNull();
  /// ```
  Future<T?> orNull() {
    return this ?? Future.value(null);
  }

  /// Executes the future if not null, otherwise returns the default.
  /// 
  /// Example:
  /// ```dart
  /// Future<String>? maybeFetch;
  /// final result = await maybeFetch.whenNotNull(
  ///   orElse: () => 'default',
  /// );
  /// ```
  Future<T> whenNotNull({required T Function() orElse}) {
    return this ?? Future.value(orElse());
  }
}

/// Extension methods for Future of nullable type with null handling.
extension FalconToolFutureNullableExtensions<T> on Future<T?> {
  /// Maps the value if not null, otherwise returns null.
  /// 
  /// Example:
  /// ```dart
  /// final length = await fetchNullableString()
  ///     .mapIfNotNull((str) => str.length);
  /// ```
  Future<R?> mapIfNotNull<R>(R Function(T value) transform) {
    return then((value) => value != null ? transform(value) : null);
  }

  /// Returns a default value if the future completes with null.
  /// 
  /// Example:
  /// ```dart
  /// final value = await fetchNullableData()
  ///     .defaultIfNull('default');
  /// ```
  Future<T> defaultIfNull(T defaultValue) {
    return then((value) => value ?? defaultValue);
  }

  /// Filters the result based on a predicate.
  /// 
  /// Returns null if the predicate returns false.
  /// 
  /// Example:
  /// ```dart
  /// final validUser = await fetchUser()
  ///     .where((user) => user.isActive);
  /// ```
  Future<T?> where(bool Function(T value) predicate) {
    return then((value) {
      if (value != null && predicate(value)) {
        return value;
      }
      return null;
    });
  }
}

/// Result type for better error handling.
