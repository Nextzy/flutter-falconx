import 'package:flutter_falconx/lib.dart';

class FullWidgetStatesBuilder extends StatefulWidget {
  const FullWidgetStatesBuilder({
    super.key,
    required this.create,
    required this.builder,
  });

  final FullWidgetStatesNotifier create;
  final Widget Function(
    BuildContext context,
    FullWidgetStates states,
  )
  builder;

  @override
  State<FullWidgetStatesBuilder> createState() =>
      _FullWidgetStatesBuilderState();
}

class _FullWidgetStatesBuilderState extends State<FullWidgetStatesBuilder> {
  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: widget.create,
    builder: (context, value, child) => widget.builder(context, value),
  );
}
