# Connectivity

`package: flutter_falconx` (`lib/networks/internet_connection_bloc.dart`). `Connectivity` and `ConnectivityResult` are `connectivity_plus`'s, re-exported through `flutter_falconnect`; see the skill shipped for `flutter_falconnect` (installed with this package) for the per-request `ConnectivityInterceptor`.

## `InternetConnectionBloc`

Wraps `connectivity_plus`'s `Connectivity` as a `BlocBase<List<ConnectivityResult>>`.

```dart
class InternetConnectionBloc extends BlocBase<List<ConnectivityResult>> {
  InternetConnectionBloc({required List<ConnectivityResult> initialResult, Connectivity? connectivity});
  List<ConnectivityResult> get result;
  bool get isConnectedInternet;    // true if wifi, ethernet, mobile, or vpn is present
  bool get isNotConnectedInternet;
}
```

```dart
final connection = InternetConnectionBloc(initialResult: await Connectivity().checkConnectivity());
BlocBuilder<InternetConnectionBloc, List<ConnectivityResult>>(
  bloc: connection,
  builder: (context, result) => connection.isConnectedInternet ? content : const OfflineBanner(),
);
```

## Gotchas

- `ConnectivityInterceptor` (`flutter_falconnect`) checks connectivity per request; it does not replace `InternetConnectionBloc`'s continuous stream for UI banners.
