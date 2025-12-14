import 'dart:async';

import 'package:flutter_falconx/lib.dart';

// extension WidgetDataStateEmitterExtensions<T>
// on Emitter<WidgetDataState<T?>> {
//   void initial([T? data]) => call(WidgetDataState.initial(data)); //
//   void loading([T? data]) => call(WidgetDataState.loading(data)); //
//   void fail([T? data]) => call(WidgetDataState.fail(data)); //
//   void warning([T? data]) => call(WidgetDataState.warning(data)); //
//   void success(T data) => call(WidgetDataState.success(data)); //
//   void cancel([T? data]) => call(WidgetDataState.cancel(data)); //
//   void saveInitial([T? data]) =>
//       call(WidgetDataState.initial(data, build: false)); //
//   void saveLoading([T? data]) =>
//       call(WidgetDataState.loading(data, build: false)); //
//   void saveFail([T? data]) => call(WidgetDataState.fail(data, build: false)); //
//   void saveWarning([T? data]) =>
//       call(WidgetDataState.warning(data, build: false)); //
//   void saveSuccess([T? data]) =>
//       call(WidgetDataState.success(data, build: false)); //
//   void saveCancel([T? data]) =>
//       call(WidgetDataState.cancel(data, build: false)); //
//
//   /// Or use:
//   /// emitter.emit(state.addEvent(...))
//   void event(WidgetDataState<T?> currentState,
//       Objecgt event,
//       {
//         Object? data,
//       }) =>
//       call(currentState.addEvent(event, data));
//
//   Future<void> callStream<A>({
//     required Stream<WidgetDataState<A?>> call,
//     required void Function(
//         WidgetDataState<A?> state,
//         ) onData,
//     VoidFailureCallback? onFailure,
//   }) =>
//       onEach(
//         call,
//         onData: (WidgetDataState<A?> state) {
//           onData(state);
//         },
//         onError: (Object error, StackTrace stackTrace) {
//           if (error is Failure) {
//             onFailure?.call(error);
//           } else {
//             FlutterError.reportError(FlutterErrorDetails(
//               exception: error,
//               stack: stackTrace,
//             ));
//           }
//         },
//       );
//
//   Future<void> callEitherStream<A>({
//     required Stream<Either<Failure, A>> call,
//     required void Function(WidgetDataState<A?> state) onData,
//     VoidFailureCallback? onFailure,
//   }) {
//     final controller =
//     StreamController<WidgetDataState<A?>>.broadcast(sync: true);
//
//     controller.onListen = () {
//       controller.add(WidgetDataState.loading(null));
//       final subscription = call.listen(
//         null,
//         onError: (Object error, StackTrace? stackTrace) {
//           if (!controller.isClosed) {
//             controller.addError(error, stackTrace);
//           }
//           controller.close();
//         },
//       )
//         ..onData(
//               (data) {
//             data.fold(
//                   (failure) {
//                 if (!controller.isClosed) {
//                   controller.addError(failure);
//                 }
//                 controller.close();
//               },
//                   (data) {
//                 if (!controller.isClosed) {
//                   controller.add(WidgetDataState.success(data));
//                 }
//               },
//             );
//           },
//         )
//         ..onDone(controller.close);
//       controller.onCancel = subscription.cancel;
//     };
//
//     return callStream<A>(
//       call: controller.stream,
//       onData: onData,
//       onFailure: onFailure,
//     );
//   }
//
//   Future<void> callEitherFuture<A>({
//     required Future<Either<Failure, A>> call,
//     required void Function(WidgetDataState<A?> state) onData,
//     VoidFailureCallback? onFailure,
//   }) {
//     final controller =
//     StreamController<WidgetDataState<A?>>.broadcast(sync: true);
//
//     controller.onListen = () {
//       controller.add(WidgetDataState.loading(null));
//       final subscription = Stream.fromFuture(call).listen(
//         null,
//         onError: (Object error, StackTrace? stackTrace) {
//           if (!controller.isClosed) {
//             controller.addError(error, stackTrace);
//           }
//           controller.close();
//         },
//       )
//         ..onData(
//               (data) {
//             data.fold(
//                   (failure) {
//                 if (!controller.isClosed) {
//                   controller.addError(failure);
//                 }
//                 controller.close();
//               },
//                   (data) {
//                 if (!controller.isClosed) {
//                   controller.add(WidgetDataState.success(data));
//                 }
//               },
//             );
//           },
//         )
//         ..onDone(controller.close);
//       controller.onCancel = subscription.cancel;
//     };
//
//     return callStream<A>(
//       call: controller.stream,
//       onData: onData,
//       onFailure: onFailure,
//     );
//   }
// }

