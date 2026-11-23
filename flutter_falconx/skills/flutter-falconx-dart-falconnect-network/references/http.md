# HTTP

`package: dart_falconnect` (re-exports `dio`, `retrofit`, `dio_cache_interceptor`, `web_socket_channel`).

## Recommended: Retrofit + Dio

```dart
// Import the barrel of the falconx package your app lists.
// Only when @Headers is needed: import 'package:retrofit/retrofit.dart' as retrofit;
// and write @retrofit.Headers(...), because dio's own Headers class is in scope.
part 'user_api.g.dart';

// CreateUserBody extends BaseRequestBody (from dart_falmodel); UserDto is your own.
@RestApi()
abstract class UserApi {
  factory UserApi(Dio dio, {String? baseUrl}) = _UserApi;

  @GET('/users/{id}')
  Future<UserDto> getUser(@Path('id') String id);

  @POST('/users')
  Future<UserDto> create(@Body() CreateUserBody body);
}

final api = UserApi(DefaultHttpClient.instance.dio); // base URL from the client config
```

Generate `_UserApi` with `dart run build_runner build --delete-conflicting-outputs`.
Retrofit's `Future<HttpResponse<T>>` gains `.unwrapResponse()` and `.catchWhenError(f)`.

## Configure a client

Every `BaseHttpClient`, `DefaultHttpClient.instance` included, runs on one `HttpClientConfig`: the dio options it owns, plus one box per feature. A null box turns its feature off. With no `configure` call, a client has JSON content type, 20 s connect and receive timeouts, no send timeout, and `DefaultNetworkExceptionHandlerInterceptor`.

```dart
final dev = HttpClientConfig(
  baseUrl: 'https://dev.api.example.com',
  log: const LogConfig(),
  retry: const RetryConfig(maxAttempts: 1),
  rateLimit: const RateLimitConfig.pauseOnly(),
);

// TokenBucketPolicy is from dart_faltool.
final prod = HttpClientConfig(
  baseUrl: 'https://api.example.com',
  cache: const CacheConfig(),
  concurrency: const ConcurrencyConfig(global: 16, perHost: 4),
  rateLimit: RateLimitConfig.tokenBucket(
    perHost: [TokenBucketPolicy(permits: 100, per: const Duration(minutes: 1))],
  ),
  retry: const RetryConfig(),
  auth: AuthConfig(
    accessToken: tokenStore.read,
    refresh: tokenStore.refresh,
    onAuthFailed: (_) => router.go('/login'),
  ),
);

void main() {
  // isRelease is your own build flag.
  DefaultHttpClient.instance.configure(isRelease ? prod : dev);
}
```

`configure` applies to requests that start after it returns. Requests already running finish on the configuration they started with. Only the interceptors whose box changed are rebuilt, so token buckets, 429 pauses, concurrency slots, and the cache survive an unrelated change:

```dart
final client = DefaultHttpClient.instance;
client.configure(client.currentConfig.copyWith(log: const LogConfig())); // limiter kept
client.configure(client.currentConfig.copyWith(log: null));              // log off
client.setupBaseUrl('https://staging.api.example.com');
```

| Box                                                              | Adds                                                                                               | Defaults                                                                                                                                                                             |
|------------------------------------------------------------------|----------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `LogConfig(...)`                                                 | `HttpLogInterceptor`; `diagnostics` also prints interceptor diagnostics                            | request, headers, and bodies on; response headers off; sensitive headers and query values redacted                                                                                   |
| `LogConfig.json(...)`                                            | `HttpJsonLogInterceptor`, one JSON line per attempt (see "Server logging")                         | headers and bodies off; sensitive headers and query values redacted                                                                                                                  |
| `CacheConfig`                                                    | `CacheInterceptor`, plus `cache.fallback` after `RetryInterceptor` when the offline fallback is on | follows the server's cache headers (`CachePolicy.request`); 50 MB memory store; entries keyed by the URL plus `authorization`, `accept`, and `accept-language`; offline fallback off |
| `ConcurrencyConfig`                                              | `ConcurrencyLimitInterceptor`                                                                      | every scope unlimited                                                                                                                                                                |
| `RateLimitConfig.none()`, `.pauseOnly(...)`, `.tokenBucket(...)` | nothing, `RetryAfterPauseInterceptor`, or `TokenBucketRateLimitInterceptor`; never both limiters   | `none()`                                                                                                                                                                             |
| `RetryConfig`                                                    | `RetryInterceptor`                                                                                 | 3 attempts, 1 s base delay, 30 s cap, 60 s deadline                                                                                                                                  |
| `RequestIdConfig`                                                | the ID step of `RequestStampInterceptor` (see "Auth and request headers")                         | `X-Request-ID`, UUID v7                                                                                                                                                              |
| `AuthConfig`                                                     | the token step of `RequestStampInterceptor`, plus `TokenRefreshInterceptor`                        | `Authorization: Bearer <token>`                                                                                                                                                      |
| `IoAdapterConfig`                                                | a dart:io adapter in place of `dio.httpClientAdapter` (see "Transport options"); the web ignores it | no connection limit, 3 s idle timeout, environment proxy, no pins                                                                                                                    |
| `WebAdapterConfig`                                               | a browser adapter in place of `dio.httpClientAdapter`; dart:io ignores it                          | `withCredentials: false`                                                                                                                                                             |

