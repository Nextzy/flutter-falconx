# WebSocket

`package: dart_falconnect` (client, interceptors, exceptions). Models `SocketOptions`, `SocketResponse`, `JsonSocketResponse`, `BinarySocketResponse`, `BaseSocketRequestBody` are in `dart_falmodel`.

## `SocketClient` lifecycle

```dart
// SocketOptions and SocketResponse are from dart_falmodel; jsonEncode and jsonDecode
// are from dart:convert; Price is your own.
class PriceSocket extends SocketClient {
  PriceSocket() : super('wss://example.com/ws');

  @override
  void setupConfig(SocketOptions configs) {
    configs.retryLimit = 5; // default 3; applied after the first received frame
  }

  @override
  void setupInterceptors(SocketInterceptors interceptors) {
    interceptors.add(SocketLogInterceptor());
  }
}

final socket = PriceSocket();
final prices = socket.getResponseStream<Price>(
  filter: (r) => r.data.contains('"ch":"btc"'),
  converter: (r) => Price.fromJson(jsonDecode(r.data) as Map<String, dynamic>),
);
final sub = prices.listen(print);                 // subscribe first: the stream is hot
await socket.request(jsonEncode({'op': 'subscribe', 'ch': 'btc'})); // opens the channel lazily
await sub.cancel();
await socket.closeChannel();
```

| Member | Notes |
|---|---|
| `SocketClient(String baseUrl)` | calls `setupConfig`, then `setupInterceptors` |
| `createChannel()` | `WebSocketChannel.connect(Uri.parse(options.uri))`; closes an existing channel first |
| `request(String body)` | opens the channel if closed, runs `onRequest` interceptors, sends a text frame |
| `getResponseStream<T>({filter, converter})` | `where(filter).asyncMap(converter)` over a `PublishSubject`; `filter` optional |
| `getRawStream({filter})` | `Stream<SocketResponse>` |
| `closeChannel()` | closes the sink, cancels the subscription, clears `options.data` |
| `checkConnection()` | sends `'ping'`; reconnects when that throws |
| `isClose`, `options`, `interceptors` | state |

## Reconnection

On a stream error with retries left, interceptors receive `SocketRetryException(retryCount:)`, the last `options.data` is re-sent, and the counter decrements. At zero, interceptors receive `SocketClientException`, the error is pushed into the response stream, and the subscription is cancelled. Every received frame resets the counter to `options.retryLimit`. Server-side `done` closes the channel; the next `request` reopens it.

## Exceptions

- `SocketClientException({response, message, exception, stackTrace})`: base (`SocketException` before 2.4.0). In a file that also imports `dart:io`, an old `on SocketException` or `is SocketException` now matches `dart:io`'s class without any diagnostic; rename it to `SocketClientException`.
- `SocketRetryException({required retryCount, ...})`: one per retry attempt.
- `SocketOperationNotFound({...})`: default message `'Operation not match'`; throw it from converters that receive an unknown frame.

## Interceptors

`SocketInterceptor` has `onRequest(SocketOptions)`, `onResponse(SocketResponse)`, `onError(SocketClientException, SocketOptions)`. `SocketInterceptors` behaves as a `List`. `SocketLogInterceptor({enabled, requestBody, responseBody, error, logPrint})` prints ANSI-coloured, chunked output.

## `SocketBoundResource.asStream`

Turns a socket stream into `Stream<Result<Entity>>` with optional persistence.

```dart
// SocketResponse and the Result events are from dart_falmodel.
final results = SocketBoundResource.asStream<Price, SocketResponse>(
  createCallStream: () => socket.getRawStream(),
  processResponse: (r) => Price.fromJson(jsonDecode(r.data) as Map<String, dynamic>),
  whenSave: (p) => p != null,
  saveCallResult: (p) => db.save(p),
  error: (e, st) => logger.e(e, error: e, stackTrace: st),
);
```

`processResponse` is required when `EntityType != ResponseType` (asserted). Any error thrown by the source, `processResponse`, `saveCallResult`, or the `error` callback becomes `Result.failure(e.toException())`. `log: true` prints debug lines.

## Models (`dart_falmodel`)

- `SocketOptions({uri = '', retryLimit = 3, protocol, data})`: mutable; `isSecure`, `hasRetry`, `copyWith`.
- `SocketResponse({data: String, requestOptions, timestamp?})`, `SocketResponse.now(...)`, `ageInMilliseconds`.
- `JsonSocketResponse.fromString(jsonString:, requestOptions:)`: `getValue<T>(key)`, `getNestedValue<T>('a.b.c')`.
- `BinarySocketResponse.fromBase64(base64String:, requestOptions:)`: `sizeInBytes`, `toBase64()`.
- `BaseSocketRequestBody`: implement `toJson()`; `toJsonStr()` is provided. Pass `toJsonStr()` to `request`.
