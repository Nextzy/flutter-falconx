import 'package:flutter_falconx/src/src.dart';

enum NavigationEvent { pop }

class WidgetEventCubit extends Cubit<BlocEvent<Object?>?> {
  new() : super(null);

  BlocEvent<Object?>? get data => state;

  void emitPopScreen<T>([T? result]) =>
      emit(BlocEvent(NavigationEvent.pop, data: result));
}
