import 'package:flutter_falconx/src/src.dart';

class StringCubit extends Cubit<String> {
  new(super.initialState);

  String get data => state;

  void call(String string) => emit(string);
}
