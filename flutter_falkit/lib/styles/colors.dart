import 'package:flutter_falkit/lib.dart';

/// Abstract base class for color palettes following Material Design 3
/// color system with enhanced transparency support.
/// 
/// Provides a comprehensive set of color shades from light (c25) to dark (c975)
/// plus a transparent palette for alpha channel manipulation.
abstract class PaletteColor {
  const PaletteColor({
    required this.c25,
    required this.c50,
    required this.c100,
    required this.c200,
    required this.c300,
    required this.c400,
    required this.c500,
    required this.c600,
    required this.c700,
    required this.c800,
    required this.c900,
    required this.c950,
    required this.c975,
    required this.transparent,
  });

  /// Lightest shade (typically for backgrounds)
  final Color c25;
  /// Very light shade
  final Color c50;
  /// Light shade
  final Color c100;
  /// Light-medium shade
  final Color c200;
  /// Medium-light shade
  final Color c300;
  /// Medium shade
  final Color c400;
  /// Base/primary shade (most commonly used)
  final Color c500;
  /// Medium-dark shade
  final Color c600;
  /// Dark shade
  final Color c700;
  /// Very dark shade
  final Color c800;
  /// Darkest shade
  final Color c900;
  /// Ultra dark shade
  final Color c950;
  /// Maximum dark shade (typically for text on light backgrounds)
  final Color c975;
  /// Transparent variations of the base color
  final TransparentPalette transparent;
}

/// Provides transparent variations of a color with predefined alpha values.
/// 
/// Useful for creating overlays, shadows, and semi-transparent UI elements.
/// All percentages represent alpha opacity 
/// (p100 = fully opaque, p0 = fully transparent).
class TransparentPalette {
  const TransparentPalette(this.color);

  /// The base color for transparency variations
  final Color color;

  Color get p0 => color.withValues(alpha: 0.0);

  Color get p1 => color.withValues(alpha: 0.01);

  Color get p2 => color.withValues(alpha: 0.02);

  Color get p3 => color.withValues(alpha: 0.03);

  Color get p4 => color.withValues(alpha: 0.04);

  Color get p5 => color.withValues(alpha: 0.05);

  Color get p6 => color.withValues(alpha: 0.06);

  Color get p8 => color.withValues(alpha: 0.08);

  Color get p10 => color.withValues(alpha: 0.10);

  Color get p12 => color.withValues(alpha: 0.12);

  Color get p14 => color.withValues(alpha: 0.14);

  Color get p16 => color.withValues(alpha: 0.16);

  Color get p18 => color.withValues(alpha: 0.18);

  Color get p20 => color.withValues(alpha: 0.20);

  Color get p24 => color.withValues(alpha: 0.24);

  Color get p30 => color.withValues(alpha: 0.30);

  Color get p40 => color.withValues(alpha: 0.40);

  Color get p50 => color.withValues(alpha: 0.50);

  Color get p60 => color.withValues(alpha: 0.60);

  Color get p70 => color.withValues(alpha: 0.70);

  Color get p80 => color.withValues(alpha: 0.80);

  Color get p90 => color.withValues(alpha: 0.90);

  Color get p96 => color.withValues(alpha: 0.96);

  Color get p98 => color.withValues(alpha: 0.98);

  Color get p100 => color.withValues(alpha: 1.0);

}
