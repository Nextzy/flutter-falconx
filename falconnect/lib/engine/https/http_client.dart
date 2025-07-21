import 'package:falconnect/lib.dart';

/// Abstract base class for HTTP clients in the FalconX framework.
/// 
/// This class provides a high-level interface for making HTTP requests
/// with automatic JSON conversion, error handling, and progress tracking.
/// It abstracts away the complexities of the underlying Dio client while
/// providing a consistent and type-safe API.
abstract class BaseHttpClient implements RequestApiService {
  /// Creates a new HTTP client with the provided Dio instance.
  /// 
  /// The client will automatically set up default options and interceptors
  /// by calling [setupOptions] and [setupInterceptors] respectively.
  BaseHttpClient({
    required Dio dio,
  }) : _dio = dio {
    setupOptions(_dio, _dio.options);
    setupInterceptors(_dio, _dio.interceptors);
  }

  
  final Dio _dio;

  /// Gets the underlying Dio instance.
  /// 
  /// Exposed for advanced use cases where direct Dio access is needed.
  Dio get dio => _dio;

  /// Sets the base URL for all requests.
  /// 
  /// This is a convenience method that updates the Dio base URL configuration.
  void setupBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  /// Called during initialization to configure Dio options.
  /// 
  /// Override this method in subclasses to provide custom configuration.
  /// The default implementation does nothing.
  void setupOptions(Dio dio, BaseOptions options) {}

  /// Called during initialization to configure Dio interceptors.
  /// 
  /// Override this method in subclasses to add custom interceptors.
  /// The default implementation does nothing.
  void setupInterceptors(Dio dio, Interceptors interceptors) {}

  /// Gets the current Dio configuration options.
  BaseOptions get config => _dio.options;

  /// Gets the current Dio interceptors.
  Interceptors get interceptors => _dio.interceptors;

