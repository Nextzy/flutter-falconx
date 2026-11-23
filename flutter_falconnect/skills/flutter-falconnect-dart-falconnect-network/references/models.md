# Models

`package: dart_falconnect`. The request, response, and `Result` models live in `dart_falmodel`; the skill shipped for that package documents them.

## `DatasourceBoundState`

Static helpers that turn local and remote calls into `Result` streams (`Result` is from `dart_falmodel`). Every thrown error becomes `Result.failure(e.toException())`, optionally rewritten by `handleError: (CommonException, StackTrace?) => CommonException`.

| Method                       | Parameters                                                                                         | Emits                                              |
|------------------------------|----------------------------------------------------------------------------------------------------|----------------------------------------------------|
| `asLocalResultStream<D>`     | `loadFromDbFuture` (required), `handleError`, `log`                                                | one local result                                   |
| `asLocalResultFuture<D>`     | same                                                                                               | first result                                       |
| `asRemoteResultStream<R, D>` | `callRemoteFuture` (required), `processResponse` (required when `R != D`), `handleError`, `log`    | one remote result                                  |
| `asRemoteResultFuture<R, D>` | `createCallFuture` (required), `processResponse`, `handleError`                                    | first result                                       |
| `asResultStream<R, D>`       | `loadFromDbFuture`, `shouldFetch(D?)`, `callRemoteFuture`, `processResponse`, `handleError`, `log` | local, then remote when `shouldFetch` returns true |

```dart
// Result is from dart_falmodel; UserDto, User, db, and api are your own.
Stream<Result<User>> watchUser(String id) =>
    DatasourceBoundState.asResultStream<UserDto, User>(
      loadFromDbFuture: () => db.getUser(id),
      shouldFetch: (u) => u == null || u.isStale,
      callRemoteFuture: () => api.getUser(id),
      processResponse: (dto) => dto.toDomain(),
    );
```

Notes: with both callbacks, a DB failure ends the stream with one failure and never reaches remote; with neither, `UnimplementedError` is thrown. `asRemoteResultFuture` names its callback `createCallFuture` while the stream variant uses `callRemoteFuture`. There is no `saveCallResult` parameter; persist inside `processResponse`.
