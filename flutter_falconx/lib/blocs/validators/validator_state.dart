import 'package:flutter_falconx/src/src.dart';

class ValidateState<DATA> {
  const new({
    this.data,
    this.failure,
    this.canBuild = false,
  });

  final DATA? data;
  final Failure? failure;
  final bool canBuild;

  ValidateState<DATA> copyWith({
    DATA? data,
    Failure? failure,
    bool? build,
  }) {
    return ValidateState(
      data: data ?? this.data,
      failure: failure ?? this.failure,
      canBuild: build ?? canBuild,
    );
  }

  @override
  String toString() {
    return 'ValidatorState{data: $data, failure: $failure, build: $canBuild}';
  }
}
