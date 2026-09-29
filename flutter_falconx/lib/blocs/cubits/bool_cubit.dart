import 'package:flutter_falconx/src/src.dart';

class BoolCubit extends Cubit<bool>{

  BoolCubit(super.data);

  bool get data => state;

  void call(bool boolean){
    emit(boolean);
  }

  void toggle(){
    emit(!state);
  }
}
