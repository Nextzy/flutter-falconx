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

  /// Buffers events into lists of specified size.
  /// 
  /// Example:
  /// ```dart
  /// final numbers = Stream.fromIterable([1, 2, 3, 4, 5]);
  /// final buffered = numbers.buffer(2); // [1, 2], [3, 4], [5]
  /// ```
  Stream<List<T>> buffer(int count) {
    if (count <= 0) {
      throw ArgumentError.value(count, 'count', 'must be positive');
    }
    
    final buffer = <T>[];
    return transform(
      StreamTransformer<T, List<T>>.fromHandlers(
        handleData: (data, sink) {
          buffer.add(data);
          if (buffer.length == count) {
            sink.add(List.from(buffer));
            buffer.clear();
          }
        },
        handleDone: (sink) {
          if (buffer.isNotEmpty) {
            sink.add(buffer);
          }
          sink.close();
        },
        handleError: (error, stackTrace, sink) => sink.addError(error, stackTrace),
      ),
    );
  }

  /// Throttles events to emit at most once per duration.
  /// 
  /// Example:
  /// ```dart
  /// final clicks = buttonClickStream;
  /// final throttled = clicks.throttle(Duration(seconds: 1));
  /// ```
  Stream<T> throttle(Duration duration) {
    Timer? timer;
    var shouldEmit = true;

    return transform(
      StreamTransformer<T, T>.fromHandlers(
        handleData: (data, sink) {
          if (shouldEmit) {
            sink.add(data);
            shouldEmit = false;
            timer = Timer(duration, () {
              shouldEmit = true;
            });
          }
        },
        handleDone: (sink) {
          timer?.cancel();
          sink.close();
        },
        handleError: (error, stackTrace, sink) {
          sink.addError(error, stackTrace);
        },
      ),
    );
  }

  /// Debounces events, emitting only after a pause in events.
  /// 
  /// Example:
  /// ```dart
  /// final searchInput = textFieldStream;
  /// final debounced = searchInput.debounce(Duration(milliseconds: 300));
  /// ```
  Stream<T> debounce(Duration duration) {
    Timer? timer;

    return transform(
      StreamTransformer<T, T>.fromHandlers(
        handleData: (data, sink) {
          timer?.cancel();
          timer = Timer(duration, () {
            sink.add(data);
          });
        },
        handleDone: (sink) {
          timer?.cancel();
          sink.close();
        },
        handleError: (error, stackTrace, sink) {
          timer?.cancel();
          sink.addError(error, stackTrace);
        },
      ),
    );
  }

  /// Retries the stream on error with exponential backoff.
  /// 
  /// Example:
  /// ```dart
  /// final apiStream = fetchDataStream();
  /// final reliable = apiStream.retryWhen(
  ///   maxAttempts: 3,
  ///   delay: Duration(seconds: 1),
  /// );
  /// ```
  Stream<T> retryWhen({
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
    bool Function(Object error)? retryIf,
  }) {
    return transform(
      StreamTransformer<T, T>.fromHandlers(
        handleData: (data, sink) => sink.add(data),
        handleError: (error, stackTrace, sink) async {
          var attempts = 0;
          var currentDelay = delay;

          while (attempts < maxAttempts) {
            if (retryIf != null && !retryIf(error)) {
              sink.addError(error, stackTrace);
              return;
            }

            attempts++;
            await Future.delayed(currentDelay);
            currentDelay *= 2; // Exponential backoff

            try {
              await for (final event in this) {
                sink.add(event);
              }
              return;
            } catch (e, st) {
              if (attempts >= maxAttempts) {
                sink.addError(e, st);
                return;
              }
              error = e;
              stackTrace = st;
            }
          }
        },
        handleDone: (sink) => sink.close(),
      ),
    );
  }

  /// Collects all events into a list.
  /// 
  /// Example:
  /// ```dart
  /// final numbers = Stream.fromIterable([1, 2, 3, 4, 5]);
  /// final list = await numbers.toListStream();
  /// ```
  Future<List<T>> toListStream() => toList();

  /// Collects all events into a set.
  /// 
  /// Example:
  /// ```dart
  /// final numbers = Stream.fromIterable([1, 2, 2, 3, 3]);
  /// final unique = await numbers.toSetStream(); // {1, 2, 3}
  /// ```
  Future<Set<T>> toSetStream() => toSet();

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

  /// Merges this stream with another stream.
  /// 
  /// Example:
  /// ```dart
  /// final stream1 = Stream.fromIterable([1, 3, 5]);
  /// final stream2 = Stream.fromIterable([2, 4, 6]);
  /// final merged = stream1.merge(stream2); // 1, 2, 3, 4, 5, 6 (interleaved)
  /// ```
  Stream<T> merge(Stream<T> other) {
    final controller = StreamController<T>.broadcast(sync: true);

    final subscription1 = listen(
      controller.add,
      onError: controller.addError,
      onDone: () {
        if (!controller.hasListener) {
          controller.close();
        }
      },
    );

    final subscription2 = other.listen(
      controller.add,
      onError: controller.addError,
      onDone: () {
        if (!controller.hasListener) {
          controller.close();
        }
      },
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

  /// Adds a delay between events.
  /// 
  /// Example:
  /// ```dart
  /// final rapid = Stream.fromIterable([1, 2, 3]);
  /// final paced = rapid.delay(Duration(seconds: 1));
  /// ```
  Stream<T> delay(Duration duration) {
    return asyncMap((event) => Future.delayed(duration, () => event));
  }

  /// Converts error events to data events.
  /// 
  /// Example:
  /// ```dart
  /// final risky = riskyStream();
  /// final safe = risky.onErrorReturn(-1);
  /// ```
  Stream<T> onErrorReturn(T value) {
    return handleError((error, stackTrace) => value);
  }

  /// Converts error events to data events using a function.
  /// 
  /// Example:
  /// ```dart
  /// final risky = riskyStream();
  /// final safe = risky.onErrorReturnWith((error) => defaultValue(error));
  /// ```
  Stream<T> onErrorReturnWith(T Function(Object error) fallback) {
    return transform(
      StreamTransformer<T, T>.fromHandlers(
        handleData: (data, sink) => sink.add(data),
        handleError: (error, stackTrace, sink) => sink.add(fallback(error)),
        handleDone: (sink) => sink.close(),
      ),
    );
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

  /// Executes an action for each event without transforming the stream.
  /// 
  /// Example:
  /// ```dart
  /// final numbers = Stream.fromIterable([1, 2, 3]);
  /// final logged = numbers.doOnData((n) => print('Got: $n'));
  /// ```
  Stream<T> doOnData(void Function(T event) action) {
    return map((event) {
      action(event);
      return event;
    });
  }

  /// Executes an action when an error occurs.
  /// 
  /// Example:
  /// ```dart
  /// final risky = riskyStream();
  /// final logged = risky.doOnError((e, s) => logError(e, s));
  /// ```
  Stream<T> doOnError(
      void Function(Object error, StackTrace stackTrace) action) {
    return transform(
      StreamTransformer<T, T>.fromHandlers(
        handleData: (data, sink) => sink.add(data),
        handleError: (error, stackTrace, sink) {
          action(error, stackTrace);
          sink.addError(error, stackTrace);
        },
        handleDone: (sink) => sink.close(),
      ),
    );
  }

  /// Executes an action when the stream completes.
  /// 
  /// Example:
  /// ```dart
  /// final data = dataStream();
  /// final tracked = data.doOnDone(() => print('Stream completed'));
  /// ```
  Stream<T> doOnDone(void Function() action) {
    return transform(
      StreamTransformer<T, T>.fromHandlers(
        handleData: (data, sink) => sink.add(data),
        handleError: (error, stackTrace, sink) =>
            sink.addError(error, stackTrace),
        handleDone: (sink) {
          action();
          sink.close();
        },
      ),
    );
  }

  /// Starts with an initial value.
  /// 
  /// Example:
  /// ```dart
  /// final numbers = Stream.fromIterable([2, 3, 4]);
  /// final complete = numbers.startWith(1); // 1, 2, 3, 4
  /// ```
  Stream<T> startWith(T value) {
    return Stream<T>.multi((controller) {
      controller.add(value);
      controller.addStream(this).then((_) => controller.close());
    });
  }

  /// Ends with a final value.
  /// 
  /// Example:
  /// ```dart
  /// final numbers = Stream.fromIterable([1, 2, 3]);
  /// final complete = numbers.endWith(4); // 1, 2, 3, 4
  /// ```
  Stream<T> endWith(T value) {
    return Stream<T>.multi((controller) {
      controller.addStream(this).then((_) {
        controller.add(value);
        controller.close();
      });
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
}

/// Extension methods for Stream of nullable type with null handling.
extension FalconToolNullableStreamExtension<T> on Stream<T?> {
  /// Filters out null values from the stream.
  /// 
  /// This method is now provided by dartx package.
  /// Use: stream.whereNotNull()
  /// 
  /// Example:
  /// ```dart
  /// final mixed = Stream.fromIterable([1, null, 2, null, 3]);
  /// final nonNull = mixed.whereNotNull(); // 1, 2, 3
  /// ```
  Stream<T> whereNotNull() {
    return where((event) => event != null).cast<T>();
  }

  /// Maps non-null values, filtering out nulls.
  /// 
  /// Example:
  /// ```dart
  /// final nullable = Stream.fromIterable([1, null, 2, null, 3]);
  /// final doubled = nullable.mapNotNull((n) => n * 2); // 2, 4, 6
  /// ```
  Stream<R> mapNotNull<R>(R Function(T value) transform) {
    return where((event) => event != null)
        .map((event) => transform(event as T));
  }
}



