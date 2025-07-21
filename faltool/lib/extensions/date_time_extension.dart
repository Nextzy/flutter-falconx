import 'package:faltool/lib.dart';

/// Extension methods for DateTime manipulation and formatting.
/// 
/// Provides comprehensive utilities for date/time operations including
/// formatting, comparisons, calculations, and timezone handling.
extension FalconToolDateTimeExtensions on DateTime {
  /// Common date format patterns.
  static const String iso8601Pattern = 'yyyy-MM-ddTHH:mm:ss';
  static const String dateOnlyPattern = 'yyyy-MM-dd';
  static const String timeOnlyPattern = 'HH:mm:ss';
  static const String shortDatePattern = 'MMM dd, yyyy';
  static const String fullDatePattern = 'EEEE, MMMM dd, yyyy';
  static const String monthYearPattern = 'MMMM yyyy';

  // Date Components

  /// Gets the start of the day (00:00:00).
  /// 
  /// Example:
  /// ```dart
  /// DateTime(2023, 5, 15, 14, 30).startOfDay; // 2023-05-15 00:00:00
  /// ```
  DateTime get startOfDay => DateTime(year, month, day);

  /// Gets the start of the month.
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// Gets the end of the month.
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  /// Gets the start of the year.
  DateTime get startOfYear => DateTime(year, 1, 1);

  /// Gets the end of the year.
  DateTime get endOfYear => DateTime(year, 12, 31, 23, 59, 59, 999);

  /// Gets the quarter of the year (1-4).
  int get quarter => ((month - 1) ~/ 3) + 1;

  /// Gets the week number in the year (ISO 8601).
  int get weekOfYear {
    // Find the Thursday of the week containing January 1st
    final jan1 = DateTime(year, 1, 1);
    final daysToThursday = (4 - jan1.weekday + 7) % 7;
    final firstThursday = jan1.add(Duration(days: daysToThursday));
    
    // If this date is before the first Thursday, it belongs to the previous year's last week
    if (isBefore(firstThursday.subtract(const Duration(days: 3)))) {
      // This is week 52 or 53 of the previous year
      final prevYearJan1 = DateTime(year - 1, 1, 1);
      final prevDaysToThursday = (4 - prevYearJan1.weekday + 7) % 7;
      final prevFirstThursday = prevYearJan1.add(Duration(days: prevDaysToThursday));
      final lastWeekStart = DateTime(year - 1, 12, 31).subtract(
        Duration(days: (DateTime(year - 1, 12, 31).weekday - 1 + 7) % 7),
      );
      return 1 + lastWeekStart.difference(prevFirstThursday).inDays ~/ 7;
    }
    
    // Calculate the Monday of the week containing the first Thursday
    final firstWeekMonday = firstThursday.subtract(Duration(days: 3));
    
    // Calculate weeks from the first week's Monday
    final daysSinceFirstWeek = difference(firstWeekMonday).inDays;
    return 1 + (daysSinceFirstWeek / 7).floor();
  }

  /// Checks if this date is yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Checks if this date is in the past.
  bool get isPast => isBefore(DateTime.now());

  /// Checks if this date is in the future.
  bool get isFuture => isAfter(DateTime.now());

  /// Checks if this date is on a weekday.
  bool get isWeekday => weekday != DateTime.saturday && weekday != DateTime.sunday;

  /// Checks if this date is in the same day as another date.
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Checks if this date is in the same month as another date.
  bool isSameMonth(DateTime other) =>
      year == other.year && month == other.month;

  /// Checks if this date is in the same year as another date.
  bool isSameYear(DateTime other) => year == other.year;

  /// Checks if this date is between two other dates.
  bool isBetween(DateTime start, DateTime end) =>
      isAfter(start) && isBefore(end);

  /// Adds the specified number of days.
  DateTime addDays(int days) => add(Duration(days: days));

  /// Subtracts the specified number of days.
  DateTime subtractDays(int days) => subtract(Duration(days: days));

  /// Adds the specified number of months.
  /// 
  /// Handles month overflow correctly (e.g., Jan 31 + 1 month = Feb 28/29).
  DateTime addMonths(int months) {
    var newYear = year;
    var newMonth = month + months;
    
    while (newMonth > 12) {
      newYear++;
      newMonth -= 12;
    }
    while (newMonth < 1) {
      newYear--;
      newMonth += 12;
    }
    
    final newDay = day.clamp(1, DateTime(newYear, newMonth + 1, 0).day);
    return DateTime(newYear, newMonth, newDay, hour, minute, second,
        millisecond, microsecond);
  }

