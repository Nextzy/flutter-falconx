# FalconX HTTP Engine

A powerful and extensible HTTP client engine built on top of Dio for the FalconX framework.

## Features

- 🚀 **High Performance**: Connection pooling, request caching, and performance monitoring
- 🔄 **Automatic Retry**: Smart retry logic with exponential backoff
- 🛡️ **Rate Limiting**: Token bucket algorithm for global and per-host rate limiting
- 💾 **Response Caching**: In-memory caching with configurable TTL
- 📊 **Performance Monitoring**: Detailed metrics and statistics
- 🔌 **Extensible**: Easy to add custom interceptors
- ⚡ **Type-Safe**: Fully typed with Dart's strong type system

## Architecture

The HTTP engine is built with a layered architecture:

```
┌─────────────────────────────────────────┐
│         Application Layer               │
├─────────────────────────────────────────┤
│         HTTP Client                     │
├─────────────────────────────────────────┤
│         Interceptors                    │
│  ┌────────────┬────────────────────┐   │
│  │ Retry      │ Rate Limit         │   │
│  ├────────────┼────────────────────┤   │
│  │ Cache      │ Performance        │   │
│  ├────────────┼────────────────────┤   │
│  │ Error      │ Connectivity       │   │
│  ├────────────┴────────────────────┤   │
│  │ Logging                         │   │
│  └─────────────────────────────────┘   │
├─────────────────────────────────────────┤
│         Dio HTTP Client                 │
└─────────────────────────────────────────┘
```

## Quick Start

### Basic Usage

```dart
import 'package:falconnect/engine/https/https.dart';

// Create a simple HTTP client
final client = BaseHttpClient.base();

// Make a GET request
final response = await client.get<User>(
  '/users/123',
  converter: (json) => User.fromJson(json),
);

// Handle the result
response.when(
  success: (user) => print('User: ${user.name}'),
  failure: (error) => print('Error: $error'),
);
```

### Configured Client

```dart
// Create a production-ready client
final config = HttpClientConfig.production();
final client = BaseHttpClient.configured(config);

// Make requests with automatic retry, caching, and rate limiting
final users = await client.get<List<User>>(
  '/users',
  converter: (json) => (json as List)
      .map((e) => User.fromJson(e))
      .toList(),
);
```

## Configuration

### HttpClientConfig

The `HttpClientConfig` class provides comprehensive configuration options:

```dart
final config = HttpClientConfig(
  // Timeouts
  connectTimeout: Duration(seconds: 30),
  receiveTimeout: Duration(seconds: 30),
  sendTimeout: Duration(seconds: 30),
  
  // Retry
  maxRetryAttempts: 3,
  retryDelay: Duration(seconds: 1),
  maxRetryDelay: Duration(seconds: 30),
  
  // Caching
  enableCache: true,
  maxCacheSize: 50 * 1024 * 1024, // 50 MB
  cacheDuration: Duration(minutes: 15),
  
  // Logging
  enableLogging: false,
  logBodies: false,
  
  // Performance
  enablePerformanceMonitoring: true,
  maxConnectionsPerHost: 5,
  idleConnectionTimeout: Duration(seconds: 15),
  
  // Security
  validateCertificates: true,
  
  // Redirects
  followRedirects: true,
  maxRedirects: 5,
  
  // Headers
  userAgent: 'MyApp/1.0',
  defaultHeaders: {
    'X-App-Version': '1.0.0',
  },
);
```

### Preset Configurations

```dart
// Production environment
final prodConfig = HttpClientConfig.production();

// Development environment with verbose logging
final devConfig = HttpClientConfig.development();

// Test environment with minimal timeouts
final testConfig = HttpClientConfig.test();
```

## Interceptors

### Retry Interceptor

Automatically retries failed requests with exponential backoff:

```dart
final retryInterceptor = RetryInterceptor(
  config: config,
  dio: dio,
);

// Retries on:
// - Network errors (connection timeout, etc.)
// - Server errors (5XX)
// - Specific client errors (408, 429)
```

### Rate Limit Interceptor

Prevents overwhelming servers with too many requests:

```dart
final rateLimitInterceptor = RateLimitInterceptor(
  config: config,
  globalRateLimit: 100, // 100 requests per second globally
  perHostRateLimit: 10, // 10 requests per second per host
  queueRequests: true, // Queue excess requests instead of rejecting
  maxQueueSize: 50,
);

// Get rate limit statistics
final stats = rateLimitInterceptor.getStatistics();
print('Global rate: ${stats['globalRequestsPerSecond']} req/s');
```

### Cache Interceptor

Caches GET requests to reduce network traffic:

```dart
final cacheInterceptor = CacheInterceptor(
  config: config,
);

// Respects cache-control headers
// Implements LRU eviction when cache is full
// Provides cache statistics

// Clear cache manually
cacheInterceptor.clearCache();

// Evict expired entries
cacheInterceptor.evictExpired();
```

### Performance Interceptor

Monitors request performance and provides detailed metrics:

