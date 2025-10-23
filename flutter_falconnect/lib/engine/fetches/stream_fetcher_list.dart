import 'package:flutter_falconnect/lib.dart';

/// Manages a collection of [EitherStreamFetcher] instances with automatic
/// cleanup, debouncing, and type-safe operations.
/// 
/// Provides centralized management of multiple stream fetchers with proper
/// resource lifecycle management and memory leak prevention.
class EitherStreamFetcherList {
  final Map<dynamic, EitherStreamFetcher> _fetcherMap = 
      <dynamic, EitherStreamFetcher>{};

  /// Fetches data from a stream with automatic debouncing and lifecycle 
  /// management.
  /// 
  /// [key] - Unique identifier for this fetch operation
  /// [call] - The stream to fetch data from
  /// [debounceFetch] - Whether to prevent duplicate fetches for the same key
  /// 
  /// Returns a stream of [WidgetDataState] for the requested data.
  Stream<WidgetDataState<T?>> fetchStream<T>({
    required Object key,
    required Stream<Either<Failure, T>> call,
    bool debounceFetch = true,
  }) {
    // Clean up closed fetchers to prevent memory leaks
    _cleanupClosedFetchers();
    
    if (_canFetch(key, debounceFetch)) {
      final fetcher = EitherStreamFetcher<T>();
      _fetcherMap[key] = fetcher;
      return fetcher.fetch(call);
    } else {
      printError('Debounce fetch!!!');
      // Type-safe casting with fallback
      final existingFetcher = _fetcherMap[key];
      if (existingFetcher is EitherStreamFetcher<T>) {
        return existingFetcher.stream;
      } else {
        // Fallback: create new fetcher if types don't match
        final fetcher = EitherStreamFetcher<T>();
        _fetcherMap[key] = fetcher;
        return fetcher.fetch(call);
      }
    }
  }

  /// Fetches data from a future with automatic debouncing and lifecycle 
  /// management.
  /// 
  /// [key] - Unique identifier for this fetch operation
  /// [call] - The future to fetch data from
  /// [debounceFetch] - Whether to prevent duplicate fetches for the same key
  /// 
  /// Returns a stream of [WidgetDataState] for the requested data.
  Stream<WidgetDataState<T?>> fetchFuture<T>({
    required Object key,
    required Future<Either<Failure, T>> call,
    bool debounceFetch = true,
  }) =>
      fetchStream<T>(
        key: key,
        call: Stream.fromFuture(call),
        debounceFetch: debounceFetch,
      );


  /// Removes closed fetchers from the map to prevent memory leaks
  void _cleanupClosedFetchers() {
    _fetcherMap.removeWhere((key, fetcher) => fetcher.isClosed);
  }

  /// Determines if a fetch operation can proceed based on debouncing rules
  bool _canFetch(Object key, bool debounceFetch) {
    if (debounceFetch) {
      return _fetcherMap[key] == null;
    } else {
      // Remove and close old fetcher before starting new one
      final fetcher = _fetcherMap.remove(key);
      fetcher?.close();
      return true;
    }
  }

  /// Synchronously initiates close operations for all fetchers.
  /// 
  /// Note: This starts the close operations but doesn't wait for completion.
  /// Use [closeAsync] if you need to wait for all operations to complete.
  void closeSync() {
    for (final fetcher in _fetcherMap.values) {
      fetcher.close();
    }
    _fetcherMap.clear();
  }

  /// Asynchronously closes all fetchers and waits for completion.
  /// 
  /// This ensures all resources are properly cleaned up before returning.
  Future<void> closeAsync() async {
    final futures = _fetcherMap.values
        .map((fetcher) => fetcher.close())
        .toList();
    _fetcherMap.clear();
    await Future.wait(futures);
  }

  /// Returns the number of active fetchers
  int get activeCount => _fetcherMap.length;

  /// Returns whether any fetchers are currently active
  bool get hasActiveFetchers => _fetcherMap.isNotEmpty;
}
