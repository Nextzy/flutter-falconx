import 'package:flutter_falconx/src/src.dart';

class TypeCubit<T> extends Cubit<T> {
  new(super.initialState);

  T get data => state;

  void call(T data) => emit(data);
}
