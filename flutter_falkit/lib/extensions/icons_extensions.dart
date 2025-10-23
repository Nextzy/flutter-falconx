// Ignore because is not necessary
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package

import 'package:flutter_falkit/lib.dart';

extension SvgIcons on String? {
  Widget toSvg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    SvgTheme? theme,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @Deprecated('Use colorFilter instead.') Color? color,
    @Deprecated('Use colorFilter instead.')
    BlendMode colorBlendMode = BlendMode.srcIn,
    @Deprecated('This no longer does anything.') bool cacheColorFilter = false,
  }) {
    if (this == null) return const SizedBox.shrink();

    return SvgPicture.asset(
      this!,
      key: key,
      matchTextDirection: matchTextDirection,
      bundle: bundle,
      package: package,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      theme: theme,
      clipBehavior: clipBehavior,
      colorFilter: colorFilter ??
          (color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null),
      color: color,
      colorBlendMode: colorBlendMode,
      cacheColorFilter: cacheColorFilter,
    );
  }

  Widget toSvgIcon({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double size = 24,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    SvgTheme theme = const SvgTheme(),
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @Deprecated('Use colorFilter instead.') Color? color,
    @Deprecated('Use colorFilter instead.')
    BlendMode colorBlendMode = BlendMode.srcIn,
    @Deprecated('This no longer does anything.') bool cacheColorFilter = false,
  }) =>
      toSvg(
        key: key,
        matchTextDirection: matchTextDirection,
        bundle: bundle,
        package: package,
        width: size,
        height: size,
        fit: fit,
        alignment: alignment,
        allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
        placeholderBuilder: placeholderBuilder,
        semanticsLabel: semanticsLabel,
        excludeFromSemantics: excludeFromSemantics,
        theme: theme,
        colorFilter: colorFilter,
        clipBehavior: clipBehavior,
        color: color,
        colorBlendMode: colorBlendMode,
        cacheColorFilter: cacheColorFilter,
      );
}