import 'package:flutter_falconx/lib.dart';

abstract class FalconWidgetDataStateBloc<EVENT, DATA>
    extends FalconBloc<EVENT, WidgetDataState<DATA>> {
  FalconWidgetDataStateBloc(
    DATA initialData,
  ) : super(
          WidgetDataState.initial(initialData),
        );

  DATA get data => state.data;

// void _emit(WidgetDataState<DATA> state) {
//   alertEmitter();
//   _emitter?.call(state);
// }
//
// void emitEvent<T>(Object event, [T? data]) =>
//     _emit(state.addEvent(event, data));
//
// void emitInitial({DATA? data, Failure? feedback}) =>
//     _emit(WidgetDataState.initial(
//       data ?? state.data,
//       feedback: feedback,
//       build: true,
//     ));
//
// void emitLoading({DATA? data, Failure? feedback}) =>
//     _emit(WidgetDataState.loading(
//       data ?? state.data,
//       feedback: feedback,
//       build: true,
//     ));
//
// void emitFail({DATA? data, Failure? feedback}) => _emit(WidgetDataState.fail(
//       data ?? state.data,
//       feedback: feedback,
//       build: true,
//     ));
//
// void emitWarning({DATA? data, Warning? feedback}) =>
//     _emit(WidgetDataState.warning(
//       data ?? state.data,
//       feedback: feedback,
//       build: true,
//     ));
//
// void emitSuccess({DATA? data, UserFeedback? feedback}) =>
//     _emit(WidgetDataState.success(
//       data ?? state.data,
//       feedback: feedback,
//       build: true,
//     ));
//
// void emitCancel({DATA? data, UserFeedback? feedback}) =>
//     _emit(WidgetDataState.cancel(
//       data ?? state.data,
//       feedback: feedback,
//       build: true,
//     ));
//
// void saveInitialState(DATA data, {UserFeedback? feedback}) =>
//     _emit(WidgetDataState.initial(
//       data,
//       feedback: feedback,
//       build: false,
//     ));
//
// void saveLoadingState(DATA data, {UserFeedback? feedback}) =>
//     _emit(WidgetDataState.loading(
//       data,
//       feedback: feedback,
//       build: false,
//     ));
//
// void saveFailState(DATA data, {Failure? feedback}) =>
//     _emit(WidgetDataState.fail(
//       data,
//       feedback: feedback,
//       build: false,
//     ));
//
// void saveWarningState(DATA data, {Warning? feedback}) =>
//     _emit(WidgetDataState.warning(
//       data,
//       feedback: feedback,
//       build: false,
//     ));
//
// void saveSuccessState(DATA data, {UserFeedback? feedback}) =>
//     _emit(WidgetDataState.success(
//       data,
//       feedback: feedback,
//       build: false,
//     ));
//
// void saveCancelState(DATA data, {UserFeedback? feedback}) =>
//     _emit(WidgetDataState.cancel(
//       data,
//       feedback: feedback,
//       build: false,
//     ));
}

abstract class FalconNullableWidgetDataStateBloc<EVENT, DATA>
    extends FalconBloc<EVENT, WidgetDataState<DATA?>> {
  FalconNullableWidgetDataStateBloc({
    DATA? initialData,
  }) : super(WidgetDataState.initial(initialData));

  DATA? get data => state.data;

// void _emit(WidgetDataState<DATA?> state) {
//   alertEmitter();
//   _emitter?.call(state);
// }
//
// void emitEvent<T>(Object event, [T? data]) =>
//     _emit(state.addEvent(event, data));
//
// void emitInitial({DATA? data, UserFeedback? feedback}) =>
//     _emit(WidgetDataState.initial(
//       data ?? state.data,
//       feedback: feedback,
//       build: true,
//     ));
//
// void emitLoading({DATA? data, UserFeedback? feedback}) =>
//     _emit(WidgetDataState.loading(
//       data ?? state.data,
//       feedback: feedback,
//       build: true,
//     ));
//
// void emitFail({DATA? data, Failure? feedback}) => _emit(WidgetDataState.fail(
//       data ?? state.data,
//       feedback: feedback,
//       build: true,
//     ));
//
// void emitWarning({DATA? data, Warning? feedback}) =>
//     _emit(WidgetDataState.warning(
//       data ?? state.data,
//       feedback: feedback,
//       build: true,
//     ));
//
// void emitSuccess({DATA? data, UserFeedback? feedback}) =>
//     _emit(WidgetDataState.success(
//       data ?? state.data,
//       feedback: feedback,
//       build: true,
//     ));
//
// void emitCancel({DATA? data, UserFeedback? feedback}) =>
//     _emit(WidgetDataState.cancel(
//       data ?? state.data,
//       feedback: feedback,
//       build: true,
//     ));
//
// void saveInitialState(DATA? data, {UserFeedback? feedback}) =>
//     _emit(WidgetDataState.initial(
//       data,
//       feedback: feedback,
//       build: false,
//     ));
//
// void saveLoadingState(DATA? data, {UserFeedback? feedback}) =>
//     _emit(WidgetDataState.loading(
//       data,
//       feedback: feedback,
//       build: false,
//     ));
//
// void saveFailState(DATA? data, {Failure? feedback}) =>
//     _emit(WidgetDataState.fail(
//       data,
//       feedback: feedback,
//       build: false,
//     ));
//
// void saveWarningState(DATA? data, {Warning? feedback}) =>
//     _emit(WidgetDataState.warning(
//       data,
//       feedback: feedback,
//       build: false,
//     ));
//
// void saveSuccessState(DATA? data, {UserFeedback? feedback}) =>
//     _emit(WidgetDataState.success(
//       data,
//       feedback: feedback,
//       build: false,
//     ));
//
// void saveCancelState(DATA? data, {UserFeedback? feedback}) =>
//     _emit(WidgetDataState.cancel(
//       data,
//       feedback: feedback,
//       build: false,
//     ));
}

