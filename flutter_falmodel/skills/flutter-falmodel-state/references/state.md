# State

`package: flutter_falmodel` (re-exports `dart_falmodel`, which supplies `UserFeedback`, `Success`, `Warning`, `Failure`, and `Information`): `WidgetDataState<T>`, `FullWidgetState`, and `FullWidgetStates`.

## `WidgetDataState<T>`

The immutable state object that the BLoCs and cubits of `flutter_falconx` emit: a `FullWidgetState`, `T data`, a `UserFeedback` (`dart_falmodel`), an optional one-shot `WidgetEvent`, and a `build` flag consumers use in `buildWhen`.

```dart
factory WidgetDataState.initial(T data, {String? id, UserFeedback? feedback, bool build = true});
factory WidgetDataState.loading(T data, {String? id, UserFeedback? feedback, bool build = true});
factory WidgetDataState.success(T data, {String? id, UserFeedback? feedback, bool build = true});
factory WidgetDataState.warning(T data, {String? id, UserFeedback? feedback, bool build = true}); // feedback defaults to Warning()
factory WidgetDataState.fail(T data, {String? id, UserFeedback? feedback, bool build = true});     // feedback defaults to Failure()
factory WidgetDataState.cancel(T data, {String? id, UserFeedback? feedback, bool build = true});
factory WidgetDataState.disabled(T data, {String? id, UserFeedback? feedback, bool build = true});
factory WidgetDataState.selected(T data, {String? id, UserFeedback? feedback, bool build = true});
// also: .normal, .empty, .hovered, .focused, .pressed, .dragged, .scrolledUnder

T get data;
FullWidgetState get state;
UserFeedback get feedback;
bool get isInitial / isLoading / isSuccess / isFail / isWarning / isCancel / isDisabled / isSelected / ... // and isNot* counterparts

WidgetDataState<T> toState(FullWidgetState newState, {T? data, String? id, UserFeedback? feedback, bool? build});
WidgetDataState<T> toLoading({T? data, String? id, UserFeedback? feedback, bool? build});
WidgetDataState<T> toSuccess({T? data, String? id, UserFeedback? feedback, bool? build});
// ...toFail, toWarning, toCancel, toInitial, toNormal, toEmpty, toDisabled, toSelected, etc. — one per FullWidgetState value

WidgetDataState<T> copyWith({FullWidgetState? state, String? id, UserFeedback? feedback, T? data, bool? build}); // never copies event
WidgetDataState<R> mapData<R>(R Function(T data) mapper);
WidgetDataState<T> mapState(FullWidgetState Function(FullWidgetState) mapper);
WidgetDataState<T> addEvent(Object eventName, [Object? eventData]); // one-shot BLoC → widget event, not copied by copyWith
```

```dart
var state = WidgetDataState.initial(<User>[]);
state = state.toLoading();
state = state.toSuccess(data: users, feedback: const Success(message: 'Loaded'));
if (state.isFail) showSnackBar(state.feedback.message); // showSnackBar: your app's function
```

`FullWidgetState` is an enum (`initial`, `normal`, `empty`, `hovered`, `focused`, `pressed`, `dragged`, `selected`, `scrolledUnder`, `disabled`, `loading`, `success`, `cancel`, `warning`, `fail`) with matching `is*`/`isNot*` getters and `toWidgetState` (maps to Flutter's `WidgetState`, or `null`). `FullWidgetStates` wraps a `Set<FullWidgetState>` with the same `is*`/`isNot*` getters, plus `contains`, `value`, and `copy`.

## `WidgetEvent`

`addEvent` attaches a one-shot `WidgetEvent` (`name`, optional `data`) for BLoC-to-widget communication; configure the consuming `buildWhen` to ignore event states.

## Extensions

- `FullWidgetStateExtension.toFullWidgetState` (on Flutter's `WidgetState`) is the inverse of `FullWidgetState.toWidgetState`; `WidgetState.error` maps to `FullWidgetState.fail`.
- `FalModelStreamResourceExtension.listen` (on `Stream<WidgetDataState>`) takes `onData` and an optional `onError`, and reports a `fail` state through `onError` as well as `onData`.

## Gotchas

- `copyWith` on `WidgetDataState` never copies `event` — events are one-shot by design. `toState` and the `toX` transitions do not carry it either; `mapData` and `mapState` do.
