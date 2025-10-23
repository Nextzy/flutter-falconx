import 'package:flutter_falkit/extensions/color_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FalconToolColorThemeExtensions', () {
    group('brighten', () {
      test('should brighten color by default 10%', () {
        const baseColor = Color(0xFF0000FF); // Pure blue
        final brightened = baseColor.brighten();

        // Should be brighter than original
        expect((brightened.r * 255).round(),
            greaterThan((baseColor.r * 255).round()));
        expect((brightened.g * 255).round(),
            greaterThan((baseColor.g * 255).round()));
        expect(
            (brightened.b * 255).round(), equals(255)); // Blue already at max
      });

      test('should brighten color by specified amount', () {
        const baseColor = Color(0xFF808080); // Medium gray
        final brightened30 = baseColor.brighten(30);
        final brightened50 = baseColor.brighten(50);

        // More brightening should result in lighter color
        expect(brightened50.red, greaterThan(brightened30.red));
        expect(brightened50.green, greaterThan(brightened30.green));
        expect(brightened50.blue, greaterThan(brightened30.blue));
      });

      test('should return white when amount >= 100', () {
        const baseColor = Color(0xFF123456);
        expect(baseColor.brighten(100), equals(Colors.white));
        expect(baseColor.brighten(150), equals(Colors.white));
      });

      test('should return original color when amount <= 0', () {
        const baseColor = Color(0xFF123456);
        expect(baseColor.brighten(0), equals(baseColor));
        expect(baseColor.brighten(-10), equals(baseColor));
      });

      test('should preserve alpha channel', () {
        const baseColor = Color(0x80FF0000); // Semi-transparent red
        final brightened = baseColor.brighten(20);
        expect(brightened.alpha, equals(baseColor.alpha));
      });
    });

    group('lighten', () {
      test('should lighten color by default 10% using HSL', () {
        const baseColor = Color(0xFF0000FF); // Pure blue
        final lightened = baseColor.lighten();

        // Check that HSL lightness increased
        final originalHSL = HSLColor.fromColor(baseColor);
        final lightenedHSL = HSLColor.fromColor(lightened);
        expect(lightenedHSL.lightness, greaterThan(originalHSL.lightness));
      });

      test('should handle black color specially to maintain greyscale', () {
        const black = Colors.black;
        final lightened = black.lighten(50);

        // Should produce a grey color (equal RGB values)
        expect(lightened.red, equals(lightened.green));
        expect(lightened.green, equals(lightened.blue));
        expect(lightened.red, greaterThan(0));
      });

      test('should return white when amount >= 100', () {
        const baseColor = Color(0xFF123456);
        expect(baseColor.lighten(100), equals(Colors.white));
        expect(baseColor.lighten(150), equals(Colors.white));
      });

      test('should return original color when amount <= 0', () {
        const baseColor = Color(0xFF123456);
        expect(baseColor.lighten(0), equals(baseColor));
        expect(baseColor.lighten(-10), equals(baseColor));
      });
    });

    group('darken', () {
      test('should darken color by default 10% using HSL', () {
        const baseColor = Color(0xFF8080FF); // Light blue
        final darkened = baseColor.darken();

        // Check that HSL lightness decreased
        final originalHSL = HSLColor.fromColor(baseColor);
        final darkenedHSL = HSLColor.fromColor(darkened);
        expect(darkenedHSL.lightness, lessThan(originalHSL.lightness));
      });

      test('should return black when amount >= 100', () {
        const baseColor = Color(0xFF123456);
        expect(baseColor.darken(100), equals(Colors.black));
        expect(baseColor.darken(150), equals(Colors.black));
      });

      test('should return original color when amount <= 0', () {
        const baseColor = Color(0xFF123456);
        expect(baseColor.darken(0), equals(baseColor));
        expect(baseColor.darken(-10), equals(baseColor));
      });

      test('should properly darken white color', () {
        const white = Colors.white;
        final darkened = white.darken(20);

        expect(darkened.red, lessThan(255));
        expect(darkened.green, lessThan(255));
        expect(darkened.blue, lessThan(255));
        // Should maintain greyscale
        expect(darkened.red, equals(darkened.green));
        expect(darkened.green, equals(darkened.blue));
      });
    });

    group('blend', () {
      test('should blend colors by default 10%', () {
        const baseColor = Colors.white;
        const blendColor = Color(0xFF0000FF); // Pure blue
        final blended = baseColor.blend(blendColor);

        // Should have some blue component
        expect((blended.b * 255).round(), equals(255)); // Blue stays max
        expect((blended.r * 255).round(), lessThan(255)); // Red reduced
        expect((blended.g * 255).round(), lessThan(255)); // Green reduced
      });

      test('should return input color when amount >= 100', () {
        const baseColor = Colors.white;
        const blendColor = Colors.blue;
        expect(baseColor.blend(blendColor, 100), equals(blendColor));
        expect(baseColor.blend(blendColor, 150), equals(blendColor));
      });

      test('should return base color when amount <= 0', () {
        const baseColor = Colors.white;
        const blendColor = Colors.blue;
        expect(baseColor.blend(blendColor, 0), equals(baseColor));
        expect(baseColor.blend(blendColor, -10), equals(baseColor));
      });

      test('should blend colors proportionally', () {
        const baseColor = Color(0xFFFFFFFF); // White
        const blendColor = Color(0xFF0000FF); // Blue

        final blend25 = baseColor.blend(blendColor, 25);
        final blend50 = baseColor.blend(blendColor, 50);

        // More blending should result in more blue
        expect(blend50.blue, equals(blend25.blue));
        expect(blend50.red, lessThan(blend25.red));
        expect(blend50.green, lessThan(blend25.green));
      });
    });

    group('getShadeColor', () {
      test('should lighten color by default', () {
        const baseColor = Color(0xFF0000FF);
        final shaded = baseColor.getShadeColor();

        final originalHSL = HSLColor.fromColor(baseColor);
        final shadedHSL = HSLColor.fromColor(shaded);
        expect(shadedHSL.lightness, greaterThan(originalHSL.lightness));
      });

      test('should darken color when lighten is false', () {
        const baseColor = Color(0xFF8080FF);
        final shaded = baseColor.getShadeColor(lighten: false);

        final originalHSL = HSLColor.fromColor(baseColor);
        final shadedHSL = HSLColor.fromColor(shaded);
        expect(shadedHSL.lightness, lessThan(originalHSL.lightness));
      });

      test('should keep black when keepBlack is true and lightening', () {
        const black = Colors.black;
        final shaded = black.getShadeColor(lighten: true, keepBlack: true);
        expect(shaded, equals(black));
      });

      test('should lighten black when keepBlack is false', () {
        const black = Colors.black;
        final shaded = black.getShadeColor(lighten: true, keepBlack: false);
        expect(shaded, isNot(equals(black)));
        expect(shaded.red, greaterThan(0));
      });

      test('should keep white when keepWhite is true and darkening', () {
        const white = Colors.white;
        final shaded = white.getShadeColor(lighten: false, keepWhite: true);
        expect(shaded, equals(white));
      });

      test('should darken white when keepWhite is false', () {
        const white = Colors.white;
        final shaded = white.getShadeColor(lighten: false, keepWhite: false);
        expect(shaded, isNot(equals(white)));
        expect(shaded.red, lessThan(255));
      });

      test('should return original color when shadeValue <= 0', () {
        const baseColor = Color(0xFF123456);
        expect(baseColor.getShadeColor(shadeValue: 0), equals(baseColor));
        expect(baseColor.getShadeColor(shadeValue: -10), equals(baseColor));
      });

      test('should clamp shadeValue to 100', () {
        const baseColor = Color(0xFF808080);
        final shaded150 = baseColor.getShadeColor(shadeValue: 150);
        final shaded100 = baseColor.getShadeColor(shadeValue: 100);

        // Should produce same result
        expect(shaded150, equals(shaded100));
      });
    });

    group('hexCode', () {
      test('should return 8-character uppercase hex string', () {
        const color = Color(0xFF123456);
        expect(color.hexCode, equals('FF123456'));
        expect(color.hexCode.length, equals(8));
      });

      test('should include alpha channel', () {
        const color = Color(0x80123456);
        expect(color.hexCode, equals('80123456'));
      });

      test('should pad with zeros if needed', () {
        const color = Color(0x00000001);
        expect(color.hexCode, equals('00000001'));
      });
    });

    group('hex', () {
      test('should return CSS-style hex string with # prefix', () {
        const color = Color(0xFF123456);
        expect(color.hex, equals('#123456'));
        expect(color.hex.startsWith('#'), isTrue);
      });

      test('should exclude alpha channel', () {
        const color = Color(0x80123456);
        expect(color.hex, equals('#123456'));
        expect(color.hex.length, equals(7)); // # + 6 chars
      });

      test('should handle pure colors correctly', () {
        // Material colors are not pure RGB values
        expect(const Color(0xFFFF0000).hex, equals('#FF0000'));
        expect(const Color(0xFF00FF00).hex, equals('#00FF00'));
        expect(const Color(0xFF0000FF).hex, equals('#0000FF'));
        expect(Colors.white.hex, equals('#FFFFFF'));
        expect(Colors.black.hex, equals('#000000'));
      });
    });
  });

  group('FalconToolStringThemeExtensions', () {
    group('toColor', () {
      test('should convert CSS hex format', () {
        expect('#FF0000'.toColor, equals(const Color(0xFFFF0000)));
        expect('#00FF00'.toColor, equals(const Color(0xFF00FF00)));
        expect('#0000FF'.toColor, equals(const Color(0xFF0000FF)));
      });

      test('should convert hex without # prefix', () {
        expect('FF0000'.toColor, equals(const Color(0xFFFF0000)));
        expect('00FF00'.toColor, equals(const Color(0xFF00FF00)));
      });

      test('should convert Flutter hex format', () {
        expect('0xFF123456'.toColor, equals(const Color(0xFF123456)));
        expect('0xff123456'.toColor, equals(const Color(0xFF123456)));
      });

      test('should handle alpha channel', () {
        expect('80FF0000'.toColor, equals(const Color(0x80FF0000)));
        expect('#80FF0000'.toColor, equals(const Color(0x80FF0000)));
      });

      test('should add default alpha (FF) if missing', () {
        expect('123456'.toColor, equals(const Color(0xFF123456)));
        expect('#123456'.toColor, equals(const Color(0xFF123456)));
      });

      test('should pad short hex strings', () {
        // Short strings are left-padded with zeros
        expect('F00'.toColor, equals(const Color(0xFF000F00)));
        expect('0F0'.toColor, equals(const Color(0xFF0000F0)));
        expect('00F'.toColor, equals(const Color(0xFF00000F)));
      });

      test('should truncate long hex strings', () {
        expect('FF112233445566'.toColor, equals(const Color(0x33445566)));
        expect('AABBCCDDEEFF1122'.toColor, equals(const Color(0xEEFF1122)));
      });

      test('should return black for invalid input', () {
        expect(''.toColor, equals(const Color(0xFF000000)));
        expect('invalid'.toColor, equals(const Color(0xFF000000)));
        expect('GGHHII'.toColor, equals(const Color(0xFF000000)));
      });

      test('should handle mixed case', () {
        expect('FfAaBb'.toColor, equals(const Color(0xFFFFAABB)));
        expect('#fFaAbB'.toColor, equals(const Color(0xFFFFAABB)));
      });
    });

    group('capitalize', () {
      test('should capitalize first letter', () {
        expect('hello'.capitalize, equals('Hello'));
        expect('world'.capitalize, equals('World'));
        expect('flutter'.capitalize, equals('Flutter'));
      });

      test('should handle single character strings', () {
        expect('a'.capitalize, equals('A'));
        expect('z'.capitalize, equals('Z'));
        expect('1'.capitalize, equals('1'));
      });

      test('should handle empty strings', () {
        expect(''.capitalize, equals(''));
      });

      test('should preserve rest of string', () {
        expect('hELLO'.capitalize, equals('HELLO'));
        expect('wORLD'.capitalize, equals('WORLD'));
      });

      test('should handle already capitalized strings', () {
        expect('Hello'.capitalize, equals('Hello'));
        expect('WORLD'.capitalize, equals('WORLD'));
      });

      test('should handle strings with numbers and symbols', () {
        expect('123abc'.capitalize, equals('123abc'));
        expect('_test'.capitalize, equals('_test'));
        expect('primaryColor'.capitalize, equals('PrimaryColor'));
      });
    });
  });
}
