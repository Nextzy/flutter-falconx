import 'package:faltool/lib.dart';

/// Extension methods for dynamic type handling and safe conversions.
/// 
/// Provides type-safe conversions and utilities for working with dynamic
/// values, particularly useful when dealing with JSON parsing and external
/// data.
extension FalconToolDynamicExtensions on dynamic {
  /// Safely casts the dynamic value to type T.
  /// 
  /// Returns null if the cast fails or the value is null.
  /// 
  /// Example:
  /// ```dart
  /// dynamic value = '123';
  /// String? str = value.as<String>(); // '123'
  /// int? num = value.as<int>(); // null
  /// ```
  T? as<T>() {
    if (this == null) return null;
    if (this is T) return this as T;
    return null;
  }

  /// Safely casts the dynamic value to type T with a default value.
  /// 
  /// Returns the default value if the cast fails or the value is null.
  /// 
  /// Example:
  /// ```dart
  /// dynamic value = null;
  /// String str = value.asOr<String>('default'); // 'default'
  /// ```
  T asOr<T>(T defaultValue) => as<T>() ?? defaultValue;

  /// Checks if the dynamic value is of type T.
  /// 
  /// Example:
  /// ```dart
  /// dynamic value = 'hello';
  /// value.isType<String>(); // true
  /// value.isType<int>(); // false
  /// ```
  bool isType<T>() => this is T;

  /// Safely converts to String.
  /// 
  /// Returns null if the value is null.
  /// 
  /// Example:
  /// ```dart
  /// dynamic value = 123;
  /// value.asString(); // '123'
  /// ```
  String? asString() => this?.toString();

  /// Safely converts to String with a default value.
  /// 
  /// Example:
  /// ```dart
  /// dynamic value = null;
  /// value.asStringOr('default'); // 'default'
  /// ```
  String asStringOr(String defaultValue) => asString() ?? defaultValue;

  /// Safely converts to int.
  /// 
  /// Handles various input types:
  /// - int: returns as-is
  /// - double: truncates to int
  /// - String: parses to int
  /// - bool: returns 1 for true, 0 for false
  /// 
  /// Example:
  /// ```dart
  /// dynamic value = '123';
  /// value.asInt(); // 123
  /// 
  /// dynamic value2 = 123.45;
  /// value2.asInt(); // 123
  /// ```
  int? asInt() {
    if (this == null) return null;
    if (this is int) return this as int;
    if (this is double) return (this as double).toInt();
    if (this is String) return int.tryParse(this as String);
    if (this is bool) return (this as bool) ? 1 : 0;
    return null;
  }

  /// Safely converts to int with a default value.
  int asIntOr(int defaultValue) => asInt() ?? defaultValue;

  /// Safely converts to double.
  /// 
  /// Handles various input types:
  /// - double: returns as-is
  /// - int: converts to double
  /// - String: parses to double
  /// - bool: returns 1.0 for true, 0.0 for false
  /// 
  /// Example:
  /// ```dart
  /// dynamic value = '123.45';
  /// value.asDouble(); // 123.45
  /// ```
  double? asDouble() {
    if (this == null) return null;
    if (this is double) return this as double;
    if (this is int) return (this as int).toDouble();
    if (this is String) return double.tryParse(this as String);
    if (this is bool) return (this as bool) ? 1.0 : 0.0;
    return null;
  }

  /// Safely converts to double with a default value.
  double asDoubleOr(double defaultValue) => asDouble() ?? defaultValue;

  /// Safely converts to bool.
  /// 
  /// Handles various input types:
  /// - bool: returns as-is
  /// - int: returns true if non-zero
  /// - double: returns true if non-zero
  /// - String: returns true for 'true', '1', 'yes', 'on' (case-insensitive)
  /// 
  /// Example:
  /// ```dart
  /// dynamic value = 'true';
  /// value.asBool(); // true
  /// 
  /// dynamic value2 = 1;
  /// value2.asBool(); // true
  /// ```
  bool? asBool() {
    if (this == null) return null;
    if (this is bool) return this as bool;
    if (this is int) return (this as int) != 0;
    if (this is double) return (this as double) != 0.0;
    if (this is String) {
      final str = (this as String).toLowerCase();
      if (str == 'true' || str == '1' || str == 'yes' || str == 'on') {
        return true;
      }
      if (str == 'false' || str == '0' || str == 'no' || str == 'off') {
        return false;
      }
    }
    return null;
  }

  /// Safely converts to bool with a default value.
  bool asBoolOr(bool defaultValue) => asBool() ?? defaultValue;

