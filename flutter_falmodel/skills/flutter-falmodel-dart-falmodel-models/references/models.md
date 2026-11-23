# Models

`package: dart_falmodel`.

## `BaseModel<T>`

`abstract class BaseModel<T> with Equatable`: `stringify` is true, `T copyWith()` is abstract, you supply `props`. `UniqueModel<T>` adds `id` (defaults to `UuidGenerator.getV4()`, from `dart_faltool`) with `props = [id]`; it is not `const`. `FirebaseModel` and `FirebaseTimestampModel({createdAt, updatedAt})` are Equatable bases for Firestore documents.

```dart
class User extends BaseModel<User> {
  const User({required this.id, required this.name});
  final String id;
  final String name;
  @override
  List<Object?> get props => [id, name];
  @override
  User copyWith({String? id, String? name}) => User(id: id ?? this.id, name: name ?? this.name);
}
```

## Requests

- `BaseRequest`: Equatable root of every request and socket model.
- `BaseRequestBody`: implement `Map<String, Object?> toJson()`; `toJsonStr()` is provided. Pass as `data:` to `BaseHttpClient.post/patch/put/delete` (from `dart_falconnect`).
- `BaseFormDataBody`: `toJson()` plus `Future<FormData> toFormData()` (`FormData` is from dio); pass the form data to `postFormData` / `putFormData`.
- `PaginatedRequest({page = 1, pageSize = 20})`: `toQueryParameters()` returns `{'page', 'page_size'}`.

```dart
class CreateUserBody extends BaseRequestBody {
  const CreateUserBody({required this.name});
  final String name;
  @override
  Map<String, Object?> toJson() => {'name': name};
  @override
  List<Object?> get props => [name];
}
```

## Responses

- `BaseResponse<T> extends Response<T>` (Dio): `BaseResponse.success(data:, requestOptions:, headers?)`, `BaseResponse.noContent(requestOptions:)`, `isSuccessful`, `isClientError`, `isServerError`. Typedefs `BoolResponse`, `IntResponse`, `DoubleResponse`, `StringResponse`, `ListResponse<T>`, `MapResponse<K, V>`, `EmptyResponse`.
- `PaginatedResponse<T>({items = const [], page, pageSize, totalItems, totalPages})`: `hasNextPage`, `hasPreviousPage`, `nextPage`, `previousPage`, `isFirstPage`, `isLastPage`, `itemCount`, `isEmpty`, `isNotEmpty`, `startIndex`, `endIndex`, `copyWith`, and generated `fromJson(json, fromJsonT)` / `toJson()` (metadata keys only; `items` are not serialized). `PaginatedResponseWithMetadata<T>` adds `metadata` and its own `fromJson(json, fromJsonT)`.
- `RemoteErrorBody({code, message, userMessage, developerMessage})` (Freezed; `RemoteError` before 2.4.0): `fromJson`, `fromData(dynamic)`.
- `parseRetryAfter(String? value, {DateTime? serverDate})` returns the `Retry-After` delay (delay-seconds or any HTTP-date; past dates give zero; unreadable values give null); `Headers.retryAfter` measures an HTTP-date from the response's `Date` header.

## `UserFeedback`

Freezed sealed class with variants `Success`, `Warning`, `Failure`, `Information`, each `({String? message, FeedbackLevel level = FeedbackLevel.medium})`. `FeedbackLevel { low, medium, high, critical }` has `isProminent`. Getters `successMessage`, `errorMessage`, `warningMessage`, `informationMessage`; `match(onSuccess:, onWarning:, onFailure:, onInformation:)`; statics `warningFromException`, `failureFromException`; from an exception, `CommonException.toFailure() / toWarning() / toInformation()`. `VoidFailureCallback = void Function(Failure)`.

## Socket and JSON-RPC models

These models live in this package and are used by the WebSocket client and the JSON-RPC service of `dart_falconnect`; the skill shipped for `dart_falconnect` documents their members:

- Socket: `SocketOptions`, `SocketResponse`, `JsonSocketResponse`, `BinarySocketResponse`, `BaseSocketRequestBody`.
- JSON-RPC: `JsonRpcRequest`, `JsonRpcResponse`, `JsonRpcError`, `JsonRpcErrorResponse`, the result types `JsonRpcModelResult`, `JsonRpcListResult`, `JsonRpcIntResult`, `JsonRpcRawResult`, `JsonRpcStringResult`, `JsonRpcBoolResult`, and the batch types `BatchJsonRpcBody`, `BatchJsonRpcItem`, `BatchJsonRpcSuccess`, `BatchJsonRpcFailure`. The JSON-RPC exception classes are in `errors.md`.
