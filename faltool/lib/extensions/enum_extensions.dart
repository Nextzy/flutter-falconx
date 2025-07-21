import 'package:faltool/lib.dart';

/// Extension methods for converting strings to enum values.
extension FalconToolEnumStringExtension on String {
  /// Converts the string to an enum value.
  /// 
  /// Searches through [enumValues] to find a matching enum value.
  /// If no match is found, returns [defaultValue] if provided,
  /// otherwise throws.
  /// 
  /// Example:
  /// ```dart
  /// enum Status { active, inactive, pending }
  /// 
  /// 'active'.toEnum(Status.values); // Status.active
  /// 'ACTIVE'.toEnum(Status.values); // Status.active (case insensitive by default)
  /// 'unknown'.toEnum(Status.values, defaultValue: Status.pending); // Status.pending
  /// ```
  T toEnum<T extends Enum>(
    List<T> enumValues, {
    T? defaultValue,
    bool caseSensitive = false,
  }) {
    try {
      if (caseSensitive) {
        return enumValues.firstWhere(
          (e) => e.toValueString() == this || e.toString() == this,
        );
      } else {
        final lowerThis = toLowerCase();
        return enumValues.firstWhere(
          (e) => 
              e.toValueString().toLowerCase() == lowerThis ||
              e.toString().toLowerCase() == lowerThis,
        );
      }
    } catch (_) {
      if (defaultValue != null) {
        return defaultValue;
      }
      throw ArgumentError(
        'No enum value found for "$this" in $T',
      );
    }
  }

  /// Converts the string to an enum value, returning null if not found.
  /// 
  /// Example:
  /// ```dart
  /// enum Status { active, inactive, pending }
  /// 
  /// 'active'.toEnumOrNull(Status.values); // Status.active
  /// 'unknown'.toEnumOrNull(Status.values); // null
  /// ```
  T? toEnumOrNull<T extends Enum>(
    List<T> enumValues, {
    bool caseSensitive = false,
  }) {
    if (caseSensitive) {
      return enumValues.firstOrNullWhere(
        (e) => e.toValueString() == this || e.toString() == this,
      );
    } else {
      final lowerThis = toLowerCase();
      return enumValues.firstOrNullWhere(
        (e) => 
            e.toValueString().toLowerCase() == lowerThis ||
            e.toString().toLowerCase() == lowerThis,
      );
    }
  }

  /// Checks if the string matches any enum value.
  /// 
  /// Example:
  /// ```dart
  /// enum Status { active, inactive }
  /// 
  /// 'active'.isValidEnum(Status.values); // true
  /// 'unknown'.isValidEnum(Status.values); // false
  /// ```
  bool isValidEnum<T extends Enum>(
    List<T> enumValues, {
    bool caseSensitive = false,
  }) {
    return toEnumOrNull(enumValues, caseSensitive: caseSensitive) != null;
  }
}

/// Extension methods for Enum types.
extension FalconEnumExtension on Enum {
  /// Converts the enum to its string value (without the enum name prefix).
  /// 
  /// Example:
  /// ```dart
  /// enum Status { active, inactive }
  /// 
  /// Status.active.toValueString(); // 'active'
  /// Status.inactive.toValueString(); // 'inactive'
  /// ```
  String toValueString() => EnumToString.convertToString(this);

  /// Converts the enum to a formatted string with custom casing.
  /// 
  /// Example:
  /// ```dart
  /// enum Status { activeUser, inactiveUser }
  /// 
  /// Status.activeUser.toFormattedString(); // 'Active User'
  /// Status.activeUser.toFormattedString(separator: '-'); // 'active-user'
  /// ```
  String toFormattedString({
    String separator = ' ',
    bool capitalize = true,
  }) {
    final value = toValueString();
    final words = value.split(RegExp('(?=[A-Z])|_'));
    
    if (capitalize) {
      return words
          .map((word) => word.isNotEmpty 
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '')
          .join(separator);
    } else {
      return words.map((word) => word.toLowerCase()).join(separator);
    }
  }

