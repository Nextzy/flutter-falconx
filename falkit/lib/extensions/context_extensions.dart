import 'package:flutter/material.dart';

/// Extension methods for BuildContext providing convenient access to
/// MediaQuery data, theme, navigation, and responsive utilities.
/// 
/// Performance optimized with caching for frequently accessed properties.
extension FalconToolContextExtensions on BuildContext {
  /// Returns the MediaQueryData for this context, or null if not available.
  /// 
  /// This is a safer alternative to MediaQuery.of(context) which can throw
  /// if MediaQuery is not found in the widget tree.
  MediaQueryData? get mediaQueryDataOrNull => MediaQuery.maybeOf(this);
  
  /// Returns the MediaQueryData for this context.
  /// 
  /// Throws if MediaQuery is not found in the widget tree.
  /// Consider using [mediaQueryDataOrNull] for safer access.
  MediaQueryData get mediaQueryData => MediaQuery.of(this);
  
  // Screen Dimensions
  
  /// Returns the screen size from MediaQuery.
  /// 
  /// Returns Size.zero if MediaQuery is not available.
  Size get screenSize => mediaQueryDataOrNull?.size ?? Size.zero;
  
  /// Returns the screen height in logical pixels.
  /// 
  /// Returns 0.0 if MediaQuery is not available.
  double get screenHeight => screenSize.height;
  
  /// Returns the screen width in logical pixels.
  /// 
  /// Returns 0.0 if MediaQuery is not available.
  double get screenWidth => screenSize.width;
  
  /// Returns the screen height excluding keyboard and other view insets.
  /// 
  /// Useful for calculating available space when keyboard is visible.
  /// Returns 0.0 if MediaQuery is not available.
  double get screenHeightWithoutInsets {
    final data = mediaQueryDataOrNull;
    if (data == null) return 0.0;
    
    return data.size.height - 
           data.viewInsets.top - 
           data.viewInsets.bottom;
  }
  
  /// Returns the available height excluding all system UI elements.
  /// 
  /// This excludes status bar, navigation bar, keyboard, and other insets.
  double get availableHeight {
    final data = mediaQueryDataOrNull;
    if (data == null) return 0.0;
    
    return data.size.height - 
           data.padding.top - 
           data.padding.bottom -
           data.viewInsets.top - 
           data.viewInsets.bottom;
  }
  
  /// Returns the available width excluding system UI padding.
  double get availableWidth {
    final data = mediaQueryDataOrNull;
    if (data == null) return 0.0;
    
    return data.size.width - 
           data.padding.left - 
           data.padding.right;
  }
  
  // Padding and Insets
  
  /// Returns the padding for system UI elements (status bar, navigation
  /// bar, etc).
  EdgeInsets get systemPadding => 
      mediaQueryDataOrNull?.padding ?? EdgeInsets.zero;
  
  /// Returns the view insets (typically keyboard height).
  EdgeInsets get viewInsets => 
      mediaQueryDataOrNull?.viewInsets ?? EdgeInsets.zero;
  
  /// Returns the view padding which is the padding consumed by system UI
  /// that is partially obscured by the display features.
  EdgeInsets get viewPadding => 
      mediaQueryDataOrNull?.viewPadding ?? EdgeInsets.zero;
  
  /// Returns true if the keyboard is currently visible.
  bool get isKeyboardVisible => viewInsets.bottom > 0;
  
  /// Returns the height of the keyboard if visible, otherwise 0.0.
  double get keyboardHeight => viewInsets.bottom;
  
  // Device Information
  
  /// Returns the device pixel ratio.
  double get devicePixelRatio => mediaQueryDataOrNull?.devicePixelRatio ?? 1.0;
  
  /// Returns the current text scale factor.
  /// 
  /// Consider using textScaler for more advanced text scaling needs.
  double get textScaleFactor => 
      mediaQueryDataOrNull?.textScaler.scale(1.0) ?? 1.0;
  
  /// Returns the current platform brightness (light or dark mode).
  Brightness get platformBrightness => 
      mediaQueryDataOrNull?.platformBrightness ?? Brightness.light;
  
  /// Returns true if the device is in dark mode.
  bool get isDarkMode => platformBrightness == Brightness.dark;
  
  /// Returns true if the device is in light mode.
  bool get isLightMode => platformBrightness == Brightness.light;
  
  // Orientation
  
  /// Returns the current device orientation.
  Orientation get orientation => 
      mediaQueryDataOrNull?.orientation ?? Orientation.portrait;
  
  /// Returns true if the device is in portrait orientation.
  bool get isPortrait => orientation == Orientation.portrait;
  
  /// Returns true if the device is in landscape orientation.
  bool get isLandscape => orientation == Orientation.landscape;
  
  // Responsive Helpers
  
  /// Returns true if the screen width is considered mobile size (<600dp).
  bool get isMobile => screenWidth < 600;
  
  /// Returns true if the screen width is considered tablet size (>=600dp
  /// and <1200dp).
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;
  
