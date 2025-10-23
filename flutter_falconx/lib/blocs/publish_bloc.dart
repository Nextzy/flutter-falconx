import 'package:flutter_falconx/lib.dart';

abstract class PublishBloc<EVENT, STATE> extends FalconBloc<EVENT, STATE> {
  PublishBloc(super.initialState);

  final _subject = PublishSubject<STATE>();

  @override
  Stream<STATE> get stream => _subject.stream;
}
