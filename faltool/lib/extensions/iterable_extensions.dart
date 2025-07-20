import 'dart:math' as math;

import 'package:dartx/dartx.dart' hide IntRange;
import 'package:faltool/lib.dart';

/// Extension methods for Iterable type with enhanced functionality.
/// 
/// Provides comprehensive utilities for collection operations including
/// safe transformations, aggregations, grouping, and advanced filtering.
extension FalconToolIterableExtensions<T> on Iterable<T> {
  /// Reduces the collection safely, returning null if empty.
  /// 
  /// Example:
  /// ```dart
  /// final sum = [1, 2, 3].reduceOrNull((a, b) => a + b); // 6
  /// final empty = <int>[].reduceOrNull((a, b) => a + b); // null
  /// ```
  T? reduceOrNull(T Function(T value, T element) combine) {
    if (isEmpty) return null;
    if (length == 1) return first;
    return reduce(combine);
  }

  /// Reduces the collection safely with a default value for empty collections.
  /// 
  /// Example:
  /// ```dart
  /// final sum = [1, 2, 3].reduceSafe((a, b) => a + b, 0); // 6
  /// final empty = <int>[].reduceSafe((a, b) => a + b, 0); // 0
  /// ```
  T reduceSafe(T Function(T value, T element) combine, T defaultValue) {
    if (isEmpty) return defaultValue;
    if (length == 1) return first;
    return reduce(combine);
  }

  /// Returns the first element matching the predicate, or null if none found.
  /// 
  /// This method is now provided by dartx package.
  /// Use: collection.firstOrNullWhere((element) => condition)
  /// 
  /// Example:
  /// ```dart
  /// final even = [1, 2, 3].firstOrNullWhere((n) => n % 2 == 0); // 2
  /// final none = [1, 3, 5].firstOrNullWhere((n) => n % 2 == 0); // null
  /// ```

  /// Returns the last element matching the predicate, or null if none found.
  /// 
  /// This method is now provided by dartx package.
  /// Use: collection.lastOrNullWhere((element) => condition)
  /// 
  /// Example:
  /// ```dart
  /// final even = [1, 2, 3, 4].lastOrNullWhere((n) => n % 2 == 0); // 4
  /// ```

  /// Returns the single element matching the predicate, or null.
  /// 
  /// This method is now provided by dartx package.
  /// Use: collection.singleOrNullWhere((element) => condition)
  /// 
  /// Returns null if no elements match or if more than one element matches.
  /// 
  /// Example:
  /// ```dart
  /// final two = [1, 2, 3].singleOrNullWhere((n) => n == 2); // 2
  /// final none = [1, 2, 3].singleOrNullWhere((n) => n > 3); // null
  /// final many = [1, 2, 3].singleOrNullWhere((n) => n > 1); // null
  /// ```

  /// Groups elements by a key function.
  /// 
  /// Example:
  /// ```dart
  /// final words = ['hello', 'world', 'hi', 'dart'];
  /// final byLength = words.groupBy((word) => word.length);
  /// // {5: ['hello', 'world'], 2: ['hi'], 4: ['dart']}
  /// ```
  Map<K, List<T>> groupBy<K>(K Function(T element) keyFunction) {
    final map = <K, List<T>>{};
    for (final element in this) {
      final key = keyFunction(element);
      (map[key] ??= []).add(element);
    }
    return map;
  }

  /// Counts elements that satisfy the given predicate.
  /// 
  /// This method is now provided by dartx package.
  /// Use: collection.count((element) => condition)
  /// 
  /// Example:
  /// ```dart
  /// final evenCount = [1, 2, 3, 4, 5].count((n) => n % 2 == 0); // 2
  /// ```

  /// Checks if none of the elements satisfy the given predicate.
  /// 
  /// This method is now provided by dartx package.
  /// Use: collection.none((element) => condition)
  /// 
  /// Example:
  /// ```dart
  /// final noNegatives = [1, 2, 3].none((n) => n < 0); // true
  /// ```

  /// Returns elements at the specified indices.
  /// 
  /// Example:
  /// ```dart
  /// final letters = ['a', 'b', 'c', 'd', 'e'];
  /// final selected = letters.whereIndexed((i, _) => i.isEven); // ['a', 'c', 'e']
  /// ```
  Iterable<T> whereIndexed(bool Function(int index, T element) test) sync* {
    var index = 0;
    for (final element in this) {
      if (test(index, element)) yield element;
      index++;
    }
  }

