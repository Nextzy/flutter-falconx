import 'package:flutter_falconx/lib.dart';

extension FalconFutureExtensions<T> on Future<T> {
  Future<Either<Failure, T>> toEitherFailure({
    Failure Function(Object? error, StackTrace stackTrace)? handleError,
  }) =>
      then<Either<Failure, T>>(
        Right.new,
      ).onError(
        (exception, stackTrace) {
          var tmpException = exception;
          if (exception is DioException) {
            tmpException = exception.error;
          }
          return Left(
            handleError?.call(exception, stackTrace) ??
                Failure.fromException(
                  tmpException.toException(stackTrace: stackTrace),
                ),
          );
        },
      );

  Future<Either<CommonException, T>> toEitherException({
    CommonException Function(Object? error, StackTrace stackTrace)? handleError,
  }) =>
      then<Either<CommonException, T>>(
        Right.new,
      ).onError(
        (exception, stackTrace) {
          var tmpException = exception;
          if (exception is DioException) {
            tmpException = exception.error;
          }
          return Left(
            handleError?.call(
                  tmpException.toException(stackTrace: stackTrace),
                  stackTrace,
                ) ??
                tmpException.toException(stackTrace: stackTrace),
          );
        },
      );
}
