# Third-party

Every package here reaches your app once you depend on `flutter_falconnect`. Do not add a duplicate direct dependency for what it already brings in, and do not pin a different version than the constraint in `flutter_falconnect/pubspec.yaml` without checking it resolves against the git-pinned `flutter_falconnect`. The libraries that `dart_falconnect` brings (`dio`, `retrofit`, `dio_cache_interceptor`, `web_socket_channel`) are listed by the skill shipped for that package.

| Package | For | Platform gaps |
|---|---|---|
| `connectivity_plus` | Connectivity type stream backing `ConnectivityInterceptor` and `InternetConnectionBloc` | none |
