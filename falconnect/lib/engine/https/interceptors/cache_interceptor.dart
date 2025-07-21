import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:falconnect/engine/https/config/http_client_config.dart';
import 'package:flutter/foundation.dart';

/// Response cache entry.
class CacheEntry {
  CacheEntry({
    required this.response,
    required this.timestamp,
    required this.maxAge,
  });

  final Response response;
  final DateTime timestamp;
  final Duration maxAge;

  bool get isExpired {
    final age = DateTime.now().difference(timestamp);
    return age > maxAge;
  }
}

/// Interceptor that caches HTTP responses.
///
/// This interceptor implements a simple in-memory cache for GET requests
/// with configurable cache duration and size limits.
class CacheInterceptor extends Interceptor {
  /// Creates a new cache interceptor.
  CacheInterceptor({
    required this.config,
  });

  final HttpClientConfig config;
  final Map<String, CacheEntry> _cache = {};
  int _currentCacheSize = 0;

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Only cache GET requests
    if (!config.enableCache || options.method != 'GET') {
      return handler.next(options);
    }

    // Check for no-cache directive
    final cacheControl = options.headers['cache-control'];
    if (cacheControl == 'no-cache' || cacheControl == 'no-store') {
      return handler.next(options);
    }

    // Generate cache key
    final cacheKey = _generateCacheKey(options);

    // Check if we have a valid cached response
    final cachedEntry = _cache[cacheKey];
    if (cachedEntry != null && !cachedEntry.isExpired) {
      if (config.enableLogging) {
        if (kDebugMode) {
          print(
              '[CacheInterceptor] Cache hit for: ${options.method} ${options.uri}');
        }
      }

      // Return cached response
      return handler.resolve(cachedEntry.response);
    }

    // Remove expired entry
    if (cachedEntry != null && cachedEntry.isExpired) {
      _removeFromCache(cacheKey);
    }

    // Continue with the request
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Only cache successful GET requests
    if (!config.enableCache ||
        response.requestOptions.method != 'GET' ||
        response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      return handler.next(response);
    }

    // Check cache-control headers
    final cacheControl = response.headers.value('cache-control');
    if (cacheControl != null &&
        (cacheControl.contains('no-cache') ||
            cacheControl.contains('no-store'))) {
      return handler.next(response);
    }

    // Generate cache key
    final cacheKey = _generateCacheKey(response.requestOptions);

    // Calculate cache duration
    final cacheDuration = _getCacheDuration(response);

    // Store in cache
    _addToCache(cacheKey, response, cacheDuration);

    handler.next(response);
  }

  /// Generates a unique cache key for a request.
  String _generateCacheKey(RequestOptions options) {
    final url = options.uri.toString();
    final queryParams = jsonEncode(options.queryParameters);
    final headers = jsonEncode(_getCacheableHeaders(options.headers));

    final input = '$url:$queryParams:$headers';

    // Simple hash function without crypto dependency
    return input.hashCode.toString();
  }

  /// Gets headers that should be included in cache key generation.
  Map<String, dynamic> _getCacheableHeaders(Map<String, dynamic> headers) {
    final cacheableHeaders = <String, dynamic>{};

    // Include headers that affect response content
    const relevantHeaders = [
      'accept',
      'accept-language',
      'accept-encoding',
      'authorization',
    ];

    for (final header in relevantHeaders) {
      if (headers.containsKey(header)) {
        cacheableHeaders[header] = headers[header];
      }
    }

    return cacheableHeaders;
  }

  /// Determines cache duration from response headers or config.
  Duration _getCacheDuration(Response response) {
    // Check Cache-Control max-age
    final cacheControl = response.headers.value('cache-control');
    if (cacheControl != null) {
      final maxAgeMatch = RegExp(r'max-age=(\d+)').firstMatch(cacheControl);
      if (maxAgeMatch != null) {
        final seconds = int.tryParse(maxAgeMatch.group(1)!);
        if (seconds != null) {
          return Duration(seconds: seconds);
        }
      }
    }

    // Check Expires header
    final expires = response.headers.value('expires');
    if (expires != null) {
      try {
        // Parse common HTTP date formats
        final expiresDate = DateTime.parse(expires);
        final duration = expiresDate.difference(DateTime.now());
        if (duration.isNegative) {
          return Duration.zero;
        }
        return duration;
      } catch (e) {
        // Invalid expires header, ignore
      }
    }

    // Use default from config
    return config.cacheDuration;
  }

  /// Adds a response to the cache.
  void _addToCache(String key, Response response, Duration maxAge) {
    // Skip if duration is zero
    if (maxAge == Duration.zero) {
      return;
    }

    // Estimate response size
    final responseSize = _estimateResponseSize(response);

    // Check if adding this would exceed cache size
    if (_currentCacheSize + responseSize > config.maxCacheSize) {
      _evictOldestEntries(responseSize);
    }

    // Add to cache
    _cache[key] = CacheEntry(
      response: response,
      timestamp: DateTime.now(),
      maxAge: maxAge,
    );
    _currentCacheSize += responseSize;

    if (config.enableLogging) {
      if (kDebugMode) {
        print(
          '[CacheInterceptor] Cached response for: ${response.requestOptions.method} '
          '${response.requestOptions.uri} (${responseSize ~/ 1024}KB, expires in ${maxAge.inSeconds}s)');
      }
    }
  }

  /// Removes an entry from the cache.
  void _removeFromCache(String key) {
    final entry = _cache.remove(key);
    if (entry != null) {
      _currentCacheSize -= _estimateResponseSize(entry.response);
    }
  }

  /// Evicts oldest entries to make room for new entry.
  void _evictOldestEntries(int requiredSize) {
    // Sort entries by timestamp (oldest first)
    final sortedEntries = _cache.entries.toList()
      ..sort((a, b) => a.value.timestamp.compareTo(b.value.timestamp));

    // Remove entries until we have enough space
    for (final entry in sortedEntries) {
      if (_currentCacheSize + requiredSize <= config.maxCacheSize) {
        break;
      }
      _removeFromCache(entry.key);
    }
  }

  /// Estimates the size of a response in bytes.
  int _estimateResponseSize(Response response) {
    // Start with headers size
    var size = 0;

    // Add headers size
    response.headers.forEach((key, values) {
      size += key.length;
      for (final value in values) {
        size += value.length;
      }
    });

    // Add response data size
    final data = response.data;
    if (data is String) {
      size += data.length;
    } else if (data is List<int>) {
      size += data.length;
    } else if (data != null) {
      // Estimate JSON size
      try {
        size += jsonEncode(data).length;
      } catch (e) {
        // Can't encode, estimate 1KB
        size += 1024;
      }
    }

    return size;
  }

  /// Clears the entire cache.
  void clearCache() {
    _cache.clear();
    _currentCacheSize = 0;
  }

  /// Removes expired entries from the cache.
  void evictExpired() {
    final keysToRemove = <String>[];

    _cache.forEach((key, entry) {
      if (entry.isExpired) {
        keysToRemove.add(key);
      }
    });

    for (final key in keysToRemove) {
      _removeFromCache(key);
    }
  }
}
