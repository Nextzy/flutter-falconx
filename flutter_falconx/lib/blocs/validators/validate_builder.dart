// Ignore because is not necessary
// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter_falconx/lib.dart';

typedef ValidateWidgetBuilder<DATA> = Widget Function(
    BuildContext context, bool valid, DATA? data, Failure? failure);

abstract class ValidatorCubit<DATA> extends Cubit<ValidateState<DATA?>> {
  ValidatorCubit() : super(const ValidateState(data: null));

  Failure? onValidate(DATA? data);

  bool get isValid => onValidate(state.data) == null;

  bool get isInvalid => !isValid;

  Failure? validate(DATA? data, {bool canBuild = false}) {
    final failure = onValidate(data);
    emit(ValidateState(data: data, failure: failure, canBuild: canBuild));
    return failure;
  }

  void clear() {
    emit(const ValidateState(data: null));
  }

  void emitError(String? message) {
    emit(ValidateState<DATA>(failure: Failure(message: message)));
  }

  @Deprecated('Please use [validate] or [emitError]')
  @protected
  @visibleForTesting
  @override
  void emit(ValidateState<DATA?> state) {
    super.emit(state);
  }
}

class ValidateBuilder<B extends Cubit<ValidateState<DATA?>>, DATA>
    extends StatelessWidget {
  const ValidateBuilder({
    super.key,
    this.source,
    required this.builder,
  });

  final B? source;
  final ValidateWidgetBuilder<DATA> builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, ValidateState<DATA?>>(
      bloc: source,
      buildWhen: (previous, current) {
        if (previous.failure != current.failure) {
          return true;
        } else {
          return current.canBuild;
        }
      },
      builder: (context, state) => builder(
        context,
        state.failure == null,
        state.data,
        state.failure,
      ),
    );
  }
}
