import 'dart:async';
import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:falconnect/engine/https/config/http_client_config.dart';
import 'package:flutter/foundation.dart';

/// Request information for rate limiting.
class _RequestInfo {
  final DateTime timestamp;
  final String host;

  _RequestInfo({
    required this.timestamp,
    required this.host,
  });
}

/// Token bucket for rate limiting.
class _TokenBucket {
  final int capacity;
  final int refillRate; // tokens per second
  int _tokens;
  DateTime _lastRefill;

  _TokenBucket({
    required this.capacity,
    required this.refillRate,
  })  : _tokens = capacity,
        _lastRefill = DateTime.now();

  /// Tries to consume a token. Returns true if successful.
  bool tryConsume() {
    _refill();
    if (_tokens > 0) {
      _tokens--;
      return true;
    }
    return false;
  }

  /// Gets the time until the next token is available.
  Duration timeUntilNextToken() {
    _refill();
    if (_tokens > 0) {
      return Duration.zero;
    }

    // Calculate time until next token
    final timeSinceLastRefill = DateTime.now().difference(_lastRefill);
    final tokensToAdd =
        (timeSinceLastRefill.inMilliseconds / 1000 * refillRate).floor();

    if (tokensToAdd < 1) {
      final millisecondsUntilNextToken = (1000 / refillRate).ceil();
      return Duration(milliseconds: millisecondsUntilNextToken);
    }

    return Duration.zero;
  }

  /// Refills tokens based on time elapsed.
  void _refill() {
    final now = DateTime.now();
    final timeSinceLastRefill = now.difference(_lastRefill);
    final secondsElapsed = timeSinceLastRefill.inMilliseconds / 1000;

    final tokensToAdd = (secondsElapsed * refillRate).floor();
    if (tokensToAdd > 0) {
      _tokens = (_tokens + tokensToAdd).clamp(0, capacity);
      _lastRefill = now;
    }
  }
}

/// Interceptor that implements rate limiting for outgoing requests.
///
/// This interceptor uses a token bucket algorithm to limit the rate
/// of requests per host and globally.
class RateLimitInterceptor extends Interceptor {
  final HttpClientConfig config;

  /// Global rate limit (requests per second).
  final int globalRateLimit;

  /// Per-host rate limit (requests per second).
  final int perHostRateLimit;

  /// Window size for sliding window rate limiting.
  final Duration windowSize;

  /// Whether to queue requests that exceed the rate limit.
  final bool queueRequests;

  /// Maximum queue size per host.
  final int maxQueueSize;

  // Token buckets for rate limiting
  late final _TokenBucket _globalBucket;
  final Map<String, _TokenBucket> _hostBuckets = {};

  // Request queues
  final Map<String, Queue<_QueuedRequest>> _requestQueues = {};

  // Request history for monitoring
  final List<_RequestInfo> _requestHistory = [];

  /// Creates a new rate limit interceptor.
  RateLimitInterceptor({
    required this.config,
    this.globalRateLimit = 100, // 100 requests per second globally
    this.perHostRateLimit = 10, // 10 requests per second per host
    this.windowSize = const Duration(minutes: 1),
    this.queueRequests = true,
    this.maxQueueSize = 50,
  }) {
    _globalBucket = _TokenBucket(
      capacity: globalRateLimit * 10, // 10 second burst capacity
      refillRate: globalRateLimit,
    );
  }

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final host = options.uri.host;

    // Get or create host bucket
    final hostBucket = _getOrCreateHostBucket(host);

    // Check if request can proceed immediately
    if (_globalBucket.tryConsume() && hostBucket.tryConsume()) {
      _recordRequest(host);
      return handler.next(options);
    }

