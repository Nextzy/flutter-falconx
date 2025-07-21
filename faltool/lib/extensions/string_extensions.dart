import 'package:faltool/lib.dart';


/// Extension methods for String manipulation and validation.
/// 
/// Provides comprehensive string utilities including conversions, validations,
/// formatting, and transformations.
extension FalconToolStringExtension on String {
  /// URL validation pattern that matches http and https URLs.
  static final _urlRegex = RegExp(
    '^(https?|http)://([-A-Z0-9.]+)'
    '(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?'
    r'(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?$',
    caseSensitive: false,
  );

  /// Email validation pattern (RFC 5322 simplified).
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Whitespace and Formatting

  /// Removes all whitespace characters from the string.
  /// 
  /// Example:
  /// ```dart
  /// 'hello world'.removeWhiteSpace; // 'helloworld'
  /// '  tab\tspace\n '.removeWhiteSpace; // 'tabspace'
  /// ```
  String get removeWhiteSpace => replaceAll(RegExp(r'\s+'), '');

  /// Removes leading and trailing whitespace and collapses internal whitespace.
  /// 
  /// Example:
  /// ```dart
  /// '  hello   world  '.normalizeWhitespace; // 'hello world'
  /// ```
  String get normalizeWhitespace => trim().replaceAll(RegExp(r'\s+'), ' ');

  // isBlank and isNotBlank are now provided by dartx package.
  // Use: string.isBlank and string.isNotBlank

  // Validation Methods

  /// Returns true if the string is a valid URL.
  /// 
  /// Validates against http and https protocols.
  /// 
  /// Example:
  /// ```dart
  /// 'https://example.com'.isUrl; // true
  /// 'not a url'.isUrl; // false
  /// ```
  bool get isUrl => _urlRegex.hasMatch(this);

  /// Returns true if the string is not a valid URL.
  bool get isNotUrl => !isUrl;

  /// Returns true if the string is a valid email address.
  /// 
  /// Example:
  /// ```dart
  /// 'user@example.com'.isEmail; // true
  /// 'invalid.email'.isEmail; // false
  /// ```
  bool get isEmail => _emailRegex.hasMatch(this);

  /// Returns true if the string is not a valid email address.
  bool get isNotEmail => !isEmail;

  /// Returns true if the string contains only numeric characters.
  /// 
  /// Allows optional leading minus sign and decimal point.
  /// 
  /// Example:
  /// ```dart
  /// '123'.isNumeric; // true
  /// '-45.67'.isNumeric; // true
  /// 'abc123'.isNumeric; // false
  /// ```
  bool get isNumeric => RegExp(r'^-?\d*\.?\d+$').hasMatch(this);

