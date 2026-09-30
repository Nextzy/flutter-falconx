import 'package:flutter_falconx/src/src.dart';

abstract class PublishBloc<EVENT, STATE> extends FalconBloc<EVENT, STATE> {
  new(super.initialState);

  final _subject = PublishSubject<STATE>();

  @override
  Stream<STATE> get stream => _subject.stream;
}