  /// Makes an HTTP GET request with automatic JSON conversion.
  /// 
  /// This method performs a GET request to the specified [path] and automatically
  /// converts the JSON response using the provided [converter] function.
  /// 
  /// Parameters:
  /// - [path]: The endpoint path (will be combined with base URL if set)
  /// - [queryParameters]: Optional query parameters to append to the URL
  /// - [options]: Additional request options (headers, timeout, etc.)
  /// - [cancelToken]: Token to cancel the request if needed
  /// - [onReceiveProgress]: Callback for tracking download progress
  /// - [converter]: Function to convert JSON response to type T
  /// - [catchError]: Optional error handler for request failures
  /// 
  /// Returns a [Future<Response<T>>] with the converted response data.
  /// 
  /// Throws [DioException] if the request fails and no [catchError] is provided.
  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, Object>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    bool isUseToken = true, // Kept for backward compatibility
    required FutureOr<T> Function(Map<String, dynamic> json) converter,
    T? Function(DioException exception, StackTrace? stackTrace)? catchError,
  }) async {
    return _performRequest<T>(
      () => _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      ),
      converter: (json) async => await converter(json),
      catchError: catchError,
    );
  }

  /// Makes an HTTP POST request with JSON body and automatic response conversion.
  /// 
  /// This method performs a POST request with a JSON body derived from the
  /// [data] parameter and converts the response using the [converter] function.
  /// 
  /// Parameters:
  /// - [path]: The endpoint path (will be combined with base URL if set)
  /// - [data]: Request body that will be serialized to JSON
  /// - [queryParameters]: Optional query parameters to append to the URL
  /// - [options]: Additional request options (headers, timeout, etc.)
  /// - [cancelToken]: Token to cancel the request if needed
  /// - [onSendProgress]: Callback for tracking upload progress
  /// - [onReceiveProgress]: Callback for tracking download progress
  /// - [converter]: Function to convert JSON response to type T
  /// - [catchError]: Optional error handler for request failures
  /// 
  /// Returns a [Future<Response<T>>] with the converted response data.
  /// 
  /// Throws [DioException] if the request fails and no [catchError] is provided.
  @override
  Future<Response<T>> post<T>(
    String path, {
    BaseRequestBody? data,
    Map<String, Object>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool isUseToken = true, // Kept for backward compatibility
    required T Function(Map<String, dynamic> json) converter,
    T? Function(DioException exception, StackTrace? stackTrace)? catchError,
  }) async {
    return _performRequest<T>(
      () => _dio.post(
        path,
        data: data?.toJson(),
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
      converter: (json) => converter(json),
      catchError: catchError,
    );
  }

  /// Makes an HTTP POST request with form data and automatic response conversion.
  /// 
  /// This method is specifically designed for uploading files or sending
  /// multipart form data. Use this when you need to upload files or send
  /// data that cannot be easily JSON-serialized.
  /// 
  /// Parameters:
  /// - [path]: The endpoint path (will be combined with base URL if set)
  /// - [data]: Form data including files and fields
  /// - [queryParameters]: Optional query parameters to append to the URL
  /// - [options]: Additional request options (headers, timeout, etc.)
  /// - [cancelToken]: Token to cancel the request if needed
  /// - [onSendProgress]: Callback for tracking upload progress
  /// - [onReceiveProgress]: Callback for tracking download progress
  /// - [converter]: Function to convert JSON response to type T
  /// - [catchError]: Optional error handler for request failures
  /// 
  /// Returns a [Future<Response<T>>] with the converted response data.
  /// 
  /// Throws [DioException] if the request fails and no [catchError] is provided.
  @override
  Future<Response<T>> postFormData<T>(
    String path, {
    FormData? data,
    Map<String, Object>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool isUseToken = true, // Kept for backward compatibility
    required T Function(Map<String, dynamic> json) converter,
    T? Function(DioException exception, StackTrace? stackTrace)? catchError,
  }) async {
    return _performRequest<T>(
      () => _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
      converter: (json) => converter(json),
      catchError: catchError,
    );
  }

  /// Makes an HTTP PATCH request with JSON body and automatic response conversion.
  /// 
  /// PATCH requests are typically used for partial updates of resources.
  /// The request body contains only the fields that need to be updated.
  /// 
  /// Parameters:
  /// - [path]: The endpoint path (will be combined with base URL if set)
  /// - [data]: Request body that will be serialized to JSON
  /// - [queryParameters]: Optional query parameters to append to the URL
  /// - [options]: Additional request options (headers, timeout, etc.)
  /// - [cancelToken]: Token to cancel the request if needed
  /// - [onSendProgress]: Callback for tracking upload progress
  /// - [onReceiveProgress]: Callback for tracking download progress
  /// - [converter]: Function to convert JSON response to type T
  /// - [catchError]: Optional error handler for request failures
  /// 
  /// Returns a [Future<Response<T>>] with the converted response data.
  /// 
  /// Throws [DioException] if the request fails and no [catchError] is provided.
  @override
  Future<Response<T>> patch<T>(
    String path, {
    BaseRequestBody? data,
    Map<String, Object>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool isUseToken = true, // Kept for backward compatibility
    required T Function(Map<String, dynamic> json) converter,
    T? Function(DioException exception, StackTrace? stackTrace)? catchError,
  }) async {
    return _performRequest<T>(
      () => _dio.patch(
        path,
        data: data?.toJson(),
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
      converter: (json) => converter(json),
      catchError: catchError,
    );
  }

  /// Makes an HTTP PUT request with JSON body and automatic response conversion.
  /// 
  /// PUT requests are typically used for complete resource updates or creation.
  /// The request body should contain the entire resource representation.
  /// 
  /// Parameters:
  /// - [path]: The endpoint path (will be combined with base URL if set)
  /// - [data]: Request body that will be serialized to JSON
  /// - [queryParameters]: Optional query parameters to append to the URL
  /// - [options]: Additional request options (headers, timeout, etc.)
  /// - [cancelToken]: Token to cancel the request if needed
  /// - [onSendProgress]: Callback for tracking upload progress
  /// - [onReceiveProgress]: Callback for tracking download progress
  /// - [converter]: Function to convert JSON response to type T
  /// - [catchError]: Optional error handler for request failures
  /// 
  /// Returns a [Future<Response<T>>] with the converted response data.
  /// 
  /// Throws [DioException] if the request fails and no [catchError] is provided.
  @override
  Future<Response<T>> put<T>(
    String path, {
    BaseRequestBody? data,
    Map<String, Object>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool isUseToken = true, // Kept for backward compatibility
    required T Function(Map<String, dynamic> json) converter,
    T? Function(DioException exception, StackTrace? stackTrace)? catchError,
  }) async {
    return _performRequest<T>(
      () => _dio.put(
        path,
        data: data?.toJson(),
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
      converter: (json) => converter(json),
      catchError: catchError,
    );
  }

  /// Makes an HTTP PUT request with form data and automatic response conversion.
  /// 
  /// This method is used for updating resources with file uploads or
  /// multipart form data. Use this when you need to upload files as part
  /// of a resource update.
  /// 
  /// Parameters:
  /// - [path]: The endpoint path (will be combined with base URL if set)
  /// - [data]: Form data including files and fields
  /// - [queryParameters]: Optional query parameters to append to the URL
  /// - [options]: Additional request options (headers, timeout, etc.)
  /// - [cancelToken]: Token to cancel the request if needed
  /// - [onSendProgress]: Callback for tracking upload progress
  /// - [onReceiveProgress]: Callback for tracking download progress
  /// - [converter]: Function to convert JSON response to type T
  /// - [catchError]: Optional error handler for request failures
  /// 
  /// Returns a [Future<Response<T>>] with the converted response data.
  /// 
  /// Throws [DioException] if the request fails and no [catchError] is provided.
  @override
  Future<Response<T>> putFormData<T>(
    String path, {
    FormData? data,
    Map<String, Object>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool isUseToken = true, // Kept for backward compatibility
    required T Function(Map<String, dynamic> json) converter,
    T? Function(DioException exception, StackTrace? stackTrace)? catchError,
  }) async {
    return _performRequest<T>(
      () => _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
      converter: (json) => converter(json),
      catchError: catchError,
    );
  }

  /// Makes an HTTP DELETE request with optional JSON body and automatic response conversion.
  /// 
  /// DELETE requests are used to remove resources from the server.
  /// Some APIs may require a request body for additional parameters.
  /// 
  /// Parameters:
  /// - [path]: The endpoint path (will be combined with base URL if set)
  /// - [data]: Optional request body that will be serialized to JSON
  /// - [queryParameters]: Optional query parameters to append to the URL
  /// - [options]: Additional request options (headers, timeout, etc.)
  /// - [cancelToken]: Token to cancel the request if needed
  /// - [converter]: Function to convert JSON response to type T
  /// - [catchError]: Optional error handler for request failures
  /// 
  /// Returns a [Future<Response<T>>] with the converted response data.
  /// 
  /// Throws [DioException] if the request fails and no [catchError] is provided.
  @override
  Future<Response<T>> delete<T>(
    String path, {
    BaseRequestBody? data,
    Map<String, Object>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool isUseToken = true, // Kept for backward compatibility
    required T Function(Map<String, dynamic> json) converter,
    T? Function(DioException exception, StackTrace? stackTrace)? catchError,
  }) async {
    return _performRequest<T>(
      () => _dio.delete(
        path,
        data: data?.toJson(),
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      converter: (json) => converter(json),
      catchError: catchError,
    );
  }

  /// Internal method to perform HTTP requests with consistent error handling.
  /// 
  /// This method centralizes the common logic for all HTTP methods including
  /// JSON mapping, error handling, and response processing.
  Future<Response<T>> _performRequest<T>(
    Future<Response<dynamic>> Function() requestFn, {
    required FutureOr<T> Function(Map<String, dynamic> json) converter,
    T? Function(DioException exception, StackTrace? stackTrace)? catchError,
  }) async {
    return requestFn()
        .mapJson(converter)
        .catchWhenError(catchError);
  }
}
