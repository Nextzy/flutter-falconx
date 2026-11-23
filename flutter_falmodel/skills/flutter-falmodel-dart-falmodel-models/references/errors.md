# Errors and Result

`package: dart_falmodel` unless marked.

## `Result<T>`

Construct: `Result.success(v)`, `Result.failure(CommonException)`, `Result.dataFailure(code:, ...)` (wraps `DataLayerException`), `Result.domainFailure(code:, ...)` (wraps `DomainLayerException`); the extra named parameters are `userMessage`, `developerMessage`, `originalException`, `stackTrace`.

Read: `isSuccess`, `isFailure`, `value` (throws on failure), `valueOrNull`, `valueOr(default)`, `exception` (throws on success), `exceptionOrNull`, `stackTraceOrNull`.

Transform: `map`, `flatMap`, `mapException`, `resolve(onSuccess, onError)`, `when(onSuccess, onError)`, `recover`, `recoverWith`, `doOnSuccess`, `doOnFailure`, `updateFailMessage(userMessage:, developerMessage:)`, `swap()`. Throws inside a transform become failures. `Result` is `Equatable`.

Async: `runCatching(() async => Result.success(await x))` turns any throw into `Result.failure`. `Future<T>.toResult([mapException])` and `Stream<T>.toResult([mapException])` wrap plain values. `Future<Result<T>>` adds `mapResult`, `flatMapResult`, `mapResultException`, `onSuccess`, `onFailure`, `getOrElse`, `getOrElseAsync`, `recover`, `recoverWith`, `whenAsync`, `unwrap()`. `Stream<Result<T>>` adds the same plus `whereSuccess`, `whereFailure`, `successOnly`, `failureOnly`, `doOnSuccess`, `doOnFailure`, `getOrElseCompute`, `partition()`, `collect()`, `collectSuccesses()`, `collectFailures()`.

```dart
// repo and its user type are your own.
final result = await runCatching(() async => Result.success(await repo.load(id)));
return result.resolve((user) => user.name, (e, st) => e.message);
```

## `CommonException` and `DefaultErrorType`

```dart
const CommonException({required Object type, String? userMessage, String? developerMessage,
    Map<String, dynamic>? data, Object? originalException, StackTrace? stackTrace});
```

`type` is any `Object`; use a `DefaultErrorType` enum so `defaultMessage` resolves:

| Enum                    | Values                                                                          |
|-------------------------|---------------------------------------------------------------------------------|
| `SystemErrorType`       | `unknown`, `system`, `unexpected`, `concurrency`                                |
| `InputErrorType`        | `validation`, `invalidFormat`, `invalidValue`, `outOfRange`, `argument`, `type` |
| `TimeoutErrorType`      | `timeout`, `deadline`                                                           |
| `StorageErrorType`      | `storage`, `cache`, `database`, `fileSystem`                                    |
| `ConnectivityErrorType` | `connection`, `socket`, `tls`, `dns`, `http`                                    |
| `AsyncErrorType`        | `stream`, `future`, `isolate`                                                   |
| `AccessErrorType`       | `permission`, `unauthorized`, `deviceNotSupported`                              |
| `ExternalErrorType`     | `thirdParty`, `serviceUnavailable`                                              |
| `BusinessErrorType`     | `businessRule`, `notFound`, `conflict`, `deprecated`                            |

Members: `message` (user, then developer, then generic), `copyWith`, `mapMessage`, `mapUserMessage`, `mapDeveloperMessage`, `toJsonRpcError()`, `toFailure()` / `toWarning()` / `toInformation()` (return `UserFeedback`). There is no `category` field. Subclasses `DataLayerException`, `DomainLayerException`, `TodoException<T>` override `copyWith` to keep their type.

Convert anything with `Object?.toException({type, userMessage, developerMessage, stackTrace})`: passes `CommonException` through, maps `DioException` to the `NetworkException` subtype for its status code, and classifies `FormatException`, `TimeoutException`, `SocketException`, `FileSystemException`, `StateError`, `ArgumentError`, and friends onto the enums above. `Exception?.toCommonResultFailure({...})` returns `Result<Never>`.

## `NetworkException` and `NetworkErrorType`

```dart
// Response and RequestOptions are from dio.
const NetworkException({required Object type, required int statusCode, String? userMessage,
    String? developerMessage, Response<dynamic>? response, RequestOptions? requestOptions,
    StackTrace? stackTrace, List<NetworkException>? errors});
```

`NetworkErrorType` values: `unknown`, `network`, `timeout`, `noInternet`, `clientError`, `serverError`, plus one per status code below (`fromStatusCode(int)`, `statusCode`, `defaultMessage`, `isClientError`, `isServerError`). `BaseHttpException` adds `isRetryable` (5xx, 408, 409, 429), `recommendedRetryDelay` (honours `Retry-After` as seconds or HTTP-date), `statusCategory`, `toLogString()`, static `extractErrorDetails(response)`. `NetworkClientException` and `NetworkServerException` accept any code in their range. Each class below defaults `statusCode` to its code and `type` to `NetworkErrorType.fromStatusCode(code)`:

