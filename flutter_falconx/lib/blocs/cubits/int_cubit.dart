import 'package:flutter_falconx/src/src.dart';

class IntCubit extends Cubit<int> {
  new(super.initialState);

  int get data => state;

  void call(int integer) => emit(integer);

  void increment([int increase = 1]) => emit(state + increase);

  void decrement([int decrease = 1]) => emit(state - decrease);
}
