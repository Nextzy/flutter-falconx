import 'package:flutter_falconx/src/src.dart';

class StringCubit extends Cubit<String> {
  StringCubit(super.data);

  String get data => state;

  void call(String string) => emit(string);
}
