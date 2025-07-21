import 'dart:math' as math;
import 'package:faltool/lib.dart';

/// Extension methods for List type with enhanced functionality.
/// 
/// Provides comprehensive utilities for list operations including
/// safe transformations, efficient modifications, and advanced filtering.
extension FalconToolListExtensions<V> on List<V> {
  /// Removes all null values from the list.
  /// 
  /// Example:
  /// ```dart
  /// final items = [1, null, 2, null, 3];
  /// final cleaned = items.removeNulls(); // [1, 2, 3]
  /// ```
  List<V> removeNulls() => removeNullsFromList(this).cast<V>();

  /// Maps each element to a future and waits for all to complete.
  /// 
  /// Example:
  /// ```dart
  /// final urls = ['url1', 'url2', 'url3'];
  /// final responses = await urls.mapAsync((url) => fetchData(url));
  /// ```
  Future<List<T>> mapAsync<T>(Future<T> Function(V e) toElement) =>
      Future.wait(map(toElement));

  /// Creates a shallow copy of the list.
  /// 
  /// Example:
  /// ```dart
  /// final original = [1, 2, 3];
  /// final copy = original.copy();
  /// copy.add(4); // original remains [1, 2, 3]
  /// ```
  List<V> copy() => toList();

  /// Creates a deep copy of the list using a copy function.
  /// 
  /// Example:
  /// ```dart
  /// final users = [User('Alice'), User('Bob')];
  /// final deepCopy = users.deepCopy((user) => User(user.name));
  /// ```
  List<V> deepCopy(V Function(V element) copyElement) {
    return map(copyElement).toList();
  }

  /// Edits the first element matching the predicate.
  /// 
  /// Returns true if an element was edited, false otherwise.
  /// 
  /// Example:
  /// ```dart
  /// final users = [User('Alice', 25), User('Bob', 30)];
  /// users.edit(
  ///   (user) => user.name == 'Alice',
  ///   (user) => User(user.name, 26),
  /// ); // true, Alice's age is now 26
  /// ```
  bool edit(
      bool Function(V element) toElement, V Function(V oldData) editData) {
    final index = indexWhere(toElement);
    if (index != -1) {
      this[index] = editData(this[index]);
      return true;
    }
    return false;
  }

  /// Edits all elements matching the predicate.
  /// 
  /// Returns the count of edited elements.
  /// 
  /// Example:
  /// ```dart
  /// final scores = [80, 90, 75, 95];
  /// final count = scores.editAll(
  ///   (score) => score < 80,
  ///   (score) => 80,
  /// ); // count = 1, list is now [80, 90, 80, 95]
  /// ```
  int editAll(
      bool Function(V element) toElement, V Function(V oldData) editData) {
    var count = 0;
    for (var i = 0; i < length; i++) {
      if (toElement(this[i])) {
        this[i] = editData(this[i]);
        count++;
      }
    }
    return count;
  }

  /// Safely gets the element at index, returning null if out of bounds.
  /// 
  /// This method is now provided by dartx package.
  /// Use: list.elementAtOrNull(index)
  /// 
  /// Example:
  /// ```dart
  /// final list = [1, 2, 3];
  /// final item = list.elementAtOrNull(5); // null
  /// ```

  /// Gets the element at index or returns a default value.
  /// 
  /// Example:
  /// ```dart
  /// final list = [1, 2, 3];
  /// final item = list.getOrDefault(5, -1); // -1
  /// ```
  V getOrDefault(int index, V defaultValue) {
    return (index >= 0 && index < length) ? this[index] : defaultValue;
  }

