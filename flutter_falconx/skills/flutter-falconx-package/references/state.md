# State

`package: flutter_falconx` (BLoCs, cubits, validators, builders, `FalconState` screens). The `WidgetDataState<T>`, `FullWidgetState`, and `FullWidgetStates` types they emit are `package: flutter_falmodel`, re-exported through `flutter_falconx`; see the skill shipped for `flutter_falmodel` (installed with this package). `Failure` and `Result` are `dart_falmodel`'s, and `Either` is `fpdart`'s, both re-exported too.

## `FalconBloc<EVENT, STATE>`

Base `Bloc` with debounced Either-stream/future fetching, keyed so a repeat call with the same `key` while one is in flight is dropped (or cancelled, with `debounceFetch: false`).

```dart
abstract class FalconBloc<EVENT, STATE> extends Bloc<EVENT, STATE> {
  FalconBloc(STATE initialState);

  Stream<WidgetDataState<T?>> fetchEitherStream<T>({required Object key, required Stream<Either<Failure, T>> call, bool debounceFetch = true});
  Stream<WidgetDataState<T>> fetchEitherStreamSafe<T>({required Object key, required Stream<Either<Failure, T>> call, required T defaultData, bool debounceFetch = true});
  Stream<WidgetDataState<T?>> fetchEitherFuture<T>({required Object key, required Future<Either<Failure, T>> call, bool debounceFetch = true});
  Stream<WidgetDataState<T>> fetchEitherFutureSafe<T>({required Object key, required Future<Either<Failure, T>> call, required T defaultData, bool debounceFetch = true});
}
```

`fetchEither*` use `EitherStreamFetcherList` (`flutter_falconnect`) internally; see the skill shipped for `flutter_falconnect` (installed with this package). `close()` closes the fetcher list before calling `super.close()`.

```dart
class UsersBloc extends FalconBloc<UsersEvent, WidgetDataState<List<User>>> {
  UsersBloc(this._repo) : super(WidgetDataState.initial(const [])) {
    on<LoadUsers>((event, emit) => emit.onEach(
      fetchEitherStreamSafe(key: 'load-users', call: _repo.watchUsers(), defaultData: const []),
      onData: emit.call,
    ));
  }
  final UserRepository _repo;
}
```

`FalconWidgetDataStateBloc<EVENT, DATA>` and `FalconNullableWidgetDataStateBloc<EVENT, DATA>` extend `FalconBloc` and pre-wrap the state in `WidgetDataState<DATA>` / `WidgetDataState<DATA?>`, exposing a `DATA` / `DATA?` `data` getter. Both are otherwise empty scaffolding — build events with `on<EVENT>` as usual.

## `BehaviorBloc` / `PublishBloc` / `ReplayBloc`

```dart
abstract class BehaviorBloc<EVENT, STATE> extends FalconBloc<EVENT, STATE> { BehaviorBloc(STATE initialState); }
abstract class PublishBloc<EVENT, STATE> extends FalconBloc<EVENT, STATE> { PublishBloc(STATE initialState); }
abstract class ReplayBloc<EVENT, STATE> extends FalconBloc<EVENT, STATE> { ReplayBloc(STATE initialState); }
```

Each overrides `stream` with an `rxdart` `BehaviorSubject` / `PublishSubject` / `ReplaySubject` in place of the plain `Bloc` stream. Subclass exactly like `FalconBloc`; pick the variant by the replay semantics your listeners need.

## Value cubits

```dart
class BoolCubit extends Cubit<bool> {
  BoolCubit(bool data);
  bool get data;
  void call(bool boolean);
  void toggle();
}
class IntCubit extends Cubit<int> {
  IntCubit(int data);
  int get data;
  void call(int integer);
  void increment([int increase = 1]);
  void decrement([int decrease = 1]);
}
class StringCubit extends Cubit<String> { StringCubit(String data); String get data; void call(String string); }
class EnumCubit<T extends Enum> extends Cubit<T> { EnumCubit(T data); T get data; void call(T data); }
class TypeCubit<T> extends Cubit<T> { TypeCubit(T data); T get data; void call(T data); }
```

