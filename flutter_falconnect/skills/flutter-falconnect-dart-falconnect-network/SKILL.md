---
name: flutter-falconnect-dart-falconnect-network
description: Use when writing or changing HTTP, WebSocket, or JSON-RPC client code with dart_falconnect, including Retrofit and Dio clients, HttpClientConfig, interceptors, token refresh, caching, rate limiting, certificate pinning, WebSocket streams, JSON-RPC calls, and DatasourceBoundState, or before adding a networking dependency or helper.
---

# dart_falconnect network

Answers "does dart_falconnect already provide this?" here and routes "how do I call it?" to one file under `references/`. `package: dart_falconnect`; its barrel is also where `dio`, `retrofit`, `dio_cache_interceptor`, and `web_socket_channel` come from.

## Capability map

| Need                                          | Use                                                                                                                                                                                                                                                                                                                                                              | Ref                         |
|-----------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------|
| Typed REST client                             | Retrofit `@RestApi` on `DefaultHttpClient.instance.dio` or a `BaseHttpClient` subclass                                                                                                                                                                                                                                                                           | `references/http.md`        |
| Converter-based HTTP                          | `BaseHttpClient.get/post/postFormData/patch/put/putFormData/delete` with `converter:`                                                                                                                                                                                                                                                                            | `references/http.md`        |
| Auth token, 401 refresh, request headers      | `HttpClientConfig(auth: AuthConfig(...), requestId: RequestIdConfig(), headerProvider: ...)`; Retrofit `@noToken`, `useTokenExtraKey`                                                                                                                                                                                                                            | `references/http.md`        |
| Client configuration                          | `HttpClientConfig` boxes (`LogConfig`, or `LogConfig.json` for a server), `configure`, `currentConfig`, `setupBaseUrl`                                                                                                                                                                                                                                           | `references/http.md`        |
| Transport: pool, proxy, pins, web credentials | `HttpClientConfig(ioAdapter: IoAdapterConfig(...), webAdapter: WebAdapterConfig(...))`; a pin failure is a `CertificatePinningException`                                                                                                                                                                                                                         | `references/http.md`        |
| Interceptors                                  | `RequestStampInterceptor`, `TokenRefreshInterceptor` (sharing an `AuthSession`), `RetryInterceptor`, `CacheInterceptor`, `ConcurrencyLimitInterceptor`, `TokenBucketRateLimitInterceptor`, `RetryAfterPauseInterceptor`, `HttpLogInterceptor`, `HttpJsonLogInterceptor`, `NetworkExceptionHandlerInterceptor`, `HttpClientConfig`; the cache, limiter, retry, and log interceptors take their own config box, the two auth interceptors an `AuthSession` | `references/http.md`        |
| Certificate pin failures                      | `DioException` of type `badCertificate` whose `error` is a `CertificatePinningException`; its `failure` is a `PinFailure` (`mismatch`, `proxied`, `plainHttp`, `unreadableCertificate`); never retried                                                                                                                                                           | `references/http.md`        |
| WebSocket streams                             | `SocketClient`, `SocketBoundResource.asStream`, `SocketLogInterceptor`                                                                                                                                                                                                                                                                                           | `references/websocket.md`   |
| JSON-RPC 2.0                                  | `JsonRpcService` / `DefaultJsonRpcService`: `request`, `notify`, `batch` returning `BatchJsonRpcItem`                                                                                                                                                                                                                                                            | `references/json-rpc.md`    |
| Local-first repository                        | `DatasourceBoundState.asResultStream` and siblings                                                                                                                                                                                                                                                                                                               | `references/models.md`      |
| Third-party libs, free with this package      | `dio`, `retrofit`, `dio_cache_interceptor`, `web_socket_channel`                                                                                                                                                                                                                                                                                                 | `references/third-party.md` |

`Result`, the exception classes, `BaseRequestBody`, and the JSON-RPC and WebSocket models that these APIs take and return come from `dart_falmodel`; the skill shipped for `dart_falmodel` documents them.

## Do not reinvent

- Before adding a pub dependency or writing a helper, scan the map above and `references/third-party.md`.
- When this package's barrel is imported, do not also import `dio`, `retrofit`, or any other library it re-exports; the symbols are already in scope.
- Never `import 'dart:io'`; the package compiles to web. Use `package:universal_io/io.dart`, added to your own pubspec (it is not re-exported).
- Never build an `IOHttpClientAdapter` or `BrowserHttpClientAdapter` yourself for a connection limit, idle timeout, proxy, certificate pins, or `withCredentials`: set `ioAdapter` and `webAdapter`, which compile on every platform.
- Prefer Retrofit + Dio for REST. Use `BaseHttpClient` methods only for one-off converter-based calls.

## Gotchas

- Hidden symbols: `dart_falconnect` hides Retrofit `Headers`, `Parser`, `CacheControl`; dio's own `Headers` is exported unhidden, so import `package:retrofit/retrofit.dart` `as retrofit` and write `@retrofit.Headers(...)`; the same prefix reaches Retrofit's `Parser` and `CacheControl`.
- `BaseRequestBody` (from `dart_falmodel`) subclasses must implement `Map<String, Object?> toJson()`; the HTTP methods call it.
- Interceptor order (`BaseHttpClient` assembles it): `RequestStampInterceptor` when `requestId`, `headerProvider`, or `auth` is set, your `interceptors`, `HttpLogInterceptor` or `HttpJsonLogInterceptor`, `CacheInterceptor`, `ConcurrencyLimitInterceptor`, the rate limiter, `TokenRefreshInterceptor` when `auth` is set, `RetryInterceptor`, the cache's offline fallback when enabled, then the exception handler. Use `auth` instead of writing a refresh interceptor; error loggers go before `RetryInterceptor`. Interceptors after `ConcurrencyLimitInterceptor` end `onRequest`, and interceptors before it end `onResponse` and `onError`, with `next` or the call-following flag (`reject(err, true)`), or the slot leaks. See `references/http.md`. Dio's own `LogInterceptor` is a different class.
- JSON-RPC batch responses silently drop items without an `id`.
- Server apps (`dart:io` `HttpServer`, shelf, dart_frog): Retrofit's `HttpResponse` replaces `dart:io`'s without any diagnostic, and dio's `Response` collides with shelf's and dart_frog's; in a dart_frog app, dio's `FormData` and Retrofit's `HttpMethod` also collide with dart_frog's. Import the packages through one app-level barrel that hides these names, and reach dio's `Response` through `package:dio/dio.dart` imported `as dio` where a route calls an HTTP client. For dart_frog, export the barrel of the falconx package your app lists with those names hidden, and dart_frog's own library after it:

  ```dart
  export '<barrel of the falconx package your app lists>'
      hide FormData, HttpMethod, HttpResponse, Response;
  ```

## Out of scope

General Dio and Retrofit usage, and package internals.
