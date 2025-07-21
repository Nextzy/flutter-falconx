import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:falconnect/engine/https/config/http_client_config.dart';
import 'package:flutter/foundation.dart';

/// Performance metrics for a single request.
class RequestMetrics {

  RequestMetrics({
    required this.method,
    required this.url,
    required this.startTime,
  });
  final String method;
  final String url;
  final DateTime startTime;
  DateTime? endTime;
  int? statusCode;
  String? error;
  
  /// Time spent in DNS lookup.
  Duration? dnsLookupTime;
  
  /// Time spent establishing connection.
  Duration? connectionTime;
  
  /// Time spent in TLS handshake.
  Duration? tlsHandshakeTime;
  
  /// Time spent sending the request.
  Duration? requestTime;
  
  /// Time spent waiting for first byte.
  Duration? timeToFirstByte;
  
  /// Time spent downloading response.
  Duration? downloadTime;
  
  /// Total request duration.
  Duration get totalDuration => endTime != null 
      ? endTime!.difference(startTime)
      : DateTime.now().difference(startTime);
  
  /// Request body size in bytes.
  int? requestSize;
  
  /// Response body size in bytes.
  int? responseSize;

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'url': url,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'statusCode': statusCode,
      'error': error,
      'totalDuration': totalDuration.inMilliseconds,
      'dnsLookupTime': dnsLookupTime?.inMilliseconds,
      'connectionTime': connectionTime?.inMilliseconds,
      'tlsHandshakeTime': tlsHandshakeTime?.inMilliseconds,
      'requestTime': requestTime?.inMilliseconds,
      'timeToFirstByte': timeToFirstByte?.inMilliseconds,
      'downloadTime': downloadTime?.inMilliseconds,
      'requestSize': requestSize,
      'responseSize': responseSize,
    };
  }
}

/// Aggregated performance statistics.
class PerformanceStatistics {
  int totalRequests = 0;
  int successfulRequests = 0;
  int failedRequests = 0;
  
  final Map<int, int> statusCodeCounts = {};
  final Map<String, int> errorCounts = {};
  
  int totalRequestSize = 0;
  int totalResponseSize = 0;
  
  Duration totalDuration = Duration.zero;
  Duration minDuration = const Duration(days: 365);
  Duration maxDuration = Duration.zero;
  
  final List<Duration> recentDurations = [];
  static const int _maxRecentDurations = 100;

  void addMetrics(RequestMetrics metrics) {
    totalRequests++;
    
    if (metrics.statusCode != null && metrics.statusCode! >= 200 && metrics.statusCode! < 300) {
      successfulRequests++;
    } else {
      failedRequests++;
    }
    
    if (metrics.statusCode != null) {
      statusCodeCounts[metrics.statusCode!] = (statusCodeCounts[metrics.statusCode!] ?? 0) + 1;
    }
    
    if (metrics.error != null) {
      errorCounts[metrics.error!] = (errorCounts[metrics.error!] ?? 0) + 1;
    }
    
    if (metrics.requestSize != null) {
      totalRequestSize += metrics.requestSize!;
    }
    
    if (metrics.responseSize != null) {
      totalResponseSize += metrics.responseSize!;
    }
    
    final duration = metrics.totalDuration;
    totalDuration += duration;
    
    if (duration < minDuration) {
      minDuration = duration;
    }
    
    if (duration > maxDuration) {
      maxDuration = duration;
    }
    
    recentDurations.add(duration);
    if (recentDurations.length > _maxRecentDurations) {
      recentDurations.removeAt(0);
    }
  }
  
  Duration get averageDuration => totalRequests > 0 
      ? Duration(milliseconds: totalDuration.inMilliseconds ~/ totalRequests)
      : Duration.zero;
  