```dart
final loading = BoolCubit(false);
loading.toggle();
final step = EnumCubit<CheckoutStep>(CheckoutStep.cart);
step(CheckoutStep.payment);
```

## Form validation

```dart
typedef ValidateWidgetBuilder<DATA> = Widget Function(BuildContext context, bool valid, DATA? data, Failure? failure);

abstract class ValidatorCubit<DATA> extends Cubit<ValidateState<DATA?>> {
  ValidatorCubit();
  Failure? onValidate(DATA? data);          // implement: return null when valid
  bool get isValid;
  bool get isInvalid;
  Failure? validate(DATA? data, {bool canBuild = false});
  void clear();
  void emitErrorMessage(String? userMessage, {FeedbackLevel level = FeedbackLevel.medium});
}

class ValidateBuilder<B extends Cubit<ValidateState<DATA?>>, DATA> extends StatelessWidget {
  const ValidateBuilder({Key? key, B? source, required ValidateWidgetBuilder<DATA> builder});
}

class ValidateState<DATA> {
  const ValidateState({DATA? data, Failure? failure, bool canBuild = false});
  DATA? get data;
  Failure? get failure;
  bool get canBuild;
  ValidateState<DATA> copyWith({DATA? data, Failure? failure, bool? build});
}
```

```dart
class EmailValidator extends ValidatorCubit<String> {
  @override
  Failure? onValidate(String? data) =>
      (data?.isEmail ?? false) ? null : const Failure(message: 'Invalid email');
}

ValidateBuilder<EmailValidator, String>(
  source: emailValidator,
  builder: (context, valid, data, failure) =>
      TextField(decoration: InputDecoration(errorText: failure?.message)),
);
```

`DisabledCubit extends Cubit<bool>` (in the same file as `DisabledBuilder`) plus:

```dart
class DisabledBuilder<B extends DisabledCubit, DATA> extends StatelessWidget {
  const DisabledBuilder({Key? key, B? source, required Widget Function(BuildContext, bool disabled) builder});
}
```

`List<ValidatorCubit>` also gets `isValid` / `isInvalid` (`ValidateListExtension`, `flutter_falconx/lib/extensions/validator_extension.dart`) to check every field in a form at once.

## Loading/success/fail UI

```dart
class FullWidgetStatesBuilder extends StatelessWidget {
  const FullWidgetStatesBuilder({Key? key, required FullWidgetStatesNotifier create, required Widget Function(BuildContext, FullWidgetStates) builder});
}
```

```dart
class FullWidgetStatesNotifier extends ValueNotifier<FullWidgetStates> {
  FullWidgetStatesNotifier([dynamic state]); // FullWidgetStates, a single FullWidgetState, or nothing (defaults to {normal})
  set state(FullWidgetState state);          // replaces the display or action state group
  set hover/select/focus/loading/disabled(bool value);
  void addState(FullWidgetState state);
  void removeState(FullWidgetState state);
  void removeAllState(List<FullWidgetState> states);
  void toggleState(FullWidgetState state);
  void setAllState(Set<FullWidgetState> newStates);
  void resetState(); // back to {normal}
  bool hasState(FullWidgetState state);
  bool hasAnyState(List<FullWidgetState> states);
  bool hasAllStates(List<FullWidgetState> states);
}
```

`ContentState<T>` and `NullableContentState<T>` are `Cubit<WidgetDataState<T>>` / `Cubit<WidgetDataState<T?>>` wrappers with `initial`, `success`, `loading`, `cancel`, `disabled`, `warning`, `selected`, `fail` emit helpers, `data` getter/setter, `status`, and the same `is*`/`isNot*` state getters as `WidgetDataState`. Pair each with `ContentBuilder<T>` / `NullableContentBuilder<T>` (`BlocBuilder` subclasses that take the cubit as `content:`).