| Code          | Class                                                     |
|---------------|-----------------------------------------------------------|
| 0             | `NoInternetConnectException` (`noInternet`)               |
| 400           | `NetworkBadRequestException`                              |
| 401           | `NetworkAuthenticationException`, `UnauthorizedException` |
| 402           | `NetworkPaymentRequiredException`                         |
| 403           | `NetworkForbiddenException`                               |
| 404           | `NetworkNotFoundException`                                |
| 405           | `MethodNotAllowedException`                               |
| 406           | `NetworkNotAcceptableException`                           |
| 407           | `NetworkProxyAuthRequiredException`                       |
| 408           | `NetworkTimeoutException` (extra `timeout: Duration?`)    |
| 409           | `NetworkConflictException`                                |
| 410           | `NetworkGoneException`                                    |
| 411           | `NetworkLengthRequiredException`                          |
| 412           | `NetworkPreconditionFailedException`                      |
| 413           | `NetworkContentTooLargeException`                         |
| 414           | `NetworkUriTooLongException`                              |
| 415           | `NetworkUnsupportedMediaTypeException`                    |
| 416           | `NetworkRangeNotSatisfiableException`                     |
| 417           | `NetworkExpectationFailedException`                       |
| 421           | `NetworkMisdirectedRequestException`                      |
| 422           | `NetworkInvalidException` (`unprocessableContent`)        |
| 423           | `NetworkLockedException`                                  |
| 424           | `NetworkFailedDependencyException`                        |
| 425           | `NetworkTooEarlyException`                                |
| 426           | `NetworkUpgradeRequiredException`                         |
| 428           | `NetworkPreconditionRequiredException`                    |
| 429           | `NetworkLimitExceededException` (`tooManyRequests`)       |
| 431           | `NetworkHeaderFieldsTooLargeException`                    |
| 451           | `NetworkUnavailableForLegalException`                     |
| 500           | `NetworkInternalServerException`                          |
| 501           | `NetworkNotImplementException`                            |
| 502           | `NetworkBadGatewayException`                              |
| 503           | `ServiceUnavailableException`                             |
| 504           | `NetworkGatewayTimeoutException`                          |
| 505           | `NetworkHttpVersionNotSupportedException`                 |
| 506           | `NetworkVariantAlsoNegotiatesException`                   |
| 507           | `NetworkInsufficientStorageException`                     |
| 508           | `NetworkLoopDetectedException`                            |
| 510           | `NetworkNotExtendedException`                             |
| 511           | `NetworkAuthRequiredException`                            |
| other 4xx/5xx | `NetworkNonStandardException(statusCode:)` (`unknown`)    |

## JSON-RPC exceptions

`JsonRpcCommonException` (same constructor as `CommonException`) branches into `JsonRpcDataLayerException` (`JsonRpcDatabaseException`, `JsonRpcExternalApiDataLayerException`) and `JsonRpcDomainLayerException` (`JsonRpcInternalApiDomainLayerException`, `JsonRpcExternalApiDomainLayerException`, `JsonRpcInvalidRequestDomainLayerException`, `JsonRpcBadRequestDomainLayerException` with `type` fixed to `BAD_REQUEST`).

Type enums: `JsonRpcApiErrorTypeEnum` (`INTERNAL_SERVER_ERROR`, `UNAUTHORIZED`, `TOKEN_INVALID`, `TOKEN_EXPIRED`, `TOKEN_REVOKED`, `FORBIDDEN`, `RATE_LIMITED`, `METHOD_NOT_IMPLEMENTED`, `BAD_GATEWAY`, `SERVICE_UNAVAILABLE`, `GATEWAY_TIMEOUT`, `METHOD_NOT_ALLOWED`, `NOT_FOUND`, `FEATURE_DISABLED`); `JsonRpcRequestErrorTypeEnum` and `JsonRpcExternalApiErrorTypeEnum` (`INVALID_JSON_RPC`, `BAD_REQUEST`, `INCORRECT_TYPE`, `INVALID_VALUE`, `CONFLICTING_PARAMETERS`). Your own enums can implement the marker interfaces `JsonRpcApiErrorType`, `JsonRpcRequestErrorType`, `JsonRpcExternalApiErrorType`. `JsonRpcErrorCategory`: `API_ERROR`, `EXTERNAL_API_ERROR`, `INVALID_REQUEST_ERROR`, `UNKNOWN`.

`toJsonRpcError({userMessage?, developerMessage?})` picks the category from the exception subclass, then from the `type` interface, else `API_ERROR`; `code` is `type.name` for enums; `data` is forwarded.

```dart
throw JsonRpcInvalidRequestDomainLayerException(
  type: JsonRpcRequestErrorTypeEnum.INVALID_VALUE,
  userMessage: 'Amount must be positive',
  data: {'field': 'amount'},
);
// at the API boundary:
JsonRpcErrorResponse.single(jsonrpc: '2.0', id: request.id!, error: e.toJsonRpcError());
```

## `Either` and `Pair` extras

`Either<F, DATA>` (fpdart): `resolve(data, fail)`, `isFailure` or `isException`, `hasData`, `data`, `dataOrNull`, `failure` or `exception`, and their `OrNull` forms; `Future<Either>.resolve(...)`. `Pair<F?, DATA>` (dartx): `isEmpty`, `isNotEmpty`, `hasFailure` or `hasException`, `hasData`, `data`, `failure` or `exception`.