  Duration get medianDuration {
    if (recentDurations.isEmpty) return Duration.zero;
    
    final sorted = List<Duration>.from(recentDurations)..sort();
    final middle = sorted.length ~/ 2;
    
    if (sorted.length.isOdd) {
      return sorted[middle];
    } else {
      return Duration(
        milliseconds: (sorted[middle - 1].inMilliseconds + sorted[middle].inMilliseconds) ~/ 2,
      );
    }
  }
  
  double get successRate => totalRequests > 0 
      ? successfulRequests / totalRequests * 100
      : 0.0;
  
  Map<String, dynamic> toJson() {
    return {
      'totalRequests': totalRequests,
      'successfulRequests': successfulRequests,
      'failedRequests': failedRequests,
      'successRate': successRate,
      'statusCodeCounts': statusCodeCounts,
      'errorCounts': errorCounts,
      'totalRequestSize': totalRequestSize,
      'totalResponseSize': totalResponseSize,
      'averageRequestSize': totalRequests > 0 ? totalRequestSize ~/ totalRequests : 0,
      'averageResponseSize': totalRequests > 0 ? totalResponseSize ~/ totalRequests : 0,
      'totalDuration': totalDuration.inMilliseconds,
      'averageDuration': averageDuration.inMilliseconds,
      'medianDuration': medianDuration.inMilliseconds,
      'minDuration': minDuration.inMilliseconds,
      'maxDuration': maxDuration.inMilliseconds,
    };
  }
}

/// Interceptor that monitors HTTP request performance.
/// 
/// This interceptor collects detailed performance metrics for each request
/// and provides aggregated statistics.
class PerformanceInterceptor extends Interceptor {

  /// Creates a new performance interceptor.
  PerformanceInterceptor({
    required this.config,
    this.maxMetricsHistory = 1000,
    this.collectDetailedTimings = true,
  });
  final HttpClientConfig config;
  
  /// Maximum number of detailed metrics to keep in memory.
  final int maxMetricsHistory;
  
  /// Whether to collect detailed timing information.
  final bool collectDetailedTimings;
  
  /// Recent request metrics.
  final Queue<RequestMetrics> _metricsHistory = Queue<RequestMetrics>();
  
  /// Aggregated statistics.
  final PerformanceStatistics _statistics = PerformanceStatistics();
  
