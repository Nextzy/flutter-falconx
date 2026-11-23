# Third-party re-exports

This package's barrel brings every row below into scope. Do not import them separately while that barrel is imported.

## Via `dart_falconnect`

| Package                 | Purpose                                                                 | Hidden                                                                                       |
|-------------------------|-------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|
| `dio`                   | `Dio`, `Response`, `Options`, `Interceptor`, `FormData`, `DioException` | none                                                                                         |
| `dio_cache_interceptor` | HTTP cache store and policy for Dio                                     | `BaseRequest`, `BaseResponse`, `HttpDate`                                                    |
| `retrofit`              | `@RestApi`, `@GET`, `@Body`, `HttpResponse`, `ParseErrorLogger`         | `CacheControl`, `Headers`, `Parser` (import `package:retrofit/retrofit.dart` `as retrofit` for `@retrofit.Headers`) |
| `web_socket_channel`    | `WebSocketChannel`                                                      | none                                                                                         |

`dart_falconnect` does not re-export `dart_falmodel` or `dart_faltool`; list the package you need yourself.

## Not re-exported

Add these to your own pubspec when needed: `universal_io` (use instead of `dart:io`), `ansicolor`, and the dev tools `build_runner`, `freezed`, `json_serializable`, `retrofit_generator`.
