import 'package:falconnect/engine/https/exceptions/base_http_exception.dart';

/// Base class for all 5XX server error exceptions.
/// 
/// Server errors indicate that the server failed to fulfill a valid request.
/// These errors are typically the server's responsibility and often retryable.
/// 
/// Ref: https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
class ServerNetworkException extends BaseHttpException {
  const ServerNetworkException({
    required super.statusCode,
    super.type,
    super.statusMessage,
    super.errorMessage,
    super.developerMessage,
    super.response,
    super.requestOptions,
    super.stackTrace,
    super.errors,
  }) : assert(
            statusCode >= 500 && statusCode < 600, 'Error code not 500 to 600');

  @override
  String get userFriendlyMessage {
    switch (statusCode) {
      case 500:
        return 'Internal server error. Please try again later.';
      case 501:
        return 'This feature is not implemented yet.';
      case 502:
        return 'Server communication error. Please try again.';
      case 503:
        return 'Service temporarily unavailable. Please try again later.';
      case 504:
        return 'Server timeout. Please try again.';
      default:
        return super.userFriendlyMessage;
    }
  }

  /// Server errors are generally retryable.
  @override
  bool get isRetryable => true;

  /// Server errors should have longer retry delays.
  @override
  int get recommendedRetryDelay {
    switch (statusCode) {
      case 503: // Service Unavailable might have Retry-After header
        final retryAfter = response?.headers.value('retry-after');
        if (retryAfter != null) {
          final seconds = int.tryParse(retryAfter);
          if (seconds != null) return seconds * 1000;
        }
        return 30000; // 30 seconds
      case 502:
      case 504:
        return 10000; // 10 seconds for gateway errors
      default:
        return 5000; // 5 seconds for other server errors
    }
  }
}
