import 'package:flutter_falconx/lib.dart';

class TypeCubit<T> extends Cubit<T> {
  TypeCubit(super.data);

  T get data => state;

  void call(T data) => emit(data);
}
