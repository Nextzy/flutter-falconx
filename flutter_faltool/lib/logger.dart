import 'dart:convert';

import 'package:flutter_faltool/lib.dart';
import 'package:flutter/foundation.dart';

/// A comprehensive logging utility for Falcon applications.
///
/// Provides structured logging with multiple severity levels, ANSI color support,
/// and automatic stack trace handling. All logging is disabled in release mode
/// to prevent sensitive information leakage.
///
/// Example:
/// ```dart
/// // Basic logging
/// Log.i('Application started');
/// Log.d('Debug information');
/// Log.w('Warning message');
/// Log.e('Error occurred', error: exception);
///
/// // Styled output
/// Log.title('Configuration');
/// Log.success('Operation completed');
///
/// // Custom logger setup
/// Log.setup(
///   level: Level.debug,
///   filter: ProductionFilter(),
///   printer: PrettyPrinter(),
/// );
/// ```
class Log {
  static Logger _logger = Logger();

  static final AnsiPen _title = AnsiPen()..white(bold: true);
  static final AnsiPen _error = AnsiPen()..red(bold: true);
  static final AnsiPen _warning = AnsiPen()..yellow(bold: true);
  static final AnsiPen _success = AnsiPen()..green(bold: true);

  /// Sets up the logger with custom configuration.
  ///
  /// [filter] - Custom log filter implementation
  /// [printer] - Custom log printer implementation
  /// [output] - Custom log output implementation
  /// [level] - Minimum log level to output
  static void setup({
    LogFilter? filter,
    LogPrinter? printer,
    LogOutput? output,
    Level? level,
  }) {
    _logger = Logger(
      filter: filter,
      printer: printer,
      output: output,
      level: level,
    );
  }

  /// Logs a trace level message.
  ///
  /// Trace level is the most verbose logging level, typically used for
  /// detailed debugging information.
  static void t(
    Object? message, {
    String? tag,
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kReleaseMode) {
      final finalTag = tag ?? error.runtimeType.toString();
      _logger.t(
        '$finalTag: $message',
        time: time,
        error: error,
        stackTrace: stackTrace ?? StackTrace.current,
      );
    }
  }

  /// Logs a debug level message.
  ///
  /// Debug level is used for debugging information that is useful during
  /// development but not in production.
  static void d(
    Object? message, {
    String? tag,
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kReleaseMode) {
      final finalTag = tag ?? error.runtimeType.toString();
      _logger.d(
        '$finalTag: $message',
        time: time,
        error: error,
        stackTrace: stackTrace ?? StackTrace.current,
      );
    }
  }

  /// Logs an info level message.
  ///
  /// Info level is used for general informational messages about application
  /// flow and state.
  static void i(
    Object? message, {
    String? tag,
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kReleaseMode) {
      final finalTag = tag ?? error.runtimeType.toString();
      _logger.i(
        '$finalTag: $message',
        time: time,
        error: error,
        stackTrace: stackTrace ?? StackTrace.current,
      );
    }
  }

  /// Logs a warning level message.
  ///
  /// Warning level is used for potentially harmful situations that the
  /// application can recover from.
  ///
  /// Automatically extracts error and stack trace information if the message
  /// is an Error or Exception object.
  static void w(
    Object? message, {
    String? tag,
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kReleaseMode) {
      final finalTag = tag ?? error.runtimeType.toString();
      if (message is Error) {
        _logger.w(
          '$finalTag: $message',
          time: time,
          error: error ?? message,
          stackTrace: stackTrace ?? message.stackTrace ?? StackTrace.current,
        );
      } else if (message is Exception) {
        _logger.w(
          '$finalTag: $message',
          time: time,
          error: error ?? message,
          stackTrace: stackTrace ?? StackTrace.current,
        );
      } else {
        _logger.w(
          '$finalTag: $message',
          time: time,
          error: error,
          stackTrace: stackTrace ?? StackTrace.current,
        );
      }
    }
  }

  /// Logs an error with stack trace.
  ///
  /// This is a convenience method specifically for logging Error objects
  /// with their associated stack traces.
  static void error(
    Object error,
    StackTrace? stackTrace, {
    String? tag,
    DateTime? time,
  }) {
    if (!kReleaseMode) {
      final finalTag = tag ?? error.runtimeType.toString();
      _logger.e(
        '$finalTag: $error',
        error: error,
        stackTrace: stackTrace ?? StackTrace.current,
        time: time,
      );
    }
  }

  /// Logs an error level message.
  ///
  /// Error level is used for error events that might still allow the
  /// application to continue running.
  ///
  /// Automatically extracts error and stack trace information if the message
  /// is an Error or Exception object.
  static void e(
    Object? message, {
    String? tag,
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kReleaseMode) {
      final finalTag = tag ?? error.runtimeType.toString();
      if (message is Error) {
        _logger.e(
          '$finalTag: $message',
          time: time,
          error: error ?? message,
          stackTrace: stackTrace ?? message.stackTrace ?? StackTrace.current,
        );
      } else if (message is Exception) {
        _logger.e(
          '$finalTag: $message',
          time: time,
          error: error ?? message,
          stackTrace: stackTrace ?? StackTrace.current,
        );
      } else {
        _logger.e(
          '$finalTag: $message',
          time: time,
          error: error,
          stackTrace: stackTrace ?? StackTrace.current,
        );
      }
    }
  }

  /// Logs a styled title message.
  ///
  /// Displays the message in white bold text with pretty-printed JSON
  /// formatting if applicable.
  static void title(Object? message) {
    if (!kReleaseMode) {
      const encoder = JsonEncoder.withIndent('  ');
      final prettyPrint = encoder.convert(
        message?.toString() ?? 'Null',
      );
      _printLong(_title(prettyPrint));
    }
  }

  /// Logs a styled success message.
  ///
  /// Displays the message in green bold text with pretty-printed JSON
  /// formatting if applicable.
  static void success(Object? message) {
    if (!kReleaseMode) {
      const encoder = JsonEncoder.withIndent('  ');
      final prettyPrint = encoder.convert(
        message?.toString() ?? 'Null',
      );
      _printLong(_success(prettyPrint));
    }
  }

  /// Logs a fatal level message.
  ///
  /// Fatal level is used for severe error events that will presumably lead
  /// the application to abort.
  static void f(
    Object? message, {
    String? tag,
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kReleaseMode) {
      final finalTag = tag ?? error.runtimeType.toString();
      _logger.f(
        '$finalTag: $message',
        time: time,
        error: error,
        stackTrace: stackTrace ?? StackTrace.current,
      );
    }
  }

  /// Prints long messages by splitting them into chunks.
  ///
  /// This is necessary because some platforms have limits on the length of
  /// strings that can be printed in a single call to print().
  ///
  /// The default chunk size is 1020 characters to ensure compatibility with
  /// most platforms.
  static void _printLong(Object? object) async {
    if (!kReleaseMode) {
      const defaultPrintLength = 1020;
      if (object == null || object.toString().length <= defaultPrintLength) {
        debugPrint(object?.toString());
      } else {
        final log = object.toString();
        var start = 0;
        var endIndex = defaultPrintLength;
        final logLength = log.length;
        var tmpLogLength = log.length;
        while (endIndex < logLength) {
          debugPrint(log.substring(start, endIndex));
          endIndex += defaultPrintLength;
          start += defaultPrintLength;
          tmpLogLength -= defaultPrintLength;
        }
        if (tmpLogLength > 0) {
          debugPrint(log.substring(start, logLength));
        }
      }
    }
  }
}
