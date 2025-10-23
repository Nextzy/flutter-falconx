import 'package:flutter_falconx/lib.dart';

class IntCubit extends Cubit<int> {
  IntCubit(super.data);

  int get data => state;

  void call(int integer) => emit(integer);

  void increment([int increase = 1]) => emit(state + increase);

  void decrement([int decrease = 1]) => emit(state - decrease);
}
