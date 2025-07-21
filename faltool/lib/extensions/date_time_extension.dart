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

  /// Gets the end of the day (23:59:59.999).
  /// 
  /// Example:
  /// ```dart
  /// DateTime(2023, 5, 15, 14, 30).endOfDay; // 2023-05-15 23:59:59.999
  /// ```
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

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
    final firstDayOfYear = DateTime(year, 1, 1);
    final daysSinceFirstDay = difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday - 1) / 7).ceil();
  }

  /// Gets the number of days in the current month.
  int get daysInMonth => DateTime(year, month + 1, 0).day;

  /// Checks if the year is a leap year.
  bool get isLeapYear =>
      (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);

  // Comparison Methods

  /// Checks if this date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Checks if this date is yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Checks if this date is tomorrow.
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Checks if this date is in the past.
  bool get isPast => isBefore(DateTime.now());

  /// Checks if this date is in the future.
  bool get isFuture => isAfter(DateTime.now());

  /// Checks if this date is on a weekend.
  bool get isWeekend => 
      weekday == DateTime.saturday || weekday == DateTime.sunday;

  /// Checks if this date is on a weekday.
  bool get isWeekday => !isWeekend;

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

  // Date Calculations

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

  /// Copies the DateTime with optional parameter changes.
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
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
    final now = DateTime.now();
    final difference = now.difference(this);
    final isInPast = !difference.isNegative;
    final duration = difference.abs();

    // Use intl package for localized relative time
    if (locale != null) {
      Intl.defaultLocale = locale;
    }

    if (duration.inSeconds < 60) {
      return isInPast 
          ? Intl.message('just now', name: 'justNow')
          : Intl.message('in a moment', name: 'inAMoment');
    } else if (duration.inMinutes < 60) {
      final minutes = duration.inMinutes;
      return isInPast
          ? Intl.plural(minutes,
              one: '$minutes minute ago',
              other: '$minutes minutes ago',
              name: 'minutesAgo',
              args: [minutes])
          : Intl.plural(minutes,
              one: 'in $minutes minute',
              other: 'in $minutes minutes',
              name: 'inMinutes',
              args: [minutes]);
    } else if (duration.inHours < 24) {
      final hours = duration.inHours;
      return isInPast
          ? Intl.plural(hours,
              one: '$hours hour ago',
              other: '$hours hours ago',
              name: 'hoursAgo',
              args: [hours])
          : Intl.plural(hours,
              one: 'in $hours hour',
              other: 'in $hours hours',
              name: 'inHours',
              args: [hours]);
    } else if (duration.inDays < 7) {
      final days = duration.inDays;
      return isInPast
          ? Intl.plural(days,
              one: '$days day ago',
              other: '$days days ago',
              name: 'daysAgo',
              args: [days])
          : Intl.plural(days,
              one: 'in $days day',
              other: 'in $days days',
              name: 'inDays',
              args: [days]);
    } else if (duration.inDays < 30) {
      final weeks = (duration.inDays / 7).round();
      return isInPast
          ? Intl.plural(weeks,
              one: '$weeks week ago',
              other: '$weeks weeks ago',
              name: 'weeksAgo',
              args: [weeks])
          : Intl.plural(weeks,
              one: 'in $weeks week',
              other: 'in $weeks weeks',
              name: 'inWeeks',
              args: [weeks]);
    } else if (duration.inDays < 365) {
      final months = (duration.inDays / 30).round();
      return isInPast
          ? Intl.plural(months,
              one: '$months month ago',
              other: '$months months ago',
              name: 'monthsAgo',
              args: [months])
          : Intl.plural(months,
              one: 'in $months month',
              other: 'in $months months',
              name: 'inMonths',
              args: [months]);
    } else {
      final years = (duration.inDays / 365).round();
      return isInPast
          ? Intl.plural(years,
              one: '$years year ago',
              other: '$years years ago',
              name: 'yearsAgo',
              args: [years])
          : Intl.plural(years,
              one: 'in $years year',
              other: 'in $years years',
              name: 'inYears',
              args: [years]);
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
  /// Returns negative values for dates in the past.
  int get daysUntil => difference(DateTime.now()).inDays;

  /// Gets the number of hours until this date.
  int get hoursUntil => difference(DateTime.now()).inHours;
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
  double get inWeeks => inDays / 7;

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
