import 'package:falmodel/lib.dart';

/// Generic base response class for all HTTP responses.
/// 
/// This class provides a type-safe wrapper around Dio's [Response] class
/// with improved type inference and documentation.
/// 
/// Type parameter [T] represents the data type of the response body.
/// 
/// Example:
/// ```dart
/// // For a simple value response
/// final response = BaseResponse<int>(
///   data: 42,
///   statusCode: 200,
///   requestOptions: requestOptions,
/// );
/// 
/// // For a complex object response
/// final userResponse = BaseResponse<User>(
///   data: User(id: 1, name: 'John'),
///   statusCode: 200,
///   requestOptions: requestOptions,
/// );
/// ```
class BaseResponse<T> extends Response<T> {
  /// Creates a base response with the given parameters.
  /// 
  /// [data] is the response body of type [T].
  /// [statusCode] is the HTTP status code.
  /// [statusMessage] is the HTTP status message.
  /// [requestOptions] contains the original request configuration.
  /// [isRedirect] indicates if the response was a redirect.
  /// [redirects] contains the redirect history.
  /// [extra] can contain any extra information.
  /// [headers] contains the response headers.
  BaseResponse({
    super.data,
    super.statusCode,
    super.statusMessage,
    required super.requestOptions,
    super.isRedirect,
    super.redirects,
    super.extra,
    super.headers,
  });

  /// Creates a successful response with 200 status code.
  factory BaseResponse.success({
    required T data,
    required RequestOptions requestOptions,
    Map<String, List<String>>? headers,
  }) {
    return BaseResponse<T>(
      data: data,
      statusCode: 200,
      statusMessage: 'OK',
      requestOptions: requestOptions,
      headers: Headers.fromMap(headers ?? {}),
    );
  }

  /// Creates a response with no content (204 status code).
  factory BaseResponse.noContent({
    required RequestOptions requestOptions,
  }) {
    return BaseResponse<T>(
      data: null,
      statusCode: 204,
      statusMessage: 'No Content',
      requestOptions: requestOptions,
    );
  }

  /// Whether the response was successful (2xx status code).
  bool get isSuccessful => statusCode != null && statusCode! >= 200 && statusCode! < 300;

  /// Whether the response was a client error (4xx status code).
  bool get isClientError => statusCode != null && statusCode! >= 400 && statusCode! < 500;

  /// Whether the response was a server error (5xx status code).
  bool get isServerError => statusCode != null && statusCode! >= 500 && statusCode! < 600;
}

/// Type aliases for common response types to maintain backward compatibility
/// and provide convenient shortcuts.

/// Response containing a boolean value.
typedef BoolResponse = BaseResponse<bool>;

/// Response containing an integer value.
typedef IntResponse = BaseResponse<int>;

/// Response containing a double value.
typedef DoubleResponse = BaseResponse<double>;

/// Response containing a string value.
typedef StringResponse = BaseResponse<String>;

/// Response containing a list of items.
typedef ListResponse<T> = BaseResponse<List<T>>;

/// Response containing a map/dictionary.
typedef MapResponse<K, V> = BaseResponse<Map<K, V>>;

/// Response with no data (void/empty response).
typedef EmptyResponse = BaseResponse<void>;
