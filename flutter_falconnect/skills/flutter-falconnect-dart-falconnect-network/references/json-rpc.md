# JSON-RPC 2.0

`package: dart_falconnect` (service), `dart_falmodel` (request, response, result, error models).

## Service

```dart
final rpc = DefaultJsonRpcService.fromHttpClient(
  DefaultHttpClient.instance,                // any BaseHttpClient
  jsonrpc: '2.0',
  baseUrl: 'https://api.example.com/rpc',    // optional; defaults to client.baseUrl
);
// or: DefaultJsonRpcService(dio, baseUrl: ..., jsonrpc: '2.0', errorLogger: ...)
```

Subclass `JsonRpcService` for custom behaviour; both constructors are `const`. `errorLogger` is Retrofit's `ParseErrorLogger`. `baseUrl` may be absolute or relative to `dio.options.baseUrl`.

## Result types (`dart_falmodel`)

`fromResultJson` must return a `JsonRpcResult`:

- `JsonRpcModelResult`: abstract with `toJson()`; make your Freezed result class implement it.
- `JsonRpcListResult<T>(List<T>)`, `JsonRpcIntResult(int)`, `JsonRpcRawResult(Map<String, dynamic>)`.
- `JsonRpcStringResult`, `JsonRpcBoolResult`: abstract, subclass them.

```dart
// JsonRpcModelResult is from dart_falmodel; @freezed is from freezed_annotation.
@freezed
abstract class BalanceResult with _$BalanceResult implements JsonRpcModelResult {
  const factory BalanceResult({required String amount}) = _BalanceResult;
  factory BalanceResult.fromJson(Map<String, dynamic> json) => _$BalanceResultFromJson(json);
}
```

## Single call

```dart
// JsonRpcResponse is from dart_falmodel.
final response = await rpc.request<BalanceResult>(
  method: 'wallet.balance',
  params: {'address': address},
  fromResultJson: BalanceResult.fromJson,
  // optional: path, jsonrpc, id, mockId, queryParameters, headers, extra
);
final balance = response.result;   // JsonRpcResponse<BalanceResult>: jsonrpc, id, result
// or: await rpc.request<BalanceResult>(...).unwrapResponse()
```

Semantics:

- `id` is `int?`; when omitted a random `1..99999999` is sent. The response `id` is decoded as `int`.
- A server `error` object or `errors` list throws `JsonRpcErrorResponse(jsonrpc, id, errors: List<JsonRpcError>)`.
- A missing `result` throws `StateError` (use `notify` for fire-and-forget); a non-map `result` throws `StateError('Invalid result type')`.
- `mockId` is sent as `"mock"` when non-null.
- Transport failures surface as `DioException`; `.catchWhenError((e, st) => fallback)` resolves with a `JsonRpcResponse` carrying the request id, and returning `null` rethrows.

## Notification

```dart
await rpc.notify(method: 'session.ping', params: {'t': 1});   // no id; response body ignored
rpc.notifySync(method: 'session.ping');                       // FutureOr<void>
```

## Batch

```dart
// BatchJsonRpcBody and BatchJsonRpcItem are from dart_falmodel.
final items = await rpc.batch('/rpc', bodyList: [
  BatchJsonRpcBody<BalanceResult>(
    id: 1, method: 'wallet.balance', params: {'address': a},
    fromResultJson: (j) => BalanceResult.fromJson(j!),
  ),
  BatchJsonRpcBody<BalanceResult>(
    id: 2, method: 'wallet.balance', params: {'address': b},
    fromResultJson: (j) => BalanceResult.fromJson(j!),
  ),
]);
for (final item in items) {   // List<BatchJsonRpcItem<dynamic>>
  item.resolve(
    success: (r) => print(r.result),
    failure: (e) => print(e.errors.first.code),
  );
}
```

Rules:

- Response items without an `id` are dropped before decoding.
- `BatchJsonRpcBody.toJson()` (generated) sends only `method` and `params`, omitting nulls; `BatchJsonRpcBody.fromJson(json)` reads them back, ignoring the envelope keys. The response `id` is matched against `BatchJsonRpcBody.id` to find `fromResultJson`, so set ids that match what your server echoes. No match throws a null-check error.
- `BatchJsonRpcItem` members: `isSuccess`, `isFailure`, `responseOrNull`, `errorOrNull`, `resolve({success, failure})`, `map(transform)`. Concrete `BatchJsonRpcSuccess(response)` and `BatchJsonRpcFailure(error)` support `switch` patterns.

## Error handling

```dart
// JsonRpcErrorResponse, JsonRpcError, and JsonRpcErrorCategory are from dart_falmodel.
try {
  await rpc.request<BalanceResult>(method: 'wallet.balance', fromResultJson: BalanceResult.fromJson);
} on JsonRpcErrorResponse catch (e) {
  final first = e.errors.first;   // JsonRpcError: category, code, userMessage, developerMessage, data
  if (first.category == JsonRpcErrorCategory.INVALID_REQUEST_ERROR) { /* ... */ }
} on DioException catch (e) {
  final ex = e.toException();     // NetworkException subtype by status code
}
```

Server side: throw a `CommonException` subclass and convert with `toJsonRpcError()` (the skill shipped for `dart_falmodel` documents both). `JsonRpcError` factories: `.invalidRequest`, `.invalidParams`, `.internal`, `.external`, `.methodNotImplement`. `JsonRpcErrorResponse.single(jsonrpc:, id:, error:)` wraps one error. `JsonRpcRequest` (Freezed: `jsonrpc`, `method`, `params`, `id`) models an inbound request.
