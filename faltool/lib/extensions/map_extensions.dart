import 'package:faltool/lib.dart';

/// Extension methods for Map type with enhanced functionality.
///
/// Provides comprehensive utilities for map operations including
/// safe transformations, filtering, merging, and advanced operations.
extension FalconToolMapExtension<K, V> on Map<K, V> {
  /// Returns a new map with null values and empty strings removed.
  ///
  /// Recursively removes nulls and empty strings from nested collections.
  ///
  /// Example:
  /// ```dart
  /// final data = {
  ///   'name': 'John',
  ///   'age': null,
  ///   'email': '',
  ///   'address': {'street': '', 'city': 'NYC'},
  /// };
  /// final cleaned = data.removeNullOrEmptyString();
  /// // {'name': 'John', 'address': {'city': 'NYC'}}
  /// ```
  Map<K, V> removeNullOrEmptyString() => Map<K, V>.fromEntries(
        entries
            .where((entry) =>
                !_isNullOrEmptyString(entry.key) &&
                !_isNullOrEmptyString(entry.value))
            .map((entry) => MapEntry(
                  entry.key,
                  _removeNullsDeep(entry.value),
                )),
      );

  /// Gets a value by key with a default if not found.
  ///
  /// Example:
  /// ```dart
  /// final config = {'timeout': 30, 'retries': 3};
  /// final maxRetries = config.getOrDefault('maxRetries', 5); // 5
  /// ```
  V getOrDefault(K key, V defaultValue) {
    return this[key] ?? defaultValue;
  }

  /// Gets a value by key, calling a function to provide default if not found.
  ///
  /// This method is now provided by dartx package.
  /// Use: map.getOrElse(key, defaultProvider)
  ///
  /// Example:
  /// ```dart
  /// final cache = {'user1': User('Alice')};
  /// final user = cache.getOrElse('user2', () => fetchUser('user2'));
  /// ```

  /// Maps keys while preserving values.
  ///
  /// This method is now provided by dartx package.
  /// Use: map.mapKeys((key, value) => newKey)
  ///
  /// Example:
  /// ```dart
  /// final scores = {'alice': 95, 'bob': 87};
  /// final upperScores = scores.mapKeys((k, v) => k.toUpperCase());
  /// // {'ALICE': 95, 'BOB': 87}
  /// ```

  /// Maps values while preserving keys.
  ///
  /// This method is now provided by dartx package.
  /// Use: map.mapValues((key, value) => newValue)
  ///
  /// Example:
  /// ```dart
  /// final prices = {'apple': 1.5, 'banana': 0.8};
  /// final doubled = prices.mapValues((k, v) => v * 2);
  /// // {'apple': 3.0, 'banana': 1.6}
  /// ```

  /// Filters entries based on a predicate.
  ///
  /// Similar to dartx's filter method but with different name.
  ///
  /// Example:
  /// ```dart
  /// final scores = {'alice': 95, 'bob': 87, 'charlie': 92};
  /// final highScores = scores.where((k, v) => v >= 90);
  /// // {'alice': 95, 'charlie': 92}
  /// ```
  Map<K, V> where(bool Function(K key, V value) test) {
    return Map.fromEntries(
      entries.where((entry) => test(entry.key, entry.value)),
    );
  }

  /// Filters entries based on key predicate.
  ///
  /// This method is similar to dartx's filterKeys method.
  /// Use: map.filterKeys((key) => condition)
  ///
  /// Example:
  /// ```dart
  /// final data = {'name': 'John', '_id': '123', '_temp': 'value'};
  /// final public = data.filterKeys((k) => !k.startsWith('_'));
  /// // {'name': 'John'}
  /// ```

  /// Filters entries based on value predicate.
  ///
  /// This method is similar to dartx's filterValues method.
  /// Use: map.filterValues((value) => condition)
  ///
  /// Example:
  /// ```dart
  /// final inventory = {'apples': 10, 'bananas': 0, 'oranges': 5};
  /// final inStock = inventory.filterValues((v) => v > 0);
  /// // {'apples': 10, 'oranges': 5}
  /// ```