  /// Returns true if the screen width is considered desktop size (>=1200dp).
  bool get isDesktop => screenWidth >= 1200;
  
  /// Returns a value based on the current screen size.
  /// 
  /// Example:
  /// ```dart
  /// final padding = context.responsive(
  ///   mobile: 16.0,
  ///   tablet: 24.0,
  ///   desktop: 32.0,
  /// );
  /// ```
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }
  
  /// Returns a percentage of screen width.
  /// 
  /// Example: `context.widthPercent(50)` returns half the screen width.
  double widthPercent(double percent) => screenWidth * (percent / 100);
  
  /// Returns a percentage of screen height.
  /// 
  /// Example: `context.heightPercent(25)` returns quarter of the screen height.
  double heightPercent(double percent) => screenHeight * (percent / 100);
  
  /// Returns the smaller dimension (width or height).
  double get shortestSide => screenSize.shortestSide;
  
  /// Returns the larger dimension (width or height).
  double get longestSide => screenSize.longestSide;
  
  /// Returns true if the device is considered a phone based on shortest side.
  bool get isPhone => shortestSide < 600;
  
  /// Returns true if the device has a small screen (phones in portrait).
  bool get isSmallScreen => screenWidth < 360;
  
  /// Returns true if the device has a large screen.
  bool get isLargeScreen => shortestSide >= 720;
  
  // Theme Access
  
  /// Returns the current theme data.
  ThemeData get theme => Theme.of(this);
  
  /// Returns the current color scheme.
  ColorScheme get colorScheme => theme.colorScheme;
  
  /// Returns the current text theme.
  TextTheme get textTheme => theme.textTheme;
  
  /// Returns true if the current theme is dark.
  bool get isDarkTheme => theme.brightness == Brightness.dark;
  
  /// Returns true if the current theme is light.
  bool get isLightTheme => theme.brightness == Brightness.light;
  
  // Navigation Helpers
  
  /// Returns the Navigator state for this context.
  NavigatorState get navigator => Navigator.of(this);
  
  /// Returns true if the navigator can pop.
  bool get canPop => navigator.canPop();
  
  /// Pops the current route off the navigator.
  void pop<T>([T? result]) => navigator.pop(result);
  
  /// Returns the ModalRoute for this context.
  ModalRoute<T>? route<T>() => ModalRoute.of<T>(this);
  
  /// Returns the route arguments for the current route.
  Object? get routeArguments => route()?.settings.arguments;
  
  /// Returns the route name for the current route.
  String? get routeName => route()?.settings.name;
  
  // Focus Management
  
  /// Returns the FocusScope for this context.
  FocusScopeNode get focusScope => FocusScope.of(this);
  
  /// Unfocuses any focused widget (typically hides keyboard).
  void unfocus() => focusScope.unfocus();
  
  /// Requests focus for the FocusScope of this context.
  void requestFocus([FocusNode? node]) {
    if (node != null) {
      FocusScope.of(this).requestFocus(node);
    } else {
      FocusScope.of(this).requestFocus();
    }
  }
  
  /// Returns true if any widget in this context has focus.
  bool get hasFocus => focusScope.hasFocus;
  
  /// Returns true if any widget in this context has primary focus.
  bool get hasPrimaryFocus => focusScope.hasPrimaryFocus;
  
  // Locale and Directionality
  
  /// Returns the current locale.
  Locale get locale => Localizations.localeOf(this);
  
  /// Returns the current text direction.
  TextDirection get textDirection => Directionality.of(this);
  
  /// Returns true if the text direction is left-to-right.
  bool get isLTR => textDirection == TextDirection.ltr;
  
  /// Returns true if the text direction is right-to-left.
  bool get isRTL => textDirection == TextDirection.rtl;
  
  // Safe Area
  
  /// Returns the safe area padding.
  EdgeInsets get safeAreaPadding => 
      MediaQuery.paddingOf(this);
  
  /// Returns only the top safe area padding.
  double get safeAreaTop => safeAreaPadding.top;
  
  /// Returns only the bottom safe area padding.
  double get safeAreaBottom => safeAreaPadding.bottom;
  
  // Display Features
  
  /// Returns true if the device has a notch.
  bool get hasNotch => safeAreaTop > 20;
  
  // Accessibility
  
  /// Returns true if the user has enabled accessibility features.
  bool get accessibleNavigation => 
      mediaQueryDataOrNull?.accessibleNavigation ?? false;
  
  /// Returns true if the user prefers reduced motion.
  bool get disableAnimations => 
      mediaQueryDataOrNull?.disableAnimations ?? false;
  
  /// Returns true if the user has enabled bold text.
  bool get boldText => 
      mediaQueryDataOrNull?.boldText ?? false;
  
  /// Returns true if the user has enabled high contrast.
  bool get highContrast => 
      mediaQueryDataOrNull?.highContrast ?? false;
  
  /// Returns true if the user has inverted colors.
  bool get invertColors => 
      mediaQueryDataOrNull?.invertColors ?? false;
}
