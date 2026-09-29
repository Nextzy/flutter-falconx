import 'package:flutter_falconx/src/src.dart';

abstract class ReplayBloc<EVENT, STATE> extends FalconBloc<EVENT, STATE> {
  ReplayBloc(super.initialState);

  final _subject = ReplaySubject<STATE>();

  @override
  Stream<STATE> get stream => _subject.stream;
}