```dart
final name = ContentState<String>.initial('');
ContentBuilder<String>(content: name, builder: (context, state) => Text(state.data));
name.success(data: 'Jane');
```

`FalconApplicationState<T extends StatefulWidget> extends FalconState<T>` is an empty marker subclass; `FalconState` (same file family, `views/states/state.dart`) is the lifecycle-aware `State` base every falcon screen extends — it owns a `FullWidgetStatesNotifier` (`stateNotifier`), forwards `AppLifecycleState` changes to `resumed()/inactive()/paused()/detached()/hidden()`, and exposes `setLoadingState`, `setFailState`, `setSuccessState`, `setNormalState`, `setDisabledState`, `setHoveredState`, `setFocusedState`, `setSelectedState`, `setWarningState`, `setEmptyState`, `setCancelState`, `setFullWidgetState`, `setWidgetStates`, `stateBuilder`, `clearFocus`, `updateState`, `currentVersion` (from `package_info_plus`).

`FalconBlocState<WIDGET, BLOC extends BlocBase<STATE>, STATE> extends FalconState<WIDGET>` adds `bloc` (`context.read<BLOC>()`) and `buildCompatPopScope`. Two ready-made variants wrap `WidgetDataState`:

```dart
abstract class FalconWidgetBlocState<WIDGET extends StatefulWidget, BLOC extends BlocBase<WidgetDataState<DATA>>, DATA> extends FalconBlocState<WIDGET, BLOC, WidgetDataState<DATA>> {
  Widget buildWithBloc({
    BlocWidgetListenerEvent<Object>? listenEvent,
    BlocWidgetListenerState<WidgetDataState<DATA>>? listenState,
    CanPopListener<WidgetDataState<DATA>>? canPop,
    PopListener<WidgetDataState<DATA>>? onPop,
    BlocListenerCondition<WidgetDataState<DATA>>? buildWhen,
    required BlocWidgetBuilder<WidgetDataState<DATA>> builder,
    BlocWidgetBuilder<WidgetDataState<DATA>>? failBuilder,
    BlocWidgetBuilder<WidgetDataState<DATA>>? loadingBuilder,
    BlocWidgetBuilder<WidgetDataState<DATA>>? warningBuilder,
  });
}
abstract class FalconNullableWidgetBlocState<WIDGET extends StatefulWidget, BLOC extends BlocBase<WidgetDataState<DATA?>>, DATA> extends FalconBlocState<WIDGET, BLOC, WidgetDataState<DATA?>> {
  // same buildWithBloc, over WidgetDataState<DATA?>
}
```

`buildWithBloc` picks `failBuilder`/`warningBuilder`/`loadingBuilder` by `state.isFail`/`isWarning`/`isLoading`, falls back to `builder`, wraps the result in a `GestureDetector` that clears focus on tap, and applies `PopScope` when `canPop`/`onPop` is set.

```dart
class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});
  @override
  State<UsersScreen> createState() => _UsersScreenState();
}
class _UsersScreenState extends FalconWidgetBlocState<UsersScreen, UsersBloc, List<User>> {
  @override
  Widget buildStates(BuildContext context, FullWidgetStates states) => buildWithBloc(
    builder: (context, state) => ListView(children: [for (final u in state.data) Text(u.name)]),
    loadingBuilder: (context, state) => const CircularProgressIndicator(),
    failBuilder: (context, state) => Text(state.feedback.message ?? 'Error'),
  );
}
```

`PopResult<D>` carries a typed result plus outcome status off a popped route:

```dart
class PopResult<D extends Object?> extends Equatable {
  const PopResult.success([D? data]);
  const PopResult.fail([D? data]);
  const PopResult.warning([D? data]);
  const PopResult.cancel([D? data]);
  const PopResult.info([D? data]);
  PopResultStatus get status; // info | fail | warning | success | cancel
  D? get data;
  bool get isSuccess / isFail / isWarning / isInfo / isCancel;
}
```