  /// Subtracts the specified number of months.
  DateTime subtractMonths(int months) => addMonths(-months);

  /// Adds the specified number of years.
  DateTime addYears(int years) => DateTime(year + years, month, day, hour, 
      minute, second, millisecond, microsecond);

  /// Subtracts the specified number of years.
  DateTime subtractYears(int years) => addYears(-years);

  /// Gets the next occurrence of a specific weekday.
  /// 
  /// Example:
  /// ```dart
  /// // Get next Monday
  /// DateTime.now().nextWeekday(DateTime.monday);
  /// ```
  DateTime nextWeekday(int weekday) {
    final daysUntilWeekday = (weekday - this.weekday + 7) % 7;
    final days = daysUntilWeekday == 0 ? 7 : daysUntilWeekday;
    return addDays(days);
  }

  /// Gets the previous occurrence of a specific weekday.
  DateTime previousWeekday(int weekday) {
    final daysUntilWeekday = (this.weekday - weekday + 7) % 7;
    final days = daysUntilWeekday == 0 ? 7 : daysUntilWeekday;
    return subtractDays(days);
  }

  // Formatting

  /// Formats the date using the specified pattern.
  /// 
  /// Example:
  /// ```dart
  /// DateTime.now().format('yyyy-MM-dd'); // '2023-05-15'
  /// DateTime.now().format('MMM dd, yyyy'); // 'May 15, 2023'
  /// ```
  String format(String pattern, {String? locale}) {
    return DateFormat(pattern, locale).format(this);
  }

  /// Formats as ISO 8601 string.
  String get toIso8601 => format(iso8601Pattern);

  /// Formats as date only (yyyy-MM-dd).
  String get toDateOnly => format(dateOnlyPattern);

  /// Formats as time only (HH:mm:ss).
  String get toTimeOnly => format(timeOnlyPattern);

  /// Formats as short date (MMM dd, yyyy).
  String get toShortDate => format(shortDatePattern);

  /// Formats as full date (EEEE, MMMM dd, yyyy).
  String get toFullDate => format(fullDatePattern);

  /// Formats as month and year (MMMM yyyy).
  String get toMonthYear => format(monthYearPattern);

  /// Formats as a relative time string with localization support.
  /// 
  /// Example:
  /// ```dart
  /// DateTime.now().subtract(Duration(minutes: 5)).toRelative(); // '5 minutes ago'
  /// DateTime.now().add(Duration(hours: 2)).toRelative(); // 'in 2 hours'
  /// ```
  String toRelative({String? locale}) {
    if (locale != null) {
      Intl.defaultLocale = locale;
    }
    
    final now = DateTime.now();
    final difference = now.difference(this);
    final isInPast = !difference.isNegative;
    final duration = difference.abs();

    if (duration.inSeconds < 60) {
      return isInPast 
          ? DateTimeLocalizations.justNow(locale: locale)
          : DateTimeLocalizations.inAMoment(locale: locale);
    } else if (duration.inMinutes < 60) {
      final minutes = duration.inMinutes;
      return isInPast
          ? Intl.plural(
              minutes,
              one: Intl.message('$minutes minute ago', 
                  name: 'minuteAgo', args: [minutes]),
              other: Intl.message('$minutes minutes ago', 
                  name: 'minutesAgo', args: [minutes]),
              locale: locale,
            )
          : Intl.plural(
              minutes,
              one: Intl.message('in $minutes minute', 
                  name: 'inMinute', args: [minutes]),
              other: Intl.message('in $minutes minutes', 
                  name: 'inMinutes', args: [minutes]),
              locale: locale,
            );
    } else if (duration.inHours < 24) {
      final hours = duration.inHours;
      return isInPast
          ? Intl.plural(
              hours,
              one: Intl.message('$hours hour ago', 
                  name: 'hourAgo', args: [hours]),
              other: Intl.message('$hours hours ago', 
                  name: 'hoursAgo', args: [hours]),
              locale: locale,
            )
          : Intl.plural(
              hours,
              one: Intl.message('in $hours hour', 
                  name: 'inHour', args: [hours]),
              other: Intl.message('in $hours hours', 
                  name: 'inHours', args: [hours]),
              locale: locale,
            );
    } else if (duration.inDays < 7) {
      final days = duration.inDays;
      return isInPast
          ? Intl.plural(
              days,
              one: Intl.message('$days day ago', 
                  name: 'dayAgo', args: [days]),
              other: Intl.message('$days days ago', 
                  name: 'daysAgo', args: [days]),
              locale: locale,
            )
          : Intl.plural(
              days,
              one: Intl.message('in $days day', 
                  name: 'inDay', args: [days]),
              other: Intl.message('in $days days', 
                  name: 'inDays', args: [days]),
              locale: locale,
            );
    } else if (duration.inDays < 30) {
      final weeks = (duration.inDays / 7).round();
      return isInPast
          ? Intl.plural(
              weeks,
              one: Intl.message('$weeks week ago', 
                  name: 'weekAgo', args: [weeks]),
              other: Intl.message('$weeks weeks ago', 
                  name: 'weeksAgo', args: [weeks]),
              locale: locale,
            )
          : Intl.plural(
              weeks,
              one: Intl.message('in $weeks week', 
                  name: 'inWeek', args: [weeks]),
              other: Intl.message('in $weeks weeks', 
                  name: 'inWeeks', args: [weeks]),
              locale: locale,
            );
    } else if (duration.inDays < 365) {
      final months = (duration.inDays / 30).round();
      return isInPast
          ? Intl.plural(
              months,
              one: Intl.message('$months month ago', 
                  name: 'monthAgo', args: [months]),
              other: Intl.message('$months months ago', 
                  name: 'monthsAgo', args: [months]),
              locale: locale,
            )
          : Intl.plural(
              months,
              one: Intl.message('in $months month', 
                  name: 'inMonth', args: [months]),
              other: Intl.message('in $months months', 
                  name: 'inMonths', args: [months]),
              locale: locale,
            );
    } else {
      final years = (duration.inDays / 365).round();
      return isInPast
          ? Intl.plural(
              years,
              one: Intl.message('$years year ago', 
                  name: 'yearAgo', args: [years]),
              other: Intl.message('$years years ago', 
                  name: 'yearsAgo', args: [years]),
              locale: locale,
            )
          : Intl.plural(
              years,
              one: Intl.message('in $years year', 
                  name: 'inYear', args: [years]),
              other: Intl.message('in $years years', 
                  name: 'inYears', args: [years]),
              locale: locale,
            );
    }
  }

