import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:falconnect/engine/https/config/http_client_config.dart';
import 'package:flutter/foundation.dart';

/// Interceptor that automatically retries failed requests.
/// 
/// This interceptor implements exponential backoff with jitter
/// and respects Retry-After headers for rate-limited requests.
class RetryInterceptor extends Interceptor {

  /// Creates a new retry interceptor.
  RetryInterceptor({
    required this.config,
    required this.dio,
  });
  final HttpClientConfig config;
  final Dio dio;
  final Random _random = Random();

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Skip retry if it's already a retry
    final isRetry = (err.requestOptions.extra['isRetry'] as bool?) ?? false;
    if (isRetry) {
      return handler.next(err);
    }

    // Get current retry count
    final retryCount = (err.requestOptions.extra['retryCount'] as int?) ?? 0;
    
    // Check if we should retry
    if (!_shouldRetry(err, retryCount)) {
      return handler.next(err);
    }

    // Calculate delay
    final delay = _calculateDelay(err, retryCount);
    
    // Log retry attempt
    if (config.enableLogging) {
      if (kDebugMode) {
        print('[RetryInterceptor] Retrying request ${retryCount + 1}/'
            '${config.maxRetryAttempts} after ${delay.inMilliseconds}ms: '
            '${err.requestOptions.method} ${err.requestOptions.uri}');
      }
    }

    // Wait before retrying
    await Future.delayed(delay);

    try {
      // Clone the request with updated retry information
      final options = Options(
        method: err.requestOptions.method,
        headers: err.requestOptions.headers,
        responseType: err.requestOptions.responseType,
        contentType: err.requestOptions.contentType,
        validateStatus: err.requestOptions.validateStatus,
        receiveDataWhenStatusError: 
            err.requestOptions.receiveDataWhenStatusError,
        followRedirects: err.requestOptions.followRedirects,
        maxRedirects: err.requestOptions.maxRedirects,
        requestEncoder: err.requestOptions.requestEncoder,
        responseDecoder: err.requestOptions.responseDecoder,
        listFormat: err.requestOptions.listFormat,
        extra: <String, dynamic>{
          ...err.requestOptions.extra,
          'retryCount': retryCount + 1,
          'isRetry': true,
        },
      );

      // Retry the request
      final response = await dio.request(
        err.requestOptions.path,
        data: err.requestOptions.data,
        queryParameters: err.requestOptions.queryParameters,
        options: options,
        cancelToken: err.requestOptions.cancelToken,
        onReceiveProgress: err.requestOptions.onReceiveProgress,
        onSendProgress: err.requestOptions.onSendProgress,
      );

      return handler.resolve(response);
    } on DioException catch (e) {
      // Update retry count in the error
      e.requestOptions.extra = <String, dynamic>{
        ...e.requestOptions.extra,
        'retryCount': retryCount + 1,
      };
      return handler.next(e);
    }
  }

  /// Determines if a request should be retried.
  bool _shouldRetry(DioException err, int retryCount) {
    // Don't retry if we've exceeded max attempts
    if (retryCount >= config.maxRetryAttempts) {
      return false;
    }

    // Don't retry cancelled requests
    if (err.type == DioExceptionType.cancel) {
      return false;
    }

    // Check if it's a network error (connection issues)
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    // Check if it's a retryable HTTP error
    if (err.response != null) {
      final statusCode = err.response!.statusCode ?? 0;
      
      // Server errors are generally retryable
      if (statusCode >= 500 && statusCode < 600) {
        return true;
      }
      
      // Specific client errors that are retryable
      const retryableClientErrors = [408, 429, 409];
      return retryableClientErrors.contains(statusCode);
    }

    return false;
  }

  /// Calculates the delay before the next retry attempt.
  Duration _calculateDelay(DioException err, int retryCount) {
    // Check for Retry-After header
    if (err.response != null && err.response!.statusCode == 429) {
      final retryAfter = err.response!.headers.value('retry-after');
      if (retryAfter != null) {
        final seconds = int.tryParse(retryAfter);
        if (seconds != null) {
          return Duration(seconds: seconds);
        }
      }
    }

    // Calculate exponential backoff with jitter
    final baseDelay = config.retryDelay.inMilliseconds;
    final exponentialDelay = (baseDelay * pow(2, retryCount)).round();
    final jitter = _random.nextInt(1000); // Add up to 1 second of jitter
    final totalDelay = exponentialDelay + jitter;

    // Cap at max delay
    final maxDelay = config.maxRetryDelay.inMilliseconds;
    final finalDelay = totalDelay > maxDelay ? maxDelay : totalDelay;

    return Duration(milliseconds: finalDelay);
  }
}
