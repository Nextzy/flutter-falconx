import 'dart:math' as math;
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

  /// Executes an action if the iterable is not null and not empty.
  void ifNotEmpty(void Function(Iterable<T> iterable) action) {
    if (this != null && this!.isNotEmpty) {
      action(this!);
    }
  }
}

extension FalconToolIterableNumAverageExtension<T extends num> on Iterable<T> {
  /// Returns the average of all elements in the collection.
  double average() {
    var count = 0;
    num sum = 0;
    for (final current in this) {
      sum += current;
      count++;
    }

    if (count == 0) {
      return 0;
    } else {
      return sum / count;
    }
  }
}



/// Extension methods for mixed-type iterables.
extension FalconToolMixedIterableExtensions on Iterable<Object?> {
  /// Calculates the sum of numeric elements, ignoring non-numeric values.
  ///
  /// Example:
  /// ```dart
  /// final mixed = ['a', 1, 'b', 2, 'c', 3];
  /// final sum = mixed.sum(); // 6
  /// ```
  num sum() {
    num total = 0;
    for (final element in this) {
      if (element is num) {
        total += element;
      }
    }
    return total;
  }

  /// Calculates the average of numeric elements, ignoring non-numeric values.
  ///
  /// Returns null if no numeric elements are found.
  ///
  /// Example:
  /// ```dart
  /// final mixed = ['a', 1, 'b', 2, 'c', 3];
  /// final avg = mixed.average(); // 2.0
  /// ```
  double? average() {
    num total = 0;
    var count = 0;
    for (final element in this) {
      if (element is num) {
        total += element;
        count++;
      }
    }
    return count > 0 ? total.toDouble() / count : null;
  }
}