  /// Gets a human-readable string for the day with localization support.
  /// 
  /// Returns localized 'Today', 'Yesterday', 'Tomorrow', or the formatted date.
  String humanReadableDay({String? locale}) {
    if (locale != null) {
      Intl.defaultLocale = locale;
    }
    
    if (isToday) {
      return Intl.message('Today', name: 'today');
    }
    if (isYesterday) {
      return Intl.message('Yesterday', name: 'yesterday');
    }
    if (isTomorrow) {
      return Intl.message('Tomorrow', name: 'tomorrow');
    }
    return format('EEEE, MMM dd', locale: locale);
  }

  // Conversion Methods

  /// Converts to Unix timestamp (seconds since epoch).
  int get toUnixTimestamp => millisecondsSinceEpoch ~/ 1000;

  /// Converts to JavaScript timestamp (milliseconds since epoch).
  int get toJsTimestamp => millisecondsSinceEpoch;

  /// Gets the age in years from this date to now.
  /// 
  /// Useful for calculating someone's age from their birthdate.
  int get age {
    final now = DateTime.now();
    var age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }

  /// Gets the number of days until this date.
  /// 
  /// Returns negative values for dates in the future.
  int get daysUntil => DateTime.now().difference(this).inDays;

  /// Gets the number of hours until this date.
  int get hoursUntil => DateTime.now().difference(this).inHours;
}

/// Extension methods for int to DateTime conversions.
extension FalconToolIntToDateTimeExtensions on int {
  /// Converts Unix timestamp (seconds) to DateTime.
  /// 
  /// Example:
  /// ```dart
  /// 1684156800.fromUnixToDateTime; // 2023-05-15 12:00:00 UTC
  /// ```
  DateTime get fromUnixToDateTime {
    return DateTime.fromMillisecondsSinceEpoch(this * 1000, isUtc: true);
  }

  /// Converts Unix timestamp (seconds) to local DateTime.
  DateTime get fromUnixToLocalDateTime {
    return DateTime.fromMillisecondsSinceEpoch(this * 1000, isUtc: false);
  }

  /// Converts JavaScript timestamp (milliseconds) to DateTime.
  DateTime get fromJsToDateTime {
    return DateTime.fromMillisecondsSinceEpoch(this, isUtc: true);
  }

  /// Converts JavaScript timestamp (milliseconds) to local DateTime.
  DateTime get fromJsToLocalDateTime {
    return DateTime.fromMillisecondsSinceEpoch(this, isUtc: false);
  }
}

