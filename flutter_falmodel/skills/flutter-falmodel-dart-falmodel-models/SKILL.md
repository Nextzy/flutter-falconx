---
name: flutter-falmodel-dart-falmodel-models
description: Use when writing or changing error handling or model code with dart_falmodel, including Result, runCatching, CommonException, NetworkException and its status-code subclasses, JSON-RPC exceptions, BaseModel, request and response bodies, PaginatedResponse, and UserFeedback, or before hand-writing an error type or response wrapper.
---

# dart_falmodel models

Answers "does dart_falmodel already provide this?" here and routes "how do I call it?" to one file under `references/`. `package: dart_falmodel`.

## Capability map

| Need                                     | Use                                                                                                             | Ref                         |
|------------------------------------------|-----------------------------------------------------------------------------------------------------------------|-----------------------------|
| Success/failure without throwing         | `Result<T>`, `runCatching`, `Future.toResult()`                                                                 | `references/errors.md`      |
| General exceptions                       | `CommonException` with `DefaultErrorType` enums (`SystemErrorType`, `InputErrorType`, ...)                      | `references/errors.md`      |
| HTTP status exceptions                   | `NetworkException` with `NetworkErrorType`; `dioException.toException()`                                        | `references/errors.md`      |
| JSON-RPC exceptions                      | `JsonRpcCommonException` family, `JsonRpcError`, `toJsonRpcError()`                                             | `references/errors.md`      |
| `Either` and `Pair` failure access       | `resolve`, `isFailure`, `hasData`, `data`, `dataOrNull`, `failure`; `Pair.hasFailure`                           | `references/errors.md`      |
| Request/response models                  | `BaseModel`, `BaseRequestBody`, `BaseFormDataBody`, `PaginatedRequest/Response`, `BaseResponse`, `UserFeedback` | `references/models.md`      |
| Socket and JSON-RPC models               | `SocketOptions`, `SocketResponse`, `BaseSocketRequestBody`, `JsonRpcRequest`, `JsonRpcResponse`, `JsonRpcError` | `references/models.md`      |
| Third-party libs, free with this package | none: the barrel re-exports no third-party library                                                              | `references/third-party.md` |

## Do not reinvent

- Before adding a pub dependency or writing a helper, scan the map above and `references/third-party.md`.
- Never `import 'dart:io'`; the package compiles to web. Use `package:universal_io/io.dart`, added to your own pubspec (it is not re-exported).

## Gotchas

- `NetworkException` carries a `NetworkErrorType`; the general hierarchy uses `DefaultErrorType` enums. Do not mix them.
- `BaseRequestBody` subclasses must implement `Map<String, Object?> toJson()`; the HTTP methods call it.
- Kept for compatibility: `NetworkNotImplementException` (501, missing "ed") and both `NetworkAuthenticationException` and `UnauthorizedException` for 401.
- `dart_falmodel` alone does not re-export `dio`; import it yourself for `Response` / `RequestOptions`.

## Out of scope

General Freezed usage, and package internals.
