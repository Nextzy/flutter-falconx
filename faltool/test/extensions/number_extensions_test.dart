import 'package:faltool/lib.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FalconToolIntExtensions', () {
    test('toDouble converts int to double', () {
      expect(5.toDouble(), 5.0);
      expect((-10).toDouble(), -10.0);
      expect(0.toDouble(), 0.0);
    });

    test('isEvenNumber and isOddNumber work correctly', () {
      expect(4.isEven, true);
      expect(4.isOdd, false);
      expect(5.isEven, false);
      expect(5.isOdd, true);
      expect(0.isEven, true);
      expect(0.isOdd, false);
    });

    test('absolute returns absolute value', () {
      expect(5.absolute, 5);
      expect((-5).absolute, 5);
      expect(0.absolute, 0);
    });

    test('clampValue clamps value between min and max', () {
      expect(10.clampValue(0, 5), 5);
      expect((-5).clampValue(0, 10), 0);
      expect(5.clampValue(0, 10), 5);
    });

    test('atLeast returns maximum of value and min', () {
      expect(5.atLeast(10), 10);
      expect(15.atLeast(10), 15);
      expect((-5).atLeast(0), 0);
    });

    test('atMost returns minimum of value and max', () {
      expect(5.atMost(10), 5);
      expect(15.atMost(10), 10);
      expect((-5).atMost(0), -5);
    });

    test('inRange checks if value is within range', () {
      expect(5.inRange(1, 10), true);
      expect(1.inRange(1, 10), true); // Inclusive
      expect(10.inRange(1, 10), true); // Inclusive
      expect(15.inRange(1, 10), false);
      expect(0.inRange(1, 10), false);
    });

    test('duration conversions work correctly', () {
      expect(5.microseconds, const Duration(microseconds: 5));
      expect(10.milliseconds, const Duration(milliseconds: 10));
      expect(30.seconds, const Duration(seconds: 30));
      expect(2.minutes, const Duration(minutes: 2));
      expect(3.hours, const Duration(hours: 3));
      expect(7.days, const Duration(days: 7));
    });

    test('times executes function n times', () {
      // Using dartx's times method
      final results = <int>[];
      3.times((i) => results.add(i));
      expect(results, [0, 1, 2]);
      
      int count = 0;
      5.times((_) => count++);
      expect(count, 5);
      
      // Edge case: 0 times
      final zeroResults = <int>[];
      0.times((i) => zeroResults.add(i));
      expect(zeroResults, isEmpty);
    });

    test('generate creates list with generator function', () {
      expect(3.generate<int>((i) => i * 2), [0, 2, 4]);
      expect(4.generate<String>((i) => 'item$i'), ['item0', 'item1', 'item2', 'item3']);
      expect(0.generate<int>((i) => i), isEmpty);
    });
  });

  group('FalconToolIntNullExtensions', () {
    test('toDoubleOrZero converts to double or returns 0.0', () {
      int? nullInt;
      int? validInt = 5;
      
      expect(nullInt.toDoubleOrZero(), 0.0);
      expect(validInt.toDoubleOrZero(), 5.0);
    });

    test('toDoubleOrNull converts to double or returns null', () {
      int? nullInt;
      int? validInt = 5;
      
      expect(nullInt.toDoubleOrNull(), null);
      expect(validInt.toDoubleOrNull(), 5.0);
    });

    test('orDefault returns value or default', () {
      int? nullInt;
      int? validInt = 5;
      
      expect(nullInt.orDefault(10), 10);
      expect(validInt.orDefault(10), 5);
    });

    test('orZero returns value or 0', () {
      int? nullInt;
      int? validInt = 5;
      int? zeroInt = 0;
      
      expect(nullInt.orZero, 0);
      expect(validInt.orZero, 5);
      expect(zeroInt.orZero, 0);
    });

    test('isNullOrZero checks for null or zero', () {
      int? nullInt;
      int? zeroInt = 0;
      int? validInt = 5;
      
      expect(nullInt.isNullOrZero, true);
      expect(zeroInt.isNullOrZero, true);
      expect(validInt.isNullOrZero, false);
    });

    test('isNotNullOrZero is opposite of isNullOrZero', () {
      int? nullInt;
      int? zeroInt = 0;
      int? validInt = 5;
      
      expect(nullInt.isNotNullOrZero, false);
      expect(zeroInt.isNotNullOrZero, false);
      expect(validInt.isNotNullOrZero, true);
    });

    test('isEvenOrFalse and isOddOrFalse handle null safely', () {
      int? nullInt;
      int? evenInt = 4;
      int? oddInt = 5;
      
      expect(nullInt.isEvenOrFalse, false);
      expect(nullInt.isOddOrFalse, false);
      expect(evenInt.isEvenOrFalse, true);
      expect(evenInt.isOddOrFalse, false);
      expect(oddInt.isEvenOrFalse, false);
      expect(oddInt.isOddOrFalse, true);
    });

    test('isPositive and isNegative handle null safely', () {
      int? nullInt;
      int? positiveInt = 5;
      int? negativeInt = -5;
      int? zeroInt = 0;
      
      expect(nullInt.isPositive, false);
      expect(nullInt.isNegative, false);
      expect(positiveInt.isPositive, true);
      expect(positiveInt.isNegative, false);
      expect(negativeInt.isPositive, false);
      expect(negativeInt.isNegative, true);
      expect(zeroInt.isPositive, false);
      expect(zeroInt.isNegative, false);
    });
  });

  group('FalconToolDoubleExtensions', () {
    test('roundToPlaces rounds to specified decimal places', () {
      expect(3.14159.roundToPlaces(2), 3.14);
      expect(3.14159.roundToPlaces(4), 3.1416);
      expect(3.14159.roundToPlaces(0), 3.0);
      expect(3.9999.roundToPlaces(2), 4.0);
      expect((-3.14159).roundToPlaces(2), -3.14);
    });

    test('toInt converts to int', () {
      expect(3.14.toInt(), 3);
      expect(3.99.toInt(), 3);
      expect((-3.14).toInt(), -3);
      expect(0.0.toInt(), 0);
    });

    test('absolute returns absolute value', () {
      expect(3.14.absolute, 3.14);
      expect((-3.14).absolute, 3.14);
      expect(0.0.absolute, 0.0);
    });

    test('clampValue clamps value between min and max', () {
      expect(10.5.clampValue(0.0, 5.0), 5.0);
      expect((-5.5).clampValue(0.0, 10.0), 0.0);
      expect(5.5.clampValue(0.0, 10.0), 5.5);
    });

    test('atLeast returns maximum of value and min', () {
      expect(5.5.atLeast(10.0), 10.0);
      expect(15.5.atLeast(10.0), 15.5);
      expect((-5.5).atLeast(0.0), 0.0);
    });

    test('atMost returns minimum of value and max', () {
      expect(5.5.atMost(10.0), 5.5);
      expect(15.5.atMost(10.0), 10.0);
      expect((-5.5).atMost(0.0), -5.5);
    });

    test('inRange checks if value is within range', () {
      expect(5.5.inRange(1.0, 10.0), true);
      expect(1.0.inRange(1.0, 10.0), true); // Inclusive
      expect(10.0.inRange(1.0, 10.0), true); // Inclusive
      expect(15.5.inRange(1.0, 10.0), false);
      expect(0.5.inRange(1.0, 10.0), false);
    });

    test('isWhole checks if double is whole number', () {
      expect(3.0.isWhole, true);
      expect(3.14.isWhole, false);
      expect((-5.0).isWhole, true);
      expect(0.0.isWhole, true);
      expect(0.1.isWhole, false);
    });

    test('format formats with decimal places', () {
      expect(3.14159.formatDecimal(2), '3.14');
      expect(3.14159.formatDecimal(4), '3.1416');
      expect(1000.0.formatDecimal(2), '1000.00');
      expect(1.0.formatDecimal(0), '1');
    });

    test('toPercentage converts to percentage string', () {
      expect(0.1234.toPercentage(), '12.34%');
      expect(0.1234.toPercentage(decimalPlaces: 1), '12.3%');
      expect(1.0.toPercentage(), '100.00%');
      expect(0.005.toPercentage(), '0.50%');
      expect(0.0.toPercentage(), '0.00%');
    });

    test('toDegrees converts radians to degrees', () {
      expect(3.14159.toDegrees, closeTo(180.0, 0.1));
      expect(1.5708.toDegrees, closeTo(90.0, 0.1));
      expect(0.0.toDegrees, 0.0);
    });

    test('toRadians converts degrees to radians', () {
      expect(180.0.toRadians, closeTo(3.14159, 0.001));
      expect(90.0.toRadians, closeTo(1.5708, 0.001));
      expect(0.0.toRadians, 0.0);
    });

    test('fractionalPart returns fractional part', () {
      expect(3.14.fractionalPart, closeTo(0.14, 0.001));
      expect((-3.14).fractionalPart, closeTo(-0.14, 0.001));
      expect(5.0.fractionalPart, 0.0);
      expect(0.99.fractionalPart, closeTo(0.99, 0.001));
    });
  });

  group('FalconToolDoubleNullExtensions', () {
    test('toDoubleOrZero returns value or 0.0', () {
      double? nullDouble;
      double? validDouble = 3.14;
      
      expect(nullDouble.toDoubleOrZero(), 0.0);
      expect(validDouble.toDoubleOrZero(), 3.14);
    });

    test('orDefault returns value or default', () {
      double? nullDouble;
      double? validDouble = 3.14;
      
      expect(nullDouble.orDefault(2.71), 2.71);
      expect(validDouble.orDefault(2.71), 3.14);
    });

    test('orZero returns value or 0.0', () {
      double? nullDouble;
      double? validDouble = 3.14;
      double? zeroDouble = 0.0;
      
      expect(nullDouble.orZero, 0.0);
      expect(validDouble.orZero, 3.14);
      expect(zeroDouble.orZero, 0.0);
    });

    test('isNullOrZero checks for null or zero', () {
      double? nullDouble;
      double? zeroDouble = 0.0;
      double? validDouble = 3.14;
      
      expect(nullDouble.isNullOrZero, true);
      expect(zeroDouble.isNullOrZero, true);
      expect(validDouble.isNullOrZero, false);
    });

    test('isNotNullOrZero is opposite of isNullOrZero', () {
      double? nullDouble;
      double? zeroDouble = 0.0;
      double? validDouble = 3.14;
      
      expect(nullDouble.isNotNullOrZero, false);
      expect(zeroDouble.isNotNullOrZero, false);
      expect(validDouble.isNotNullOrZero, true);
    });

    test('roundToPlaces handles null safely', () {
      double? nullDouble;
      double? validDouble = 3.14159;
      
      expect(nullDouble.roundToPlaces(2), null);
      expect(validDouble.roundToPlaces(2), 3.14);
    });

    test('format handles null safely', () {
      double? nullDouble;
      double? validDouble = 3.14159;
      
      expect(nullDouble.format(2), null);
      expect(validDouble.formatDecimal(2), '3.14');
    });

    test('toPercentage handles null safely', () {
      double? nullDouble;
      double? validDouble = 0.1234;
      
      expect(nullDouble.toPercentage(), null);
      expect(validDouble.toPercentage(), '12.34%');
      expect(validDouble.toPercentage(decimalPlaces: 1), '12.3%');
    });
  });

  group('FalconToolNumExtensions', () {
    test('toDouble converts num to double', () {
      num intNum = 5;
      num doubleNum = 3.14;
      
      expect(intNum.toDouble(), 5.0);
      expect(doubleNum.toDouble(), 3.14);
    });

    test('toInt converts num to int', () {
      num intNum = 5;
      num doubleNum = 3.14;
      
      expect(intNum.toInt(), 5);
      expect(doubleNum.toInt(), 3);
    });

    test('absolute returns absolute value', () {
      num positive = 5.5;
      num negative = -5.5;
      
      expect(positive.absolute, 5.5);
      expect(negative.absolute, 5.5);
    });

    test('clampValue clamps value between min and max', () {
      num value = 10.5;
      expect(value.clampValue(0, 5), 5);
      
      value = -5.5;
      expect(value.clampValue(0, 10), 0);
      
      value = 5.5;
      expect(value.clampValue(0, 10), 5.5);
    });

    test('atLeast returns maximum of value and min', () {
      num value = 5.5;
      expect(value.atLeast(10), 10);
      expect(value.atLeast(3), 5.5);
    });

    test('atMost returns minimum of value and max', () {
      num value = 15.5;
      expect(value.atMost(10), 10);
      expect(value.atMost(20), 15.5);
    });

    test('inRange checks if value is within range', () {
      num value = 5.5;
      expect(value.inRange(1, 10), true);
      expect(value.inRange(6, 10), false);
      expect(value.inRange(1, 5), false);
      expect(value.inRange(1, 5.5), true); // Inclusive
    });

    test('isPositive, isNegative, isZero work correctly', () {
      expect(5.isPositive, true);
      expect(5.isNegative, false);
      expect(5.isZero, false);
      
      expect((-5).isPositive, false);
      expect((-5).isNegative, true);
      expect((-5).isZero, false);
      
      expect(0.isPositive, false);
      expect(0.isNegative, false);
      expect(0.isZero, true);
    });

    test('lerp performs linear interpolation', () {
      expect(10.lerp(20, 0.5), 15.0);
      expect(0.lerp(100, 0.25), 25.0);
      expect(10.lerp(20, 0.0), 10.0);
      expect(10.lerp(20, 1.0), 20.0);
      expect(20.lerp(10, 0.5), 15.0); // Works backwards too
    });

    test('mapRange maps value from one range to another', () {
      // Map 50 from range 0-100 to range 0-1
      expect(50.mapRange(0, 100, 0, 1), 0.5);
      
      // Map 25 from range 0-100 to range 0-10
      expect(25.mapRange(0, 100, 0, 10), 2.5);
      
      // Map 0.5 from range 0-1 to range 0-255
      expect(0.5.mapRange(0, 1, 0, 255), 127.5);
      
      // Map with negative ranges
      expect(0.mapRange(-10, 10, -1, 1), 0.0);
    });
  });

  group('FalconToolNumNullExtensions', () {
    test('toDoubleOrZero converts to double or returns 0.0', () {
      num? nullNum;
      num? intNum = 5;
      num? doubleNum = 3.14;
      
      expect(nullNum.toDoubleOrZero(), 0.0);
      expect(intNum.toDoubleOrZero(), 5.0);
      expect(doubleNum.toDoubleOrZero(), 3.14);
    });

    test('toIntOrZero converts to int or returns 0', () {
      num? nullNum;
      num? intNum = 5;
      num? doubleNum = 3.14;
      
      expect(nullNum.toIntOrZero(), 0);
      expect(intNum.toIntOrZero(), 5);
      expect(doubleNum.toIntOrZero(), 3);
    });

    test('orDefault returns value or default', () {
      num? nullNum;
      num? validNum = 5.5;
      
      expect(nullNum.orDefault(10), 10);
      expect(validNum.orDefault(10), 5.5);
    });

    test('orZero returns value or 0', () {
      num? nullNum;
      num? validNum = 5.5;
      num? zeroNum = 0;
      
      expect(nullNum.orZero, 0);
      expect(validNum.orZero, 5.5);
      expect(zeroNum.orZero, 0);
    });

    test('isNullOrZero checks for null or zero', () {
      num? nullNum;
      num? zeroIntNum = 0;
      num? zeroDoubleNum = 0.0;
      num? validNum = 5.5;
      
      expect(nullNum.isNullOrZero, true);
      expect(zeroIntNum.isNullOrZero, true);
      expect(zeroDoubleNum.isNullOrZero, true);
      expect(validNum.isNullOrZero, false);
    });

    test('isNotNullOrZero is opposite of isNullOrZero', () {
      num? nullNum;
      num? zeroNum = 0;
      num? validNum = 5.5;
      
      expect(nullNum.isNotNullOrZero, false);
      expect(zeroNum.isNotNullOrZero, false);
      expect(validNum.isNotNullOrZero, true);
    });

    test('isPositive and isNegative handle null safely', () {
      num? nullNum;
      num? positiveNum = 5.5;
      num? negativeNum = -5.5;
      num? zeroNum = 0;
      
      expect(nullNum.isPositive, false);
      expect(nullNum.isNegative, false);
      expect(positiveNum.isPositive, true);
      expect(positiveNum.isNegative, false);
      expect(negativeNum.isPositive, false);
      expect(negativeNum.isNegative, true);
      expect(zeroNum.isPositive, false);
      expect(zeroNum.isNegative, false);
    });
  });
}