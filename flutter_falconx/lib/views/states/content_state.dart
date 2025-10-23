import 'package:flutter_falconx/lib.dart';

class ContentState<T> extends Cubit<WidgetDataState<T>> {
  ContentState.initial(T data) : super(WidgetDataState.initial(data));

  bool get isInitial => state.isInitial; //
  bool get isSelected => state.isSelected; //
  bool get isDisabled => state.isDisabled; //
  bool get isLoading => state.isLoading; //
  bool get isSuccess => state.isSuccess; //
  bool get isFail => state.isFail; //
  bool get isWarning => state.isWarning; //
  bool get isCancel => state.isCancel; //

  bool get isNotInitial => !isInitial; //
  bool get isNotSelected => !isSelected; //
  bool get isNotDisabled => !isDisabled; //
  bool get isNotLoading => !isLoading; //
  bool get isNotSuccess => !isSuccess; //
  bool get isNotFail => !isFail; //
  bool get isNotWarning => !isWarning; //
  bool get isNotCancel => !isCancel; //

  FullWidgetState get status => state.state;

  T get data => state.data;

  set data(T data) => success(data: data);

  void initial([T? data]) {
    emit(WidgetDataState.initial(data ?? state.data));
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

class ContentBuilder<T>
    extends BlocBuilder<ContentState<T>, WidgetDataState<T>> {
  const ContentBuilder({
    super.key,
    required ContentState<T> content,
    super.buildWhen,
    required super.builder,
  }) : super(bloc: content);
}
