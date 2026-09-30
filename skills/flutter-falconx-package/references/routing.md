# Routing

`flutter_falconx/lib/routers/routers.dart` is an empty barrel — it exports nothing. `flutter_falconx` ships no routing API at 4.0.0.

Bring your own router (`go_router`, `auto_route`, Navigator 2.0, or plain `Navigator.push`) and add it to your app's own `pubspec.yaml`. Pair route results with `PopResult<D>` (`references/state.md`) to carry a typed, status-tagged value back from a popped route:

```dart
final result = await Navigator.of(context).push<PopResult<User>>(
  MaterialPageRoute(builder: (_) => const EditUserScreen()),
);
if (result?.isSuccess ?? false) refreshList(result!.data);
```

`FalconBlocState.buildCompatPopScope` (`references/state.md`) wires `PopScope` around whatever router you choose, so gate-based pop confirmation still goes through `buildWithBloc`'s `canPop`/`onPop` parameters rather than a router-specific API.
