import 'dart:convert';

import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/foundation.dart';

export 'dart:async';
export 'dart:convert';
export 'dart:io' hide HttpResponse, SocketException;

export 'package:ansicolor/ansicolor.dart';
export 'package:flutter_falconnect/utils/nlog.dart';
export 'package:flutter_falmodel/flutter_falmodel.dart';
export 'package:flutter_faltool/flutter_faltool.dart';
export 'package:freezed_annotation/freezed_annotation.dart';
export 'flutter_falconnect.dart';


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
