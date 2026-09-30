import 'package:flutter_falconx/src/src.dart';

abstract class BehaviorBloc<EVENT, STATE> extends FalconBloc<EVENT, STATE> {
  new(super.initialState);

  final _subject = BehaviorSubject<STATE>();

  @override
  Stream<STATE> get stream => _subject.stream;
}
