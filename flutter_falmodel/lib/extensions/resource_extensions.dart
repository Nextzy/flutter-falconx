// Ignore because is not necessary
// ignore_for_file:  join_return_with_assignment
// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter_falmodel/lib.dart';

extension FalModelStreamResourceExtension<T extends WidgetDataState>
    on Stream<T> {
  StreamSubscription<T> listen({
    required void Function(T data) onData,
    VoidErrorCallback? onError,
  }) {
    StreamSubscription<T>? _subscription;
    _subscription = this.listen((T data) {
      final state = data.state;
      if (state == FullWidgetState.fail) {
        if (onError != null) {
          onError(Exception(data.data), StackTrace.current);
        }
      }
      onData(data);
    }, onError: (Object error, StackTrace? stackTrace) {
      if (onError != null) {
        onError(error, stackTrace);
      }
    }, onDone: () {
      _subscription?.cancel();
    });
    return _subscription;
  }
}