  /// Maps elements with their indices.
  /// 
  /// This method is now provided by dartx package.
  /// Use: collection.mapIndexed((index, element) => result)
  /// 
  /// Example:
  /// ```dart
  /// final indexed = ['a', 'b', 'c'].mapIndexed((i, e) => '$i: $e');
  /// // ['0: a', '1: b', '2: c']
  /// ```

  /// Returns distinct elements based on a key function.
  /// 
  /// This method is now provided by dartx package.
  /// Use: collection.distinctBy((element) => key)
  /// 
  /// Example:
  /// ```dart
  /// final people = [
  ///   Person('Alice', 25),
  ///   Person('Bob', 30),
  ///   Person('Alice', 35),
  /// ];
  /// final unique = people.distinctBy((p) => p.name); // Alice(25), Bob(30)
  /// ```

  /// Returns the minimum element according to the provided comparator.
  /// 
  /// Example:
  /// ```dart
  /// final people = [Person('Alice', 25), Person('Bob', 30)];
  /// final youngest = people.minBy((p) => p.age); // Alice
  /// ```
  T? minBy<R extends Comparable<R>>(R Function(T element) selector) {
    if (isEmpty) return null;
    return reduce((a, b) => selector(a).compareTo(selector(b)) <= 0 ? a : b);
  }

  /// Returns the maximum element according to the provided comparator.
  /// 
  /// Example:
  /// ```dart
  /// final people = [Person('Alice', 25), Person('Bob', 30)];
  /// final oldest = people.maxBy((p) => p.age); // Bob
  /// ```
  T? maxBy<R extends Comparable<R>>(R Function(T element) selector) {
    if (isEmpty) return null;
    return reduce((a, b) => selector(a).compareTo(selector(b)) >= 0 ? a : b);
  }

