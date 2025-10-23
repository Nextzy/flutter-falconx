import 'package:flutter_falconx/lib.dart';

class EnumCubit<T extends Enum> extends Cubit<T> {
  EnumCubit(super.data);

  T get data => state;

  void call(T data) => emit(data);
}