```dart
final performanceInterceptor = PerformanceInterceptor(
  config: config,
  maxMetricsHistory: 1000,
  collectDetailedTimings: true,
);

// Get performance statistics
final stats = performanceInterceptor.getStatistics();
print('Success rate: ${stats.successRate}%');
print('Average duration: ${stats.averageDuration.inMilliseconds}ms');

// Get URL-specific statistics
final urlStats = performanceInterceptor.getUrlStatistics();
urlStats.forEach((pattern, stats) {
  print('$pattern: ${stats.averageDuration.inMilliseconds}ms');
});
```

## Exception Handling

The HTTP engine provides a rich exception hierarchy:

```dart
try {
  final result = await client.get('/api/data');
} on NetworkException catch (e) {
  if (e is ClientNetworkException) {
    // Handle client errors (4XX)
    switch (e.statusCode) {
      case 401:
        // Handle authentication error
        break;
      case 404:
        // Handle not found
        break;
    }
  } else if (e is ServerNetworkException) {
    // Handle server errors (5XX)
    if (e.isRetryable) {
      // Retry after recommended delay
      await Future.delayed(
        Duration(milliseconds: e.recommendedRetryDelay),
      );
    }
  }
  
  // Show user-friendly message
  showError(e.userFriendlyMessage);
}
```

### Exception Types

- `NetworkException`: Base exception for all network errors
- `BaseHttpException`: Base for HTTP-specific exceptions
- `ClientNetworkException`: 4XX client errors
- `ServerNetworkException`: 5XX server errors
- `NonStandardErrorException`: Non-standard HTTP errors

Each exception provides:
- Status code and error details
- User-friendly error messages
- Retry recommendations
- Request/response information

## Advanced Usage

### Custom Interceptors

Create custom interceptors by extending `Interceptor`:

```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add authentication token
    options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Refresh token and retry
      await refreshToken();
      final response = await retry(err.requestOptions);
      handler.resolve(response);
    } else {
      handler.next(err);
    }
  }
}
```

### Request Cancellation

```dart
final cancelToken = CancelToken();

// Start request
final future = client.get(
  '/large-file',
  cancelToken: cancelToken,
);

// Cancel if needed
cancelToken.cancel('User cancelled');
```

### File Upload

```dart
final formData = FormData.fromMap({
  'name': 'upload.txt',
  'file': await MultipartFile.fromFile(
    '/path/to/file.txt',
    filename: 'upload.txt',
  ),
});

final response = await client.post(
  '/upload',
  data: formData,
  onSendProgress: (sent, total) {
    print('Progress: ${(sent / total * 100).toStringAsFixed(0)}%');
  },
);
```

## Best Practices

1. **Use Configuration Presets**: Start with `HttpClientConfig.production()` or `.development()`
2. **Enable Monitoring**: Keep performance monitoring enabled to identify issues
3. **Handle Exceptions**: Always handle `NetworkException` and its subtypes
4. **Set Reasonable Timeouts**: Adjust timeouts based on your use case
5. **Use Caching Wisely**: Enable caching for frequently accessed, stable data
6. **Monitor Rate Limits**: Check rate limit statistics in production
7. **Test Error Scenarios**: Test network failures, timeouts, and error responses

## Performance Tips

1. **Connection Pooling**: Reuse HTTP clients instead of creating new ones
2. **Response Caching**: Cache responses for read-heavy endpoints
3. **Batch Requests**: Use batch endpoints when available
4. **Compression**: Enable gzip compression for large payloads
5. **Timeout Tuning**: Set appropriate timeouts to fail fast
6. **Parallel Requests**: Use `Future.wait` for independent requests

## Troubleshooting

### Enable Detailed Logging

```dart
final config = HttpClientConfig(
  enableLogging: true,
  logBodies: true, // Log request/response bodies
);
```

### Check Performance Metrics

```dart
final metrics = performanceInterceptor.getRecentMetrics(limit: 10);
for (final metric in metrics) {
  print('${metric.method} ${metric.url}: ${metric.totalDuration.inMilliseconds}ms');
}
```

### Monitor Rate Limiting

```dart
final stats = rateLimitInterceptor.getStatistics();
if (stats['queuedRequests'].isNotEmpty) {
  print('Queued requests: ${stats['queuedRequests']}');
}
```

### Clear Cache

```dart
// Clear all cached responses
cacheInterceptor.clearCache();

// Or evict only expired entries
cacheInterceptor.evictExpired();
```

## Migration Guide

### From Raw Dio

```dart
// Before
final dio = Dio();
final response = await dio.get('/api/users');

// After
final client = BaseHttpClient.configured(HttpClientConfig.production());
final result = await client.get<List<User>>(
  '/api/users',
  converter: (json) => (json as List).map((e) => User.fromJson(e)).toList(),
);
```

### From Other HTTP Clients

1. Replace HTTP client initialization with `BaseHttpClient`
2. Update error handling to use `NetworkException` hierarchy
3. Leverage built-in interceptors instead of custom middleware
4. Use the `Result` type for better error handling

## Contributing

When adding new features to the HTTP engine:

1. Follow the existing architecture patterns
2. Add comprehensive documentation
3. Include unit and integration tests
4. Update this README with examples
5. Ensure backward compatibility

## License

This HTTP engine is part of the FalconX framework and follows the same license terms.