  /// Gets the enum index.
  /// 
  /// Example:
  /// ```dart
  /// enum Priority { low, medium, high }
  /// 
  /// Priority.low.enumIndex; // 0
  /// Priority.high.enumIndex; // 2
  /// ```
  int get enumIndex => index;

  /// Checks if this enum value equals another, with null safety.
  /// 
  /// Example:
  /// ```dart
  /// enum Status { active, inactive }
  /// 
  /// Status? status = Status.active;
  /// status.isEqual(Status.active); // true
  /// status.isEqual(Status.inactive); // false
  /// ```
  bool isEqual(Enum? other) => this == other;

  /// Checks if this enum value is in a list of values.
  /// 
  /// Example:
  /// ```dart
  /// enum Status { active, inactive, pending }
  /// 
  /// Status.active.isIn([Status.active, Status.pending]); // true
  /// Status.inactive.isIn([Status.active, Status.pending]); // false
  /// ```
  bool isIn(List<Enum> values) => values.contains(this);

  /// Checks if this enum value is not in a list of values.
  bool isNotIn(List<Enum> values) => !isIn(values);
}

/// Extension methods for lists of enum values.
extension FalconEnumListExtension<T extends Enum> on List<T> {
  /// Converts all enum values to their string representations.
  /// 
  /// Example:
  /// ```dart
  /// enum Status { active, inactive }
  /// 
  /// Status.values.toValueStrings(); // ['active', 'inactive']
  /// ```
  List<String> toValueStrings() => map((e) => e.toValueString()).toList();

  /// Finds an enum by its string value.
  /// 
  /// Example:
  /// ```dart
  /// enum Status { active, inactive }
  /// 
  /// Status.values.byValue('active'); // Status.active
  /// Status.values.byValue('unknown'); // throws ArgumentError
  /// ```
  T byValue(String value, {bool caseSensitive = false}) {
    return value.toEnum(this, caseSensitive: caseSensitive);
  }

  /// Finds an enum by its string value, returning null if not found.
  T? byValueOrNull(String value, {bool caseSensitive = false}) {
    return value.toEnumOrNull(this, caseSensitive: caseSensitive);
  }

  /// Gets a map of enum values to their string representations.
  /// 
  /// Example:
  /// ```dart
  /// enum Status { active, inactive }
  /// 
  /// Status.values.toMap(); // {Status.active: 'active', Status.inactive: 'inactive'}
  /// ```
  Map<T, String> toMap() {
    return Map.fromEntries(
      map((e) => MapEntry(e, e.toValueString())),
    );
  }

  /// Gets a map of string representations to enum values.
  /// 
  /// Example:
  /// ```dart
  /// enum Status { active, inactive }
  /// 
  /// Status.values.toReverseMap(); // {'active': Status.active, 'inactive': Status.inactive}
  /// ```
  Map<String, T> toReverseMap() {
    return Map.fromEntries(
      map((e) => MapEntry(e.toValueString(), e)),
    );
  }

  /// Filters enum values by a predicate on their string representation.
  /// 
  /// Example:
  /// ```dart
  /// enum Status { active, inactive, archived }
  /// 
  /// Status.values.whereValue((v) => v.startsWith('a')); // [Status.active, Status.archived]
  /// ```
  List<T> whereValue(bool Function(String value) test) {
    return where((e) => test(e.toValueString())).toList();
  }
}

/// Extension methods for nullable enum values.
extension FalconEnumNullExtension<T extends Enum> on T? {
  /// Converts the enum to its string value, returning null if the enum is null.
  String? toValueStringOrNull() => this?.toValueString();

  /// Converts the enum to its string value, returning a default if null.
  String toValueStringOr(String defaultValue) => 
      this?.toValueString() ?? defaultValue;

  /// Checks if the nullable enum equals a value.
  bool isEqual(T value) => this == value;

  /// Checks if the nullable enum is in a list of values.
  bool isIn(List<T> values) => this != null && values.contains(this);

  /// Checks if the nullable enum is not in a list of values.
  bool isNotIn(List<T> values) => !isIn(values);

  /// Returns the enum value or a default if null.
  T orDefault(T defaultValue) => this ?? defaultValue;
}