  /// Returns true if the string is valid JSON.
  /// 
  /// Example:
  /// ```dart
  /// '{"key": "value"}'.isJson; // true
  /// 'not json'.isJson; // false
  /// ```
  bool get isJson {
    try {
      json.decode(this);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Returns true if the string is not valid JSON.
  bool get isNotJson => !isJson;

  // Conversion Methods

  // toInt() and toIntOrNull() are now provided by dartx package.
  // Use: string.toInt() and string.toIntOrNull()

  /// Converts the string to an integer, returning 0 if parsing fails.
  /// 
  /// Removes whitespace before parsing.
  /// 
  /// Example:
  /// ```dart
  /// ' 123 '.toIntOrZero(); // 123
  /// 'abc'.toIntOrZero(); // 0
  /// ```
  int toIntOrZero() {
    final cleaned = removeWhiteSpace;
    if (cleaned.isEmpty) return 0;
    return int.tryParse(cleaned) ?? 0;
  }

  // toDouble() and toDoubleOrNull() are now provided by dartx package.
  // Use: string.toDouble() and string.toDoubleOrNull()

  /// Converts the string to a double, returning 0.0 if parsing fails.
  double toDoubleOrZero() => double.tryParse(this) ?? 0.0;

  /// Converts the string to a boolean value.
  /// 
  /// Returns true for 'true' or '1', false for 'false' or '0'.
  /// Throws [UnsupportedError] for other values.
  /// 
  /// Example:
  /// ```dart
  /// 'true'.toBoolean(); // true
  /// '1'.toBoolean(); // true
  /// 'false'.toBoolean(); // false
  /// 'maybe'.toBoolean(); // throws UnsupportedError
  /// ```
  bool toBoolean() {
    final lower = toLowerCase();
    if (lower == 'true' || lower == '1') return true;
    if (lower == 'false' || lower == '0') return false;
    throw UnsupportedError('Cannot convert "$this" to boolean');
  }

  /// Converts the string to a boolean, returning null if conversion fails.
  /// 
  /// Example:
  /// ```dart
  /// 'true'.toBooleanOrNull(); // true
  /// 'maybe'.toBooleanOrNull(); // null
  /// ```
  bool? toBooleanOrNull() {
    final lower = toLowerCase();
    if (lower == 'true' || lower == '1') return true;
    if (lower == 'false' || lower == '0') return false;
    return null;
  }

  /// Parses the string as JSON and returns a Map.
  /// 
  /// Throws [FormatException] if the string is not valid JSON.
  /// 
  /// Example:
  /// ```dart
  /// '{"key": "value"}'.toMap(); // {'key': 'value'}
  /// ```
  Map<String, dynamic> toMap() {
    try {
      final decoded = json.decode(this);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw FormatException('JSON is not a Map: $this');
    } catch (e) {
      throw FormatException('Invalid JSON: $e');
    }
  }

  /// Parses the string as JSON and returns a Map, or null if parsing fails.
  Map<String, dynamic>? toMapOrNull() {
    try {
      final decoded = json.decode(this);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  /// Parses the string as JSON and returns a Map,
  /// or empty map if parsing fails.
  Map<String, dynamic> toMapOrEmpty() => toMapOrNull() ?? {};

  /// Encodes the string to base64.
  /// 
  /// Example:
  /// ```dart
  /// 'Hello'.toBase64(); // 'SGVsbG8='
  /// ```
  String toBase64() => base64.encode(utf8.encode(this));

  /// Decodes the string from base64.
  /// 
  /// Throws [FormatException] if the string is not valid base64.
  /// 
  /// Example:
  /// ```dart
  /// 'SGVsbG8='.fromBase64(); // 'Hello'
  /// ```
  String fromBase64() => utf8.decode(base64.decode(this));

  /// Converts the string to bytes using UTF-8 encoding.
  Uint8List toBytes() => Uint8List.fromList(utf8.encode(this));

  // Case Conversions

  /// Converts the string to camelCase.
  /// 
  /// Example:
  /// ```dart
  /// 'hello_world'.toCamelCase(); // 'helloWorld'
  /// 'HELLO-WORLD'.toCamelCase(); // 'helloWorld'
  /// ```
  String toCamelCase() {
    final words = split(RegExp(r'[_\-\s]+'));
    if (words.isEmpty) return this;
    
    return words.first.toLowerCase() + 
           words.skip(1).map((w) => w.capitalize).join();
  }

  /// Converts the string to snake_case.
  /// 
  /// Example:
  /// ```dart
  /// 'helloWorld'.toSnakeCase(); // 'hello_world'
  /// 'HelloWorld'.toSnakeCase(); // 'hello_world'
  /// ```
  String toSnakeCase() {
    return replaceAllMapped(
      RegExp('[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceAll(RegExp('^_'), '').replaceAll(RegExp(r'[\s\-]+'), '_');
  }

  /// Converts the string to PascalCase.
  /// 
  /// Example:
  /// ```dart
  /// 'hello_world'.toPascalCase(); // 'HelloWorld'
  /// 'hello-world'.toPascalCase(); // 'HelloWorld'
  /// ```
  String toPascalCase() {
    final words = split(RegExp(r'[_\-\s]+'));
    return words.map((w) => w.capitalize).join();
  }

  /// Converts the string to kebab-case.
  /// 
  /// Example:
  /// ```dart
  /// 'helloWorld'.toKebabCase(); // 'hello-world'
  /// 'HelloWorld'.toKebabCase(); // 'hello-world'
  /// ```
  String toKebabCase() => toSnakeCase().replaceAll('_', '-');

  // String Manipulation

  // capitalize is now provided by dartx package.
  // Use: string.capitalize()

  /// Capitalizes the first letter of each word.
  /// 
  /// Example:
  /// ```dart
  /// 'hello world'.capitalizeWords(); // 'Hello World'
  /// ```
  String capitalizeWords() {
    return split(' ').map((word) => word.isEmpty ? word : word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  /// Reverses the string.
  /// 
  /// This method is now provided by dartx package.
  /// Use: string.reversed
  /// 
  /// Example:
  /// ```dart
  /// 'hello'.reversed; // 'olleh'
  /// ```
  String reverse() => split('').reversed.join();

  /// Truncates the string to the specified length.
  /// 
  /// [length] - Maximum length of the result
  /// [ellipsis] - String to append if truncated (default: '...')
  /// 
  /// Example:
  /// ```dart
  /// 'Hello World'.truncate(8); // 'Hello...'
  /// 'Hello World'.truncate(8, ellipsis: '~'); // 'Hello W~'
  /// ```
  String truncate(int length, {String ellipsis = '...'}) {
    if (this.length <= length) return this;
    if (length <= ellipsis.length) return ellipsis.substring(0, length);
    return substring(0, length - ellipsis.length) + ellipsis;
  }

  /// Removes the protocol (http:// or https://) from the URL.
  /// 
  /// Example:
  /// ```dart
  /// 'https://example.com'.removeHttp; // 'example.com'
  /// 'http://example.com'.removeHttp; // 'example.com'
  /// ```
  String get removeHttp => replaceFirst(RegExp('^https?://'), '');

  /// Returns true if the string contains the pattern (case-insensitive).
  /// 
  /// Example:
  /// ```dart
  /// 'Hello World'.containsIgnoreCase('WORLD'); // true
  /// ```
  bool containsIgnoreCase(String pattern) {
    return toLowerCase().contains(pattern.toLowerCase());
  }

  /// Counts occurrences of a pattern in the string.
  /// 
  /// Example:
  /// ```dart
  /// 'hello hello world'.countOccurrences('hello'); // 2
  /// ```
  int countOccurrences(String pattern) {
    if (pattern.isEmpty) return 0;
    return split(pattern).length - 1;
  }

  /// Escapes HTML special characters.
  /// 
  /// Example:
  /// ```dart
  /// '<div>Hello</div>'.escapeHtml(); // '&lt;div&gt;Hello&lt;/div&gt;'
  /// ```
  String escapeHtml() {
    return replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  /// Unescapes HTML special characters.
  /// 
  /// Example:
  /// ```dart
  /// '&lt;div&gt;'.unescapeHtml(); // '<div>'
  /// ```
  String unescapeHtml() {
    return replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }
}

/// Extension methods for nullable String manipulation and validation.
extension FalconStringNullExtension on String? {

  /// Returns the string or the default value if null.
  String orEmpty() => this ?? '';

  /// Returns the string or the provided default value if null.
  String or(String defaultValue) => this ?? defaultValue;

  /// Safely converts to integer with null safety.
  int? toIntOrNull() => this == null ? null : int.tryParse(this!);

  /// Safely converts to integer, returning 0 for null or invalid values.
  int toIntOrZero() => this?.toIntOrZero() ?? 0;

  /// Safely converts to double with null safety.
  double? toDoubleOrNull() => this == null ? null : double.tryParse(this!);

  /// Safely converts to double, returning 0.0 for null or invalid values.
  double toDoubleOrZero() => this?.toDoubleOrZero() ?? 0.0;

  /// Safely checks if the string is a valid URL.
  bool get isUrl => this?.isUrl ?? false;

  /// Safely checks if the string is a valid email.
  bool get isEmail => this?.isEmail ?? false;

  /// Safely checks if the string is valid JSON.
  bool get isJson => this?.isJson ?? false;

  /// Safely converts to boolean with null safety.
  bool? toBooleanOrNull() => this?.toBooleanOrNull();

  /// Safely converts to Map with null safety.
  Map<String, dynamic>? toMapOrNull() => this?.toMapOrNull();

  /// Safely converts to Map, returning empty map for null or invalid values.
  Map<String, dynamic> toMapOrEmpty() => this?.toMapOrEmpty() ?? {};

  /// Safely removes whitespace.
  String? get removeWhiteSpace => this?.removeWhiteSpace;

  /// Safely normalizes whitespace.
  String? get normalizeWhitespace => this?.normalizeWhitespace;

  /// Safely capitalizes the string.
  String? get capitalize => this == null || this!.isEmpty ? this : this![0].toUpperCase() + this!.substring(1);

  /// Safely truncates the string.
  String? truncate(int length, {String ellipsis = '...'}) =>
      this?.truncate(length, ellipsis: ellipsis);
}
