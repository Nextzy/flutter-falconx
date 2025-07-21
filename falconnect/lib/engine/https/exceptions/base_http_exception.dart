import 'package:dio/dio.dart';
import 'package:falconnect/engine/https/exceptions/network_exception.dart';

/// Base class for all HTTP-specific exceptions.
///
/// This abstract class provides common functionality for HTTP exceptions
/// including status code handling, error message extraction, and
/// standardized error representation.
abstract class BaseHttpException extends NetworkException {
  /// Creates a base HTTP exception.
  ///
  /// All HTTP exceptions should extend this class to inherit
  /// common functionality and ensure consistent behavior.
  const BaseHttpException({
    required super.statusCode,
    super.type,
    super.statusMessage,
    super.errorMessage,
    super.developerMessage,
    super.response,
    super.requestOptions,
    super.stackTrace,
    super.errors,
  });

  /// Returns the HTTP status category (e.g., 4XX, 5XX).
  String get statusCategory {
    if (statusCode >= 400 && statusCode < 500) return '4XX';
    if (statusCode >= 500 && statusCode < 600) return '5XX';
    return 'Unknown';
  }

  /// Returns a user-friendly error message based on the status code.
  String get userFriendlyMessage {
    if (statusCode >= 400 && statusCode < 500) {
      return 'The request could not be processed. Please check your input and try again.';
    }
    if (statusCode >= 500 && statusCode < 600) {
      return 'The server encountered an error. Please try again later.';
    }
    return 'An unexpected error occurred. Please try again.';
  }

  /// Checks if this is a client error (4XX).
  bool get isClientError => statusCode >= 400 && statusCode < 500;

  /// Checks if this is a server error (5XX).
  bool get isServerError => statusCode >= 500 && statusCode < 600;

  /// Checks if the error is potentially retryable.
  ///
  /// Server errors and certain client errors (like 408 Request Timeout)
  /// are considered retryable.
  bool get isRetryable {
    // Server errors are generally retryable
    if (isServerError) return true;

    // Specific client errors that are retryable
    const retryableClientErrors = [408, 429, 409];
    return retryableClientErrors.contains(statusCode);
  }

  /// Returns the recommended retry delay in milliseconds.
  ///
  /// For rate limiting (429), checks the Retry-After header.
  /// For other retryable errors, returns a default delay.
  int get recommendedRetryDelay {
    if (!isRetryable) return 0;

    // Check for Retry-After header (429 errors)
    if (statusCode == 429 && response?.headers != null) {
      final retryAfter = response!.headers.value('retry-after');
      if (retryAfter != null) {
        final seconds = int.tryParse(retryAfter);
        if (seconds != null) return seconds * 1000;
      }
    }

    // Default retry delays
    if (statusCode == 429) return 60000; // 1 minute for rate limiting
    if (isServerError) return 5000; // 5 seconds for server errors
    return 3000; // 3 seconds for other retryable errors
  }

  /// Extracts error details from various response formats.
  ///
  /// Attempts to extract error information from common API error
  /// response formats including JSON and plain text.
  static Map<String, String?> extractErrorDetails(Response? response) {
    final result = <String, String?>{
      'type': null,
      'message': null,
      'developerMessage': null,
    };

    if (response?.data == null) return result;

    final data = response!.data;

    // Handle JSON responses
    if (data is Map<String, dynamic>) {
      // Common error message fields
      result['message'] = (data['message'] ??
              data['error'] ??
              data['error_message'] ??
              data['detail'])
          ?.toString();

      // Developer/debug message fields
      result['developerMessage'] = (data['developerMessage'] ??
              data['developer_message'] ??
              data['debug_message'] ??
              data['debug'])
          ?.toString();

      // Error type/code fields
      result['type'] = (data['type'] ??
              data['error_type'] ??
              data['error_code'] ??
              data['code'])
          ?.toString();
    }
    // Handle string responses
    else if (data is String) {
      result['message'] = data;
    }

    return result;
  }

  /// Creates a string representation suitable for logging.
  ///
  /// Includes all relevant details for debugging including
  /// request URL, method, status code, and error messages.
  String toLogString() {
    final buffer = StringBuffer()
      ..writeln('HTTP Exception: $runtimeType')
      ..writeln('Status Code: $statusCode ($statusCategory)');

    if (requestOptions != null) {
      buffer
          .writeln('Request: ${requestOptions!.method} ${requestOptions!.uri}');
    }

    if (type != null) buffer.writeln('Type: $type');
    if (errorMessage != null) buffer.writeln('Error: $errorMessage');
    if (developerMessage != null) {
      buffer.writeln('Developer Message: $developerMessage');
    }
    if (statusMessage != null) buffer.writeln('Status Message: $statusMessage');

    return buffer.toString();
  }
}
