import 'dart:math' as math;
import 'package:faltool/lib.dart';

/// Extension methods for int type with null safety.
extension FalconToolIntExtensions on int {
  /// Converts the integer to a double.
  /// 
  /// This is just a wrapper for the built-in toDouble() method.
  /// Consider using toDouble() directly.
  double toDoubleValue() => toDouble();

  /// Checks if the integer is even.
  /// 
  /// This is just a wrapper for the built-in isEven property.
  /// Consider using isEven directly.
  bool get isEvenNumber => isEven;

  /// Checks if the integer is odd.
  /// 
  /// This is just a wrapper for the built-in isOdd property.
  /// Consider using isOdd directly.
  bool get isOddNumber => isOdd;

  /// Returns the absolute value.
  /// 
  /// This is just a wrapper for the built-in abs() method.
  /// Consider using abs() directly.
  int get absoluteValue => abs();

  /// Clamps the value between min and max.
  /// 
  /// This is just a wrapper for the built-in clamp() method.
  /// Consider using clamp() directly.
  /// 
  /// Example:
  /// ```dart
  /// 10.clamp(0, 5); // 5
  /// (-5).clamp(0, 10); // 0
  /// ```
  int clampValue(int min, int max) => clamp(min, max).toInt();

  /// Returns the value or the provided minimum if less than min.
  /// 
  /// Similar to dartx's coerceAtLeast method.
  /// 
  /// Example:
  /// ```dart
  /// 5.atLeast(10); // 10
  /// 15.atLeast(10); // 15
  /// ```
  int atLeast(int min) => math.max(this, min);

  /// Returns the value or the provided maximum if greater than max.
  /// 
  /// Similar to dartx's coerceAtMost method.
  /// 
  /// Example:
  /// ```dart
  /// 5.atMost(10); // 5
  /// 15.atMost(10); // 10
  /// ```
  int atMost(int max) => math.min(this, max);

  /// Checks if the integer is within the given range (inclusive).
  /// 
  /// Example:
  /// ```dart
  /// 5.inRange(1, 10); // true
  /// 15.inRange(1, 10); // false
  /// ```
  bool inRange(int min, int max) => this >= min && this <= max;

  /// Converts the integer to a Duration in various units.
  /// 
  /// These methods are now provided by dartx package.
  /// Use: number.microseconds, number.milliseconds, etc.
  Duration get microseconds => Duration(microseconds: this);
  Duration get milliseconds => Duration(milliseconds: this);
  Duration get seconds => Duration(seconds: this);
  Duration get minutes => Duration(minutes: this);
  Duration get hours => Duration(hours: this);
  Duration get days => Duration(days: this);

  /// Formats the integer with thousand separators.
  /// 
  /// Example:
  /// ```dart
  /// 1000000.formatted(); // '1,000,000'
  /// 1000000.formatted(separator: '.'); // '1.000.000'
  /// ```
  String formatted({String separator = ','}) {
    final isNegative = this < 0;
    final absValue = absoluteValue.toString();
    final buffer = StringBuffer();
    
    for (var i = 0; i < absValue.length; i++) {
      if (i > 0 && (absValue.length - i) % 3 == 0) {
        buffer.write(separator);
      }
      buffer.write(absValue[i]);
    }
    
    return isNegative ? '-$buffer' : buffer.toString();
  }

  /// Converts the integer to ordinal string.
  /// 
  /// This method is now provided by dartx package.
  /// Use: number.ordinal()
  /// 
  /// Example:
  /// ```dart
  /// 1.ordinal(); // '1st'
  /// 2.ordinal(); // '2nd'
  /// 3.ordinal(); // '3rd'
  /// 21.ordinal(); // '21st'
  /// ```

