/// Internal library for FalStore package.
///
/// This file contains internal utilities and exports for the FalStore package.
/// It should not be imported directly by external packages.
import 'dart:convert';

import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/foundation.dart';

export 'package:flutter_faltool/flutter_faltool.dart';
export 'package:flutter_secure_storage/flutter_secure_storage.dart';

export 'flutter_falstore.dart';

/// ANSI color pen for normal log messages.
final AnsiPen _normal = AnsiPen()..white(bold: true);

/// ANSI color pen for error log messages.
final AnsiPen _error = AnsiPen()..red(bold: true);

/// ANSI color pen for success log messages.
final AnsiPen _success = AnsiPen()..green(bold: true);

/// Prints an informational message to the console in debug mode.
///
/// The message is formatted with JSON indentation for better readability
/// and displayed in white color. This function only prints in debug mode
/// to avoid exposing sensitive information in production.
///
/// Example:
/// ```dart
/// printInfo('User logged in successfully');
/// printInfo({'userId': 123, 'timestamp': DateTime.now()});
/// ```
void printInfo(Object? message) {
  if (kDebugMode) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      final prettyPrint = encoder.convert(message?.toString());
      print(_normal(prettyPrint));
    } catch (error) {
      // If JSON encoding fails, print the error for debugging
      print('[FalStore] Info print error: $error');
    }
  }
}

/// Prints an error message to the console in debug mode.
///
/// The message is formatted with JSON indentation for better readability
/// and displayed in red color. Optionally includes a stack trace for
/// debugging purposes. This function only prints in debug mode.
///
/// Example:
/// ```dart
/// try {
///   // Some operation
/// } catch (e, stackTrace) {
///   printError('Failed to load data: $e', stackTrace);
/// }
/// ```
void printError(Object? message, [StackTrace? stacktrace]) {
  if (kDebugMode) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      final prettyPrint = encoder.convert(message?.toString());
      print(_error(prettyPrint));
      if (stacktrace != null) {
        print(_error('Stack trace:\n${stacktrace.toString().trimRight()}'));
      }
    } catch (error) {
      // If JSON encoding fails, print the error for debugging
      print('[FalStore] Error print error: $error');
    }
  }
}

/// Prints a success message to the console in debug mode.
///
/// The message is formatted with JSON indentation for better readability
/// and displayed in green color. This function only prints in debug mode
/// to avoid exposing sensitive information in production.
///
/// Example:
/// ```dart
/// printSuccess('Data saved successfully');
/// printSuccess({'saved': true, 'items': 10});
/// ```
void printSuccess(Object? message) {
  if (kDebugMode) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      final prettyPrint = encoder.convert(message?.toString());
      print(_success(prettyPrint));
    } catch (error) {
      // If JSON encoding fails, print the error for debugging
      print('[FalStore] Success print error: $error');
    }
  }
}
