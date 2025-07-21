import 'package:faltool/lib.dart';
import 'package:flutter_test/flutter_test.dart';

// Test enums
enum TestStatus { active, inactive, pending }
enum TestPriority { low, medium, high }
enum TestUserType { regularUser, premiumUser, adminUser }

void main() {
  group('FalconToolEnumStringExtension', () {
    group('toEnum', () {
      test('should convert string to enum value', () {
        expect('active'.toEnum(TestStatus.values), TestStatus.active);
        expect('inactive'.toEnum(TestStatus.values), TestStatus.inactive);
        expect('pending'.toEnum(TestStatus.values), TestStatus.pending);
      });

      test('should handle case insensitive conversion by default', () {
        expect('ACTIVE'.toEnum(TestStatus.values), TestStatus.active);
        expect('Active'.toEnum(TestStatus.values), TestStatus.active);
        expect('aCtIvE'.toEnum(TestStatus.values), TestStatus.active);
      });

      test('should handle case sensitive conversion when specified', () {
        expect(
          () => 'ACTIVE'.toEnum(TestStatus.values, caseSensitive: true),
          throwsArgumentError,
        );
        expect(
          'active'.toEnum(TestStatus.values, caseSensitive: true),
          TestStatus.active,
        );
      });

      test('should return default value when not found', () {
        expect(
          'unknown'.toEnum(TestStatus.values, defaultValue: TestStatus.pending),
          TestStatus.pending,
        );
      });

      test('should throw ArgumentError when not found and no default', () {
        expect(
          () => 'unknown'.toEnum(TestStatus.values),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should work with full enum string format', () {
        expect(
          'TestStatus.active'.toEnum(TestStatus.values),
          TestStatus.active,
        );
      });

      test('should work with enums containing underscores', () {
        expect('regularUser'.toEnum(TestUserType.values), TestUserType.regularUser);
        expect('premiumUser'.toEnum(TestUserType.values), TestUserType.premiumUser);
        expect('adminUser'.toEnum(TestUserType.values), TestUserType.adminUser);
      });
    });

    group('toEnumOrNull', () {
      test('should convert string to enum value or null', () {
        expect('active'.toEnumOrNull(TestStatus.values), TestStatus.active);
        expect('unknown'.toEnumOrNull(TestStatus.values), null);
      });

      test('should handle case insensitive conversion by default', () {
        expect('ACTIVE'.toEnumOrNull(TestStatus.values), TestStatus.active);
        expect('Active'.toEnumOrNull(TestStatus.values), TestStatus.active);
      });

      test('should handle case sensitive conversion when specified', () {
        expect(
          'ACTIVE'.toEnumOrNull(TestStatus.values, caseSensitive: true),
          null,
        );
        expect(
          'active'.toEnumOrNull(TestStatus.values, caseSensitive: true),
          TestStatus.active,
        );
      });

      test('should return null for empty string', () {
        expect(''.toEnumOrNull(TestStatus.values), null);
      });
    });

    group('isValidEnum', () {
      test('should check if string is valid enum value', () {
        expect('active'.isValidEnum(TestStatus.values), true);
        expect('inactive'.isValidEnum(TestStatus.values), true);
        expect('unknown'.isValidEnum(TestStatus.values), false);
      });

      test('should handle case insensitive check by default', () {
        expect('ACTIVE'.isValidEnum(TestStatus.values), true);
        expect('Active'.isValidEnum(TestStatus.values), true);
      });

      test('should handle case sensitive check when specified', () {
        expect(
          'ACTIVE'.isValidEnum(TestStatus.values, caseSensitive: true),
          false,
        );
        expect(
          'active'.isValidEnum(TestStatus.values, caseSensitive: true),
          true,
        );
      });
    });
  });

  group('FalconEnumExtension', () {
    group('toValueString', () {
      test('should convert enum to string value', () {
        expect(TestStatus.active.toValueString(), 'active');
        expect(TestStatus.inactive.toValueString(), 'inactive');
        expect(TestStatus.pending.toValueString(), 'pending');
      });

      test('should handle enums with camelCase names', () {
        expect(TestUserType.regularUser.toValueString(), 'regularUser');
        expect(TestUserType.premiumUser.toValueString(), 'premiumUser');
        expect(TestUserType.adminUser.toValueString(), 'adminUser');
      });
    });

    group('toFormattedString', () {
      test('should format enum value with default settings', () {
        expect(TestUserType.regularUser.toFormattedString(), 'Regular User');
        expect(TestUserType.premiumUser.toFormattedString(), 'Premium User');
        expect(TestUserType.adminUser.toFormattedString(), 'Admin User');
      });

      test('should format with custom separator', () {
        expect(
          TestUserType.regularUser.toFormattedString(separator: '-'),
          'Regular-User',
        );
        expect(
          TestUserType.premiumUser.toFormattedString(separator: '_'),
          'Premium_User',
        );
      });

      test('should format without capitalization', () {
        expect(
          TestUserType.regularUser.toFormattedString(capitalize: false),
          'regular user',
        );
        expect(
          TestUserType.premiumUser.toFormattedString(
            separator: '-',
            capitalize: false,
          ),
          'premium-user',
        );
      });

      test('should handle single word enums', () {
        expect(TestStatus.active.toFormattedString(), 'Active');
        expect(TestStatus.inactive.toFormattedString(), 'Inactive');
      });
    });

    group('enumIndex', () {
      test('should return correct index', () {
        expect(TestStatus.active.enumIndex, 0);
        expect(TestStatus.inactive.enumIndex, 1);
        expect(TestStatus.pending.enumIndex, 2);
      });

      test('should match built-in index property', () {
        expect(TestPriority.low.enumIndex, TestPriority.low.index);
        expect(TestPriority.medium.enumIndex, TestPriority.medium.index);
        expect(TestPriority.high.enumIndex, TestPriority.high.index);
      });
    });

    group('isEqual', () {
      test('should compare enum values correctly', () {
        // Using the FalconEnumExtension isEqual method explicitly
        expect(FalconEnumExtension(TestStatus.active).isEqual(TestStatus.active), true);
        expect(FalconEnumExtension(TestStatus.active).isEqual(TestStatus.inactive), false);
        expect(FalconEnumExtension(TestStatus.active).isEqual(null), false);
      });

      test('should work across different enum types', () {
        expect(FalconEnumExtension(TestStatus.active).isEqual(TestPriority.low), false);
      });
    });

    group('isIn', () {
      test('should check if enum is in list', () {
        final activeStatuses = [TestStatus.active, TestStatus.pending];
        expect(TestStatus.active.isIn(activeStatuses), true);
        expect(TestStatus.inactive.isIn(activeStatuses), false);
      });

      test('should handle empty list', () {
        expect(TestStatus.active.isIn([]), false);
      });

      test('should work with same enum type only', () {
        // Note: isIn requires same enum type in Dart
        final statuses = [TestStatus.active, TestStatus.pending];
        expect(TestStatus.active.isIn(statuses), true);
        expect(TestStatus.inactive.isIn(statuses), false);
      });
    });

    group('isNotIn', () {
      test('should check if enum is not in list', () {
        final activeStatuses = [TestStatus.active, TestStatus.pending];
        expect(TestStatus.inactive.isNotIn(activeStatuses), true);
        expect(TestStatus.active.isNotIn(activeStatuses), false);
      });

      test('should handle empty list', () {
        expect(TestStatus.active.isNotIn([]), true);
      });
    });
  });

  group('FalconEnumListExtension', () {
    group('toValueStrings', () {
      test('should convert all enum values to strings', () {
        expect(
          TestStatus.values.toValueStrings(),
          ['active', 'inactive', 'pending'],
        );
      });

      test('should handle empty list', () {
        expect(<TestStatus>[].toValueStrings(), []);
      });

      test('should handle partial enum list', () {
        final partial = [TestStatus.active, TestStatus.pending];
        expect(partial.toValueStrings(), ['active', 'pending']);
      });
    });

    group('byValue', () {
      test('should find enum by string value', () {
        expect(TestStatus.values.byValue('active'), TestStatus.active);
        expect(TestStatus.values.byValue('inactive'), TestStatus.inactive);
      });

      test('should handle case insensitive search by default', () {
        expect(TestStatus.values.byValue('ACTIVE'), TestStatus.active);
        expect(TestStatus.values.byValue('Active'), TestStatus.active);
      });

      test('should handle case sensitive search when specified', () {
        expect(
          () => TestStatus.values.byValue('ACTIVE', caseSensitive: true),
          throwsArgumentError,
        );
      });

      test('should throw ArgumentError for unknown value', () {
        expect(
          () => TestStatus.values.byValue('unknown'),
          throwsArgumentError,
        );
      });
    });

    group('byValueOrNull', () {
      test('should find enum by string value or return null', () {
        expect(TestStatus.values.byValueOrNull('active'), TestStatus.active);
        expect(TestStatus.values.byValueOrNull('unknown'), null);
      });

      test('should handle case insensitive search by default', () {
        expect(TestStatus.values.byValueOrNull('ACTIVE'), TestStatus.active);
      });

      test('should handle case sensitive search when specified', () {
        expect(
          TestStatus.values.byValueOrNull('ACTIVE', caseSensitive: true),
          null,
        );
      });
    });

    group('toMap', () {
      test('should create map of enum to string', () {
        final map = TestStatus.values.toMap();
        expect(map[TestStatus.active], 'active');
        expect(map[TestStatus.inactive], 'inactive');
        expect(map[TestStatus.pending], 'pending');
        expect(map.length, 3);
      });

      test('should handle empty list', () {
        expect(<TestStatus>[].toMap(), {});
      });

      test('should handle partial enum list', () {
        final partial = [TestStatus.active, TestStatus.pending];
        final map = partial.toMap();
        expect(map[TestStatus.active], 'active');
        expect(map[TestStatus.pending], 'pending');
        expect(map.length, 2);
      });
    });

    group('toReverseMap', () {
      test('should create map of string to enum', () {
        final map = TestStatus.values.toReverseMap();
        expect(map['active'], TestStatus.active);
        expect(map['inactive'], TestStatus.inactive);
        expect(map['pending'], TestStatus.pending);
        expect(map.length, 3);
      });

      test('should handle empty list', () {
        expect(<TestStatus>[].toReverseMap(), {});
      });
    });

    group('whereValue', () {
      test('should filter enums by value predicate', () {
        final result = TestStatus.values.whereValue((v) => v.startsWith('a'));
        expect(result, [TestStatus.active]);
      });

      test('should filter enums by value length', () {
        final result = TestStatus.values.whereValue((v) => v.length > 6);
        expect(result, [TestStatus.inactive, TestStatus.pending]);
      });

      test('should return empty list when no matches', () {
        final result = TestStatus.values.whereValue((v) => v.startsWith('z'));
        expect(result, []);
      });

      test('should handle complex predicates', () {
        final result = TestUserType.values.whereValue(
          (v) => v.contains('User') && v.length > 10,
        );
        expect(result, [TestUserType.regularUser, TestUserType.premiumUser]);
      });
    });
  });

  group('FalconEnumNullExtension', () {
    group('toValueStringOrNull', () {
      test('should convert enum to string or return null', () {
        TestStatus? status = TestStatus.active;
        expect(status.toValueStringOrNull(), 'active');

        status = null;
        expect(status.toValueStringOrNull(), null);
      });
    });

    group('toValueStringOr', () {
      test('should convert enum to string or return default', () {
        TestStatus? status = TestStatus.active;
        expect(status.toValueStringOr('default'), 'active');

        status = null;
        expect(status.toValueStringOr('default'), 'default');
      });
    });

    group('isEqual', () {
      test('should compare nullable enum correctly', () {
        TestStatus? status = TestStatus.active;
        // Using the FalconEnumNullExtension isEqual method
        expect(FalconEnumNullExtension(status).isEqual(TestStatus.active), true);
        expect(FalconEnumNullExtension(status).isEqual(TestStatus.inactive), false);

        status = null;
        expect(FalconEnumNullExtension(status).isEqual(TestStatus.active), false);
      });
    });

    group('isIn', () {
      test('should check if nullable enum is in list', () {
        TestStatus? status = TestStatus.active;
        final list = [TestStatus.active, TestStatus.pending];
        expect(status.isIn(list), true);

        status = TestStatus.inactive;
        expect(status.isIn(list), false);

        status = null;
        expect(status.isIn(list), false);
      });
    });

    group('isNotIn', () {
      test('should check if nullable enum is not in list', () {
        TestStatus? status = TestStatus.inactive;
        final list = [TestStatus.active, TestStatus.pending];
        expect(status.isNotIn(list), true);

        status = TestStatus.active;
        expect(status.isNotIn(list), false);

        status = null;
        expect(status.isNotIn(list), true);
      });
    });

    group('orDefault', () {
      test('should return value or default', () {
        TestStatus? status = TestStatus.active;
        expect(status.orDefault(TestStatus.pending), TestStatus.active);

        status = null;
        expect(status.orDefault(TestStatus.pending), TestStatus.pending);
      });
    });
  });
}