  /// Executes the given function [n] times.
  /// 
  /// This method is now provided by dartx package.
  /// Use: number.times((index) => action)
  /// 
  /// Example:
  /// ```dart
  /// 3.times((i) => print('Count: \${i}'));
  /// // Count: 0
  /// // Count: 1
  /// // Count: 2
  /// ```
  void times(void Function(int index) action) {
    for (var i = 0; i < this; i++) {
      action(i);
    }
  }

  /// Creates a list by executing the given function [n] times.
  /// 
  /// Example:
  /// ```dart
  /// 3.generate<int>((i) => i * 2); // [0, 2, 4]
  /// ```
  List<T> generate<T>(T Function(int index) generator) {
    return List.generate(this, generator);
  }
}

/// Extension methods for nullable int type.
extension FalconToolIntNullExtensions on int? {
  /// Converts to double or returns 0.0 if null.
  double toDoubleOrZero() => this?.toDouble() ?? 0.0;

  /// Converts to double or returns null if null.
  double? toDoubleOrNull() => this?.toDouble();

  /// Returns the value or the provided default if null.
  int orDefault(int defaultValue) => this ?? defaultValue;

  /// Returns the value or 0 if null.
  int get orZero => this ?? 0;

  /// Checks if the value is null or zero.
  bool get isNullOrZero => this == null || this == 0;

  /// Checks if the value is not null and not zero.
  bool get isNotNullOrZero => !isNullOrZero;

  /// Safely checks if the value is even.
  bool get isEvenOrFalse => this?.isEven ?? false;

  /// Safely checks if the value is odd.
  bool get isOddOrFalse => this?.isOdd ?? false;

  /// Safely checks if the value is positive (> 0).
  bool get isPositive => this != null && this! > 0;

  /// Safely checks if the value is negative (< 0).
  bool get isNegative => this != null && this! < 0;

  /// Safely formats the integer with thousand separators.
  String? formatted({String separator = ','}) => 
      this?.formatted(separator: separator);
}

/// Extension methods for double type.
extension FalconToolDoubleExtensions on double {
  /// Rounds to the specified number of decimal places.
  /// 
  /// Example:
  /// ```dart
  /// 3.14159.roundToPlaces(2); // 3.14
  /// 3.14159.roundToPlaces(4); // 3.1416
  /// ```
  double roundToPlaces(int places) {
    final mod = math.pow(10.0, places);
    return (this * mod).round().toDouble() / mod;
  }

  /// Converts to int by truncating decimals.
  int toIntValue() => toInt();

  /// Returns the absolute value.
  double get absoluteValue => abs();

  /// Clamps the value between min and max.
  double clampValue(double min, double max) => clamp(min, max).toDouble();

  /// Returns the value or the provided minimum if less than min.
  double atLeast(double min) => math.max(this, min);

  /// Returns the value or the provided maximum if greater than max.
  double atMost(double max) => math.min(this, max);

  /// Checks if the double is within the given range (inclusive).
  bool inRange(double min, double max) => this >= min && this <= max;

  /// Checks if the double represents a whole number.
  /// 
  /// Example:
  /// ```dart
  /// 3.0.isWhole; // true
  /// 3.14.isWhole; // false
  /// ```
  bool get isWhole => this == truncateToDouble();

  /// Formats the double with the specified number of decimal places.
  /// 
  /// Example:
  /// ```dart
  /// 3.14159.format(2); // '3.14'
  /// 1000.0.format(2); // '1000.00'
  /// ```
  String format(int decimalPlaces) {
    return toStringAsFixed(decimalPlaces);
  }

  /// Formats the double as a percentage.
  /// 
  /// Example:
  /// ```dart
  /// 0.1234.toPercentage(); // '12.34%'
  /// 0.1234.toPercentage(decimalPlaces: 1); // '12.3%'
  /// ```
  String toPercentage({int decimalPlaces = 2}) {
    return '${(this * 100).format(decimalPlaces)}%';
  }

  /// Converts radians to degrees.
  double get toDegrees => this * (180.0 / math.pi);

  /// Converts degrees to radians.
  double get toRadians => this * (math.pi / 180.0);

