import 'package:flutter_falconx/lib.dart';

class NullableContentState<T> extends Cubit<WidgetDataState<T?>> {
  NullableContentState.initial({T? data, UserFeedback? feedback})
      : super(WidgetDataState.initial(data, feedback: feedback));

  bool get isInitial => state.isInitial; //
  bool get isEmpty => state.isEmpty; //
  bool get isSelected => state.isSelected; //
  bool get isDisabled => state.isDisabled; //
  bool get isLoading => state.isLoading; //
  bool get isSuccess => state.isSuccess; //
  bool get isFail => state.isFail; //
  bool get isWarning => state.isWarning; //
  bool get isCancel => state.isCancel; //

  bool get isNotInitial => !isInitial; //
  bool get isNotEmpty => !isEmpty; //
  bool get isNotSelected => !isSelected; //
  bool get isNotDisabled => !isDisabled; //
  bool get isNotLoading => !isLoading; //
  bool get isNotSuccess => !isSuccess; //
  bool get isNotFail => !isFail; //
  bool get isNotWarning => !isWarning; //
  bool get isNotCancel => !isCancel; //

  FullWidgetState get status => state.state;

  T? get data => state.data;

  set data(T? data) => success(data: data);

  void initial({T? data, UserFeedback? feedback}) {
    emit(WidgetDataState.initial(data ?? state.data, feedback: feedback));
  }

  void empty() {
    emit(WidgetDataState.empty(null));
  }

  void success({T? data, UserFeedback? feedback}) {
    emit(WidgetDataState.success(data ?? state.data, feedback: feedback));
  }

  void loading({T? data, UserFeedback? feedback}) {
    emit(WidgetDataState.loading(data ?? state.data, feedback: feedback));
  }

  void cancel({T? data, UserFeedback? feedback}) {
    emit(WidgetDataState.cancel(data ?? state.data, feedback: feedback));
  }

  void disabled({T? data, UserFeedback? feedback}) {
    emit(WidgetDataState.disabled(data ?? state.data, feedback: feedback));
  }

  void warning({T? data, Warning? feedback}) {
    emit(WidgetDataState.warning(data ?? state.data, feedback: feedback));
  }

  void selected({T? data, UserFeedback? feedback}) {
    emit(WidgetDataState.selected(data ?? state.data, feedback: feedback));
  }

  void fail({T? data, Failure? feedback}) {
    emit(WidgetDataState.fail(data ?? state.data, feedback: feedback));
  }
}

class NullableContentBuilder<T>
    extends BlocBuilder<NullableContentState<T>, WidgetDataState<T?>> {
  const NullableContentBuilder({
    super.key,
    required NullableContentState<T> content,
    super.buildWhen,
    required super.builder,
  }) : super(bloc: content);
}
