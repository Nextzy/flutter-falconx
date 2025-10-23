import 'dart:developer';
import 'package:flutter/foundation.dart';

class NLog {
  static bool get _isDebug => !kReleaseMode;

  static const String TOP_LEFT_CORNER = '┌';
  static const String BOTTOM_LEFT_CORNER = '└';
  static const String MIDDLE_CORNER = '├';
  static const String HORIZONTAL_LINE = '│';
  static const String DOUBLE_DIVIDER =
      '────────────────────────────────────────────────────────';
  static const String SINGLE_DIVIDER =
      '┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄';

  static void i(String tag, String message) {
    if (_isDebug) {
      log('$tag | $TOP_LEFT_CORNER$DOUBLE_DIVIDER');
      log('$tag | $HORIZONTAL_LINE $message');
      log('$tag | $BOTTOM_LEFT_CORNER$DOUBLE_DIVIDER');
    }
  }

  static void e(String tag, String serviceName, Object exception) {
    if (_isDebug) {
      log('$tag | $TOP_LEFT_CORNER$DOUBLE_DIVIDER');
      log('$tag | $HORIZONTAL_LINE Throwable: ${exception.runtimeType}');
      log('$tag | $HORIZONTAL_LINE Message: $exception');
      log('$tag | $MIDDLE_CORNER$SINGLE_DIVIDER');
      log('$tag | $HORIZONTAL_LINE Service: $serviceName');
      log('$tag | $BOTTOM_LEFT_CORNER$DOUBLE_DIVIDER');
    }
  }
}
