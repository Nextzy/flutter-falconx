import 'package:faltool/lib.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FalconToolStreamExtension', () {
    group('mapTransform', () {
      test('should transform stream data', () async {
        final stream = Stream.fromIterable([1, 2, 3, 4, 5]);
        final doubled = stream.mapTransform<int>(
          handleData: (data, sink) => sink.add(data * 2),
        );
        
        expect(await doubled.toList(), [2, 4, 6, 8, 10]);
      });

      test('should handle errors with custom handler', () async {
        final stream = Stream<int>.multi((controller) {
          controller.add(1);
          controller.addError(Exception('Test error'));
          controller.add(2);
          controller.close();
        });
        
        final transformed = stream.mapTransform<int>(
          handleData: (data, sink) => sink.add(data * 2),
          handleError: (error, stackTrace, sink) => sink.add(-1),
        );
        
        expect(await transformed.toList(), [2, -1, 4]);
      });
    });

    group('whereStream', () {
      test('should filter stream events', () async {
        final stream = Stream.fromIterable([1, 2, 3, 4, 5]);
        final evens = stream.whereStream((n) => n % 2 == 0);
        
        expect(await evens.toList(), [2, 4]);
      });
    });

    group('asyncMapStream', () {
      test('should map events asynchronously', () async {
        final stream = Stream.fromIterable([1, 2, 3]);
        final delayed = stream.asyncMapStream((n) async {
          await Future.delayed(const Duration(milliseconds: 10));
          return n * 2;
        });
        
        expect(await delayed.toList(), [2, 4, 6]);
      });
    });

    group('indexed', () {
      test('should combine events with their index', () async {
        final stream = Stream.fromIterable(['a', 'b', 'c']);
        final indexed = stream.indexed();
        
        final list = await indexed.toList();
        expect(list, [(0, 'a'), (1, 'b'), (2, 'c')]);
      });
    });



    // Note: retryWhen functionality is available in RxDart package

    group('toListStream', () {
      test('should collect all events into list', () async {
        final stream = Stream.fromIterable([1, 2, 3, 4, 5]);
        final list = await stream.toList();
        expect(list, [1, 2, 3, 4, 5]);
      });
    });

    group('toSetStream', () {
      test('should collect unique events into set', () async {
        final stream = Stream.fromIterable([1, 2, 2, 3, 3, 4]);
        final set = await stream.toSet();
        expect(set, {1, 2, 3, 4});
      });
    });

    group('combineLatest', () {
      test('should combine latest values from two streams', () async {
        final controller1 = StreamController<int>();
        final controller2 = StreamController<String>();
        
        final combined = controller1.stream.combineLatest(
          controller2.stream,
          (a, b) => '$a$b',
        );
        
        final events = <String>[];
        combined.listen(events.add);
        
        controller1.add(1);
        await Future.delayed(const Duration(milliseconds: 10));
        controller2.add('a');
        await Future.delayed(const Duration(milliseconds: 10));
        controller1.add(2);
        await Future.delayed(const Duration(milliseconds: 10));
        controller2.add('b');
        await Future.delayed(const Duration(milliseconds: 10));
        
        await controller1.close();
        await controller2.close();
        
        expect(events, ['1a', '2a', '2b']);
      });
    });

    group('takeWhileStream', () {
      test('should take events while condition is true', () async {
        final stream = Stream.fromIterable([1, 2, 3, 4, 5]);
        final limited = stream.takeWhileStream((n) => n < 4);
        
        expect(await limited.toList(), [1, 2, 3]);
      });
    });

    group('skipWhileStream', () {
      test('should skip events while condition is true', () async {
        final stream = Stream.fromIterable([1, 2, 3, 4, 5]);
        final skipped = stream.skipWhileStream((n) => n < 3);
        
        expect(await skipped.toList(), [3, 4, 5]);
      });
    });

    group('delay', () {
      test('should delay events', () async {
        final start = DateTime.now();
        final stream = Stream.fromIterable([1, 2, 3]);
        final delayed = stream.delay(const Duration(milliseconds: 150));
        
        final events = await delayed.toList();
        final duration = DateTime.now().difference(start);
        
        expect(events, [1, 2, 3]);
        expect(duration.inMilliseconds, greaterThanOrEqualTo(150));
      });
    });

    group('onErrorReturn', () {
      test('should convert errors to values', () async {
        final stream = Stream<int>.multi((controller) {
          controller.add(1);
          controller.addError(Exception('Error'));
          controller.add(2);
          controller.close();
        });
        
        final safe = stream.onErrorReturn(-1);
        expect(await safe.toList(), [1, -1, 2]);
      });
    });

    group('onErrorReturnWith', () {
      test('should convert errors to values using function', () async {
        final stream = Stream<int>.multi((controller) {
          controller.add(1);
          controller.addError(Exception('Error 1'));
          controller.add(2);
          controller.addError(Exception('Error 2'));
          controller.close();
        });
        
        final safe = stream.onErrorReturnWith((error, stackTrace) {
          if (error.toString().contains('1')) return -1;
          return -2;
        });
        
        expect(await safe.toList(), [1, -1, 2, -2]);
      });
    });

    group('ignoreErrors', () {
      test('should ignore all errors', () async {
        final stream = Stream<int>.multi((controller) {
          controller.add(1);
          controller.addError(Exception('Error 1'));
          controller.add(2);
          controller.addError(Exception('Error 2'));
          controller.add(3);
          controller.close();
        });
        
        final safe = stream.ignoreErrors();
        expect(await safe.toList(), [1, 2, 3]);
      });
    });

    group('doOnData', () {
      test('should execute action for each event', () async {
        final sideEffects = <int>[];
        final stream = Stream.fromIterable([1, 2, 3]);
        final logged = stream.doOnData((n) => sideEffects.add(n));
        
        final events = await logged.toList();
        expect(events, [1, 2, 3]);
        expect(sideEffects, [1, 2, 3]);
      });
    });

    group('doOnError', () {
      test('should execute action on errors', () async {
        final errors = <String>[];
        final stream = Stream<int>.multi((controller) {
          controller.add(1);
          controller.addError(Exception('Error 1'));
          controller.add(2);
          controller.close();
        });
        
        final logged = stream.doOnError((error, stackTrace) {
          errors.add(error.toString());
        });
        
        // Use onErrorReturn to handle the error after doOnError logs it
        final safe = logged.onErrorReturn(-999);
        final events = await safe.toList();
        
        expect(events, [1, -999, 2]);
        expect(errors, [contains('Error 1')]);
      });
    });

    group('doOnDone', () {
      test('should execute action when stream completes', () async {
        var completed = false;
        final stream = Stream.fromIterable([1, 2, 3]);
        final tracked = stream.doOnDone(() => completed = true);
        
        await tracked.toList();
        expect(completed, true);
      });
    });

    group('startWith', () {
      test('should start stream with initial value', () async {
        final stream = Stream.fromIterable([2, 3, 4]);
        final complete = stream.startWith(1);
        
        expect(await complete.toList(), [1, 2, 3, 4]);
      });
    });

    group('endWith', () {
      test('should end stream with final value', () async {
        final stream = Stream.fromIterable([1, 2, 3]);
        final complete = stream.endWith(4);
        
        expect(await complete.toList(), [1, 2, 3, 4]);
      });
    });

    group('count', () {
      test('should count total events', () async {
        final stream = Stream.fromIterable([1, 2, 3, 4, 5]);
        final total = await stream.count();
        expect(total, 5);
      });

      test('should count empty stream', () async {
        final stream = Stream<int>.empty();
        final total = await stream.count();
        expect(total, 0);
      });
    });
  });

  group('FalconToolNullableStreamExtension', () {
    group('whereNotNull', () {
      test('should filter out null values', () async {
        final stream = Stream.fromIterable([1, null, 2, null, 3]);
        final nonNull = stream.whereNotNull();
        
        expect(await nonNull.toList(), [1, 2, 3]);
      });

      test('should handle all null stream', () async {
        final stream = Stream<int?>.fromIterable([null, null, null]);
        final nonNull = stream.whereNotNull();
        
        expect(await nonNull.toList(), []);
      });
    });

    group('mapNotNull', () {
      test('should map non-null values and filter nulls', () async {
        final stream = Stream.fromIterable([1, null, 2, null, 3]);
        final doubled = stream.mapNotNull((n) => n != null ? n * 2 : null);
        
        expect(await doubled.toList(), [2, 4, 6]);
      });

      test('should handle empty result', () async {
        final stream = Stream<int?>.fromIterable([null, null]);
        final mapped = stream.mapNotNull((n) => n != null ? n * 2 : null);
        
        expect(await mapped.toList(), []);
      });
    });
  });
}