/// Extension methods for nullable DateTime handling.
extension FalconToolDateTimeNullExtensions on DateTime? {
  /// Checks if the DateTime is null or in the past.
  bool get isNullOrPast => this == null || this!.isPast;

  /// Checks if the DateTime is null or in the future.
  bool get isNullOrFuture => this == null || this!.isFuture;

  /// Safely formats the DateTime, returning null if null.
  String? format(String pattern, {String? locale}) {
    return this?.format(pattern, locale: locale);
  }

  /// Safely converts to relative time string with localization support.
  String? toRelative({String? locale}) => this?.toRelative(locale: locale);

  /// Returns the DateTime or the current time if null.
  DateTime get orNow => this ?? DateTime.now();

  /// Returns the DateTime or the provided default if null.
  DateTime orDefault(DateTime defaultValue) => this ?? defaultValue;

  /// Safely gets the Unix timestamp.
  int? get toUnixTimestamp => this?.toUnixTimestamp;

  /// Safely calculates the age.
  int? get age => this?.age;
}

/// Extension methods for Duration manipulation.
extension FalconToolDurationExtensions on Duration {
  /// Formats the duration as a human-readable string with localization support.
  /// 
  /// Example:
  /// ```dart
  /// Duration(hours: 2, minutes: 30).toHumanReadable(); // '2h 30m'
  /// Duration(days: 1, hours: 2).toHumanReadable(); // '1d 2h'
  /// ```
  String toHumanReadable({String? locale}) {
    if (locale != null) {
      Intl.defaultLocale = locale;
    }

    final days = inDays;
    final hours = inHours.remainder(24);
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    final parts = <String>[];
    if (days > 0) {
      parts.add(Intl.message('${days}d', 
          name: 'daysShort', args: [days]));
    }
    if (hours > 0) {
      parts.add(Intl.message('${hours}h', 
          name: 'hoursShort', args: [hours]));
    }
    if (minutes > 0) {
      parts.add(Intl.message('${minutes}m', 
          name: 'minutesShort', args: [minutes]));
    }
    if (seconds > 0 || parts.isEmpty) {
      parts.add(Intl.message('${seconds}s', 
          name: 'secondsShort', args: [seconds]));
    }

    return parts.join(' ');
  }

  /// Formats the duration as HH:mm:ss.
  String toTimeString() {
    final hours = inHours.toString().padLeft(2, '0');
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Gets the total number of weeks in the duration.
  /// 
  /// This property is now provided by dartx package (via time package).
  /// Use: duration.inWeeks
  /// 
  /// Example:
  /// ```dart
  /// Duration(days: 14).inWeeks; // 2
  /// ```
  // double get inWeeks => inDays / 7.0;

  /// Gets the total number of years in the duration (approximate).
  double get inYears => inDays / 365.25;

  /// Adds another duration to this one.
  Duration operator +(Duration other) => 
      Duration(microseconds: inMicroseconds + other.inMicroseconds);

  /// Subtracts another duration from this one.
  Duration operator -(Duration other) => 
      Duration(microseconds: inMicroseconds - other.inMicroseconds);

  /// Multiplies the duration by a factor.
  Duration operator *(num factor) => 
      Duration(microseconds: (inMicroseconds * factor).round());

  /// Divides the duration by a factor.
  Duration operator /(num factor) => 
      Duration(microseconds: (inMicroseconds / factor).round());
}

/// Helper class for localizable date/time strings.
/// 
/// This class provides static methods to get localized strings
/// without hardcoding them in the extension methods.
class DateTimeLocalizations {
  /// Gets localized 'Today' string.
  static String today({String? locale}) {
    if (locale != null) {
      Intl.defaultLocale = locale;
    }
    return Intl.message('Today', name: 'today');
  }

  /// Gets localized 'Yesterday' string.
  static String yesterday({String? locale}) {
    if (locale != null) {
      Intl.defaultLocale = locale;
    }
    return Intl.message('Yesterday', name: 'yesterday');
  }

  /// Gets localized 'Tomorrow' string.
  static String tomorrow({String? locale}) {
    if (locale != null) {
      Intl.defaultLocale = locale;
    }
    return Intl.message('Tomorrow', name: 'tomorrow');
  }

  /// Gets localized 'just now' string.
  static String justNow({String? locale}) {
    if (locale != null) {
      Intl.defaultLocale = locale;
    }
    return Intl.message('just now', name: 'justNow');
  }

  /// Gets localized 'in a moment' string.
  static String inAMoment({String? locale}) {
    if (locale != null) {
      Intl.defaultLocale = locale;
    }
    return Intl.message('in a moment', name: 'inAMoment');
  }
}
