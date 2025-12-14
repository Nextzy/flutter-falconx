import 'package:flutter/material.dart';

/// Extension methods for Color manipulation and transformation.
/// Provides utilities for brightening, darkening, blending, and converting
/// colors.
extension FalconToolColorThemeExtensions on Color {
  /// Maximum percentage value for color operations
  static const double _maxPercentage = 100.0;

  /// Default percentage amount for color operations
  static const double _defaultAmount = 10.0;

  /// Maximum RGB channel value
  static const int _maxChannelValue = 255;

  /// Hex string padding length
  static const int _hexPadLength = 8;

  /// RGB hex substring start position
  static const int _rgbHexStart = 2;

  Color applyOpacity(double opacity) {
    return withValues(alpha: a * opacity);
  }

  /// Brightens the color with the given percentage amount.
  ///
  /// [amount] - The percentage to brighten (0-100). Defaults to 10%.
  /// Returns the original color if amount <= 0, white if amount >= 100.
  Color brighten([double amount = _defaultAmount]) {
    if (amount <= 0) return this;
    if (amount >= _maxPercentage) return Colors.white;

    final factor = amount / _maxPercentage;
    final currentR = (r * _maxChannelValue).round();
    final currentG = (g * _maxChannelValue).round();
    final currentB = (b * _maxChannelValue).round();
    final adjustment = (_maxChannelValue * factor).round();

    return Color.fromARGB(
      (a * _maxChannelValue).round(),
      _clampChannel(currentR + adjustment),
      _clampChannel(currentG + adjustment),
      _clampChannel(currentB + adjustment),
    );
  }

  /// Lightens the color with the given percentage amount using HSL color
  /// space.
  ///
  /// [amount] - The percentage to lighten (0-100). Defaults to 10%.
  /// Special handling for black color to maintain greyscale.
  Color lighten([double amount = _defaultAmount]) {
    if (amount <= 0) return this;
    if (amount >= _maxPercentage) return Colors.white;

    // Special handling for black to maintain greyscale
    final hsl = this == Colors.black
        ? HSLColor.fromColor(this).withSaturation(0)
        : HSLColor.fromColor(this);

    final newLightness = (hsl.lightness + amount / _maxPercentage).clamp(
      0.0,
      1.0,
    );
    return hsl.withLightness(newLightness).toColor();
  }

  /// Darkens the color with the given percentage amount using HSL color
  /// space.
  ///
  /// [amount] - The percentage to darken (0-100). Defaults to 10%.
  Color darken([double amount = _defaultAmount]) {
    if (amount <= 0) return this;
    if (amount >= _maxPercentage) return Colors.black;

    final hsl = HSLColor.fromColor(this);
    final newLightness = (hsl.lightness - amount / _maxPercentage).clamp(
      0.0,
      1.0,
    );
    return hsl.withLightness(newLightness).toColor();
  }

  /// Blends the given input color with this color using alpha blending.
  ///
  /// Typically used to create background colors with a hint of a theme
  /// color. This is a wrapper around dart:ui Color.alphaBlend for
  /// convenience.
  ///
  /// [input] - The color to blend into this color.
  /// [amount] - The blend percentage (0-100). Defaults to 10%.
  Color blend(Color input, [double amount = _defaultAmount]) {
    if (amount <= 0) return this;
    if (amount >= _maxPercentage) return input;

    final blendAlpha = (_maxChannelValue * amount / _maxPercentage).round();
    return Color.alphaBlend(input.withAlpha(blendAlpha), this);
  }

  /// Creates a lighter or darker shade of the color.
  ///
  /// Useful for creating gradients or color variations.
  /// Special handling for black and white colors based on parameters.
  ///
  /// [shadeValue] - The percentage to change the shade (0-100).
  ///   Defaults to 15%.
  /// [lighten] - Whether to lighten (true) or darken (false).
  ///   Defaults to true.
  /// [keepBlack] - Preserve black color when lightening. Defaults to true.
  /// [keepWhite] - Preserve white color when darkening. Defaults to true.
  Color getShadeColor({
    double shadeValue = 15.0,
    bool lighten = true,
    bool keepBlack = true,
    bool keepWhite = true,
  }) {
    if (shadeValue <= 0) return this;

    final clampedValue = shadeValue.clamp(0.0, _maxPercentage);

    // Handle black color
    if (this == Colors.black) {
      if (!lighten || keepBlack) return this;
      return this.lighten(clampedValue);
    }

    // Handle white color
    if (this == Colors.white) {
      if (lighten || keepWhite) return this;
      return darken(clampedValue);
    }

    // Handle all other colors
    return lighten ? this.lighten(clampedValue) : darken(clampedValue);
  }

  /// Returns the color as an uppercase 8-character hex string (AARRGGBB).
  ///
  /// This format includes the alpha channel and is commonly used in
  /// Flutter.
  String get hexCode {
    return toARGB32()
        .toRadixString(16)
        .toUpperCase()
        .padLeft(_hexPadLength, '0');
  }