  /// Safely converts to List of type T.
  /// 
  /// Returns null if the value is not a List or if any element
  /// cannot be cast to type T.
  /// 
  /// Example:
  /// ```dart
  /// dynamic value = [1, 2, 3];
  /// value.asList<int>(); // [1, 2, 3]
  /// ```
  List<T>? asList<T>() {
    if (this == null) return null;
    if (this is List) {
      try {
        return (this as List).cast<T>();
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Safely converts to List of type T with a default value.
  List<T> asListOr<T>(List<T> defaultValue) => asList<T>() ?? defaultValue;

  /// Safely converts to Map with key type K and value type V.
  /// 
  /// Returns null if the value is not a Map or if any key/value
  /// cannot be cast to types K/V.
  /// 
  /// Example:
  /// ```dart
  /// dynamic value = {'key': 'value'};
  /// value.asMap<String, String>(); // {'key': 'value'}
  /// ```
  Map<K, V>? asMap<K, V>() {
    if (this == null) return null;
    if (this is Map) {
      try {
        return (this as Map).cast<K, V>();
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Safely converts to Map with key type K and value type V with a
  /// default value.
  Map<K, V> asMapOr<K, V>(Map<K, V> defaultValue) =>
      asMap<K, V>() ?? defaultValue;

  /// Safely converts to DateTime.
  /// 
  /// Handles various input types:
  /// - DateTime: returns as-is
  /// - int: interprets as milliseconds since epoch
  /// - String: parses ISO 8601 format
  /// 
  /// Example:
  /// ```dart
  /// dynamic value = '2023-01-01T00:00:00Z';
  /// value.asDateTime(); // DateTime(2023, 1, 1)
  /// ```
  DateTime? asDateTime() {
    if (this == null) return null;
    if (this is DateTime) return this as DateTime;
    if (this is int) {
      return DateTime.fromMillisecondsSinceEpoch(this as int);
    }
    if (this is String) {
      return DateTime.tryParse(this as String);
    }
    return null;
  }

  /// Safely converts to DateTime with a default value.
  DateTime asDateTimeOr(DateTime defaultValue) =>
      asDateTime() ?? defaultValue;

  /// Checks if the dynamic value is null or empty.
  /// 
  /// Returns true for:
  /// - null values
  /// - empty strings
  /// - empty collections (List, Map, Set)
  /// - zero numbers (int, double)
  /// 
  /// Example:
  /// ```dart
  /// dynamic value = '';
  /// value.isNullOrEmpty; // true
  /// 
  /// dynamic value2 = [];
  /// value2.isNullOrEmpty; // true
  /// ```
  bool get isNullOrEmpty {
    if (this == null) return true;
    if (this is String) return (this as String).isEmpty;
    if (this is List) return (this as List).isEmpty;
    if (this is Map) return (this as Map).isEmpty;
    if (this is Set) return (this as Set).isEmpty;
    if (this is int) return (this as int) == 0;
    if (this is double) return (this as double) == 0.0;
    return false;
  }

  /// Checks if the dynamic value is not null and not empty.
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// Safely encodes the value to JSON string.
  /// 
  /// Returns null if encoding fails.
  /// 
  /// Example:
  /// ```dart
  /// dynamic value = {'key': 'value'};
  /// value.toJsonString(); // '{"key":"value"}'
  /// ```
  String? toJsonString() {
    if (this == null) return null;
    try {
      return json.encode(this);
    } catch (_) {
      return null;
    }
  }

  /// Safely encodes the value to pretty-printed JSON string.
  /// 
  /// Returns null if encoding fails.
  /// 
  /// Example:
  /// ```dart
  /// dynamic value = {'key': 'value', 'list': [1, 2]};
  /// value.toPrettyJsonString();
  /// // {
  /// //   "key": "value",
  /// //   "list": [1, 2]
  /// // }
  /// ```
  String? toPrettyJsonString() {
    if (this == null) return null;
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(this);
    } catch (_) {
      return null;
    }
  }

  /// Safely gets a nested value from a Map using a dot-notation path.
  /// 
  /// Example:
  /// ```dart
  /// dynamic value = {
  ///   'user': {
  ///     'profile': {
  ///       'name': 'John'
  ///     }
  ///   }
  /// };
  /// value.getPath('user.profile.name'); // 'John'
  /// ```
  dynamic getPath(String path) {
    if (this == null || this is! Map) return null;
    
    final keys = path.split('.');
    dynamic current = this;
    
    for (final key in keys) {
      if (current is Map && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }
    
    return current;
  }

  /// Safely gets a nested value with type casting.
  /// 
  /// Example:
  /// ```dart
  /// dynamic value = {'user': {'age': 25}};
  /// value.getPathAs<int>('user.age'); // 25
  /// ```
  T? getPathAs<T>(String path) {
    final value = getPath(path);
    if (value == null) return null;
    if (value is T) return value;
    return null;
  }

  /// Applies a transformation function if the value is not null.
  /// 
  /// Example:
  /// ```dart
  /// dynamic value = 'hello';
  /// value.map((v) => v.toUpperCase()); // 'HELLO'
  /// 
  /// dynamic nullValue = null;
  /// nullValue.map((v) => v.toString()); // null
  /// ```
  T? map<T>(T Function(dynamic value) transform) {
    if (this == null) return null;
    return transform(this);
  }

  /// Applies a transformation function with a default value for null.
  /// 
  /// Example:
  /// ```dart
  /// dynamic value = null;
  /// value.mapOr((v) => v.toString(), 'default'); // 'default'
  /// ```
  T mapOr<T>(T Function(dynamic value) transform, T defaultValue) {
    return map(transform) ?? defaultValue;
  }
}