  /// Merges another map into this one, with custom conflict resolution.
  ///
  /// Example:
  /// ```dart
  /// final defaults = {'timeout': 30, 'retries': 3};
  /// final custom = {'timeout': 60, 'debug': true};
  /// final config = defaults.merge(custom, (a, b) => b);
  /// // {'timeout': 60, 'retries': 3, 'debug': true}
  /// ```
  Map<K, V> merge(
    Map<K, V> other,
    V Function(V currentValue, V newValue)? resolve,
  ) {
    final result = Map<K, V>.from(this);
    other.forEach((key, value) {
      if (result.containsKey(key) && resolve != null) {
        result[key] = resolve(result[key] as V, value);
      } else {
        result[key] = value;
      }
    });
    return result;
  }

  /// Inverts the map, swapping keys and values.
  ///
  /// Note: If multiple keys have the same value, only the last one is kept.
  ///
  /// Example:
  /// ```dart
  /// final codes = {'US': 'United States', 'UK': 'United Kingdom'};
  /// final countries = codes.invert();
  /// // {'United States': 'US', 'United Kingdom': 'UK'}
  /// ```
  Map<V, K> invert() {
    return Map.fromEntries(
      entries.map((entry) => MapEntry(entry.value, entry.key)),
    );
  }

  /// Groups values by their keys using a key extractor.
  ///
  /// Example:
  /// ```dart
  /// final data = {'a1': 10, 'a2': 20, 'b1': 30, 'b2': 40};
  /// final grouped = data.groupByKey((k, v) => k[0]);
  /// // {'a': [10, 20], 'b': [30, 40]}
  /// ```
  Map<K2, List<V>> groupByKey<K2>(K2 Function(K key, V value) keyExtractor) {
    final result = <K2, List<V>>{};
    forEach((key, value) {
      final newKey = keyExtractor(key, value);
      (result[newKey] ??= []).add(value);
    });
    return result;
  }

  /// Returns a sorted map by keys.
  ///
  /// Example:
  /// ```dart
  /// final scores = {'charlie': 92, 'alice': 95, 'bob': 87};
  /// final sorted = scores.sortByKey();
  /// // {'alice': 95, 'bob': 87, 'charlie': 92}
  /// ```
  Map<K, V> sortByKey([int Function(K a, K b)? compare]) {
    final sortedKeys = keys.toList()..sort(compare);
    return Map.fromEntries(
      sortedKeys.map((key) => MapEntry(key, this[key] as V)),
    );
  }

  /// Returns a sorted map by values.
  ///
  /// Example:
  /// ```dart
  /// final scores = {'alice': 95, 'bob': 87, 'charlie': 92};
  /// final sorted = scores.sortByValue();
  /// // {'bob': 87, 'charlie': 92, 'alice': 95}
  /// ```
  Map<K, V> sortByValue([int Function(V a, V b)? compare]) {
    final sortedEntries = entries.toList()
      ..sort((a, b) {
        if (compare != null) {
          return compare(a.value, b.value);
        }
        if (a.value is Comparable) {
          return (a.value as Comparable).compareTo(b.value);
        }
        throw ArgumentError('Values must be Comparable');
      });
    return Map.fromEntries(sortedEntries);
  }

  /// Picks specific keys from the map.
  ///
  /// Example:
  /// ```dart
  /// final user = {
  ///   'id': 1,
  ///   'name': 'John',
  ///   'email': 'john@example.com',
  ///   'age': 30,
  /// };
  /// final publicInfo = user.pick(['name', 'email']);
  /// // {'name': 'John', 'email': 'john@example.com'}
  /// ```
  Map<K, V> pick(Iterable<K> keys) {
    return Map.fromEntries(
      entries.where((entry) => keys.contains(entry.key)),
    );
  }

  /// Omits specific keys from the map.
  ///
  /// Example:
  /// ```dart
  /// final user = {'id': 1, 'name': 'John', 'password': 'secret'};
  /// final safe = user.omit(['password']);
  /// // {'id': 1, 'name': 'John'}
  /// ```
  Map<K, V> omit(Iterable<K> keys) {
    return Map.fromEntries(
      entries.where((entry) => !keys.contains(entry.key)),
    );
  }

