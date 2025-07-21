import 'package:falconnect/engine/https/exceptions/base_http_exception.dart';

/// Base class for all 4XX client error exceptions.
/// 
/// Client errors indicate that the request contains bad syntax or cannot
/// be fulfilled. These errors are typically the client's responsibility.
/// 
/// Ref: https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
class ClientNetworkException extends BaseHttpException {
  const ClientNetworkException({
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
            statusCode >= 400 && statusCode < 500, 'Error code not 400 to 500');

  @override
  String get userFriendlyMessage {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Authentication required. Please log in.';
      case 403:
        return "Access denied. You don't have permission.";
      case 404:
        return 'The requested resource was not found.';
      case 405:
        return 'This operation is not allowed.';
      case 408:
        return 'Request timed out. Please try again.';
      case 429:
        return 'Too many requests. Please wait and try again.';
      default:
        return super.userFriendlyMessage;
    }
  }
}