// abstract class FalconEventBloc<EVENT, STATE>
//     extends FalconBloc<BlocEvent<EVENT>, STATE> {
//   FalconEventBloc(
//     super.initialState, {
//     EventTransformer<BlocEvent<EVENT>>? transformer,
//   }) {
//     on<BlocEvent<EVENT>>(
//         (BlocEvent<EVENT> event, Emitter<STATE> emitter) async {
//       await onBlocEvent(event, emitter);
//     }, transformer: transformer);
//   }
//
//   Future<void> onBlocEvent(BlocEvent<EVENT> event, Emitter<STATE> emit);
//
//   // Future<void> callStream<A>({
//   //   required Stream<WidgetDataState<A?>> call,
//   //   required void Function(WidgetDataState<A?> state) onData,
//   //   VoidFailureCallback? onFailure,
//   // }) {
//   //   alertEmitter();
//   //   return _emitter!.onEach(
//   //     call,
//   //     onData: (WidgetDataState<A?> state) {
//   //       onData(state);
//   //     },
//   //     onError: (Object error, StackTrace stackTrace) {
//   //       if (error is Failure) {
//   //         onFailure?.call(error);
//   //       } else {
//   //         FlutterError.reportError(FlutterErrorDetails(
//   //           exception: error,
//   //           stack: stackTrace,
//   //         ));
//   //       }
//   //     },
//   //   );
//   // }
//   //
//   // Future<void> callEitherFuture<A>({
//   //   required Object key,
//   //   required Future<Either<Failure, A>> call,
//   //   required void Function(WidgetDataState<A?> state) onData,
//   //   VoidFailureCallback? onFailure,
//   //   bool debounceCall = true,
//   // }) =>
//   //     callStream<A>(
//   //       call: fetchEitherFuture<A>(
//   //         key: key,
//   //         call: call,
//   //         debounceFetch: debounceCall,
//   //       ),
//   //       onData: onData,
//   //       onFailure: onFailure,
//   //     );
//   //
//   // Future<void> callEitherStream<A>({
//   //   required Object key,
//   //   required Stream<Either<Failure, A>> call,
//   //   required void Function(WidgetDataState<A?> state) onData,
//   //   VoidFailureCallback? onFailure,
//   //   bool debounceCall = true,
//   // }) =>
//   //     callStream<A>(
//   //       call: fetchEitherStream<A>(
//   //         key: key,
//   //         call: call,
//   //         debounceFetch: debounceCall,
//   //       ),
//   //       onData: onData,
//   //       onFailure: onFailure,
//   //     );
// }

abstract class FalconBloc<EVENT, STATE> extends Bloc<EVENT, STATE> {
  FalconBloc(
    super.initialState,
  )   : _fetcher = EitherStreamFetcherList();

  final EitherStreamFetcherList _fetcher;

  STATE get currentState => state;

  Stream<WidgetDataState<T?>> fetchEitherStream<T>({
    required Object key,
    required Stream<Either<Failure, T>> call,
    bool debounceFetch = true,
  }) =>
      _fetcher.fetchStream(
        key: key,
        call: call,
        debounceFetch: debounceFetch,
      );

  Stream<WidgetDataState<T>> fetchEitherStreamSafe<T>({
    required Object key,
    required Stream<Either<Failure, T>> call,
    required T defaultData,
    bool debounceFetch = true,
  }) =>
      fetchEitherStream(
        key: key,
        call: call,
        debounceFetch: debounceFetch,
      ).map(
        (WidgetDataState<T?> event) => event.mapData(
          (T? a) => a ?? defaultData,
        ),
      );

  Stream<WidgetDataState<T?>> fetchEitherFuture<T>({
    required Object key,
    required Future<Either<Failure, T>> call,
    bool debounceFetch = true,
  }) =>
      _fetcher.fetchFuture(
        key: key,
        call: call,
        debounceFetch: debounceFetch,
      );

  Stream<WidgetDataState<T>> fetchEitherFutureSafe<T>({
    required Object key,
    required Future<Either<Failure, T>> call,
    required T defaultData,
    bool debounceFetch = true,
  }) =>
      fetchEitherFuture(
        key: key,
        call: call,
        debounceFetch: debounceFetch,
      ).map(
        (WidgetDataState<T?> event) => event.mapData(
          (T? a) => a ?? defaultData,
        ),
      );

  @override
  Future<void> close() async {
    await _fetcher.closeAsync();
    return super.close();
  }
}