## `Emitter<WidgetDataState<T>>` extensions

`flutter_falconx/lib/blocs/extensions/emitter.dart` adds `WidgetDataStateEmitterExtensions<T>` so a `Bloc`'s `on<EVENT>` handler can transition state without hand-rolling `emit(currentState.toX(...))`:

```dart
extension WidgetDataStateEmitterExtensions<T> on Emitter<WidgetDataState<T>> {
  void initial(WidgetDataState<T> currentState, {T? data, String? id, UserFeedback? feedback});
  void loading(WidgetDataState<T> currentState, {T? data, String? id, UserFeedback? feedback});
  void success(WidgetDataState<T> currentState, {T? data, String? id, UserFeedback? feedback});
  void fail(WidgetDataState<T> currentState, {T? data, String? id, UserFeedback? feedback});
  void warning(WidgetDataState<T> currentState, {T? data, String? id, UserFeedback? feedback});
  void cancel(WidgetDataState<T> currentState, {T? data, String? id, UserFeedback? feedback});
  // saveLoading/saveSuccess/saveFail/saveWarning/saveCancel: same signature, build: false
  // saveInitial: same signature; see Gotchas
  void event(WidgetDataState<T> currentState, Object event, {Object? data});

  Future<void> callStream<A>({required Stream<WidgetDataState<A?>> call, required void Function(WidgetDataState<A?> result) onData, VoidFailureCallback? onFailure});
  Future<void> callEitherStream<A>({required Stream<Either<Failure, A>> call, required void Function(WidgetDataState<A?> result) onData, VoidFailureCallback? onFailure});
  Future<void> callResultStream<A>({required Stream<Result<A>> call, required void Function(WidgetDataState<A?> result) onData, VoidFailureCallback? onFailure});
  Future<void> callEitherFuture<A>({required Future<Either<Failure, A>> call, required void Function(WidgetDataState<A?> state) onData, VoidFailureCallback? onFailure});
  Future<void> callResultFuture<A>({required Future<Result<A>> call, required void Function(WidgetDataState<A?> state) onData, VoidFailureCallback? onFailure});
}
```

`callEitherStream`/`callEitherFuture` consume `fpdart`'s `Either<Failure, A>`; `callResultStream`/`callResultFuture` consume `dart_falmodel`'s `Result<A>` — pick the one matching what your repository layer returns. Every `call*` variant emits `WidgetDataState.loading(null)` first, forwards `Failure`s to `onFailure`, and reports non-`Failure` errors through `FlutterError.reportError`.

```dart
on<LoadProfile>((event, emit) => emit.callResultFuture(
  call: _repo.getProfile(),
  onData: (state) => emit(state),
  onFailure: (failure) => emit.fail(state, feedback: failure),
));
```

## Also in this package

- `BlocEvent<Event>` (`{name, data}` pair) for BLoC-to-widget one-off events outside `WidgetDataState.addEvent`.
- `FalconFutureExtensions<T>` on `Future<T>`: `toEitherFailure()` / `toEitherException()` unwrap a `DioException` and convert any other error into a `Failure` / `CommonException`.
- `BuildConfig.debug` / `BuildConfig.release` — thin wrapper over `kReleaseMode`.

## Gotchas

- `ValidatorCubit.emit` is `@Deprecated`; call `validate(...)`, `clear()`, or `emitErrorMessage(...)` instead of emitting a `ValidateState` directly.
- `WillPopListener` and the `onWillPop` parameter were removed in 4.0.0; pass `canPop`/`onPop` to `buildWithBloc`.
- `BehaviorBloc`/`PublishBloc`/`ReplayBloc` only change which `rxdart` subject backs `stream`; they do not publish into that subject automatically — `emit` still drives it through the normal `Bloc` machinery.
- `Emitter.saveInitial` does not pass `build: false`, unlike the other `save*` extensions, so its state still rebuilds listeners.