extension WidgetDataStateEmitterExtensions<T> on Emitter<WidgetDataState<T>> {
  void initial(
    WidgetDataState<T> currentState, {
    T? data,
    String? id,
    UserFeedback? feedback,
  }) => call(currentState.toInitial(data: data, id: id, feedback: feedback));

  void loading(
    WidgetDataState<T> currentState, {
    T? data,
    String? id,
    UserFeedback? feedback,
  }) => call(currentState.toLoading(data: data, id: id, feedback: feedback));

  void fail(
    WidgetDataState<T> currentState, {
    T? data,
    String? id,
    UserFeedback? feedback,
  }) => call(currentState.toFail(data: data, id: id, feedback: feedback));

  void warning(
    WidgetDataState<T> currentState, {
    T? data,
    String? id,
    UserFeedback? feedback,
  }) => call(currentState.toWarning(data: data, id: id, feedback: feedback));

  void success(
    WidgetDataState<T> currentState, {
    T? data,
    String? id,
    UserFeedback? feedback,
  }) => call(currentState.toSuccess(data: data, id: id, feedback: feedback));

  void cancel(
    WidgetDataState<T> currentState, {
    T? data,
    String? id,
    UserFeedback? feedback,
  }) => call(currentState.toCancel(data: data, id: id, feedback: feedback));

  void saveInitial(
    WidgetDataState<T> currentState, {
    T? data,
    String? id,
    UserFeedback? feedback,
  }) => call(currentState.toInitial(data: data, id: id, feedback: feedback));

  void saveLoading(
    WidgetDataState<T> currentState, {
    T? data,
    String? id,
    UserFeedback? feedback,
  }) => call(
    currentState.toLoading(
      data: data,
      id: id,
      feedback: feedback,
      build: false,
    ),
  );

  void saveFail(
    WidgetDataState<T> currentState, {
    T? data,
    String? id,
    UserFeedback? feedback,
  }) => call(
    currentState.toFail(data: data, id: id, feedback: feedback, build: false),
  );

  void saveWarning(
    WidgetDataState<T> currentState, {
    T? data,
    String? id,
    UserFeedback? feedback,
  }) => call(
    currentState.toWarning(
      data: data,
      id: id,
      feedback: feedback,
      build: false,
    ),
  );

  void saveSuccess(
    WidgetDataState<T> currentState, {
    T? data,
    String? id,
    UserFeedback? feedback,
  }) => call(
    currentState.toSuccess(
      data: data,
      id: id,
      feedback: feedback,
      build: false,
    ),
  );

  void saveCancel(
    WidgetDataState<T> currentState, {
    T? data,
    String? id,
    UserFeedback? feedback,
  }) => call(
    currentState.toCancel(data: data, id: id, feedback: feedback, build: false),
  );

  /// Or use:
  /// emitter.emit(state.addEvent(...))
  void event(
    WidgetDataState<T> currentState,
    Object event, {
    Object? data,
  }) => call(currentState.addEvent(event, data));

