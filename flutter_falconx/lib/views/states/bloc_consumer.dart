import 'package:flutter_falconx/lib.dart';

class NullableWidgetStateBlocConsumer<
B extends StateStreamable<WidgetDataState<DATA?>>,
DATA> extends BlocConsumer<B, WidgetDataState<DATA?>> {
  NullableWidgetStateBlocConsumer({
    super.key,
    super.bloc,
    BlocWidgetListenerEvent<Object>? listenEvent,
    BlocWidgetListenerState<WidgetDataState<DATA?>>? listenState,
    BlocBuilderCondition<WidgetDataState<DATA?>>? buildWhen,
    required BlocWidgetBuilder<WidgetDataState<DATA?>> builder,
    BlocWidgetBuilder<WidgetDataState<DATA?>>? failBuilder,
    BlocWidgetBuilder<WidgetDataState<DATA?>>? loadingBuilder,
    BlocWidgetBuilder<WidgetDataState<DATA?>>? warningBuilder,
  }) : super(
    listenWhen: (previous, current) => true,
    listener: (context, state) {
      if (state.event != null) {
        listenEvent?.call(context, state.event!.name, state.event!.data);
      } else {
        listenState?.call(context, state);
      }
    },
    buildWhen: (previous, current) {
      if (current.event != null) {
        // No build the widget when state has event
        return false;
      } else if (buildWhen != null) {
        return buildWhen(previous, current);
      } else if (current.event == null) {
        return current.build;
      } else {
        return true;
      }
    },
    builder: (context, state) {
      if (state.isFail && failBuilder != null) {
        return failBuilder(context, state);
      } else if (state.isWarning && warningBuilder != null) {
        return warningBuilder(context, state);
      } else if (state.isLoading && loadingBuilder != null) {
        return loadingBuilder(context, state);
      } else {
        return builder(context, state);
      }
    },
  );
}

class WidgetStateBlocConsumer<B extends StateStreamable<WidgetDataState<DATA>>,
DATA> extends BlocConsumer<B, WidgetDataState<DATA>> {
  WidgetStateBlocConsumer({
    super.key,
    super.bloc,
    BlocWidgetListenerEvent<Object>? listenEvent,
    BlocWidgetListenerState<WidgetDataState<DATA>>? listenState,
    BlocBuilderCondition<WidgetDataState<DATA>>? buildWhen,
    required BlocWidgetBuilder<WidgetDataState<DATA>> builder,
    BlocWidgetBuilder<WidgetDataState<DATA>>? failBuilder,
    BlocWidgetBuilder<WidgetDataState<DATA>>? loadingBuilder,
    BlocWidgetBuilder<WidgetDataState<DATA>>? warningBuilder,
  }) : super(
    listenWhen: (previous, current) => true,
    listener: (context, state) {
      if (state.event != null) {
        listenEvent?.call(context, state.event!.name, state.event!.data);
      } else {
        listenState?.call(context, state);
      }
    },
    buildWhen: (previous, current) {
      if (current.event != null) {
        // No build the widget when state has event
        return false;
      } else if (buildWhen != null) {
        return buildWhen(previous, current);
      } else if (current.event == null) {
        return current.build;
      } else {
        return true;
      }
    },
    builder: (context, state) {
      if (state.isFail && failBuilder != null) {
        return failBuilder(context, state);
      } else if (state.isWarning && warningBuilder != null) {
        return warningBuilder(context, state);
      } else if (state.isLoading && loadingBuilder != null) {
        return loadingBuilder(context, state);
      } else {
        return builder(context, state);
      }
    },
  );
}