- `LogConfig` is a sealed union of `PrettyLogConfig` (`LogConfig(...)`) and `JsonLogConfig` (`LogConfig.json(...)`). `request`, `requestHeader`, `responseHeader`, and `error` exist only on the pretty variant, so match it before reading or copying them: `if (config.log case final PrettyLogConfig log) client.configure(config.copyWith(log: log.copyWith(responseHeader: true)));`.
- The client orders the chain: `RequestStampInterceptor` when `requestId`, `headerProvider`, or `auth` is set, your `interceptors`, log, cache, concurrency limit, rate limit, `TokenRefreshInterceptor` when `auth` is set, retry, the cache's offline fallback when its box enables it, then `exceptionHandler` (null means `DefaultNetworkExceptionHandlerInterceptor`).
- `configure` owns `baseUrl`, the three timeouts, `contentType`, redirects, `validateStatus` (null means dio's default, 2xx only), and the header keys of `headers` and `userAgent`. Other `dio.options` fields, and headers you set by hand, survive it. So does `dio.httpClientAdapter`, unless the platform's adapter box is set.
- Add interceptors with `addInterceptors` or the config, never with `dio.interceptors.add(...)`: `configure` rebuilds the list.
- When the client switches base URLs, give Retrofit APIs no absolute `baseUrl`, neither as the factory argument nor in `@RestApi(baseUrl:)`. An absolute one wins over `dio.options.baseUrl`.
- A box holding an inline lambda (`logPrint`, `onRetry`, `validateStatus`) is unequal on every `configure`, so its interceptor is rebuilt. Pass top-level functions.
- The next attempt of a request that was retrying across a `configure` passes the new chain, with its old retry settings.
- Call `dispose()` at the end of a test or a CLI. A Flutter app never needs it.

## Auth and request headers

Three `HttpClientConfig` fields stamp headers on every attempt, in this order, before your `interceptors` run. Each is null, and off, by default.

```dart
DefaultHttpClient.instance.configure(
  HttpClientConfig(
    baseUrl: Env.apiBaseUrl,
    headerProvider: (options) => {'Accept-Language': locale.current},
    requestId: const RequestIdConfig(),
    auth: AuthConfig(
      accessToken: tokenStore.accessToken,         // FutureOr<String?> Function()
      refresh: tokenStore.refresh,                 // TokenRefreshCallback: Future<bool> Function() (RefreshCallback before 2.4.0)
      onAuthFailed: (error) => router.go('/login'),
    ),
  ),
);
```

- `requestId` stamps one ID per request under `headerName` (default `X-Request-ID`): a UUID v7, or `generate()`. Every retry attempt and the re-send after a refresh keep the first attempt's ID; a request that sets the header keeps its own value. Read it with `requestOptions.requestId`. On the web, a custom header makes the browser send a CORS preflight, so the server must list it in `Access-Control-Allow-Headers`. Never add it to `CacheConfig.keyHeaders`, or every request misses the cache.
- `headerProvider` runs for every attempt and may be async. Its headers override `headers` and lose to headers the request sets itself; on a retry it runs again and overwrites the values it wrote before.
- `auth` writes `Authorization: Bearer <accessToken()>` (`headerName` and `scheme` change it; `scheme: ''` sends the bare token). It overwrites any `Authorization` the request set; to send your own, pass `isUseToken: false`. A null token sends no header, and a 401 that arrives after `accessToken()` turns null passes on without a refresh. The app owns the token: refresh before expiry inside `accessToken()` if you want it. The token header is redacted in both logs and keys the cache exactly as `Authorization` does: wherever `redactHeaders` or `keyHeaders` holds `authorization`, the client adds a custom `headerName` too. A chain you build by hand adds it to both sets itself.
- On a 401 to a request that carried a token, `TokenRefreshInterceptor` calls `refresh()` once for every request failing at the same time, then sends each again with the new token. A request whose token is already older than the current one is sent again without a refresh, and a request that starts during a refresh waits for it.
- When `refresh()` returns false or throws, `onAuthFailed` runs once and every waiting request fails with its 401, mapped as any 401. A re-send that gets a 401 again also calls `onAuthFailed`. Later 401s with the same failed token neither refresh nor call it again. `onAuthFailed` is not awaited.
- Requests sent from inside `refresh()` never wait for the refresh and never refresh, so calling your refresh endpoint through the same client does not deadlock. Still send it with `isUseToken: false` or a separate `Dio`.
- A `Stream` body refreshes but is not sent again. A `FormData` body is cloned for the re-send.
- Retrofit requests get all of this through the client's `dio`. Turn the token off on an endpoint with `@noToken`, or per call with `@Extras()`:

```dart
@GET('/public/news')
@noToken
Future<List<NewsDto>> news();

@GET('/feed')
Future<List<NewsDto>> feed(@Extras() Map<String, dynamic> extras);
// api.feed({useTokenExtraKey: false});
```

- `AuthConfig` holds functions, which compare by identity. `copyWith` keeps them, so an unrelated `configure` keeps the running refresh; a config built with new closures builds a new `AuthSession` and forgets the failed token. A new session does not join a refresh already running, so a `configure` with new closures during a refresh can start a second one; pass tear-offs, as the example does.

## Transport options

Two boxes set what the platform's HTTP adapter does. Both fit in one config: dart:io platforms (Android, iOS, macOS, Windows, Linux, servers) read only `ioAdapter`, and the web reads only `webAdapter`, so the app never imports `dart:io` or `package:dio/io.dart`.

```dart
DefaultHttpClient.instance.configure(
  HttpClientConfig(
    baseUrl: 'https://api.example.com',
    ioAdapter: IoAdapterConfig(
      maxConnectionsPerHost: 6,
      proxy: isDebug ? '192.168.1.10:9090' : null, // isDebug is your own build flag
      pins: isDebug
          ? const {}
          : const {
              'api.example.com': {
                'sha256/AAAA...=', // current key
                'sha256/BBBB...=', // backup key
              },
            },
      debugTrustAnyCertificate: true,
    ),
    webAdapter: const WebAdapterConfig(withCredentials: true),
  ),
);
```

| `IoAdapterConfig` field | Effect | Default |
|---|---|---|
| `maxConnectionsPerHost` | most open connections to one host; requests past it wait inside `HttpClient`, and the wait counts toward `connectTimeout` | no limit |
| `idleTimeout` | how long an idle connection stays open for reuse | 3 s, as dio uses |
| `proxy` | `host:port` for every request; a request that cannot reach the proxy goes direct, except to a pinned host | the `https_proxy`, `http_proxy`, and `no_proxy` environment variables |
| `pins` | certificate pins per host, `sha256/<base64>` of the leaf's SubjectPublicKeyInfo | none |
| `debugTrustAnyCertificate` | trusts every certificate chain while assertions are enabled (Flutter debug, `dart test`, `dart run --enable-asserts`); release builds and `dart compile exe` ignore it | off |

**Certificate pinning**

- The leaf certificate is checked right after the TLS handshake, before `HttpClient` writes any byte of the request, token included. A server behind a wrong pin therefore logs a completed handshake with no request after it. A mismatch fails with a `DioException` of type `badCertificate` whose `error` is a `CertificatePinningException`; `RetryInterceptor` never retries it.
- `CertificatePinningException.failure` says why: `mismatch`, `proxied` (a pinned `https` host through any proxy, the environment's included, since no pin can be checked there), `plainHttp` (a pinned host over `http`, which never goes through a proxy, so it cannot ride a pooled proxy connection), or `unreadableCertificate`. On a mismatch, `presented` holds the pin the server sent.
- Get a host's pin:

  ```bash
  openssl s_client -connect api.example.com:443 -servername api.example.com </dev/null \
    | openssl x509 -pubkey -noout \
    | openssl pkey -pubin -outform der \
    | openssl dgst -sha256 -binary | base64
  ```

- The pin follows the server's key, not its certificate. It survives a renewal only when the server keeps its key: `certbot` makes a new key on every renewal unless you pass `--reuse-key`. Ship a backup pin for the next key in every release, or installed apps stop connecting when the key changes.
- Only the leaf can be pinned; Dart exposes no certificate chain. Hosts match exactly, ignoring case and a trailing dot in the URL, with no wildcards.
- `configure` throws `ArgumentError` on a malformed pin, a pin host that is not a bare host name (a wildcard or a trailing dot included), or a malformed `proxy`, on every platform, the web included.

**Debugging with Proxyman on Android**

Set `proxy` to the Mac's address and `debugTrustAnyCertificate: true`, and drop the pins in debug builds, as the example above does: pins still apply with the switch on, so a pinned host rejects Proxyman's certificate. Hosts without a pin show in Proxyman, and fall back to direct when Proxyman is closed.

**Swapping and ownership**

- A box builds a new adapter when it changes; an equal box keeps the adapter. The replaced adapter closes with `force: false`, so requests already running on it finish. Requests still waiting in a limiter, and retries, go out through the new adapter.
- While a box is set, the client owns `dio.httpClientAdapter`. A box that returns to null, and `dispose()`, put back the adapter `dio` had before, which the client never closes.
- `withCredentials` on the web makes cross-site requests send cookies and authorization headers; a request's `extra['withCredentials']` overrides it.

## Custom client: subclass `BaseHttpClient`

Write one client class per external system, and pass its configuration to the super constructor:

```dart
class PaymentHttpClient extends BaseHttpClient {
  PaymentHttpClient()
    : super(
        dio: Dio(),
        config: HttpClientConfig(
          baseUrl: 'https://pay.example.com',
          retry: const RetryConfig(),
          interceptors: [PaymentAuthInterceptor()],
        ),
      );
}
```

An interceptor that needs the client's `dio`, such as one that re-sends a request, is built in the constructor body, where `dio` is ready. `PaymentReplayInterceptor` stands for your own `Interceptor` subclass that takes a `Dio`; for token refresh, set `auth` instead:

```dart
class PaymentHttpClient extends BaseHttpClient {
  PaymentHttpClient() : super(dio: Dio()) {
    configure(HttpClientConfig(
      baseUrl: 'https://pay.example.com',
      interceptors: [PaymentReplayInterceptor(dio)],
    ));
  }
}
```

The constructor applies the configuration at once. It replaces what an injected `Dio` had for the options the configuration owns (base URL, timeouts, content type, redirects, `validateStatus`, and its header keys); the adapter and every other option stay. Set those values through the configuration.

Your interceptors run before `ConcurrencyLimitInterceptor`, so they follow its slot-safety rule (see "Interceptor order"): end `onResponse` and `onError` with `handler.next(...)` or `handler.reject(err, true)`.

Members: `dio`, `baseUrl`, `options` (the dio `BaseOptions`), `interceptors`, `currentConfig`, `configure(config)`, `setupBaseUrl(url)`, `addInterceptors(interceptors)`, `dispose()`.

## Converter-based calls

Every method takes `converter: (Map<String, dynamic> json) => T` and returns `Future<Response<T>>`; `BaseRequestBody` is from `dart_falmodel`. A plain `String` body arrives as `{'result': body}`.

| Method                                | Body                                                    | Extras                                                                                       |
|---------------------------------------|---------------------------------------------------------|----------------------------------------------------------------------------------------------|
| `get<T>`                              | none                                                    | `queryParameters`, `options`, `cancelToken`, `onReceiveProgress`                             |
| `post<T>`, `patch<T>`, `put<T>`       | `data: BaseRequestBody?` (serialised with `toJson()`)   | plus `onSendProgress`                                                                        |
| `postFormData<T>`, `putFormData<T>`   | `data: FormData?`                                       | same                                                                                         |
| `delete<T>`                           | `data: BaseRequestBody?`                                | `queryParameters`, `cancelToken`                                                             |

Every method accepts a converter that may be async. `catchError: (DioException e, StackTrace? st) => T?` returns a fallback value, and returning `null` rethrows the original error; a failure with no response, such as a timeout or a lost connection, recovers too. A body that is not a JSON object, or a converter that throws, fails with a `DioException` whose `error` is `CommonException(type: InputErrorType.invalidFormat)`, and `catchError` sees it. `isUseToken: false` sets `requestOptions.useToken` to false, so the auth interceptors neither stamp nor refresh a token; `useToken` reads true when unset, Retrofit requests included, and `@noToken` turns it off there.

```dart
final res = await client.get<UserDto>('/users/$id', converter: UserDto.fromJson);
final user = res.data;
```

## Interceptor catalog

| Class                                       | Constructor                                                                                                                                                                                                         | Behaviour                                                                                                                                                                                                                                                                                                                                                                         |
|---------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `RequestStampInterceptor`                   | `(requestId:, headerProvider:, auth:, dio:)` | stamps the request ID, the provider's headers, and the token on every attempt; a throwing callback fails the request with a `DioException` of type `unknown` naming the callback |
| `TokenRefreshInterceptor`                   | `(session:, dio:)` | on a 401 to a request that carried a token: one refresh for all concurrent 401s, then a re-send through the whole chain; resolves with the re-send's response or rejects with its error |
| `AuthSession`                               | `(config, logPrint:)` | not an interceptor: the refresh state both auth interceptors share; pass one session to both in a hand-built chain. `isInsideRefresh`, `waitForRefresh()`, `refreshFor(token, error)`, `isFailedToken(token)`, and `fail(token, error)` are the contract those two use; an app never calls them |
| `RetryInterceptor`                          | `(config: RetryConfig(maxAttempts: 3, delay: 1 s, maxDelay: 30 s, maxDuration: 60 s, onRetry:), dio:, logPrint:, random:)`                                                                                          | loops up to `retryAttempts ?? config.maxAttempts`; 429 and `connectionTimeout` for every method; timeouts, connection errors, 408/409/5xx only for idempotent methods unless `retryNonIdempotent`; `Retry-After` on 429/503 (not retried above `maxDelay`), else full jitter; stops at `config.maxDuration`; never retries cancels, local 429s, `Stream` bodies, bad certificates |
| `CacheInterceptor`                          | `(config: CacheConfig(policy: CachePolicy.request, maxStale:, maxSize: 50 MB, store:, keyHeaders: {authorization, accept, accept-language}, hitCacheOnNetworkFailure: false, hitCacheOnErrorCodes: {}), logPrint:)` | `dio_cache_interceptor` underneath; follows `Cache-Control`, `Expires`, `ETag`, and `Last-Modified`; a hit is decoded fresh from stored bytes, bound to the current request, passes every response interceptor, and reads `response.isCacheHit`; `store`, `clearCache()`, `fallback` (see "Caching")                                                                              |
| `ConcurrencyLimitInterceptor`               | `(config: ConcurrencyConfig(global:, perHost:, hosts:, queueRequests: true, maxQueueSize: 50, maxGlobalQueueSize: 500), logPrint:)`                                                                                 | most requests in flight per host and in total, on `resilience` `Bulkhead`; a null limit means none; full queue → local 429 with `BulkheadRejectedException` and no `Retry-After`; a retry or re-send sent while its request still holds a slot shares that slot, but `RetryInterceptor` and `TokenRefreshInterceptor` send after the slot is back, so theirs take a new one; `getStatistics()`, `dispose()`                                                                                                                    |
| `TokenBucketRateLimitInterceptor`           | `(config: TokenBucketRateLimitConfig(global: [], perHost: [], hosts: {}, queueRequests: true, maxQueueSize: 50, maxGlobalQueueSize: 500, pause: PauseConfig()), logPrint:)`                                         | token buckets from `TokenBucketPolicy` lists; no policy means no token limit; pauses a host on 429, or 503 with `Retry-After`; full queue or long pause → local 429 through the error chain; `getStatistics()`, `dispose()`; do not add `RetryAfterPauseInterceptor` next to it                                                                                                   |
| `RetryAfterPauseInterceptor`                | `(config: PauseOnlyRateLimitConfig(pause: PauseConfig(maxPauseWait: 10 s, maxPause: 10 min, defaultPause: 5 s), maxQueueSize: 50), logPrint:)`                                                                      | the pause of `TokenBucketRateLimitInterceptor` without token limits; `dispose()`                                                                                                                                                                                                                                                                                                  |
| `HttpLogInterceptor`                        | `(enabled, request, requestHeader, requestBody, responseHeader, responseBody, error, redactHeaders, redactQueryParameters, logPrint)`                                                                               | ANSI-coloured chunked printing, following the global `ansiColorDisabled`, which it never writes; prints the status and duration of every response and error; redacts listed headers and query values; logs requests and responses from anywhere in the chain, errors only when placed before `RetryInterceptor` and the exception handler                                         |
| `HttpJsonLogInterceptor`                    | `(config: JsonLogConfig(requestHeaders: false, responseHeaders: false, requestBody: false, responseBody: false, maxBodyBytes: 4096, redactHeaders:, redactQueryParameters:, logPrint:))`                            | one JSON line per attempt with OpenTelemetry field names (see "Server logging"); never resolves or rejects; a throwing `logPrint` is ignored                                                                                                                                                                                                                                      |
| `NetworkExceptionHandlerInterceptor`        | abstract `QueuedInterceptor`                                                                                                                                                                                        | implement `onClientError` (4xx) and `onServerError` (5xx), optionally `onNonStandardError`; connect/receive timeouts become `NetworkTimeoutException` first                                                                                                                                                                                                                       |
| `DefaultNetworkExceptionHandlerInterceptor` | `()`                                                                                                                                                                                                                | rejects every error as-is                                                                                                                                                                                                                                                                                                                                                         |

Every `config` defaults to its box built with no arguments. `logPrint` receives diagnostics; null prints nothing. The two logs are the exception: their `logPrint` receives the log itself and defaults to the console. Inside a `BaseHttpClient`, the client passes a printer that follows `LogConfig.diagnostics`.

`HttpClientConfig` is freezed: `==`, `copyWith` (which can set a box to `null`), `effectiveHeaders`, and `applyTo(dio)`, which writes the owned options onto a bare `Dio`, merges `headers`, and sets `validateStatus` only when given. It has no presets.

The public model classes behind the interceptors (`ConcurrencyLimitStatistics`, `TokenBucketRateLimitStatistics`) are freezed classes exported from `interceptors/models/`. Every `getStatistics()` returns an immutable snapshot: its maps throw on mutation, and a snapshot taken earlier keeps its values while the interceptor handles more requests.

## Interceptor order

`BaseHttpClient` assembles this order itself, with your `interceptors`, and `HttpLogInterceptor` or `HttpJsonLogInterceptor` in front. A chain you build by hand on a bare `Dio` must follow it:

```dart
final cache = CacheInterceptor();
final session = AuthSession(authConfig);
dio.interceptors.addAll([
  RequestStampInterceptor(auth: session, dio: dio),
  cache,
  ConcurrencyLimitInterceptor(
    config: const ConcurrencyConfig(global: 16, perHost: 4),
  ),
  TokenBucketRateLimitInterceptor(), // or RetryAfterPauseInterceptor, never both
  TokenRefreshInterceptor(session: session, dio: dio),
  RetryInterceptor(dio: dio),
  cache.fallback, // answers only when the box enables the offline fallback
  DefaultNetworkExceptionHandlerInterceptor(),
]);
```

- `CacheInterceptor` comes before the limiters: a cache hit answers in `onRequest` before the limiters see the request, so it takes no concurrency slot and spends no token. The hit still passes every response interceptor, where the limiters find no slot to give back. Any interceptor that answers in `onRequest`, such as a cache or a mock, goes before `ConcurrencyLimitInterceptor`; placed after it, every answer it gives with a plain `resolve` keeps a slot forever. The cache's `fallback` goes after `RetryInterceptor`: it answers a failed request from the cache only after the last retry, and after `ConcurrencyLimitInterceptor.onError` has returned the slot.
- `ConcurrencyLimitInterceptor` comes before the rate limiter: the slot is taken before the tokens, so the token ceiling holds on the wire and the pause gate sees every request. A request holds its slot while the rate limiter holds it, so set `perHost` below `global`, for example 4 and 16, so one slow or paused host cannot take every global slot.
- The rate limiter comes before `RetryInterceptor`: dio runs `onError` in list order, so the limiter sees a server 429 and starts the pause before the retry is sent. The retry then passes the pause gate, and the total wait is the longer of the retry delay and the pause, never their sum.
- `RequestStampInterceptor` comes first, so the log prints the stamped headers, the cache keys entries by the token, and your interceptors see every stamped header.
- `TokenRefreshInterceptor` comes after the rate limiter and before `RetryInterceptor`: the 401 attempt gives its slot back and reaches the log like any failure, the re-send takes a new slot and a new token, and a 401 never enters the retry loop. It rejects a failed re-send without the rest of the chain, which the re-send already passed.
- Use `auth` rather than your own refresh interceptor. One of your own that re-sends from `onError` goes in your `interceptors`, which a `BaseHttpClient` places before `ConcurrencyLimitInterceptor`. There the re-send reuses its request's slot, as long as the interceptor ends the error phase by the slot-safety rule below.
- **Slot safety.** dio has no "request finished" hook, so `ConcurrencyLimitInterceptor` gives a slot back only when its own `onResponse` or `onError` runs, or when the request's `CancelToken` cancels. Keep both reachable:
  - Interceptors after it end `onRequest` with `handler.next(...)`, `handler.resolve(response, true)`, or `handler.reject(err, true)`. A plain `resolve` or `reject` skips the limiter's `onResponse` and `onError` (a cancel-type reject is safe). An auth interceptor that rejects when it has no token must pass `true`.
  - Interceptors before it end `onResponse` and `onError` with `handler.next(...)` or `handler.reject(err, true)`. A business-error interceptor that turns a 200 into a `DioException` must pass `true`, or go after the limiter. `handler.resolve(...)` in their `onError` is safe only with the response of a re-send of the same `RequestOptions`, which gives the slot back itself.
- `DefaultNetworkExceptionHandlerInterceptor` comes last: it rejects without calling later error interceptors, so a `ConcurrencyLimitInterceptor` placed after it would never get its slots back.
- Every retry passes the whole chain again, so error interceptors see each attempt. Placed before `RetryInterceptor`, one sees every attempt exactly once with a distinct `requestOptions.retryAttempt`; placed after it, one sees attempts 1..n from inside the retries plus the final error again, so it reports the last failure twice. Place error loggers and crash reporters before `RetryInterceptor`.
- A retry is a fresh `dio.fetch` of a copy of the original options. To replay a failed request by hand, call `dio.get(...)` (or `fetch` with fresh options) again, not `dio.fetch(error.requestOptions)`: the failed options carry `retryAttempt > 0`, which reads as a nested attempt and is never retried.

## Caching

`CacheConfig()` follows the server: a `GET` response is stored only when its headers allow it (`Cache-Control: max-age`, `Expires`, `ETag`, or `Last-Modified`), a fresh entry answers without the network, and a stale one is revalidated with `If-None-Match` or `If-Modified-Since`. A `304` answers with the stored body; when the entry vanished in flight, for example through `clearCache()`, the request fails with a `badResponse` 304, as it would without the cache. A response without cache headers is never stored.

```dart
// Cache this endpoint for 5 minutes, whatever the server's headers say.
dio.get('/config', options: Options()..cacheFor = const Duration(minutes: 5));

// Skip the cached answer and store the fresh one (pull to refresh).
dio.get('/feed', options: Options()..cachePolicy = CachePolicy.refresh);

// Never read the cache, store nothing, and drop the stored entry.
dio.get('/balance', options: Options()..cachePolicy = CachePolicy.noCache);
```

- `cacheFor` must be positive and applies to `GET` only; other methods ignore it. It forces the cache for that request, `no-store` included, and the entry expires that long after it was stored however often it is read. A `cacheFor` request never answers from an entry older than `cacheFor`, even one stored earlier under the server's headers; it fetches and stores a fresh one. `CacheConfig(policy: CachePolicy.forceCache, maxStale: ...)` does the same for every request.
- `keyHeaders` (default `authorization`, `accept`, `accept-language`) split one URL into separate entries, compared ignoring case. On a server that serves many users through one client, keep `authorization` in the set, or one user reads another's cached responses.
- A hit is decoded again from stored bytes, so editing `response.data` never changes the cache. A response over 512,000 bytes, or over a fifth of `maxSize`, is not stored in the default memory store.
- A streamed request (`ResponseType.stream`, as `dio.download` sends) is never stored or answered from the cache.
- Diagnostics print the method, host, and path of a hit, never the query.

| Where                      | Store                                                                                                                                                          | Note                                                                                  |
|----------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------|
| Flutter mobile and desktop | the default memory store, or `FileCacheStore`, `HiveCacheStore`, `IsarCacheStore`, `DriftCacheStore` from their own packages through `CacheConfig(store: ...)` | a persistent store keeps entries across launches                                      |
| Flutter web                | memory, Hive, Isar                                                                                                                                             | `FileCacheStore` does nothing on web; the browser keeps its own HTTP cache underneath |
| Server (dart_frog, CLI)    | memory                                                                                                                                                         | one cache per process; `maxSize` bounds memory                                        |

The client never closes a store passed in. A store that throws never fails a request: the request goes to the network, its response reaches the app unstored, and a diagnostic names the error type. Changing `policy`, `maxStale`, `keyHeaders`, or the offline settings through `configure` keeps the entries; changing `store` or `maxSize` starts an empty cache.

**Offline fallback.** `CacheConfig(hitCacheOnNetworkFailure: true)` answers a `GET` that failed without a response from the stored entry, and `hitCacheOnErrorCodes: {503}` does the same for the listed statuses. Both are off by default. The answer comes only after the last retry, reads `response.isCacheFallback` and `response.isCacheHit`, skips an entry past its `maxStale`, and never answers a cancelled request. The log shows the last attempt's error; the fallback prints a diagnostic. For offline-first screens, prefer `DatasourceBoundState`, which keeps models in the app's own store.

## Rate limiting

Every scope is unlimited until you give it a policy. A `TokenBucketPolicy` means "at most `permits` requests in any window of `per`"; `burst` (null means 10% of `permits`, at least 1; `effectiveBurst` returns the computed value) is how many may leave back to back after idle time, and the steady rate is `permits - effectiveBurst + 1` per `per`.

```dart
// TokenBucketPolicy is from dart_faltool.
const rateLimit = RateLimitConfig.tokenBucket(
  hosts: {
    'api.partner.com': [
      TokenBucketPolicy(permits: 100, per: Duration(minutes: 1)),
      TokenBucketPolicy(permits: 5000, per: Duration(hours: 1), burst: 50),
    ],
  },
);
// In a client: HttpClientConfig(rateLimit: rateLimit).
// On a bare Dio: TokenBucketRateLimitInterceptor(config: rateLimit).
```

`hosts` keys must be bare hosts exactly as `Uri.host` returns them: lowercase, with no port, brackets, or spaces (`::1` is valid). An empty list (`'api.my-backend.com': []`) opts a host out of `perHost`.

Tokens are never returned. When a later tier's full queue rejects a request, tokens already taken by earlier tiers stay spent. A request cancelled with a `CancelToken` while it waits for tokens keeps its queue place and still spends a token when it reaches the front; it is neither forwarded nor counted in `getStatistics().forwarded`. For screens that cancel queued requests often, keep `maxQueueSize` small or set `queueRequests: false`.

Each host gets its own buckets on its first request. When a new host arrives, the interceptor forgets every host with no request inside or waiting whose buckets have refilled, so a server that calls many hosts keeps buckets only for recent ones; the next request to a forgotten host starts on full buckets, as it would have anyway. `getStatistics().waitingByHost` lists only the hosts it still remembers.

### Pause on 429 and 503

A 429 pauses its host for its `Retry-After` (seconds or HTTP-date), else for `defaultPause`; a 503 pauses only when it carries `Retry-After`. Every pause is clamped to `maxPause`, never shortens an earlier one, and applies to hosts without a policy too. While a host is paused, a request waits when the remaining pause is at most `maxPauseWait` and fewer than `maxQueueSize` requests already wait; otherwise it fails at once with a local 429 carrying `Retry-After`. An extension that pushes the remaining pause past `maxPauseWait` also releases every held request, which then re-checks the pause and fails the same way, so a held request waits at most about `maxPauseWait` from admission. A request that gets its tokens during a pause spends them and waits again, so the ceiling also holds after the pause.

A local 429 (full queue or long pause) has type `DioExceptionType.badResponse` and goes through every error interceptor, so callers get `NetworkLimitExceededException` for local and server 429s alike. `response.isLocalRateLimit` tells them apart, for example to keep them out of crash reports. `getStatistics()` exposes the pause through `heldByHost` (requests held per host) and `pausedUntilByHost` (end time of each active pause), and its `rejected` counter includes pause rejections.

Use `RetryAfterPauseInterceptor` for the pause alone. `TokenBucketRateLimitInterceptor` already contains it; a chain with the token bucket must not add `RetryAfterPauseInterceptor`.

### Refill timers and `dispose()`

Refill timers outlive the last request, so call `dispose()` where timers must stop:

| Context                                        | Call `dispose()`                                                                                         |
|------------------------------------------------|----------------------------------------------------------------------------------------------------------|
| Flutter app, client lives as long as the app   | not needed                                                                                               |
| Scoped client (DI scope, logout, env switch)   | when the scope ends: get_it `dispose:`, injectable `@disposeMethod`, Riverpod `ref.onDispose`            |
| `testWidgets` with a real client               | at the end of the test body or from a widget's `dispose`; `addTearDown` is too late and the test fails   |
| Unit test under `fakeAsync`                    | at the end of the `fakeAsync` body                                                                       |
| CLI                                            | in a `finally` before `main` returns, or exit waits until every bucket refills                           |
| Server (dart_frog)                             | not needed                                                                                               |

On a server, build the client once per process (a top-level variable returned by `provider`). A client built inside a per-request `provider` starts with full buckets on every request and limits nothing.

## Concurrency limit

`ConcurrencyLimitInterceptor` limits how many requests are in flight at once. Every scope is unlimited until you set it.

```dart
const concurrency = ConcurrencyConfig(
  global: 16,
  perHost: 4,
  hosts: {'pay.partner.com': 2, 'cdn.example.com': null},
);
```

`pay.partner.com` runs 2 requests at once; `cdn.example.com` has no host limit but still counts toward the 16 global slots; every other host gets 4. `hosts` keys follow the token bucket rule: bare lowercase hosts as `Uri.host` returns them.

A request takes a slot in `onRequest` and gives it back when its response or error passes the interceptor, or when its `CancelToken` cancels. Without a free slot it waits in a FIFO queue (`maxQueueSize` per host, `maxGlobalQueueSize` for the global limit), or fails at once with `queueRequests: false`. A full queue fails the request with a local 429: `isLocalRateLimit` is true, `err.error` is a `BulkheadRejectedException` until the exception handler maps it to `NetworkLimitExceededException`, and there is no `Retry-After`, so `recommendedRetryDelay` falls back to 1 minute. A retry attempt, or a re-send of `err.requestOptions`, reuses the slot its request still holds, so a limit of 1 never deadlocks.

Limitations:

- Nothing limits the time a request spends in the queue. Pass a `CancelToken` with a deadline to bound it.
- A request cancelled while it waits keeps its queue place until it reaches the head, so it counts toward `maxQueueSize` until then. One cancelled while it waits for the global slot also keeps its host slot until then.
- A request that never ends holds its slot. Keep `connectTimeout` and `receiveTimeout` set.
- A `ResponseType.stream` response gives its slot back when its headers arrive, before its body is read.
- Two concurrent fetches of one `RequestOptions` object share one slot: the second waits for the first one's slot, and may still run after the first gives it back.

`getStatistics()` returns `ConcurrencyLimitStatistics`: `forwarded`, `rejected`, `activeByHost` and `waitingByHost` (only hosts with a request in flight or queued; idle hosts are forgotten), `globalActive`, `globalWaiting`. `dispose()` cancels queued requests and lets requests in flight finish; afterwards, requests to a limited host are cancelled and requests to an unlimited host pass. `Bulkhead` keeps no timer, so a missing `dispose()` never delays a CLI exit or fails `testWidgets`.

## Server logging

On a server, turn on the JSON log. Each HTTP attempt becomes one JSON line on stdout, with OpenTelemetry field names, so any log aggregator can read it.

```dart
DefaultHttpClient.instance.configure(
  HttpClientConfig(
    baseUrl: Env.apiBaseUrl,
    log: const LogConfig.json(),
    retry: const RetryConfig(),
  ),
);
```

```json
{"timestamp":"2026-09-24T07:12:03.184Z","severity_text":"WARN","body":"GET https://api.example.com/users/7?token=REDACTED 404 0.184s","http.request.method":"GET","url.full":"https://api.example.com/users/7?token=REDACTED","server.address":"api.example.com","server.port":443,"http.response.status_code":404,"error.type":"404","http.client.request.duration":0.184}
```

| Field | Value |
|---|---|
| `timestamp` | completion time of the attempt, ISO 8601 UTC |
| `severity_text` | `INFO` below 400 and on cancel; `WARN` for 4xx; `ERROR` for 5xx and errors without a response |
| `body` | `<method> <url> <status or error type> <seconds>s`, plus ` (cache)` on a hit |
| `http.request.method`, `url.full`, `server.address`, `server.port` | from the request; `url.full` redacted |
| `http.response.status_code` | when a response exists |
| `error.type` | the status as a string, or the `DioExceptionType` name such as `connectionTimeout` |
| `http.client.request.duration` | seconds, including time spent in the limiters' queues |
| `http.request.resend_count` | on retries |
| `falconx.cache.hit`, `falconx.rate_limit.local` | `true` on a cache hit, and on a 429 built by a limiter |
| `falconx.request.id` | the request ID, when `requestId` is set |
| `falconx.auth.resent` | `true` on the re-send after a token refresh |

- Opt in to more with `LogConfig.json(requestHeaders: true, responseHeaders: true, requestBody: true, responseBody: true, maxBodyBytes: 4096)`. Headers appear as `http.request.header.<name>` lists; bodies as `falconx.request.body` and `falconx.response.body`, cut at `maxBodyBytes` UTF-8 bytes with a `.truncated` flag. Bodies are never redacted: turn them on only where they carry no personal data.
- `redactHeaders` (default `defaultRedactedHeaders`) and `redactQueryParameters` (default `defaultRedactedQueryParameters`) apply to both log formats and compare names ignoring case. Extend them: `redactHeaders: {...defaultRedactedHeaders, 'x-tenant-secret'}`. Pass `const {}` to turn one off, for example in development.
- A retried request prints one line per attempt. Limiter diagnostics print as JSON lines with `severity_text` `DEBUG` while `diagnostics` is on.
- A `logPrint` that throws is ignored, and a header or body value whose `toString()` throws leaves a minimal `WARN` line whose `body` ends in `(log failed)`; logging never fails a request.
- An OpenTelemetry Collector's `filelog` receiver with a `json_parser` operator turns each line into a log record; the Datadog agent and Cloud Logging read JSON on stdout too. Cloud Logging without a Collector does not map `severity_text` to its own `severity`.
- Switch formats at run time with `client.configure(client.currentConfig.copyWith(log: const LogConfig.json()))`; the limiters keep their state.

## Client and server deployment

**Web**

- A browser hides every cross-origin response header outside the CORS safelist, including `Retry-After` and `Date`. Have the server send `Access-Control-Expose-Headers: Retry-After, Date`. Without it, a 429 pauses for `defaultPause`, a 503 does not pause, `RetryInterceptor` uses backoff instead of `Retry-After`, and the pause runs on the client clock. Tests with a fake adapter cannot catch this.
- Chrome opens at most 6 connections per host over HTTP/1.1 and queues the rest itself. That queue time counts toward `connectTimeout`, so keep `perHost` at 6 or less on the web, and the queue stays in `ConcurrencyLimitInterceptor`, where you can see and cancel it.

**Apps**

- A request that stalls, for example while the app is in the background, holds its concurrency slot until a dio timeout fires.

**Servers**

- Limits count per process, isolate, or container instance. Divide a partner's limit by the instance count; with autoscaling, rely on the 429 pause as the last line.
- Limits are keyed by host. When a partner limits per API key and you use one key per tenant, build one client per key; otherwise one tenant's 429 pauses every tenant.
- Queued requests outlive the incoming request that started them. Give each incoming request a `CancelToken` that cancels at its deadline; it bounds the concurrency queue, the token wait, the pause hold, retry backoff, and the request in flight together.
- Build the client once per process (see "Refill timers and `dispose()`").
- Keep `IoAdapterConfig.maxConnectionsPerHost` at or above every per-host limit of `ConcurrencyConfig`; the client prints a diagnostic when it is lower.
- For an open-ended set of hosts, prefer named `hosts` keys over `perHost` in `TokenBucketRateLimitInterceptor`: its per-host buckets are never freed. `ConcurrencyLimitInterceptor` forgets idle hosts itself.

## Retry

```dart
await dio.post<dynamic>(
  '/payments',
  options: Options()
    ..retryNonIdempotent = true // allow retries of this POST after 5xx and timeouts
    ..retryAttempts = 5,        // overrides RetryConfig.maxAttempts
);
await dio.get<dynamic>('/live', options: Options()..disableRetry = true);
```

`RetryConfig(onRetry: (error, attempt, delay) {...})` runs before each wait; `error.stackTrace` holds the failure's stack trace.

## Helpers

- `RequestOptions.setHeaderTokenBearer(token)` / `removeHeaderToken()`.
- `HttpHeader.AUTHORIZE`, `ACCEPT_LANGUAGE`, `CACHE_CONTROL`, `CONTENT_TYPE`, `CONTENT_LENGTH`, `COOKIE`, `KEEP_ALIVE`, `ORIGIN`, `USER_AGENT`, `X_API_KEY`; `HttpCode.SUCCESS`, `ERROR_UNAUTHORIZED`, `ERROR_NOT_FOUND`, `ERROR_INTERNAL`.
- `Response<dynamic>?.copyWith<T>(...)`, `.transformData<T>(data:)`.
- `Future<Response<T>>.unwrapResponse()`, `.catchWhenError(f)`; `Future<Response<dynamic>>.mapJson(f)`.
- `DioException.toException()` maps to the `NetworkException` subtype for its status code; the skill shipped for `dart_falmodel` documents it.
- `headers.retryAfter` and `parseRetryAfter(value, serverDate:)` (from `dart_falmodel`) read `Retry-After` as seconds or HTTP-date; `response.isLocalRateLimit` marks a client-side 429.
- `response.isCacheHit` marks a response answered from the cache without a network round trip, and `response.isCacheFallback` one answered by the offline fallback; a response interceptor that counts responses sees hits too, so check it there. A `304` revalidation reads `isCacheHit` false.
