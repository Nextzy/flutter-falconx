import 'dart:convert';

import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/foundation.dart';

export 'dart:async';
export 'dart:convert';

export 'package:ansicolor/ansicolor.dart';
export 'package:dart_faltool/dart_faltool.dart';
export 'package:flutter_udid/flutter_udid.dart';

export 'extensions/extensions.dart';
export 'flutter_faltool.dart';
export 'logger.dart';
export 'utils/utils.dart';


final AnsiPen _normal = AnsiPen()..white(bold: true);
final AnsiPen _error = AnsiPen()..red(bold: true);
final AnsiPen _success = AnsiPen()..green(bold: true);

void printInfo(Object? message) {
  if (kDebugMode) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      final prettyPrint = encoder.convert(message?.toString());
      print(_normal(prettyPrint));
    } catch (error) {
      print(error);
    }
  }
}

void printError(Object? message, [StackTrace? stacktrace]) {
  if (kDebugMode) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      final prettyPrint = encoder.convert(message?.toString());
      print(_error(prettyPrint));
      if (stacktrace != null) {
        print(_error(stacktrace.toString().trimRight()));
      }
    } catch (error) {
      print(error);
    }
  }
}

void printSuccess(Object? message) {
  if (kDebugMode) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      final prettyPrint = encoder.convert(message?.toString());
      print(_success(prettyPrint));
    } catch (error) {
      print(error);
    }
  }
}