  /// Returns the color as an uppercase RGB hex string with # prefix
  /// (#RRGGBB).
  ///
  /// This format excludes the alpha channel and is commonly used in CSS and
  /// web APIs.
  String get hex {
    final fullHex = toARGB32()
        .toRadixString(16)
        .toUpperCase()
        .padLeft(_hexPadLength, '0');
    return '#${fullHex.substring(_rgbHexStart)}';
  }

  /// Helper method to clamp RGB channel values between 0 and 255.
  int _clampChannel(int value) => value.clamp(0, _maxChannelValue);

  /// Checks if the color is considered light based on its brightness.
  ///
  /// Uses the computeLuminance() method to determine if the color has
  /// a light brightness (luminance > 0.5).
  bool get isLight => computeLuminance() > 0.5;

  /// Checks if the color is considered dark based on its brightness.
  ///
  /// Uses the computeLuminance() method to determine if the color has
  /// a dark brightness (luminance <= 0.5).
  bool get isDark => computeLuminance() <= 0.5;

  /// Gets the brightness level of the color.
  ///
  /// Returns Brightness.light if the color is light (luminance > 0.5),
  /// otherwise returns Brightness.dark.
  Brightness get brightness => isLight ? Brightness.light : Brightness.dark;

  /// Gets the inverse brightness of the color.
  ///
  /// Returns Brightness.dark if the color is light,
  /// otherwise returns Brightness.light.
  /// Useful for determining contrasting text or icon colors.
  Brightness get inverseBrightness =>
      isLight ? Brightness.dark : Brightness.light;
}

/// Extension methods for String manipulation in theme context.
///
/// Provides utilities for color conversion and string formatting.
extension FalconToolStringThemeExtensions on String {
  /// Default color returned when parsing fails
  static const Color _defaultColor = Color(0xFF000000);

  /// Minimum hex color length (without alpha)
  static const int _minHexLength = 6;

  /// Full hex color length (with alpha)
  static const int _fullHexLength = 8;

  /// Converts a hex-encoded color string to a Color object.
  ///
  /// Accepts various formats:
  /// - With or without '#' prefix: #RRGGBB, RRGGBB
  /// - With or without '0x' prefix: 0xRRGGBB, RRGGBB
  /// - RGB format (6 chars): RRGGBB (defaults to FF for alpha)
  /// - ARGB format (8 chars): AARRGGBB (Flutter format)
  /// - RGBA format (8 chars): RRGGBBAA (CSS format, converted to ARGB)
  /// - Examples: "#000000FF" (opaque black), "#00000024" (14% opacity)
  /// - Strings longer than 8 characters are right-truncated
  ///
  /// Returns opaque black (0xFF000000) if parsing fails or string is empty.
  Color get toColor {
    if (isEmpty) return _defaultColor;

    // Check if it starts with '0x' or '0X' (Flutter format - definitely ARGB)
    final isFlutterFormat = startsWith('0x') || startsWith('0X');

    // Remove common prefixes
    final cleanHex = replaceAll(
      '#',
      '',
    ).replaceAll('0x', '').replaceAll('0X', '');

    // Handle different hex length formats
    String finalHex;

    if (cleanHex.length <= _minHexLength) {
      // Short format (6 or fewer chars): RGB format
      // Pad RGB to 6 chars, then add FF for full opacity
      final paddedRgb = cleanHex.padLeft(_minHexLength, '0');
      finalHex = 'FF$paddedRgb';
    } else if (cleanHex.length == _fullHexLength) {
      // 8 chars: Could be AARRGGBB or RRGGBBAA format
      if (isFlutterFormat) {
        // Flutter format (0x prefix) is always AARRGGBB
        finalHex = cleanHex;
      } else {
        // Heuristic to distinguish AARRGGBB from RRGGBBAA
        final last2 = cleanHex.substring(6, 8);
        final lastValue = int.tryParse(last2, radix: 16) ?? 255;

        // If last 2 bytes suggest a partial opacity (not FF and not 00),
        // treat as RRGGBBAA format
        if (lastValue < 0xFF && lastValue > 0x00) {
          // RRGGBBAA: move alpha from end to beginning
          final rgb = cleanHex.substring(0, 6);
          final alpha = cleanHex.substring(6, 8);
          finalHex = '$alpha$rgb';
        } else {
          // AARRGGBB format (or ambiguous case, default to ARGB)
          finalHex = cleanHex;
        }
      }
    } else if (cleanHex.length > _fullHexLength) {
      // Too long: take last 8 characters
      finalHex = cleanHex.substring(cleanHex.length - _fullHexLength);
    } else {
      // 7 chars: treat as RGB with partial alpha, pad to 8
      finalHex = cleanHex.padLeft(_fullHexLength, 'F');
    }

    return Color(int.tryParse('0x$finalHex') ?? _defaultColor.toARGB32());
  }

  /// Capitalizes the first letter of the string.
  ///
  /// Returns the string unchanged if empty, or fully uppercase if single
  /// character.
  String get capitalize {
    if (isEmpty) return this;
    if (length == 1) return toUpperCase();
    return this[0].toUpperCase() + substring(1);
  }
}

extension FalconToolBrightnessExtensions on Brightness {
  ThemeMode get theme =>
      this == Brightness.light ? ThemeMode.light : ThemeMode.dark;
}
