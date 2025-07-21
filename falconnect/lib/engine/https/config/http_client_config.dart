import 'package:dio/dio.dart';

/// Configuration class for HTTP client behavior.
///
/// This class provides a centralized way to configure HTTP client
/// behavior including timeouts, retries, caching, and connection pooling.
class HttpClientConfig {
  /// Creates a new HTTP client configuration.
  const HttpClientConfig({
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.maxRetryAttempts = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.maxRetryDelay = const Duration(seconds: 30),
    this.enableCache = true,
    this.maxCacheSize = 50 * 1024 * 1024, // 50 MB
    this.cacheDuration = const Duration(minutes: 15),
    this.enableLogging = false,
    this.logBodies = false,
    this.enablePerformanceMonitoring = true,
    this.maxConnectionsPerHost = 5,
    this.idleConnectionTimeout = const Duration(seconds: 15),
    this.validateCertificates = true,
    this.followRedirects = true,
    this.maxRedirects = 5,
    this.userAgent,
    this.defaultHeaders = const {},
  });

  /// Creates a production-ready configuration with conservative settings.
  factory HttpClientConfig.production() {
    return const HttpClientConfig(
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 60),
      sendTimeout: Duration(seconds: 60),
      maxRetryAttempts: 3,
      retryDelay: Duration(seconds: 2),
      maxRetryDelay: Duration(minutes: 1),
      enableCache: true,
      maxCacheSize: 100 * 1024 * 1024,
      // 100 MB
      cacheDuration: Duration(minutes: 30),
      enableLogging: false,
      logBodies: false,
      enablePerformanceMonitoring: true,
      maxConnectionsPerHost: 10,
      idleConnectionTimeout: Duration(seconds: 30),
      validateCertificates: true,
      followRedirects: true,
      maxRedirects: 5,
    );
  }

  /// Creates a development configuration with verbose logging.
  factory HttpClientConfig.development() {
    return const HttpClientConfig(
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 30),
      sendTimeout: Duration(seconds: 30),
      maxRetryAttempts: 1,
      retryDelay: Duration(seconds: 1),
      maxRetryDelay: Duration(seconds: 5),
      enableCache: false,
      maxCacheSize: 10 * 1024 * 1024,
      // 10 MB
      cacheDuration: Duration(minutes: 5),
      enableLogging: true,
      logBodies: true,
      enablePerformanceMonitoring: true,
      maxConnectionsPerHost: 3,
      idleConnectionTimeout: Duration(seconds: 10),
      validateCertificates: false,
      followRedirects: true,
      maxRedirects: 3,
    );
  }

  /// Creates a test configuration with minimal timeouts.
  factory HttpClientConfig.test() {
    return const HttpClientConfig(
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 5),
      sendTimeout: Duration(seconds: 5),
      maxRetryAttempts: 0,
      retryDelay: Duration(milliseconds: 100),
      maxRetryDelay: Duration(seconds: 1),
      enableCache: false,
      maxCacheSize: 1 * 1024 * 1024,
      // 1 MB
      cacheDuration: Duration(seconds: 30),
      enableLogging: true,
      logBodies: false,
      enablePerformanceMonitoring: false,
      maxConnectionsPerHost: 1,
      idleConnectionTimeout: Duration(seconds: 1),
      validateCertificates: false,
      followRedirects: false,
      maxRedirects: 0,
    );
  }

  /// Connection timeout for establishing a connection.
  final Duration connectTimeout;

  /// Timeout for receiving data from the server.
  final Duration receiveTimeout;

  /// Timeout for sending data to the server.
  final Duration sendTimeout;

  /// Maximum number of retry attempts for failed requests.
  final int maxRetryAttempts;

  /// Base delay for exponential backoff retry strategy.
  final Duration retryDelay;

  /// Maximum delay between retry attempts.
  final Duration maxRetryDelay;

  /// Whether to enable response caching.
  final bool enableCache;

  /// Maximum size of the response cache in bytes.
  final int maxCacheSize;

  /// Duration for which cached responses are considered valid.
  final Duration cacheDuration;

  /// Whether to enable request/response logging.
  final bool enableLogging;

  /// Whether to log request/response bodies.
  final bool logBodies;

  /// Whether to enable performance monitoring.
  final bool enablePerformanceMonitoring;

  /// Maximum number of concurrent connections per host.
  final int maxConnectionsPerHost;

  /// Duration to keep idle connections alive.
  final Duration idleConnectionTimeout;

  /// Whether to validate SSL certificates.
  final bool validateCertificates;

  /// Whether to follow redirects automatically.
  final bool followRedirects;

  /// Maximum number of redirects to follow.
  final int maxRedirects;

  /// User agent string for requests.
  final String? userAgent;

  /// Default headers to include in all requests.
  final Map<String, String> defaultHeaders;

  /// Applies this configuration to a Dio instance.
  void applyTo(Dio dio) {
    dio.options
      ..connectTimeout = connectTimeout
      ..receiveTimeout = receiveTimeout
      ..sendTimeout = sendTimeout
      ..followRedirects = followRedirects
      ..maxRedirects = maxRedirects
      ..validateStatus = (status) => status != null && status < 500;

    // Apply default headers
    dio.options.headers.addAll(defaultHeaders);

    // Apply user agent if specified
    if (userAgent != null) {
      dio.options.headers['User-Agent'] = userAgent;
    }
  }

  /// Creates a copy of this configuration with optional overrides.
  HttpClientConfig copyWith({
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    int? maxRetryAttempts,
    Duration? retryDelay,
    Duration? maxRetryDelay,
    bool? enableCache,
    int? maxCacheSize,
    Duration? cacheDuration,
    bool? enableLogging,
    bool? logBodies,
    bool? enablePerformanceMonitoring,
    int? maxConnectionsPerHost,
    Duration? idleConnectionTimeout,
    bool? validateCertificates,
    bool? followRedirects,
    int? maxRedirects,
    String? userAgent,
    Map<String, String>? defaultHeaders,
  }) {
    return HttpClientConfig(
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      maxRetryAttempts: maxRetryAttempts ?? this.maxRetryAttempts,
      retryDelay: retryDelay ?? this.retryDelay,
      maxRetryDelay: maxRetryDelay ?? this.maxRetryDelay,
      enableCache: enableCache ?? this.enableCache,
      maxCacheSize: maxCacheSize ?? this.maxCacheSize,
      cacheDuration: cacheDuration ?? this.cacheDuration,
      enableLogging: enableLogging ?? this.enableLogging,
      logBodies: logBodies ?? this.logBodies,
      enablePerformanceMonitoring:
          enablePerformanceMonitoring ?? this.enablePerformanceMonitoring,
      maxConnectionsPerHost:
          maxConnectionsPerHost ?? this.maxConnectionsPerHost,
      idleConnectionTimeout:
          idleConnectionTimeout ?? this.idleConnectionTimeout,
      validateCertificates: validateCertificates ?? this.validateCertificates,
      followRedirects: followRedirects ?? this.followRedirects,
      maxRedirects: maxRedirects ?? this.maxRedirects,
      userAgent: userAgent ?? this.userAgent,
      defaultHeaders: defaultHeaders ?? this.defaultHeaders,
    );
  }
}
