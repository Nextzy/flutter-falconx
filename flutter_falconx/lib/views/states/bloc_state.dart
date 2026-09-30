import 'package:flutter_falconx/src/src.dart';

typedef BlocWidgetListenerState<S> = void Function(
  BuildContext context,
  S state,
);
typedef BlocWidgetListenerEvent<S> = void Function(
  BuildContext context,
  S event,
  Object? data,
);
typedef CanPopListener<S> = bool Function(S state);
typedef PopListener<S> = void Function(S state, Object? result);

abstract class FalconNullableWidgetBlocState<
  WIDGET extends StatefulWidget,
  BLOC extends BlocBase<WidgetDataState<DATA?>>,
  DATA
>
    extends FalconBlocState<WIDGET, BLOC, WidgetDataState<DATA?>> {
  new({super.initialWidgetState});

  Widget buildWithBloc({
    BlocWidgetListenerEvent<Object>? listenEvent,
    BlocWidgetListenerState<WidgetDataState<DATA?>>? listenState,
    CanPopListener<WidgetDataState<DATA?>>? canPop,
    PopListener<WidgetDataState<DATA?>>? onPop,
    BlocListenerCondition<WidgetDataState<DATA?>>? buildWhen,
    required BlocWidgetBuilder<WidgetDataState<DATA?>> builder,
    BlocWidgetBuilder<WidgetDataState<DATA?>>? failBuilder,
    BlocWidgetBuilder<WidgetDataState<DATA?>>? loadingBuilder,
    BlocWidgetBuilder<WidgetDataState<DATA?>>? warningBuilder,
  }) => NullableWidgetStateBlocConsumer<BLOC, DATA>(
    bloc: bloc,
    listenEvent: listenEvent,
    listenState: listenState,
    buildWhen: buildWhen,
    builder: (context, state) => GestureDetector(
      onTap: clearFocus,
      child: buildCompatPopScope<WidgetDataState<DATA?>>(
        state: state,
        canPop: canPop,
        onPop: onPop,
        child: builder(context, state),
      ),
    ),
    failBuilder: failBuilder,
    loadingBuilder: loadingBuilder,
    warningBuilder: warningBuilder,
  );
}

abstract class FalconWidgetBlocState<
  WIDGET extends StatefulWidget,
  BLOC extends BlocBase<WidgetDataState<DATA>>,
  DATA
>
    extends FalconBlocState<WIDGET, BLOC, WidgetDataState<DATA>> {
  new({super.initialWidgetState});

  Widget buildWithBloc({
    BlocWidgetListenerEvent<Object>? listenEvent,
    BlocWidgetListenerState<WidgetDataState<DATA>>? listenState,
    CanPopListener<WidgetDataState<DATA>>? canPop,
    PopListener<WidgetDataState<DATA>>? onPop,
    BlocListenerCondition<WidgetDataState<DATA>>? buildWhen,
    required BlocWidgetBuilder<WidgetDataState<DATA>> builder,
    BlocWidgetBuilder<WidgetDataState<DATA>>? failBuilder,
    BlocWidgetBuilder<WidgetDataState<DATA>>? loadingBuilder,
    BlocWidgetBuilder<WidgetDataState<DATA>>? warningBuilder,
  }) => WidgetStateBlocConsumer<BLOC, DATA>(
    bloc: bloc,
    listenEvent: listenEvent,
    listenState: listenState,
    buildWhen: buildWhen,
    builder: (context, state) => GestureDetector(
      onTap: clearFocus,
      child: buildCompatPopScope<WidgetDataState<DATA>>(
        state: state,
        canPop: canPop,
        onPop: onPop,
        child: builder(context, state),
      ),
    ),
    failBuilder: failBuilder,
    loadingBuilder: loadingBuilder,
    warningBuilder: warningBuilder,
  );
}

abstract class FalconBlocState<
  WIDGET extends StatefulWidget,
  BLOC extends BlocBase<STATE>,
  STATE
>
    extends FalconState<WIDGET> {
  new({super.initialWidgetState});

  FocusNode? get focusNode => FocusManager.instance.primaryFocus;

  BLOC get bloc => context.read<BLOC>();

  Widget buildCompatPopScope<S>({
    required S state,
    required CanPopListener<S>? canPop,
    required PopListener<S>? onPop,
    required Widget child,
  }) => onPop != null || canPop != null
      ? PopScope(
          canPop: canPop?.call(state) ?? true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            clearFocus();
            onPop?.call(state, result);
          },
          child: child,
        )
      : child;
}
