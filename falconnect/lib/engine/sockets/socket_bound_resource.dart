import 'package:falconnect/lib.dart';

class SocketBoundResource<EntityType, ResponseType> {
  SocketBoundResource._();

  static const String TAG = 'SocketBoundResource';

  static Stream<Either<Failure, EntityType>>
      asStream<EntityType, ResponseType>({
    bool Function(EntityType? data)? whenSave,
    required Stream<ResponseType> Function() createCallStream,
    FutureOr<EntityType> Function(ResponseType result)? processResponse,
    Future Function(EntityType item)? saveCallResult,
    VoidErrorCallback? error,
  }) {
    assert(
      ResponseType == EntityType ||
          (!(ResponseType == EntityType) && processResponse != null),
      'You need to specify the `processResponse` when the EntityType and ResponseType types are different',
    );

    // Start: inner function
    void onHandleException({
      required VoidErrorCallback? onError,
      required Object exception,
      required StackTrace? stackTrace,
      required EventSink<Either<Failure, EntityType>> sink,
    }) {
      if (exception is Failure) {
        sink.add(Left(exception));
      } else if (exception is Exception) {
        try {
          onError?.call(exception, stackTrace);
        } catch (newException, stackTrace) {
          if (newException is Failure) {
            sink.add(Left(newException));
          } else if (newException is Exception) {
            sink.add(Left(Failure(
              message: newException.toString(),
              exception: newException,
              stackTrace: stackTrace,
            )));
          }
        }
        NLog.e(TAG, 'Operation failed', exception);
      }
    }
    // End: inner function

    return createCallStream().transform(StreamTransformer<ResponseType,
        Either<Failure, EntityType>>.fromHandlers(
      handleData: (ResponseType response, sink) async {
        try {
          late EntityType data;
          if (processResponse != null) {
            final processedData = await processResponse(response);
            data = processedData;
          } else {
            final castData = response as EntityType;
            data = castData;
          }

          if ((whenSave?.call(data) ?? false) && saveCallResult != null) {
            await saveCallResult(data);
            NLog.i(TAG, 'Success save result data');
          }
          sink.add(Right(data));
        } on Exception catch (exception, stackTrace) {
          onHandleException(
              onError: error,
              exception: exception,
              stackTrace: stackTrace,
              sink: sink);
        }
      },
      handleError: (exception, stackTrace, sink) {
        onHandleException(
            onError: error,
            exception: exception,
            stackTrace: stackTrace,
            sink: sink);
      },
      handleDone: (sink) {
        sink.close();
      },
    ));
  }
}