  /// Removes the first element matching the predicate.
  /// 
  /// Returns true if an element was removed.
  /// 
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 5];
  /// final removed = numbers.removeFirst((n) => n > 3); // true
  /// // numbers is now [1, 2, 3, 5]
  /// ```
  bool removeFirst(bool Function(V element) test) {
    final index = indexWhere(test);
    if (index != -1) {
      removeAt(index);
      return true;
    }
    return false;
  }

  /// Removes all elements matching the predicate.
  /// 
  /// Returns the count of removed elements.
  /// 
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 5];
  /// final count = numbers.removeAll((n) => n % 2 == 0); // 2
  /// // numbers is now [1, 3, 5]
  /// ```
  int removeAll(bool Function(V element) test) {
    final originalLength = length;
    removeWhere(test);
    return originalLength - length;
  }

  /// Removes duplicate elements while preserving order.
  /// 
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 2, 3, 1, 4];
  /// final unique = numbers.removeDuplicates(); // [1, 2, 3, 4]
  /// ```
  List<V> removeDuplicates() {
    final seen = <V>{};
    return where(seen.add).toList();
  }

  /// Removes duplicates based on a key function.
  /// 
  /// Example:
  /// ```dart
  /// final users = [User('Alice', 25), User('Bob', 30), User('Alice', 35)];
  /// final unique = users.removeDuplicatesBy((u) => u.name);
  /// // [User('Alice', 25), User('Bob', 30)]
  /// ```
  List<V> removeDuplicatesBy<K>(K Function(V element) keyFunction) {
    final seen = <K>{};
    return where((element) => seen.add(keyFunction(element))).toList();
  }

  /// Swaps two elements at the given indices.
  /// 
  /// This method is now provided by dartx package.
  /// Use: list.swap(index1, index2)
  /// 
  /// Example:
  /// ```dart
  /// final list = ['a', 'b', 'c'];
  /// list.swap(0, 2); // ['c', 'b', 'a']
  /// ```

  /// Moves an element from one index to another.
  /// 
  /// Example:
  /// ```dart
  /// final list = ['a', 'b', 'c', 'd'];
  /// list.move(0, 2); // ['b', 'c', 'a', 'd']
  /// ```
  void move(int fromIndex, int toIndex) {
    if (fromIndex < 0 || fromIndex >= length || 
        toIndex < 0 || toIndex >= length) {
      throw RangeError('Index out of range');
    }
    if (fromIndex == toIndex) return;
    
    final element = removeAt(fromIndex);
    insert(toIndex, element);
  }

  /// Rotates the list by the specified number of positions.
  /// 
  /// Positive values rotate right, negative values rotate left.
  /// 
  /// Example:
  /// ```dart
  /// final list = [1, 2, 3, 4, 5];
  /// list.rotate(2); // [4, 5, 1, 2, 3]
  /// list.rotate(-2); // [3, 4, 5, 1, 2]
  /// ```
  List<V> rotate(int positions) {
    if (isEmpty) return copy();
    final normalizedPositions = positions % length;
    if (normalizedPositions == 0) return copy();
    
    return [
      ...sublist(length - normalizedPositions),
      ...sublist(0, length - normalizedPositions),
    ];
  }

  /// Splits the list into two lists at the specified index.
  /// 
  /// Example:
  /// ```dart
  /// final list = [1, 2, 3, 4, 5];
  /// final (left, right) = list.splitAt(3); // ([1, 2, 3], [4, 5])
  /// ```
  (List<V>, List<V>) splitAt(int index) {
    if (index < 0 || index > length) {
      throw RangeError('Index out of range');
    }
    return (sublist(0, index), sublist(index));
  }

  /// Returns the indices of all elements matching the predicate.
  /// 
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 2, 4, 2];
  /// final indices = numbers.indicesWhere((n) => n == 2); // [1, 3, 5]
  /// ```
  List<int> indicesWhere(bool Function(V element) test) {
    final indices = <int>[];
    for (var i = 0; i < length; i++) {
      if (test(this[i])) {
        indices.add(i);
      }
    }
    return indices;
  }

  /// Inserts an element if it doesn't already exist.
  /// 
  /// Returns true if the element was inserted.
  /// 
  /// Example:
  /// ```dart
  /// final set = [1, 2, 3];
  /// final inserted = set.insertUnique(4); // true, set is [1, 2, 3, 4]
  /// final notInserted = set.insertUnique(2); // false, set unchanged
  /// ```
  bool insertUnique(V element) {
    if (!contains(element)) {
      add(element);
      return true;
    }
    return false;
  }

  /// Binary search for a sorted list.
  /// 
  /// This method is now provided by dartx package.
  /// Use: list.binarySearch(element, compare: (a, b) => a.compareTo(b))
  /// 
  /// Returns the index of the element, or -1 if not found.
  /// The list must be sorted according to the comparator.
  /// 
  /// Example:
  /// ```dart
  /// final sorted = [1, 3, 5, 7, 9];
  /// final index = sorted.binarySearch(5, compare: (a, b) => a.compareTo(b)); // 2
  /// ```

  /// Inserts an element in a sorted list maintaining order.
  /// 
  /// Example:
  /// ```dart
  /// final sorted = [1, 3, 5, 7];
  /// sorted.insertSorted(4); // [1, 3, 4, 5, 7]
  /// ```
  void insertSorted(V element, [int Function(V a, V b)? compare]) {
    final comparator = compare ?? _defaultCompare<V>;
    var index = 0;
    
    while (index < length && comparator(this[index], element) < 0) {
      index++;
    }
    
    insert(index, element);
  }

  /// Pads the list to a minimum length with a value.
  /// 
  /// Example:
  /// ```dart
  /// final list = [1, 2, 3];
  /// final padded = list.padRight(5, 0); // [1, 2, 3, 0, 0]
  /// ```
  List<V> padRight(int minLength, V padding) {
    if (length >= minLength) return copy();
    return [...this, ...List.filled(minLength - length, padding)];
  }

  /// Pads the list at the beginning to a minimum length.
  /// 
  /// Example:
  /// ```dart
  /// final list = [1, 2, 3];
  /// final padded = list.padLeft(5, 0); // [0, 0, 1, 2, 3]
  /// ```
  List<V> padLeft(int minLength, V padding) {
    if (length >= minLength) return copy();
    return [...List.filled(minLength - length, padding), ...this];
  }

  /// Counts occurrences of elements.
  /// 
  /// Example:
  /// ```dart
  /// final items = ['a', 'b', 'a', 'c', 'b', 'a'];
  /// final counts = items.countBy(); // {'a': 3, 'b': 2, 'c': 1}
  /// ```
  Map<V, int> countBy() {
    final counts = <V, int>{};
    for (final element in this) {
      counts[element] = (counts[element] ?? 0) + 1;
    }
    return counts;
  }

  /// Finds the most common element(s).
  /// 
  /// Example:
  /// ```dart
  /// final items = ['a', 'b', 'a', 'c', 'b', 'a'];
  /// final mode = items.mode(); // ['a']
  /// ```
  List<V> mode() {
    if (isEmpty) return [];
    
    final counts = countBy();
    final maxCount = counts.values.reduce(math.max);
    
    return counts.entries
        .where((entry) => entry.value == maxCount)
        .map((entry) => entry.key)
        .toList();
  }

  static int _defaultCompare<T>(T a, T b) {
    if (a is Comparable) {
      return (a as Comparable).compareTo(b);
    }
    throw ArgumentError('Elements must be Comparable');
  }
}

extension FalconToolListNullableExtensions<V> on List<V>? {

  /// Maps each element to a future or value asynchronously.
  /// 
  /// Returns an empty list if the original list is null.
  /// 
  /// Example:
  /// ```dart
  /// final urls = ['url1', 'url2', 'url3'];
  /// final responses = await urls.futureAsyncMap((url) => fetchData(url));
  /// ```
  Future<List<T>> futureAsyncMap<T>(
      FutureOr<T> Function(V element) toElement) async {
    return this != null
        ? await Stream.fromIterable(this!)
            .asyncMap((event) => toElement(event))
            .toList()
        : [];
  }

  /// Returns the list or an empty list if null.
  List<V> get orEmpty => this ?? [];

  /// Safely gets an element at index, returning null if out of bounds or null.
  /// 
  /// For non-null lists, use dartx's elementAtOrNull(index) instead.
  V? getOrNull(int index) {
    if (this == null || index < 0 || index >= this!.length) return null;
    return this![index];
  }

  /// Executes an action if the list is not null and not empty.
  void ifNotEmpty(void Function(List<V> list) action) {
    if (this != null && this!.isNotEmpty) {
      action(this!);
    }
  }
}