  /// Returns the fractional part of the double.
  /// 
  /// Example:
  /// ```dart
  /// 3.14.fractionalPart; // 0.14
  /// -3.14.fractionalPart; // -0.14
  /// ```
  double get fractionalPart => this - truncateToDouble();
}

/// Extension methods for nullable double type.
extension FalconToolDoubleNullExtensions on double? {
  /// Returns the value or 0.0 if null.
  double toDoubleOrZero() => this ?? 0.0;

  /// Returns the value or the provided default if null.
  double orDefault(double defaultValue) => this ?? defaultValue;

  /// Returns the value or 0.0 if null.
  double get orZero => this ?? 0.0;

  /// Checks if the value is null or zero.
  bool get isNullOrZero => this == null || this == 0.0;

  /// Checks if the value is not null and not zero.
  bool get isNotNullOrZero => !isNullOrZero;

  /// Safely rounds to the specified number of decimal places.
  double? roundToPlaces(int places) => this?.roundToPlaces(places);

  /// Safely formats the double.
  String? format(int decimalPlaces) => this?.format(decimalPlaces);

  /// Safely converts to percentage string.
  String? toPercentage({int decimalPlaces = 2}) =>
      this?.toPercentage(decimalPlaces: decimalPlaces);
}

/// Extension methods for num type.
extension FalconToolNumExtensions on num {
  /// Converts to double.
  double toDoubleValue() => toDouble();

  /// Converts to int.
  int toIntValue() => toInt();

  /// Returns the absolute value.
  num get absoluteValue => abs();

  /// Clamps the value between min and max.
  num clampValue(num min, num max) => clamp(min, max);

  /// Returns the value or the provided minimum if less than min.
  num atLeast(num min) => this < min ? min : this;

  /// Returns the value or the provided maximum if greater than max.
  num atMost(num max) => this > max ? max : this;

  /// Checks if the number is within the given range (inclusive).
  bool inRange(num min, num max) => this >= min && this <= max;

  /// Checks if the number is positive (> 0).
  bool get isPositive => this > 0;

  /// Checks if the number is negative (< 0).
  bool get isNegative => this < 0;

  /// Checks if the number is zero.
  bool get isZero => this == 0;

  /// Linearly interpolates between this number and another.
  /// 
  /// [t] should be between 0.0 and 1.0.
  /// 
  /// Example:
  /// ```dart
  /// 10.lerp(20, 0.5); // 15.0
  /// 0.lerp(100, 0.25); // 25.0
  /// ```
  double lerp(num other, double t) {
    return this + (other - this) * t;
  }

  /// Maps the number from one range to another.
  /// 
  /// Example:
  /// ```dart
  /// // Map 50 from range 0-100 to range 0-1
  /// 50.mapRange(0, 100, 0, 1); // 0.5
  /// ```
  double mapRange(num fromMin, num fromMax, num toMin, num toMax) {
    return (this - fromMin) * (toMax - toMin) / (fromMax - fromMin) + toMin;
  }
}

/// Extension methods for nullable num type.
extension FalconToolNumNullExtensions on num? {
  /// Converts to double or returns 0.0 if null.
  double toDoubleOrZero() => this?.toDouble() ?? 0.0;

  /// Converts to int or returns 0 if null.
  int toIntOrZero() => this?.toInt() ?? 0;

  /// Returns the value or the provided default if null.
  num orDefault(num defaultValue) => this ?? defaultValue;

  /// Returns the value or 0 if null.
  num get orZero => this ?? 0;

  /// Checks if the value is null or zero.
  bool get isNullOrZero => this == null || this == 0;

  /// Checks if the value is not null and not zero.
  bool get isNotNullOrZero => !isNullOrZero;

  /// Safely checks if the value is positive.
  bool get isPositive => this != null && this! > 0;

  /// Safely checks if the value is negative.
  bool get isNegative => this != null && this! < 0;
}
