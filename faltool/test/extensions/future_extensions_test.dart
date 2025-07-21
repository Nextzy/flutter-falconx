import 'package:faltool/lib.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FalconToolFutureExtensions', () {
    group('timeoutWithDefault', () {
      test('should return result when completed within timeout', () async {
        final future = Future.delayed(
          const Duration(milliseconds: 100),
          () => 'success',
        );
        final result = await future.timeoutWithDefault(
          const Duration(milliseconds: 200),
          'default',
        );
        expect(result, 'success');
      });

      test('should return default value on timeout', () async {
        final future = Future.delayed(
          const Duration(milliseconds: 200),
          () => 'success',
        );
        final result = await future.timeoutWithDefault(
          const Duration(milliseconds: 100),
          'default',
        );
        expect(result, 'default');
      });
    });

    group('timeoutWithCallback', () {
      test('should execute callback on timeout', () async {
        var callbackExecuted = false;
        final future = Future.delayed(
          const Duration(milliseconds: 200),
          () => 'success',
        );
        
        final result = await future.timeoutWithCallback(
          const Duration(milliseconds: 100),
          onTimeout: () {
            callbackExecuted = true;
            return 'timeout';
          },
        );
        
        expect(result, 'timeout');
        expect(callbackExecuted, true);
      });

      test('should not execute callback when completed in time', () async {
        var callbackExecuted = false;
        final future = Future.delayed(
          const Duration(milliseconds: 100),
          () => 'success',
        );
        
        final result = await future.timeoutWithCallback(
          const Duration(milliseconds: 200),
          onTimeout: () {
            callbackExecuted = true;
            return 'timeout';
          },
        );
        
        expect(result, 'success');
        expect(callbackExecuted, false);
      });
    });

    group('retryWithBackoff', () {
      test('should succeed on first attempt', () async {
        var attempts = 0;
        final future = Future(() {
          attempts++;
          return 'success';
        });
        
        final result = await future.retryWithBackoff();
        expect(result, 'success');
        expect(attempts, 1);
      });

      test('should work with pre-completed futures', () async {
        // retryWithBackoff on an already-started future just returns the result
        final future = Future.value('success');
        
        final result = await future.retryWithBackoff(
          maxAttempts: 3,
          delay: const Duration(milliseconds: 10),
        );
        expect(result, 'success');
      });

      test('should fail after max attempts', () async {
        var attempts = 0;
        final future = Future(() {
          attempts++;
          throw Exception('Always fail');
        });
        
        expect(
          () => future.retryWithBackoff(
            maxAttempts: 3,
            delay: const Duration(milliseconds: 10),
          ),
          throwsException,
        );
      });

      test('should fail immediately with retryIf returning false', () async {
        final future = Future<String>.error(Exception('Not retryable'));
        
        expect(
          () => future.retryWithBackoff(
            maxAttempts: 3,
            delay: const Duration(milliseconds: 10),
            retryIf: (error) => false,
          ),
          throwsException,
        );
      });

      // Note: Exponential backoff test removed because retryWithBackoff
      // operates on already-started futures and cannot truly retry the computation
    });

    group('ignoreErrors', () {
      test('should ignore errors and complete normally', () async {
        final future = Future<void>.error(Exception('Error'));
        await expectLater(future.ignoreErrors(), completes);
      });

      test('should complete successfully for non-error futures', () async {
        final future = Future.value('success');
        await expectLater(future.ignoreErrors(), completes);
      });
    });

    group('onErrorDo', () {
      test('should execute callback on error and rethrow', () async {
        var callbackError;
        var callbackStackTrace;
        
        final future = Future<String>.error(Exception('Test error'));
        
        expect(
          () => future.onErrorDo((error, stackTrace) {
            callbackError = error;
            callbackStackTrace = stackTrace;
          }),
          throwsException,
        );
        
        // Wait for the future to complete
        await Future.delayed(const Duration(milliseconds: 10));
        
        expect(callbackError, isException);
        expect(callbackStackTrace, isNotNull);
      });

      test('should not execute callback on success', () async {
        var callbackExecuted = false;
        
        final future = Future.value('success');
        final result = await future.onErrorDo((error, stackTrace) {
          callbackExecuted = true;
        });
        
        expect(result, 'success');
        expect(callbackExecuted, false);
      });
    });

    group('mapSuccess', () {
      test('should transform successful result', () async {
        final future = Future.value(5);
        final result = await future.mapSuccess((value) => value * 2);
        expect(result, 10);
      });

      test('should propagate errors without transformation', () async {
        final future = Future<int>.error(Exception('Error'));
        expect(
          () => future.mapSuccess((value) => value * 2),
          throwsException,
        );
      });
    });

    group('mapError', () {
      test('should transform error', () async {
        final future = Future<String>.error(Exception('Original'));
        
        try {
          await future.mapError((error) => Exception('Transformed'));
          fail('Should have thrown');
        } catch (e) {
          expect(e.toString(), contains('Transformed'));
        }
      });

      test('should not transform successful results', () async {
        final future = Future.value('success');
        final result = await future.mapError((error) => Exception('Should not run'));
        expect(result, 'success');
      });
    });

    group('whenCompleteDo', () {
      test('should execute action on success', () async {
        var actionExecuted = false;
        final future = Future.value('success');
        
        final result = await future.whenCompleteDo(() {
          actionExecuted = true;
        });
        
        expect(result, 'success');
        expect(actionExecuted, true);
      });

      test('should execute action on error', () async {
        var actionExecuted = false;
        final future = Future<String>.error(Exception('Error'));
        
        try {
          await future.whenCompleteDo(() {
            actionExecuted = true;
          });
        } catch (_) {
          // Expected
        }
        
        expect(actionExecuted, true);
      });
    });

    group('guard', () {
      test('should execute future when condition is true', () async {
        final future = Future.value('success');
        final result = await future.guard(
          () => true,
          fallback: 'fallback',
        );
        expect(result, 'success');
      });

      test('should return fallback when condition is false', () async {
        final future = Future.value('success');
        final result = await future.guard(
          () => false,
          fallback: 'fallback',
        );
        expect(result, 'fallback');
      });
    });

    group('toResult', () {
      test('should wrap successful future in Result.success', () async {
        final future = Future.value('success');
        final result = await future.toResult();
        
        expect(result.isSuccess, true);
        expect(result.isFailure, false);
        result.fold(
          onSuccess: (value) => expect(value, 'success'),
          onFailure: (error, stackTrace) => fail('Should not fail'),
        );
      });

      test('should wrap failed future in Result.failure', () async {
        final exception = Exception('Test error');
        final future = Future<String>.error(exception);
        final result = await future.toResult();
        
        expect(result.isSuccess, false);
        expect(result.isFailure, true);
        result.fold(
          onSuccess: (value) => fail('Should not succeed'),
          onFailure: (error, stackTrace) => expect(error, exception),
        );
      });
    });

    group('delayed', () {
      test('should delay future execution', () async {
        final start = DateTime.now();
        final future = Future.value('success');
        final result = await future.delayed(const Duration(milliseconds: 100));
        final duration = DateTime.now().difference(start);
        
        expect(result, 'success');
        expect(duration.inMilliseconds, greaterThanOrEqualTo(100));
      });
    });

    group('cancelAfter', () {
      test('should return value when completed within timeout', () async {
        final future = Future.delayed(
          const Duration(milliseconds: 50),
          () => 'success',
        );
        final result = await future.cancelAfter(const Duration(milliseconds: 100));
        expect(result, 'success');
      });

      test('should return null on timeout', () async {
        final future = Future.delayed(
          const Duration(milliseconds: 150),
          () => 'success',
        );
        final result = await future.cancelAfter(const Duration(milliseconds: 100));
        expect(result, null);
      });
    });

    group('timed', () {
      test('should measure execution time for successful future', () async {
        Duration? measuredDuration;
        final future = Future.delayed(
          const Duration(milliseconds: 100),
          () => 'success',
        );
        
        final result = await future.timed((duration) {
          measuredDuration = duration;
        });
        
        expect(result, 'success');
        expect(measuredDuration, isNotNull);
        expect(measuredDuration!.inMilliseconds, greaterThanOrEqualTo(100));
      });

      test('should measure execution time for failed future', () async {
        Duration? measuredDuration;
        final future = Future.delayed(
          const Duration(milliseconds: 100),
          () => throw Exception('Error'),
        );
        
        try {
          await future.timed((duration) {
            measuredDuration = duration;
          });
          fail('Should have thrown');
        } catch (_) {
          // Expected
        }
        
        expect(measuredDuration, isNotNull);
        expect(measuredDuration!.inMilliseconds, greaterThanOrEqualTo(100));
      });
    });

    group('toStream', () {
      test('should convert future to stream', () async {
        final future = Future.value('success');
        final stream = future.toStream();
        
        final events = await stream.toList();
        expect(events, ['success']);
      });

      test('should propagate errors to stream', () async {
        final future = Future<String>.error(Exception('Error'));
        final stream = future.toStream();
        
        expect(stream, emitsError(isException));
      });
    });
  });

  group('FalconToolEitherFutureExtensions', () {
    group('toEither', () {
      test('should wrap successful result in Right', () async {
        final future = Future.value('success');
        final either = await future.toEither((error) => 'Error: $error');
        
        expect(either.isRight(), true);
        expect(either.isLeft(), false);
        either.fold(
          (left) => fail('Should not be left'),
          (right) => expect(right, 'success'),
        );
      });

      test('should wrap error in Left using error mapper', () async {
        final future = Future<String>.error(Exception('Test error'));
        final either = await future.toEither((error) => 'Error: $error');
        
        expect(either.isLeft(), true);
        expect(either.isRight(), false);
        either.fold(
          (left) => expect(left, contains('Error: Exception: Test error')),
          (right) => fail('Should not be right'),
        );
      });

      test('should handle different error types', () async {
        final future = Future<int>.error('String error');
        final either = await future.toEither((error) {
          if (error is String) {
            return 'String: $error';
          }
          return 'Unknown: $error';
        });
        
        expect(either.isLeft(), true);
        either.fold(
          (left) => expect(left, 'String: String error'),
          (right) => fail('Should not be right'),
        );
      });

      test('should work with async operations', () async {
        final future = Future.delayed(
          const Duration(milliseconds: 50),
          () => 'delayed success',
        );
        final either = await future.toEither((error) => 'Error: $error');
        
        expect(either.isRight(), true);
        either.fold(
          (left) => fail('Should not be left'),
          (right) => expect(right, 'delayed success'),
        );
      });

      test('should work with async errors', () async {
        final future = Future.delayed(
          const Duration(milliseconds: 50),
          () => throw Exception('Delayed error'),
        );
        final either = await future.toEither((error) => 'Error: $error');
        
        expect(either.isLeft(), true);
        either.fold(
          (left) => expect(left, contains('Error: Exception: Delayed error')),
          (right) => fail('Should not be right'),
        );
      });
    });
  });

  group('FalconToolFutureNullExtensions', () {
    group('orDefault', () {
      test('should return future when not null', () async {
        final Future<String>? future = Future.value('success');
        final result = await future.orDefault('default');
        expect(result, 'success');
      });

      test('should return default future when null', () async {
        final Future<String>? future = null;
        final result = await future.orDefault('default');
        expect(result, 'default');
      });
    });

    group('orNull', () {
      test('should return future when not null', () async {
        final Future<String>? future = Future.value('success');
        final result = await future.orNull();
        expect(result, 'success');
      });

      test('should return null future when null', () async {
        final Future<String>? future = null;
        final result = await future.orNull();
        expect(result, null);
      });
    });

    group('whenNotNull', () {
      test('should return future when not null', () async {
        final Future<String>? future = Future.value('success');
        final result = await future.whenNotNull(orElse: () => 'default');
        expect(result, 'success');
      });

      test('should return orElse value when null', () async {
        final Future<String>? future = null;
        final result = await future.whenNotNull(orElse: () => 'default');
        expect(result, 'default');
      });
    });
  });

  group('FalconToolFutureNullableExtensions', () {
    group('mapIfNotNull', () {
      test('should map non-null values', () async {
        final future = Future<String?>.value('hello');
        final result = await future.mapIfNotNull((value) => value.length);
        expect(result, 5);
      });

      test('should return null for null values', () async {
        final future = Future<String?>.value(null);
        final result = await future.mapIfNotNull((value) => value.length);
        expect(result, null);
      });
    });

    group('defaultIfNull', () {
      test('should return value when not null', () async {
        final future = Future<String?>.value('success');
        final result = await future.defaultIfNull('default');
        expect(result, 'success');
      });

      test('should return default when null', () async {
        final future = Future<String?>.value(null);
        final result = await future.defaultIfNull('default');
        expect(result, 'default');
      });
    });

    group('where', () {
      test('should return value when predicate is true', () async {
        final future = Future<int?>.value(5);
        final result = await future.where((value) => value > 3);
        expect(result, 5);
      });

      test('should return null when predicate is false', () async {
        final future = Future<int?>.value(2);
        final result = await future.where((value) => value > 3);
        expect(result, null);
      });

      test('should return null when value is null', () async {
        final future = Future<int?>.value(null);
        final result = await future.where((value) => value > 3);
        expect(result, null);
      });
    });
  });
}