// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/foundation.dart';

final AnsiPen _normal = AnsiPen()..white(bold: true);
final AnsiPen _error = AnsiPen()..red(bold: true);
final AnsiPen _success = AnsiPen()..green(bold: true);

/// Prints [message] in white, pretty-printed, in debug mode only.
void printInfo(Object? message) {
  if (kDebugMode) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      print(_normal(encoder.convert(message?.toString())));
    } catch (error) {
      print(error);
    }
  }
}

/// Prints [message] and an optional [stacktrace] in red, debug mode only.
void printError(Object? message, [StackTrace? stacktrace]) {
  if (kDebugMode) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      print(_error(encoder.convert(message?.toString())));
      if (stacktrace != null) {
        print(_error(stacktrace.toString().trimRight()));
      }
    } catch (error) {
      print(error);
    }
  }
}

/// Prints [message] in green, pretty-printed, in debug mode only.
void printSuccess(Object? message) {
  if (kDebugMode) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      print(_success(encoder.convert(message?.toString())));
    } catch (error) {
      print(error);
    }
  }
}