  /// Metrics by URL pattern.
  final Map<String, PerformanceStatistics> _urlStatistics = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!config.enablePerformanceMonitoring) {
      return handler.next(options);
    }

    // Create metrics for this request
    final metrics = RequestMetrics(
      method: options.method,
      url: options.uri.toString(),
      startTime: DateTime.now(),
    );
    
    // Estimate request size
    metrics.requestSize = _estimateRequestSize(options);
    
    // Store metrics in request options
    options.extra['performanceMetrics'] = metrics;
    
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!config.enablePerformanceMonitoring) {
      return handler.next(response);
    }

    // Get metrics from request
    final metrics = response.requestOptions.extra['performanceMetrics'] as RequestMetrics?;
    if (metrics == null) {
      return handler.next(response);
    }

    // Update metrics
    metrics.endTime = DateTime.now();
    metrics.statusCode = response.statusCode;
    
    // Estimate response size
    metrics.responseSize = _estimateResponseSize(response);
    
    // Add to history and statistics
    _addMetrics(metrics);
    
    if (config.enableLogging) {
      if (kDebugMode) {
        print('[PerformanceInterceptor] ${metrics.method} ${metrics.url} - '
            '${metrics.totalDuration.inMilliseconds}ms, '
            'status: ${metrics.statusCode}, '
            'response: ${metrics.responseSize} bytes');
      }
    }
    
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!config.enablePerformanceMonitoring) {
      return handler.next(err);
    }

    // Get metrics from request
    final metrics = err.requestOptions.extra['performanceMetrics'] as RequestMetrics?;
    if (metrics == null) {
      return handler.next(err);
    }

    // Update metrics
    metrics.endTime = DateTime.now();
    metrics.statusCode = err.response?.statusCode;
    metrics.error = err.type.toString();
    
    if (err.response != null) {
      metrics.responseSize = _estimateResponseSize(err.response!);
    }
    
    // Add to history and statistics
    _addMetrics(metrics);
    
    if (config.enableLogging) {
      print('[PerformanceInterceptor] ${metrics.method} ${metrics.url} - '
            'FAILED: ${metrics.totalDuration.inMilliseconds}ms, '
            'error: ${metrics.error}');
    }
    
    handler.next(err);
  }

  /// Adds metrics to history and updates statistics.
  void _addMetrics(RequestMetrics metrics) {
    // Add to history
    _metricsHistory.add(metrics);
    if (_metricsHistory.length > maxMetricsHistory) {
      _metricsHistory.removeFirst();
    }
    
    // Update global statistics
    _statistics.addMetrics(metrics);
    
    // Update URL pattern statistics
    final urlPattern = _getUrlPattern(metrics.url);
    _urlStatistics.putIfAbsent(urlPattern, () => PerformanceStatistics())
        .addMetrics(metrics);
  }

  /// Gets a normalized URL pattern for grouping statistics.
  String _getUrlPattern(String url) {
    try {
      final uri = Uri.parse(url);
      
      // Remove query parameters and numeric path segments
      final pathSegments = uri.pathSegments
          .map((segment) => int.tryParse(segment) != null ? '{id}' : segment)
          .toList();
      
      return '${uri.scheme}://${uri.host}/${pathSegments.join('/')}';
    } catch (e) {
      return url;
    }
  }

  /// Estimates the size of a request in bytes.
  int _estimateRequestSize(RequestOptions options) {
    int size = 0;
    
    // Add method and URL
    size += options.method.length + options.uri.toString().length;
    
    // Add headers
    options.headers.forEach((key, value) {
      size += key.length + value.toString().length;
    });
    
    // Add body
    if (options.data != null) {
      if (options.data is String) {
        size += (options.data as String).length;
      } else if (options.data is List<int>) {
        size += (options.data as List<int>).length;
      } else if (options.data is FormData) {
        // Estimate FormData size
        final formData = options.data as FormData;
        for (final field in formData.fields) {
          size += field.key.length + field.value.length;
        }
        // Note: File sizes are not included in this estimate
      }
    }
    
    return size;
  }

  /// Estimates the size of a response in bytes.
  int _estimateResponseSize(Response response) {
    int size = 0;
    
    // Add status line
    size += 20; // Approximate size of status line
    
    // Add headers
    response.headers.forEach((key, values) {
      size += key.length;
      for (final value in values) {
        size += value.length;
      }
    });
    
    // Add body
    if (response.data != null) {
      if (response.data is String) {
        size += (response.data as String).length;
      } else if (response.data is List<int>) {
        size += (response.data as List<int>).length;
      }
    }
    
    return size;
  }

  /// Gets recent performance metrics.
  List<RequestMetrics> getRecentMetrics({int? limit}) {
    final metrics = _metricsHistory.toList();
    if (limit != null && metrics.length > limit) {
      return metrics.sublist(metrics.length - limit);
    }
    return metrics;
  }

  /// Gets aggregated performance statistics.
  PerformanceStatistics getStatistics() => _statistics;

  /// Gets performance statistics grouped by URL pattern.
  Map<String, PerformanceStatistics> getUrlStatistics() => Map.from(_urlStatistics);

  /// Clears all collected metrics and statistics.
  void clear() {
    _metricsHistory.clear();
    _statistics.totalRequests = 0;
    _statistics.successfulRequests = 0;
    _statistics.failedRequests = 0;
    _statistics.statusCodeCounts.clear();
    _statistics.errorCounts.clear();
    _statistics.totalRequestSize = 0;
    _statistics.totalResponseSize = 0;
    _statistics.totalDuration = Duration.zero;
    _statistics.minDuration = const Duration(days: 365);
    _statistics.maxDuration = Duration.zero;
    _statistics.recentDurations.clear();
    _urlStatistics.clear();
  }
}
