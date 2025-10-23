import 'package:flutter_falconx/lib.dart';

enum PopResultStatus {
  info,
  fail,
  warning,
  success,
  cancel,
}

class PopResult<D extends Object?> extends Equatable {
  const PopResult.success([
    this.data,
  ]) : status = PopResultStatus.success;

  const PopResult.fail([
    this.data,
  ]) : status = PopResultStatus.fail;

  const PopResult.warning([
    this.data,
  ]) : status = PopResultStatus.warning;

  const PopResult.cancel([
    this.data,
  ]) : status = PopResultStatus.cancel;

  const PopResult.info([
    this.data,
  ]) : status = PopResultStatus.info;

  final PopResultStatus status;
  final D? data;

  bool get isSuccess => status == PopResultStatus.success;
  bool get isFail => status == PopResultStatus.fail;
  bool get isWarning => status == PopResultStatus.warning;
  bool get isInfo => status == PopResultStatus.info;
  bool get isCancel => status == PopResultStatus.cancel;

  bool get isNotSuccess => !isSuccess;
  bool get isNotFail => !isFail;
  bool get isNotWarning => !isWarning;
  bool get isNotInfo => !isInfo;
  bool get isNotCancel => !isCancel;

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [status, data];
}