    // Request exceeds rate limit
    if (!queueRequests) {
      // Reject immediately
      if (config.enableLogging) {
        if (kDebugMode) {
          print('[RateLimitInterceptor] Rate limit exceeded for $host');
        }
      }

      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: 'Rate limit exceeded',
          response: Response(
            requestOptions: options,
            statusCode: 429,
            statusMessage: 'Too Many Requests',
          ),
        ),
      );
      return;
    }

    // Queue the request
    await _queueRequest(options, handler, host);
  }

  /// Gets or creates a token bucket for a host.
  _TokenBucket _getOrCreateHostBucket(String host) {
    return _hostBuckets.putIfAbsent(
      host,
      () => _TokenBucket(
        capacity: perHostRateLimit * 10, // 10 second burst capacity
        refillRate: perHostRateLimit,
      ),
    );
  }

  /// Records a request for monitoring.
  void _recordRequest(String host) {
    final now = DateTime.now();
    _requestHistory.add(_RequestInfo(timestamp: now, host: host));

    // Clean old entries
    final cutoff = now.subtract(windowSize);
    _requestHistory.removeWhere((info) => info.timestamp.isBefore(cutoff));
  }

  /// Queues a request that exceeded the rate limit.
  Future<void> _queueRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
    String host,
  ) async {
    // Get or create queue for host
    final queue =
        _requestQueues.putIfAbsent(host, () => Queue<_QueuedRequest>());

    // Check queue size
    if (queue.length >= maxQueueSize) {
      if (config.enableLogging) {
        if (kDebugMode) {
          print('[RateLimitInterceptor] Request queue full for $host');
        }
      }

      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: 'Rate limit queue full',
          response: Response(
            requestOptions: options,
            statusCode: 429,
            statusMessage: 'Too Many Requests',
          ),
        ),
      );
      return;
    }

    // Create queued request
    final queuedRequest = _QueuedRequest(
      options: options,
      handler: handler,
      completer: Completer<void>(),
    );

    queue.add(queuedRequest);

    if (config.enableLogging) {
      if (kDebugMode) {
        print(
            '[RateLimitInterceptor] Request queued for $host (queue size: ${queue.length})');
      }
    }

    // Start processing queue if not already running
    _processQueue(host);

    // Wait for request to be processed
    await queuedRequest.completer.future;
  }

  /// Processes queued requests for a host.
  Future<void> _processQueue(String host) async {
    final queue = _requestQueues[host];
    if (queue == null || queue.isEmpty) {
      return;
    }

    final hostBucket = _getOrCreateHostBucket(host);

    while (queue.isNotEmpty) {
      // Wait for tokens to be available
      final globalDelay = _globalBucket.timeUntilNextToken();
      final hostDelay = hostBucket.timeUntilNextToken();
      final delay = globalDelay > hostDelay ? globalDelay : hostDelay;

      if (delay > Duration.zero) {
        await Future.delayed(delay);
      }

      // Try to consume tokens
      if (_globalBucket.tryConsume() && hostBucket.tryConsume()) {
        final queuedRequest = queue.removeFirst();
        _recordRequest(host);

        if (config.enableLogging) {
          if (kDebugMode) {
            print('[RateLimitInterceptor] Processing queued request for $host '
                '(remaining: ${queue.length})');
          }
        }

        // Process the request
        queuedRequest.handler.next(queuedRequest.options);
        queuedRequest.completer.complete();
      }
    }

    // Remove empty queue
    if (queue.isEmpty) {
      _requestQueues.remove(host);
    }
  }

  /// Gets current rate limit statistics.
  Map<String, dynamic> getStatistics() {
    final now = DateTime.now();
    final cutoff = now.subtract(windowSize);

    // Calculate global rate
    final recentRequests = _requestHistory
        .where((info) => info.timestamp.isAfter(cutoff))
        .toList();

    // Calculate per-host rates
    final hostCounts = <String, int>{};
    for (final request in recentRequests) {
      hostCounts[request.host] = (hostCounts[request.host] ?? 0) + 1;
    }

    return {
      'globalRequestsInWindow': recentRequests.length,
      'globalRequestsPerSecond': recentRequests.length / windowSize.inSeconds,
      'hostRequestCounts': hostCounts,
      'queuedRequests':
          _requestQueues.map((host, queue) => MapEntry(host, queue.length)),
      'windowSize': windowSize.toString(),
    };
  }

  /// Clears all queued requests.
  void clearQueues() {
    for (final queue in _requestQueues.values) {
      for (final request in queue) {
        request.handler.reject(
          DioException(
            requestOptions: request.options,
            type: DioExceptionType.cancel,
            error: 'Rate limit queue cleared',
          ),
        );
        request.completer.completeError('Queue cleared');
      }
    }
    _requestQueues.clear();
  }
}

/// A queued request waiting for rate limit.
class _QueuedRequest {
  final RequestOptions options;
  final RequestInterceptorHandler handler;
  final Completer<void> completer;

  _QueuedRequest({
    required this.options,
    required this.handler,
    required this.completer,
  });
}
