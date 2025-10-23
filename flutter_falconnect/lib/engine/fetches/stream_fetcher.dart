import 'dart:async';

import 'package:flutter_falconnect/lib.dart';

/// A stream fetcher that handles Either&lt;Failure, T&gt; streams and manages
/// their lifecycle with proper resource cleanup and error handling.
///
/// Provides automatic memory management and prevents resource leaks through
/// proper subscription and controller cleanup.
class EitherStreamFetcher<T> {
  EitherStreamFetcher([StreamController<WidgetDataState<T?>>? controller])
      : _streamController =
            controller ?? StreamController<WidgetDataState<T?>>.broadcast();

  final StreamController<WidgetDataState<T?>> _streamController;
  StreamSubscription? _streamSubscription;
  bool _isClosed = false;

  /// The output stream of widget data states
  Stream<WidgetDataState<T?>> get stream => _streamController.stream;

  /// Whether this fetcher has been closed
  bool get isClosed => _isClosed || _streamController.isClosed;

  /// Fetches data from the provided stream and manages the subscription
  /// lifecycle.
  ///
  /// Returns a stream of [WidgetDataState] that emits loading, success, or
  /// error states. Automatically handles cleanup when the stream completes or
  /// encounters errors.
  Stream<WidgetDataState<T?>> fetch(
    Stream<Either<Failure, T>> call,
  ) {
    if (_isClosed) {
      throw StateError('Cannot fetch on a closed EitherStreamFetcher');
    }

    // Cancel any existing subscription before starting a new one
    _streamSubscription?.cancel();

    // Use scheduleMicrotask to ensure loading state is emitted after listeners are attached
    scheduleMicrotask(() {
      if (!_streamController.isClosed && !_isClosed) {
        _streamController.add(WidgetDataState.loading(null));
      }
    });

    _streamSubscription = call.listen(
      (data) {
        if (_isClosed) return; // Ignore if already closed

        data.fold(
          (failure) {
            if (!_streamController.isClosed) {
              _streamController.addError(failure);
            }
            _closeInternal();
          },
          (T data) {
            if (!_streamController.isClosed) {
              _streamController.add(WidgetDataState.success(data));
            }
          },
        );
      },
      onDone: () {
        printSuccess('Fetch: onDone called');
        _closeInternal();
      },
      onError: (Object error, StackTrace? stackTrace) {
        if (!_streamController.isClosed) {
          _streamController.addError(error, stackTrace);
        }
        _closeInternal();
      },
    );
    return _streamController.stream;
  }

  /// Closes the fetcher and cleans up all resources.
  ///
  /// This method is idempotent and safe to call multiple times.
  Future<void> close() async {
    await _closeInternal();
  }

  /// Internal method to handle closing without external exposure
  Future<void> _closeInternal() async {
    if (_isClosed) return;

    _isClosed = true;

    // Cancel subscription first to prevent new events
    await _streamSubscription?.cancel();
    _streamSubscription = null;

    // Close the stream controller
    if (!_streamController.isClosed) {
      await _streamController.close();
    }
  }
}