  Future<void> callStream<A>({
    required Stream<WidgetDataState<A?>> call,
    required void Function(WidgetDataState<A?> result) onData,
    VoidFailureCallback? onFailure,
  }) => onEach(
    call,
    onData: (WidgetDataState<A?> data) {
      onData(data);
    },
    onError: (Object error, StackTrace stackTrace) {
      if (error is Failure) {
        onFailure?.call(error);
      } else {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
          ),
        );
      }
    },
  );

  Future<void> callEitherStream<A>({
    required Stream<Either<Failure, A>> call,
    required void Function(WidgetDataState<A?> result) onData,
    VoidFailureCallback? onFailure,
  }) {
    final controller = StreamController<WidgetDataState<A?>>.broadcast(
      sync: true,
    );

    controller.onListen = () {
      controller.add(WidgetDataState.loading(null));
      final subscription =
          call.listen(
              null,
              onError: (Object error, StackTrace? stackTrace) {
                if (!controller.isClosed) {
                  controller.addError(error, stackTrace);
                }
                unawaited(controller.close());
              },
            )
            ..onData(
              (data) {
                data.fold(
                  (failure) {
                    if (!controller.isClosed) {
                      controller.addError(failure);
                    }
                    unawaited(controller.close());
                  },
                  (data) {
                    if (!controller.isClosed) {
                      controller.add(WidgetDataState.success(data));
                    }
                  },
                );
              },
            )
            ..onDone(controller.close);
      controller.onCancel = subscription.cancel;
    };

    return callStream<A>(
      call: controller.stream,
      onData: onData,
      onFailure: onFailure,
    );
  }

  Future<void> callResultStream<A>({
    required Stream<Result<A>> call,
    required void Function(WidgetDataState<A?> result) onData,
    VoidFailureCallback? onFailure,
  }) {
    final controller = StreamController<WidgetDataState<A?>>.broadcast(
      sync: true,
    );

    controller.onListen = () {
      controller.add(WidgetDataState.loading(null));
      final subscription =
          call.listen(
              null,
              onError: (Object error, StackTrace? stackTrace) {
                if (!controller.isClosed) {
                  controller.addError(error, stackTrace);
                }
                unawaited(controller.close());
              },
            )
            ..onData(
              (data) {
                data.resolve(
                  (data) {
                    if (!controller.isClosed) {
                      controller.add(WidgetDataState.success(data));
                    }
                  },
                  (failure, stacktrace) {
                    if (!controller.isClosed) {
                      controller.addError(failure);
                    }
                    unawaited(controller.close());
                  },
                );
              },
            )
            ..onDone(controller.close);
      controller.onCancel = subscription.cancel;
    };

    return callStream<A>(
      call: controller.stream,
      onData: onData,
      onFailure: onFailure,
    );
  }

  Future<void> callEitherFuture<A>({
    required Future<Either<Failure, A>> call,
    required void Function(WidgetDataState<A?> state) onData,
    VoidFailureCallback? onFailure,
  }) {
    final controller = StreamController<WidgetDataState<A?>>.broadcast(
      sync: true,
    );

    controller.onListen = () {
      controller.add(WidgetDataState.loading(null));
      final subscription =
          Stream.fromFuture(call).listen(
              null,
              onError: (Object error, StackTrace? stackTrace) {
                if (!controller.isClosed) {
                  controller.addError(error, stackTrace);
                }
                unawaited(controller.close());
              },
            )
            ..onData(
              (data) {
                data.fold(
                  (failure) {
                    if (!controller.isClosed) {
                      controller.addError(failure);
                    }
                    unawaited(controller.close());
                  },
                  (data) {
                    if (!controller.isClosed) {
                      controller.add(WidgetDataState.success(data));
                    }
                  },
                );
              },
            )
            ..onDone(controller.close);
      controller.onCancel = subscription.cancel;
    };

    return callStream<A>(
      call: controller.stream,
      onData: onData,
      onFailure: onFailure,
    );
  }

  Future<void> callResultFuture<A>({
    required Future<Result<A>> call,
    required void Function(WidgetDataState<A?> state) onData,
    VoidFailureCallback? onFailure,
  }) {
    final controller = StreamController<WidgetDataState<A?>>.broadcast(
      sync: true,
    );

    controller.onListen = () {
      controller.add(WidgetDataState.loading(null));
      final subscription =
          Stream.fromFuture(call).listen(
              null,
              onError: (Object error, StackTrace? stackTrace) {
                if (!controller.isClosed) {
                  controller.addError(error, stackTrace);
                }
                unawaited(controller.close());
              },
            )
            ..onData(
              (data) {
                data.resolve(
                  (data) {
                    if (!controller.isClosed) {
                      controller.add(WidgetDataState.success(data));
                    }
                  },
                  (failure, stacktrace) {
                    if (!controller.isClosed) {
                      controller.addError(failure);
                    }
                    unawaited(controller.close());
                  },
                );
              },
            )
            ..onDone(controller.close);
      controller.onCancel = subscription.cancel;
    };

    return callStream<A>(
      call: controller.stream,
      onData: onData,
      onFailure: onFailure,
    );
  }
}