  /// Chunks the iterable into lists of the specified size.
  /// 
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 5, 6, 7];
  /// final chunks = numbers.chunked(3); // [[1, 2, 3], [4, 5, 6], [7]]
  /// ```
  Iterable<List<T>> chunked(int size) sync* {
    if (size <= 0) {
      throw ArgumentError.value(size, 'size', 'must be positive');
    }
    
    final iterator = this.iterator;
    while (iterator.moveNext()) {
      final chunk = <T>[iterator.current];
      for (var i = 1; i < size && iterator.moveNext(); i++) {
        chunk.add(iterator.current);
      }
      yield chunk;
    }
  }

  /// Returns elements separated by the specified separator.
  /// 
  /// Example:
  /// ```dart
  /// final letters = ['a', 'b', 'c'];
  /// final separated = letters.intersperse('-'); // ['a', '-', 'b', '-', 'c']
  /// ```
  Iterable<T> intersperse(T separator) sync* {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return;
    
    yield iterator.current;
    while (iterator.moveNext()) {
      yield separator;
      yield iterator.current;
    }
  }

  /// Flattens nested iterables by one level.
  /// 
  /// Example:
  /// ```dart
  /// final nested = [[1, 2], [3, 4], [5]];
  /// final flat = nested.flatten(); // [1, 2, 3, 4, 5]
  /// ```
  Iterable<R> flatten<R>() sync* {
    for (final element in this) {
      if (element is Iterable<R>) {
        yield* element;
      }
    }
  }

  /// Zips this iterable with another iterable.
  /// 
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3];
  /// final letters = ['a', 'b', 'c'];
  /// final zipped = numbers.zip(letters); // [(1, 'a'), (2, 'b'), (3, 'c')]
  /// ```
  Iterable<(T, R)> zip<R>(Iterable<R> other) sync* {
    final iterator1 = iterator;
    final iterator2 = other.iterator;
    
    while (iterator1.moveNext() && iterator2.moveNext()) {
      yield (iterator1.current, iterator2.current);
    }
  }

  /// Partitions elements into two lists based on a predicate.
  /// 
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 5];
  /// final (evens, odds) = numbers.partition((n) => n % 2 == 0);
  /// // evens: [2, 4], odds: [1, 3, 5]
  /// ```
  (List<T>, List<T>) partition(bool Function(T element) test) {
    final matching = <T>[];
    final notMatching = <T>[];
    
    for (final element in this) {
      if (test(element)) {
        matching.add(element);
      } else {
        notMatching.add(element);
      }
    }
    
    return (matching, notMatching);
  }

  /// Returns a random element from the iterable.
  /// 
  /// Example:
  /// ```dart
  /// final colors = ['red', 'green', 'blue'];
  /// final random = colors.randomElement(); // Random color
  /// ```
  T? randomElement([math.Random? random]) {
    if (isEmpty) return null;
    final rand = random ?? math.Random();
    final index = rand.nextInt(length);
    return elementAt(index);
  }

  /// Returns a shuffled copy of the iterable.
  /// 
  /// This method is now provided by dartx package.
  /// Use: collection.shuffled()
  /// 
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 5];
  /// final shuffled = numbers.shuffled(); // Randomly ordered
  /// ```

  /// Converts the iterable to a string with custom formatting.
  /// 
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3];
  /// final str = numbers.joinToString(
  ///   separator: ', ',
  ///   prefix: '[',
  ///   postfix: ']',
  ///   transform: (n) => 'Item $n',
  /// ); // '[Item 1, Item 2, Item 3]'
  /// ```
  String joinToString({
    String separator = ', ',
    String prefix = '',
    String postfix = '',
    int? limit,
    String truncated = '...',
    String Function(T)? transform,
  }) {
    final buffer = StringBuffer(prefix);
    var count = 0;
    
    for (final element in this) {
      if (count > 0) buffer.write(separator);
      
      if (limit != null && count >= limit) {
        buffer.write(truncated);
        break;
      }
      
      buffer.write(transform?.call(element) ?? element);
      count++;
    }
    
    buffer.write(postfix);
    return buffer.toString();
  }

  /// Calculates the sum of numeric elements.
  /// 
  /// Example:
  /// ```dart
  /// final total = [1, 2, 3, 4, 5].sum(); // 15
  /// ```
  num sum() {
    num result = 0;
    for (final element in this) {
      if (element is num) {
        result += element;
      }
    }
    return result;
  }

  /// Calculates the average of numeric elements.
  /// 
  /// Example:
  /// ```dart
  /// final avg = [1, 2, 3, 4, 5].average(); // 3.0
  /// ```
  double? average() {
    if (isEmpty) return null;
    num total = 0;
    var count = 0;
    
    for (final element in this) {
      if (element is num) {
        total += element;
        count++;
      }
    }
    
    return count > 0 ? total / count : null;
  }
}

/// Extension methods for nullable Iterable type.
extension FalconToolNullIterableExtensions<T> on Iterable<T>? {
  /// Reduces the collection safely, returning null if null or empty.
  T? reduceOrNull(T Function(T value, T element) combine) {
    if (this == null || this!.isEmpty) return null;
    if (this!.length == 1) return this!.first;
    return this!.reduce(combine);
  }

  /// Reduces the collection safely with a default value.
  T reduceSafe(T Function(T value, T element) combine, T defaultValue) {
    if (this == null || this!.isEmpty) return defaultValue;
    if (this!.length == 1) return this!.first;
    return this!.reduce(combine);
  }

  /// Returns true if the iterable is null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Returns true if the iterable is not null and not empty.
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// Returns the iterable or an empty iterable if null.
  Iterable<T> get orEmpty => this ?? const [];

  /// Returns the iterable as a list or an empty list if null.
  List<T> get orEmptyList => this?.toList() ?? [];

  /// Returns the iterable as a set or an empty set if null.
  Set<T> get orEmptySet => this?.toSet() ?? {};

  /// Maps elements if not null, otherwise returns null.
  Iterable<R>? mapOrNull<R>(R Function(T element) toElement) {
    return this?.map(toElement);
  }

  /// Filters elements if not null, otherwise returns null.
  Iterable<T>? whereOrNull(bool Function(T element) test) {
    return this?.where(test);
  }

  /// Returns the first element or null if the iterable is null or empty.
  T? get firstOrNull => this?.firstOrNull;

  /// Returns the last element or null if the iterable is null or empty.
  T? get lastOrNull => this?.lastOrNull;

  /// Executes an action if the iterable is not null and not empty.
  void ifNotEmpty(void Function(Iterable<T> iterable) action) {
    if (this != null && this!.isNotEmpty) {
      action(this!);
    }
  }
}
