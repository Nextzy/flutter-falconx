# Network

`package: flutter_falconnect` (re-exports `connectivity_plus`, `dart_falconnect`, `flutter_falmodel`), except `InternetConnectionBloc`, which lives in `package: flutter_falconx` (`lib/networks/internet_connection_bloc.dart`).

For `BaseHttpClient`, Retrofit, `HttpClientConfig`, interceptor configuration, and exceptions, see the `dart-falconx-package` skill's `references/http.md` — `flutter_falconnect` does not add its own HTTP client, only a connectivity gate and stream/future fetch plumbing on top of `dart_falconnect`.

## `ConnectivityInterceptor`

A Dio interceptor that rejects a request before it leaves the device when there is no usable connection (wifi, ethernet, mobile, or VPN).

```dart
class ConnectivityInterceptor extends Interceptor {
  ConnectivityInterceptor({Connectivity? connectivity});
}
```

```dart
DefaultHttpClient.instance.dio.interceptors.add(ConnectivityInterceptor());
```

On no connectivity it rejects with a `DioException` whose `error` is `NoInternetConnectException` (`connectionError` type) rather than letting the request time out.

## `InternetConnectionBloc`

`package: flutter_falconx`. Wraps `connectivity_plus`'s `Connectivity` as a `BlocBase<List<ConnectivityResult>>`.

```dart
class InternetConnectionBloc extends BlocBase<List<ConnectivityResult>> {
  InternetConnectionBloc({required List<ConnectivityResult> initialResult, Connectivity? connectivity});
  List<ConnectivityResult> get result;
  bool get isConnectedInternet;    // true if wifi, ethernet, mobile, or vpn is present
  bool get isNotConnectedInternet;
}
```

```dart
final connection = InternetConnectionBloc(initialResult: await Connectivity().checkConnectivity());
BlocBuilder<InternetConnectionBloc, List<ConnectivityResult>>(
  bloc: connection,
  builder: (context, result) => connection.isConnectedInternet ? content : const OfflineBanner(),
);
```

## `EitherStreamFetcher<T>` / `EitherStreamFetcherList`

The machinery behind `FalconBloc.fetchEither*` (`references/state.md`); use directly only when you need fetch lifecycle management outside a `FalconBloc`.

```dart
class EitherStreamFetcher<T> {
  EitherStreamFetcher([StreamController<WidgetDataState<T?>>? controller]);
  Stream<WidgetDataState<T?>> get stream;
  bool get isClosed;
  Stream<WidgetDataState<T?>> fetch(Stream<Either<Failure, T>> call);
  Future<void> close();
}

class EitherStreamFetcherList {
  Stream<WidgetDataState<T?>> fetchStream<T>({required Object key, required Stream<Either<Failure, T>> call, bool debounceFetch = true});
  Stream<WidgetDataState<T?>> fetchFuture<T>({required Object key, required Future<Either<Failure, T>> call, bool debounceFetch = true});
  int get activeCount;
  bool get hasActiveFetchers;
  void closeSync();
  Future<void> closeAsync();
}
```

`debounceFetch: true` (the default) drops a repeat `fetchStream`/`fetchFuture` call for a `key` already in flight and returns the existing fetcher's stream instead; `debounceFetch: false` cancels the in-flight fetcher and starts a new one. Every fetcher emits `WidgetDataState.loading(null)` first, then `success`/error from the underlying `Either`.

## `NLog`

A boxed-corner console logger, active only outside release mode (`!kReleaseMode`).

```dart
class NLog {
  static void i(String tag, String message);
  static void e(String tag, String serviceName, Object exception);
}
```

```dart
NLog.i('UserRepo', 'fetched ${users.length} users');
NLog.e('UserRepo', 'getUser', exception);
```

For general debug logging outside a network context, prefer `Log` (`references/utils.md`), which adds levels, ANSI color, and stack traces.

## Gotchas

- `ConnectivityInterceptor` checks connectivity per request; it does not cache the result or replace `InternetConnectionBloc`'s continuous stream for UI banners.
- `EitherStreamFetcherList.fetchStream` treats a debounce hit for a key that resolved to a different generic type as a fallback: it creates a brand-new fetcher rather than crashing on the cast, but this only happens if you reuse a `key` across mismatched types.
