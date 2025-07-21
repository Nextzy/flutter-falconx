import 'package:faltool/lib.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // BDD Helper functions
  void given(String description, void Function() callback) => callback();
  void when(String description, void Function() callback) => callback();
  void then(String description, void Function() callback) => callback();
  void and(String description, void Function() callback) => callback();

  group('Feature: DateTime Extensions', () {
    group('Scenario: Date Component Extraction', () {
      test('should extract start of day from any time', () {
        // Given
        late DateTime dateWithTime;
        late DateTime result;

        given('a date with specific time (2023-05-15 14:30:45)', () {
          dateWithTime = DateTime(2023, 5, 15, 14, 30, 45);
        });

        // When
        when('getting the start of day', () {
          result = dateWithTime.startOfDay;
        });

        // Then
        then('it should return the same date at 00:00:00.000', () {
          expect(result, equals(DateTime(2023, 5, 15, 0, 0, 0, 0)));
        });
      });

      test('should extract end of day from any time', () {
        // Given
        late DateTime dateWithTime;
        late DateTime result;

        given('a date with specific time (2023-05-15 14:30:45)', () {
          dateWithTime = DateTime(2023, 5, 15, 14, 30, 45);
        });

        // When
        when('getting the end of day', () {
          result = dateWithTime.endOfDay;
        });

        // Then
        then('it should return the same date at 23:59:59.999', () {
          expect(result.year, equals(2023));
          expect(result.month, equals(5));
          expect(result.day, equals(15));
          expect(result.hour, equals(23));
          expect(result.minute, equals(59));
          expect(result.second, equals(59));
          expect(result.millisecond, equals(999));
        });
      });

      test('should extract start and end of month', () {
        // Given
        late DateTime midMonthDate;
        late DateTime startResult;
        late DateTime endResult;

        given('a date in the middle of May 2023', () {
          midMonthDate = DateTime(2023, 5, 15);
        });

        // When
        when('getting the start and end of month', () {
          startResult = midMonthDate.startOfMonth;
          endResult = midMonthDate.endOfMonth;
        });

        // Then
        then('start should be May 1st', () {
          expect(startResult, equals(DateTime(2023, 5, 1)));
        });

        and('end should be May 31st at 23:59:59.999', () {
          expect(endResult.day, equals(31));
          expect(endResult.hour, equals(23));
          expect(endResult.minute, equals(59));
          expect(endResult.second, equals(59));
          expect(endResult.millisecond, equals(999));
        });
      });

      test('should extract start and end of year', () {
        // Given
        late DateTime midYearDate;
        late DateTime startResult;
        late DateTime endResult;

        given('a date in the middle of 2023', () {
          midYearDate = DateTime(2023, 5, 15);
        });

        // When
        when('getting the start and end of year', () {
          startResult = midYearDate.startOfYear;
          endResult = midYearDate.endOfYear;
        });

        // Then
        then('start should be January 1st', () {
          expect(startResult, equals(DateTime(2023, 1, 1)));
        });

        and('end should be December 31st at 23:59:59.999', () {
          expect(endResult.month, equals(12));
          expect(endResult.day, equals(31));
          expect(endResult.hour, equals(23));
          expect(endResult.minute, equals(59));
          expect(endResult.second, equals(59));
          expect(endResult.millisecond, equals(999));
        });
      });

      test('should correctly identify quarters', () {
        // Given
        final quarterTestCases = [
          (month: 1, expectedQuarter: 1),
          (month: 2, expectedQuarter: 1),
          (month: 3, expectedQuarter: 1),
          (month: 4, expectedQuarter: 2),
          (month: 5, expectedQuarter: 2),
          (month: 6, expectedQuarter: 2),
          (month: 7, expectedQuarter: 3),
          (month: 8, expectedQuarter: 3),
          (month: 9, expectedQuarter: 3),
          (month: 10, expectedQuarter: 4),
          (month: 11, expectedQuarter: 4),
          (month: 12, expectedQuarter: 4),
        ];

        for (final testCase in quarterTestCases) {
          given('a date in month ${testCase.month}', () {
            final date = DateTime(2023, testCase.month, 15);

            when('getting the quarter', () {
              final quarter = date.quarter;

              then('it should return quarter ${testCase.expectedQuarter}', () {
                expect(quarter, equals(testCase.expectedQuarter));
              });
            });
          });
        }
      });

      test('should calculate week of year', () {
        // Given
        late DateTime firstWeekDate;
        late DateTime midYearDate;

        given('dates in first week and mid-year of 2023', () {
          firstWeekDate = DateTime(2023, 1, 2); // Monday, first day of week 1
          midYearDate = DateTime(2023, 7, 1);
        });

        // When & Then
        when('getting week of year for January 2nd', () {
          final week = firstWeekDate.weekOfYear;

          then('it should be week 1', () {
            expect(week, equals(1));
          });
        });

        when('getting week of year for July 1st', () {
          final week = midYearDate.weekOfYear;

          then('it should be between weeks 26 and 27', () {
            expect(week, greaterThan(25));
            expect(week, lessThan(28));
          });
        });
      });

      test('should correctly identify days in month', () {
        // Given
        final monthTestCases = [
          (date: DateTime(2023, 1, 15), expectedDays: 31),
          // January
          (date: DateTime(2023, 2, 15), expectedDays: 28),
          // February (non-leap)
          (date: DateTime(2024, 2, 15), expectedDays: 29),
          // February (leap)
          (date: DateTime(2023, 4, 15), expectedDays: 30),
          // April
        ];

        for (final testCase in monthTestCases) {
          when('checking days in ${testCase.date.month}/${testCase.date.year}',
              () {
            final days = testCase.date.daysInMonth;

            then('it should have ${testCase.expectedDays} days', () {
              expect(days, equals(testCase.expectedDays));
            });
          });
        }
      });

      test('should correctly identify leap years', () {
        // Given
        final leapYearTestCases = [
          (year: 2020, isLeap: true, reason: 'divisible by 4'),
          (year: 2021, isLeap: false, reason: 'not divisible by 4'),
          (year: 2000, isLeap: true, reason: 'divisible by 400'),
          (year: 1900, isLeap: false, reason: 'divisible by 100 but not 400'),
        ];

        for (final testCase in leapYearTestCases) {
          given('year ${testCase.year} (${testCase.reason})', () {
            final date = DateTime(testCase.year, 1, 1);

            when('checking if it is a leap year', () {
              final isLeap = date.isLeapYear;

              then('it should be ${testCase.isLeap}', () {
                expect(isLeap, equals(testCase.isLeap));
              });
            });
          });
        }
      });
    });

    group('Scenario: Date Comparisons', () {
      test('should identify today, yesterday, and tomorrow', () {
        // Given
        late DateTime now;
        late DateTime today;
        late DateTime yesterday;
        late DateTime tomorrow;

        given('the current date and surrounding dates', () {
          now = DateTime.now();
          today = DateTime(now.year, now.month, now.day, 10, 0, 0);
          yesterday = today.subtract(const Duration(days: 1));
          tomorrow = today.add(const Duration(days: 1));
        });

        // When & Then
        when('checking if dates are today', () {
          then('today should return true', () {
            expect(today.isToday, isTrue);
          });

          and('yesterday should return false', () {
            expect(yesterday.isToday, isFalse);
          });

          and('tomorrow should return false', () {
            expect(tomorrow.isToday, isFalse);
          });
        });

        when('checking if dates are yesterday', () {
          then('yesterday should return true', () {
            expect(yesterday.isYesterday, isTrue);
          });

          and('today should return false', () {
            expect(today.isYesterday, isFalse);
          });
        });

        when('checking if dates are tomorrow', () {
          then('tomorrow should return true', () {
            expect(tomorrow.isTomorrow, isTrue);
          });

          and('today should return false', () {
            expect(today.isTomorrow, isFalse);
          });
        });
      });

      test('should correctly identify past and future dates', () {
        // Given
        late DateTime now;
        late DateTime pastDate;
        late DateTime futureDate;

        given('current time and dates in past and future', () {
          now = DateTime.now();
          pastDate = now.subtract(const Duration(days: 1));
          futureDate = now.add(const Duration(days: 1));
        });

        // When & Then
        when('checking if past date is in the past', () {
          then('isPast should return true', () {
            expect(pastDate.isPast, isTrue);
          });

          and('isFuture should return false', () {
            expect(pastDate.isFuture, isFalse);
          });
        });

        when('checking if future date is in the future', () {
          then('isFuture should return true', () {
            expect(futureDate.isFuture, isTrue);
          });

          and('isPast should return false', () {
            expect(futureDate.isPast, isFalse);
          });
        });
      });

      test('should identify weekends and weekdays', () {
        // Given
        final dayTestCases = [
          (date: DateTime(2023, 5, 15), isWeekend: false, day: 'Monday'),
          (date: DateTime(2023, 5, 20), isWeekend: true, day: 'Saturday'),
          (date: DateTime(2023, 5, 21), isWeekend: true, day: 'Sunday'),
        ];

        for (final testCase in dayTestCases) {
          given('a ${testCase.day}', () {
            when('checking if it is a weekend', () {
              then('isWeekend should return ${testCase.isWeekend}', () {
                expect(testCase.date.isWeekend, equals(testCase.isWeekend));
              });

              and('isWeekday should return ${!testCase.isWeekend}', () {
                expect(testCase.date.isWeekday, equals(!testCase.isWeekend));
              });
            });
          });
        }
      });

      test('should compare dates correctly', () {
        // Given
        late DateTime date1;
        late DateTime date2SameDay;
        late DateTime date3DifferentDay;
        late DateTime date4SameMonth;
        late DateTime date5DifferentMonth;

        given('various dates for comparison', () {
          date1 = DateTime(2023, 5, 15, 10, 30);
          date2SameDay = DateTime(2023, 5, 15, 20, 45);
          date3DifferentDay = DateTime(2023, 5, 16, 10, 30);
          date4SameMonth = DateTime(2023, 5, 30);
          date5DifferentMonth = DateTime(2023, 6, 15);
        });

        // When & Then
        when('comparing same day', () {
          then('isSameDay should return true for same day different time', () {
            expect(date1.isSameDay(date2SameDay), isTrue);
          });

          and('isSameDay should return false for different days', () {
            expect(date1.isSameDay(date3DifferentDay), isFalse);
          });
        });

        when('comparing same month', () {
          then('isSameMonth should return true for same month', () {
            expect(date1.isSameMonth(date4SameMonth), isTrue);
          });

          and('isSameMonth should return false for different months', () {
            expect(date1.isSameMonth(date5DifferentMonth), isFalse);
          });
        });

        when('comparing same year', () {
          then('isSameYear should return true for same year', () {
            expect(date1.isSameYear(date5DifferentMonth), isTrue);
          });
        });
      });

      test('should check if date is between two dates', () {
        // Given
        late DateTime start;
        late DateTime middle;
        late DateTime end;
        late DateTime outside;

        given('a date range and test dates', () {
          start = DateTime(2023, 5, 1);
          middle = DateTime(2023, 5, 15);
          end = DateTime(2023, 5, 31);
          outside = DateTime(2023, 6, 15);
        });

        // When & Then
        when('checking if dates are between start and end', () {
          then('middle date should be between', () {
            expect(middle.isBetween(start, end), isTrue);
          });

          and('outside date should not be between', () {
            expect(outside.isBetween(start, end), isFalse);
          });

          and('boundaries should not be inclusive', () {
            expect(start.isBetween(start, end), isFalse);
            expect(end.isBetween(start, end), isFalse);
          });
        });
      });
    });

    group('Scenario: Date Calculations', () {
      test('should add and subtract days correctly', () {
        // Given
        late DateTime baseDate;

        given('a base date of May 15, 2023', () {
          baseDate = DateTime(2023, 5, 15);
        });

        // When & Then
        when('adding 5 days', () {
          final result = baseDate.addDays(5);

          then('it should be May 20, 2023', () {
            expect(result, equals(DateTime(2023, 5, 20)));
          });
        });

        when('subtracting 5 days', () {
          final result = baseDate.subtractDays(5);

          then('it should be May 10, 2023', () {
            expect(result, equals(DateTime(2023, 5, 10)));
          });
        });

        when('adding negative days', () {
          final result = baseDate.addDays(-5);

          then('it should work like subtraction', () {
            expect(result, equals(DateTime(2023, 5, 10)));
          });
        });
      });

      test('should handle month calculations with overflow', () {
        // Given
        final monthTestCases = [
          // Normal addition
          (
            start: DateTime(2023, 5, 15),
            monthsToAdd: 2,
            expected: DateTime(2023, 7, 15),
            description: 'normal month addition'
          ),
          // Year overflow
          (
            start: DateTime(2023, 11, 15),
            monthsToAdd: 3,
            expected: DateTime(2024, 2, 15),
            description: 'year overflow'
          ),
          // Day overflow (Jan 31 + 1 month = Feb 28/29)
          (
            start: DateTime(2023, 1, 31),
            monthsToAdd: 1,
            expected: DateTime(2023, 2, 28),
            description: 'day overflow to non-leap February'
          ),
          (
            start: DateTime(2024, 1, 31),
            monthsToAdd: 1,
            expected: DateTime(2024, 2, 29),
            description: 'day overflow to leap February'
          ),
          // Negative months
          (
            start: DateTime(2023, 3, 15),
            monthsToAdd: -2,
            expected: DateTime(2023, 1, 15),
            description: 'negative months'
          ),
          (
            start: DateTime(2023, 2, 15),
            monthsToAdd: -3,
            expected: DateTime(2022, 11, 15),
            description: 'negative months with year underflow'
          ),
        ];

        for (final testCase in monthTestCases) {
          given('${testCase.description}', () {
            when('adding ${testCase.monthsToAdd} months to ${testCase.start}',
                () {
              final result = testCase.start.addMonths(testCase.monthsToAdd);

              then('it should equal ${testCase.expected}', () {
                expect(result, equals(testCase.expected));
              });
            });
          });
        }
      });

      test('should add and subtract years correctly', () {
        // Given
        late DateTime baseDate;

        given('a base date with time components', () {
          baseDate = DateTime(2023, 5, 15, 10, 30, 45);
        });

        // When & Then
        when('adding 2 years', () {
          final result = baseDate.addYears(2);

          then('year should be 2025 with time preserved', () {
            expect(result.year, equals(2025));
            expect(result.month, equals(5));
            expect(result.day, equals(15));
            expect(result.hour, equals(10));
            expect(result.minute, equals(30));
            expect(result.second, equals(45));
          });
        });

        when('subtracting 2 years', () {
          final result = baseDate.subtractYears(2);

          then('it should be 2021 with time preserved', () {
            expect(result, equals(DateTime(2021, 5, 15, 10, 30, 45)));
          });
        });
      });

      test('should find next and previous weekdays', () {
        // Given
        late DateTime monday;

        given('a Monday (May 15, 2023)', () {
          monday = DateTime(2023, 5, 15);
        });

        // When & Then
        when('finding next Tuesday', () {
          final result = monday.nextWeekday(DateTime.tuesday);

          then('it should be the next day and a Tuesday', () {
            expect(result.weekday, equals(DateTime.tuesday));
            expect(result.day, equals(16));
          });
        });

        when('finding next Monday', () {
          final result = monday.nextWeekday(DateTime.monday);

          then('it should be next week Monday', () {
            expect(result.weekday, equals(DateTime.monday));
            expect(result.day, equals(22));
          });
        });

        when('finding previous Sunday', () {
          final result = monday.previousWeekday(DateTime.sunday);

          then('it should be yesterday and a Sunday', () {
            expect(result.weekday, equals(DateTime.sunday));
            expect(result.day, equals(14));
          });
        });

        when('finding previous Monday', () {
          final result = monday.previousWeekday(DateTime.monday);

          then('it should be last week Monday', () {
            expect(result.weekday, equals(DateTime.monday));
            expect(result.day, equals(8));
          });
        });
      });

      test('should copy DateTime with modifications', () {
        // Given
        late DateTime original;

        given('an original DateTime with all components', () {
          original = DateTime(2023, 5, 15, 10, 30, 45, 123, 456);
        });

        // When & Then
        when('copying with year change', () {
          final result = original.copyWith(year: 2024);

          then('only year should change', () {
            expect(result.year, equals(2024));
            expect(result.month, equals(5));
            expect(result.day, equals(15));
          });
        });

        when('copying with multiple changes', () {
          final result = original.copyWith(
            month: 6,
            hour: 14,
            minute: 45,
          );

          then('only specified fields should change', () {
            expect(result.year, equals(2023));
            expect(result.month, equals(6));
            expect(result.day, equals(15));
            expect(result.hour, equals(14));
            expect(result.minute, equals(45));
            expect(result.second, equals(45));
            expect(result.millisecond, equals(123));
            expect(result.microsecond, equals(456));
          });
        });
      });
    });

    group('Scenario: Date Formatting', () {
      test('should format dates with custom patterns', () {
        // Given
        late DateTime date;

        given('a specific date and time', () {
          date = DateTime(2023, 5, 15, 14, 30, 45);
        });

        // When & Then
        final formatTestCases = [
          (pattern: 'yyyy-MM-dd', expected: '2023-05-15'),
          (pattern: 'dd/MM/yyyy', expected: '15/05/2023'),
          (pattern: 'HH:mm:ss', expected: '14:30:45'),
        ];

        for (final testCase in formatTestCases) {
          when('formatting with pattern "${testCase.pattern}"', () {
            final result = date.format(testCase.pattern);

            then('it should return "${testCase.expected}"', () {
              expect(result, equals(testCase.expected));
            });
          });
        }
      });

      test('should use predefined format methods', () {
        // Given
        late DateTime date;

        given('a specific date and time', () {
          date = DateTime(2023, 5, 15, 14, 30, 45);
        });

        // When & Then
        when('formatting as ISO 8601', () {
          final result = date.toIso8601;

          then('it should contain date and time parts', () {
            expect(result, contains('2023-05-15'));
            expect(result, contains('14:30:45'));
          });
        });

        when('formatting as date only', () {
          final result = date.toDateOnly;

          then('it should return yyyy-MM-dd format', () {
            expect(result, equals('2023-05-15'));
          });
        });

        when('formatting as time only', () {
          final result = date.toTimeOnly;

          then('it should return HH:mm:ss format', () {
            expect(result, equals('14:30:45'));
          });
        });

        when('formatting as short date', () {
          final result = date.toShortDate;

          then('it should contain month name, day, and year', () {
            expect(result, contains('May'));
            expect(result, contains('15'));
            expect(result, contains('2023'));
          });
        });

        when('formatting as full date', () {
          final result = date.toFullDate;

          then('it should contain weekday and full month name', () {
            expect(result, contains('Monday'));
            expect(result, contains('May'));
          });
        });
      });

      test('should format relative time correctly', () {
        // Given
        late DateTime now;

        given('the current time', () {
          now = DateTime.now();
        });

        // When & Then
        final relativeTimeTestCases = [
          (time: now, expected: 'just now', description: 'current time'),
          (
            time: now.subtract(const Duration(minutes: 5)),
            expected: '5 minutes ago',
            description: '5 minutes ago'
          ),
          (
            time: now.subtract(const Duration(hours: 2)),
            expected: '2 hours ago',
            description: '2 hours ago'
          ),
          (
            time: now.subtract(const Duration(days: 3)),
            expected: '3 days ago',
            description: '3 days ago'
          ),
          (
            time: now.add(const Duration(hours: 2, minutes: 1)),
            expected: 'in 2 hours',
            description: '2 hours in future'
          ),
        ];

        for (final testCase in relativeTimeTestCases) {
          when('formatting ${testCase.description}', () {
            final result = testCase.time.toRelative();

            then('it should contain "${testCase.expected}"', () {
              expect(result, contains(testCase.expected));
            });
          });
        }
      });

      test('should format human readable day names', () {
        // Given
        late DateTime now;
        late DateTime today;
        late DateTime yesterday;
        late DateTime tomorrow;
        late DateTime otherDay;

        given('various days relative to today', () {
          now = DateTime.now();
          today = DateTime(now.year, now.month, now.day);
          yesterday = today.subtract(const Duration(days: 1));
          tomorrow = today.add(const Duration(days: 1));
          otherDay = today.add(const Duration(days: 5));
        });

        // When & Then
        when('formatting today', () {
          final result = today.humanReadableDay();

          then('it should return "Today"', () {
            expect(result, equals('Today'));
          });
        });

        when('formatting yesterday', () {
          final result = yesterday.humanReadableDay();

          then('it should return "Yesterday"', () {
            expect(result, equals('Yesterday'));
          });
        });

        when('formatting tomorrow', () {
          final result = tomorrow.humanReadableDay();

          then('it should return "Tomorrow"', () {
            expect(result, equals('Tomorrow'));
          });
        });

        when('formatting other days', () {
          final result = otherDay.humanReadableDay();

          then('it should return the weekday name', () {
            expect(result, contains(DateFormat('EEEE').format(otherDay)));
          });
        });
      });
    });

    group('Scenario: Date Conversions', () {
      test('should convert to timestamps', () {
        // Given
        late DateTime date;

        given('a date from known timestamps', () {
          date = DateTime.fromMillisecondsSinceEpoch(1684156800000);
        });

        // When & Then
        when('converting to Unix timestamp', () {
          final result = date.toUnixTimestamp;

          then('it should return seconds since epoch', () {
            expect(result, equals(1684156800));
          });
        });

        when('converting to JavaScript timestamp', () {
          final result = date.toJsTimestamp;

          then('it should return milliseconds since epoch', () {
            expect(result, equals(1684156800000));
          });
        });
      });

      test('should calculate age correctly', () {
        // Given
        late DateTime now;
        late DateTime birthdate25;
        late DateTime birthdateFuture;

        given('birthdates for age calculation', () {
          now = DateTime.now();
          birthdate25 = DateTime(now.year - 25, now.month, now.day);
          birthdateFuture = DateTime(now.year - 25, now.month + 1, now.day);
        });

        // When & Then
        when('birthday has already passed this year', () {
          final age = birthdate25.age;

          then('age should be 25', () {
            expect(age, equals(25));
          });
        });

        when('birthday has not happened yet this year', () {
          final age = birthdateFuture.age;

          then('age should be 24', () {
            expect(age, equals(24));
          });
        });
      });

      test('should calculate days and hours until date', () {
        // Given
        late DateTime now;
        late DateTime futureDate;
        late DateTime pastDate;

        given('dates in past and future', () {
          now = DateTime.now();
          futureDate = now.add(const Duration(days: 5, hours: 3));
          pastDate = now.subtract(const Duration(days: 2));
        });

        // When & Then
        when('calculating days until future date', () {
          final days = futureDate.daysUntil;

          then('it should be negative (in the future)', () {
            expect(days, equals(-5));
          });
        });

        when('calculating days until past date', () {
          final days = pastDate.daysUntil;

          then('it should be positive (in the past)', () {
            expect(days, equals(2));
          });
        });

        when('calculating hours until future date', () {
          final hours = futureDate.hoursUntil;

          then('it should be more than 5 days in hours', () {
            expect(hours, lessThan(-120));
          });
        });
      });
    });
  });

  group('Feature: Integer to DateTime Conversions', () {
    group('Scenario: Unix Timestamp Conversions', () {
      test('should convert Unix timestamp to UTC DateTime', () {
        // Given
        late int unixTimestamp;

        given('a Unix timestamp for May 15, 2023 12:00:00 UTC', () {
          unixTimestamp = 1684156800;
        });

        // When
        when('converting to DateTime', () {
          final date = unixTimestamp.fromUnixToDateTime;

          // Then
          then('it should create correct UTC DateTime', () {
            expect(date.year, equals(2023));
            expect(date.month, equals(5));
            expect(date.day, equals(15));
            expect(date.isUtc, isTrue);
          });
        });
      });

      test('should convert Unix timestamp to local DateTime', () {
        // Given
        late int unixTimestamp;

        given('a Unix timestamp', () {
          unixTimestamp = 1684156800;
        });

        // When
        when('converting to local DateTime', () {
          final date = unixTimestamp.fromUnixToLocalDateTime;

          // Then
          then('it should not be UTC', () {
            expect(date.isUtc, isFalse);
          });
        });
      });
    });

    group('Scenario: JavaScript Timestamp Conversions', () {
      test('should convert JS timestamp to UTC DateTime', () {
        // Given
        late int jsTimestamp;

        given('a JavaScript timestamp in milliseconds', () {
          jsTimestamp = 1684156800000;
        });

        // When
        when('converting to DateTime', () {
          final date = jsTimestamp.fromJsToDateTime;

          // Then
          then('it should create correct UTC DateTime', () {
            expect(date.year, equals(2023));
            expect(date.month, equals(5));
            expect(date.day, equals(15));
            expect(date.isUtc, isTrue);
          });
        });
      });

      test('should convert JS timestamp to local DateTime', () {
        // Given
        late int jsTimestamp;

        given('a JavaScript timestamp', () {
          jsTimestamp = 1684156800000;
        });

        // When
        when('converting to local DateTime', () {
          final date = jsTimestamp.fromJsToLocalDateTime;

          // Then
          then('it should not be UTC', () {
            expect(date.isUtc, isFalse);
          });
        });
      });
    });
  });

  group('Feature: Nullable DateTime Extensions', () {
    group('Scenario: Null Safety Checks', () {
      test('should handle null checks for past and future', () {
        // Given
        DateTime? nullDate;
        late DateTime pastDate;
        late DateTime futureDate;

        given('null and non-null dates', () {
          nullDate = null;
          pastDate = DateTime.now().subtract(const Duration(days: 1));
          futureDate = DateTime.now().add(const Duration(days: 1));
        });

        // When & Then
        when('checking isNullOrPast', () {
          then('null should return true', () {
            expect(nullDate.isNullOrPast, isTrue);
          });

          and('past date should return true', () {
            expect(pastDate.isNullOrPast, isTrue);
          });

          and('future date should return false', () {
            expect(futureDate.isNullOrPast, isFalse);
          });
        });

        when('checking isNullOrFuture', () {
          then('null should return true', () {
            expect(nullDate.isNullOrFuture, isTrue);
          });

          and('past date should return false', () {
            expect(pastDate.isNullOrFuture, isFalse);
          });

          and('future date should return true', () {
            expect(futureDate.isNullOrFuture, isTrue);
          });
        });
      });

      test('should handle null-safe formatting', () {
        // Given
        DateTime? nullDate;
        late DateTime validDate;

        given('null and valid dates', () {
          nullDate = null;
          validDate = DateTime(2023, 5, 15);
        });

        // When & Then
        when('formatting null date', () {
          final result = nullDate.format('yyyy-MM-dd');

          then('it should return null', () {
            expect(result, isNull);
          });
        });

        when('formatting valid date', () {
          final result = validDate.format('yyyy-MM-dd');

          then('it should return formatted string', () {
            expect(result, equals('2023-05-15'));
          });
        });
      });

      test('should provide default values for null dates', () {
        // Given
        DateTime? nullDate;
        late DateTime validDate;
        late DateTime defaultDate;

        given('null, valid, and default dates', () {
          nullDate = null;
          validDate = DateTime(2023, 5, 15);
          defaultDate = DateTime(2023, 1, 1);
        });

        // When & Then
        when('using orNow on null', () {
          final result = nullDate.orNow;

          then('it should return current date', () {
            expect(result.day, equals(DateTime.now().day));
          });
        });

        when('using orNow on valid date', () {
          final result = validDate.orNow;

          then('it should return the original date', () {
            expect(result, equals(validDate));
          });
        });

        when('using orDefault', () {
          then('null should return default', () {
            expect(nullDate.orDefault(defaultDate), equals(defaultDate));
          });

          and('valid date should return itself', () {
            expect(validDate.orDefault(defaultDate), equals(validDate));
          });
        });
      });
    });
  });

  group('Feature: Duration Extensions', () {
    group('Scenario: Human Readable Formatting', () {
      test('should format durations in human readable format', () {
        // Given
        final durationTestCases = [
          (duration: const Duration(hours: 2, minutes: 30), expected: '2h 30m'),
          (duration: const Duration(days: 1, hours: 2), expected: '1d 2h'),
          (
            duration: const Duration(minutes: 45, seconds: 30),
            expected: '45m 30s'
          ),
          (duration: const Duration(seconds: 45), expected: '45s'),
          (duration: Duration.zero, expected: '0s'),
        ];

        for (final testCase in durationTestCases) {
          when('formatting ${testCase.duration}', () {
            final result = testCase.duration.toHumanReadable();

            then('it should return "${testCase.expected}"', () {
              expect(result, equals(testCase.expected));
            });
          });
        }
      });

      test('should format duration as time string', () {
        // Given
        final timeStringTestCases = [
          (
            duration: const Duration(hours: 2, minutes: 30, seconds: 45),
            expected: '02:30:45'
          ),
          (
            duration: const Duration(hours: 25, minutes: 5),
            expected: '25:05:00'
          ),
          (
            duration: const Duration(minutes: 5, seconds: 8),
            expected: '00:05:08'
          ),
        ];

        for (final testCase in timeStringTestCases) {
          when('formatting ${testCase.duration} as time string', () {
            final result = testCase.duration.toTimeString();

            then('it should return "${testCase.expected}"', () {
              expect(result, equals(testCase.expected));
            });
          });
        }
      });
    });

    group('Scenario: Duration Calculations', () {
      test('should calculate weeks correctly', () {
        // Given
        late Duration twoWeeks;
        late Duration tenDays;

        given('durations in days', () {
          twoWeeks = const Duration(days: 14);
          tenDays = const Duration(days: 10);
        });

        // When & Then
        when('calculating weeks for 14 days', () {
          final weeks = twoWeeks.inWeeks;

          then('it should equal 2 weeks', () {
            expect(weeks, equals(2));
          });
        });

        when('calculating weeks for 10 days', () {
          final weeks = tenDays.inWeeks;

          then('it should equal 2 weeks (ceiling)', () {
            expect(weeks, equals(2));
          });
        });
      });

      test('should calculate years approximately', () {
        // Given
        late Duration oneYear;
        late Duration twoYears;

        given('durations in days', () {
          oneYear = const Duration(days: 365);
          twoYears = const Duration(days: 730);
        });

        // When & Then
        when('calculating years for 365 days', () {
          final years = oneYear.inYears;

          then('it should be approximately 1 year', () {
            expect(years, closeTo(0.999, 0.01));
          });
        });

        when('calculating years for 730 days', () {
          final years = twoYears.inYears;

          then('it should be approximately 2 years', () {
            expect(years, closeTo(1.998, 0.01));
          });
        });
      });

      test('should perform arithmetic operations', () {
        // Given
        late Duration duration1;
        late Duration duration2;

        given('two durations', () {
          duration1 = const Duration(hours: 2, minutes: 30);
          duration2 = const Duration(hours: 1, minutes: 15);
        });

        // When & Then
        when('adding durations', () {
          final sum = duration1 + duration2;

          then('it should equal 3h 45m', () {
            expect(sum.inMinutes, equals(225));
          });
        });

        when('subtracting durations', () {
          final diff = duration1 - duration2;

          then('it should equal 1h 15m', () {
            expect(diff.inMinutes, equals(75));
          });
        });

        when('multiplying duration by 2', () {
          final multiplied = duration1 * 2;

          then('it should equal 5h', () {
            expect(multiplied.inMinutes, equals(300));
          });
        });

        when('dividing duration by 2', () {
          final divided = duration1 / 2;

          then('it should equal 1h 15m', () {
            expect(divided.inMinutes, equals(75));
          });
        });
      });
    });
  });

  group('Feature: DateTime Localizations', () {
    test('should provide localized strings', () {
      // Given & When & Then
      final localizationTestCases = [
        (method: DateTimeLocalizations.today, expected: 'Today'),
        (method: DateTimeLocalizations.yesterday, expected: 'Yesterday'),
        (method: DateTimeLocalizations.tomorrow, expected: 'Tomorrow'),
        (method: DateTimeLocalizations.justNow, expected: 'just now'),
        (method: DateTimeLocalizations.inAMoment, expected: 'in a moment'),
      ];

      for (final testCase in localizationTestCases) {
        when('getting localized string', () {
          final result = testCase.method();

          then('it should return "${testCase.expected}"', () {
            expect(result, equals(testCase.expected));
          });
        });
      }
    });
  });
}
