import 'package:faltool/lib.dart';

/// Extension methods for Stream type with enhanced functionality.
///
/// Provides comprehensive utilities for stream operations including
/// transformations, filtering, error handling, and advanced operators.
extension FalconToolStreamExtension<T> on Stream<T> {
  /// Transforms a stream using custom handlers for data and errors.
  ///
  /// Example:
  /// ```dart
  /// final numbers = Stream.fromIterable([1, 2, 3, 4, 5]);
  /// final doubled = numbers.mapTransform<int>(
  ///   handleData: (data, sink) => sink.add(data * 2),
  /// );
  /// ```
  Stream<S> mapTransform<S>({
    required void Function(T data, EventSink<S> sink) handleData,
    void Function(Object error, StackTrace stackTrace, EventSink<S> sink)?
        handleError,
  }) =>
      transform<S>(StreamTransformer<T, S>.fromHandlers(
        handleData: handleData,
        handleError: handleError,
      ));

  /// Filters stream events based on a predicate.
  ///
  /// Example:
  /// ```dart
  /// final numbers = Stream.fromIterable([1, 2, 3, 4, 5]);
  /// final evens = numbers.whereStream((n) => n % 2 == 0);
  /// ```
  Stream<T> whereStream(bool Function(T event) test) {
    return where(test);
  }

  /// Maps each event to a new value asynchronously.
  ///
  /// Example:
  /// ```dart
  /// final ids = Stream.fromIterable([1, 2, 3]);
  /// final users = ids.asyncMapStream((id) => fetchUser(id));
  /// ```
  Stream<S> asyncMapStream<S>(Future<S> Function(T event) convert) {
    return asyncMap(convert);
  }

  /// Combines events with their index.
  ///
  /// Example:
  /// ```dart
  /// final letters = Stream.fromIterable(['a', 'b', 'c']);
  /// final indexed = letters.indexed(); // (0, 'a'), (1, 'b'), (2, 'c')
  /// ```
  Stream<(int, T)> indexed() {
    var index = 0;
    return map((event) => (index++, event));
  }

  // Note: retryWhen method is provided by RxDart
  // Use: stream.retryWhen((error, attempt) => Stream.value(null).delay(Duration(seconds: attempt)))

  /// Combines the latest values from two streams.
  ///
  /// Example:
  /// ```dart
  /// final stream1 = Stream.periodic(Duration(seconds: 1), (i) => i);
  /// final stream2 = Stream.periodic(Duration(seconds: 2), (i) => i * 10);
  /// final combined = stream1.combineLatest(stream2, (a, b) => a + b);
  /// ```
  Stream<R> combineLatest<S, R>(
    Stream<S> other,
    R Function(T a, S b) combiner,
  ) {
    final controller = StreamController<R>.broadcast(
      sync: true,
    );

    T? latestFirst;
    S? latestSecond;
    var hasFirst = false;
    var hasSecond = false;

    void tryEmit() {
      if (hasFirst && hasSecond) {
        controller.add(combiner(latestFirst as T, latestSecond as S));
      }
    }

    final subscription1 = listen(
      (event) {
        latestFirst = event;
        hasFirst = true;
        tryEmit();
      },
      onError: controller.addError,
      onDone: controller.close,
    );

    final subscription2 = other.listen(
      (event) {
        latestSecond = event;
        hasSecond = true;
        tryEmit();
      },
      onError: controller.addError,
      onDone: controller.close,
    );

    controller.onCancel = () {
      subscription1.cancel();
      subscription2.cancel();
    };

    return controller.stream;
  }

  /// Takes events while a condition is true.
  ///
  /// Example:
  /// ```dart
  /// final numbers = Stream.fromIterable([1, 2, 3, 4, 5]);
  /// final limited = numbers.takeWhileStream((n) => n < 4); // 1, 2, 3
  /// ```
  Stream<T> takeWhileStream(bool Function(T element) test) {
    return takeWhile(test);
  }

  /// Skips events while a condition is true.
  ///
  /// Example:
  /// ```dart
  /// final numbers = Stream.fromIterable([1, 2, 3, 4, 5]);
  /// final skipped = numbers.skipWhileStream((n) => n < 3); // 3, 4, 5
  /// ```
  Stream<T> skipWhileStream(bool Function(T element) test) {
    return skipWhile(test);
  }

  /// Ignores all error events.
  ///
  /// Example:
  /// ```dart
  /// final risky = riskyStream();
  /// final safe = risky.ignoreErrors();
  /// ```
  Stream<T> ignoreErrors() {
    return handleError((error, stackTrace) {
      // Ignore errors
    });
  }

  /// Counts the total number of events.
  ///
  /// Example:
  /// ```dart
  /// final events = Stream.fromIterable([1, 2, 3, 4, 5]);
  /// final count = await events.count(); // 5
  /// ```
  Future<int> count() async {
    var count = 0;
    await for (final _ in this) {
      count++;
    }
    return count;
  }
  // Note: delay, onErrorReturn, onErrorReturnWith, doOnData, doOnError, 
  // doOnDone, startWith, endWith methods are provided by RxDart
}

/// Extension methods for Stream<T>? (nullable stream).
extension FalconToolStreamNullExtension<T> on Stream<T>? {
  /// Returns true if the stream is null.
  bool get isNull => this == null;

  /// Returns true if the stream is not null.
  bool get isNotNull => this != null;

  /// Returns the stream or an empty stream if null.
  Stream<T> get orEmpty => this ?? const Stream.empty();

  /// Executes an action if the stream is not null.
  void ifNotNull(void Function(Stream<T> stream) action) {
    if (this != null) {
      action(this!);
    }
  }

  /// Safely listens to the stream if it's not null.
  StreamSubscription<T>? listenSafely(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return this?.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

// Note: whereNotNull and mapNotNull methods are provided by RxDart