  /// Transforms the map into a list using a transformer function.
  ///
  /// This method is now provided by dartx package.
  /// Use: map.toList() for list of entries
  ///
  /// Example:
  /// ```dart
  /// final scores = {'alice': 95, 'bob': 87};
  /// final results = scores.entries
  ///     .map((e) => '${e.key} scored ${e.value}')
  ///     .toList();
  /// // ['alice scored 95', 'bob scored 87']
  /// ```

  /// Checks if any entry satisfies the predicate.
  ///
  /// This method is now provided by dartx package.
  /// Use: map.any((key, value) => condition)
  ///
  /// Example:
  /// ```dart
  /// final scores = {'alice': 95, 'bob': 87};
  /// final hasHighScore = scores.any((k, v) => v > 90); // true
  /// ```

  /// Checks if every entry satisfies the predicate.
  ///
  /// This method is similar to dartx's all method.
  /// Use: map.all((key, value) => condition)
  ///
  /// Example:
  /// ```dart
  /// final scores = {'alice': 95, 'bob': 87};
  /// final allPassed = scores.all((k, v) => v >= 80); // true
  /// ```

  /// Creates a nested path in the map and sets a value.
  ///
  /// Example:
  /// ```dart
  /// final config = <String, dynamic>{};
  /// config.setPath(['database', 'host'], 'localhost');
  /// // {'database': {'host': 'localhost'}}
  /// ```
  void setPath(List<K> path, V value) {
    if (path.isEmpty) return;

    Map<dynamic, dynamic> current = this;
    for (var i = 0; i < path.length - 1; i++) {
      final key = path[i];
      if (current[key] == null || current[key] is! Map) {
        current[key] = <K, dynamic>{};
      }
      current = current[key] as Map<dynamic, dynamic>;
    }
    current[path.last] = value;
  }

  /// Gets a value from a nested path in the map.
  ///
  /// Example:
  /// ```dart
  /// final config = {'database': {'host': 'localhost', 'port': 5432}};
  /// final host = config.getPath(['database', 'host']); // 'localhost'
  /// ```
  T? getPath<T>(List<K> path) {
    dynamic current = this;
    for (final key in path) {
      if (current is Map && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }
    return current as T?;
  }
}

/// Extension methods for nullable Map type.
extension FalconToolNullableMapExtension<K, V> on Map<K, V>? {
  /// Returns true if the map is null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Returns true if the map is not null and not empty.
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// Returns the map or an empty map if null.
  Map<K, V> get orEmpty => this ?? {};

  /// Executes an action if the map is not null and not empty.
  void ifNotEmpty(void Function(Map<K, V> map) action) {
    if (this != null && this!.isNotEmpty) {
      action(this!);
    }
  }
}

/// Checks if a value is null or an empty string
bool _isNullOrEmptyString(dynamic value) {
  if (value == null) return true;
  if (value is String) return value.isEmpty;
  return false;
}

/// Recursively removes nulls and empty strings from collections
T _removeNullsDeep<T>(T value) {
  if (value is List) {
    return removeNullsFromList(value) as T;
  } else if (value is Map) {
    return removeNullsFromMap(value) as T;
  }
  return value;
}

/// Removes nulls and empty strings from a list
List<T> removeNullsFromList<T>(List<T> list) {
  if (list.isEmpty) return <T>[];

  return list
      .where((item) => !_isNullOrEmptyString(item))
      .map(_removeNullsDeep)
      .toList();
}

/// Removes nulls and empty strings from a map
Map<K, V> removeNullsFromMap<K, V>(Map<K, V> map) {
  if (map.isEmpty) return <K, V>{};

  return Map<K, V>.fromEntries(
    map.entries
        .where((entry) =>
            !_isNullOrEmptyString(entry.key) &&
            !_isNullOrEmptyString(entry.value))
        .map((entry) => MapEntry(
              entry.key,
              _removeNullsDeep(entry.value),
            )),
  );
}

/// Public API for removing nulls and empty strings from any data structure
T removeNullsAndEmptyStrings<T>(T data) => _removeNullsDeep(data);
