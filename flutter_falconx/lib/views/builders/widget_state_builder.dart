import 'package:flutter_falconx/lib.dart';

class FullWidgetStatesBuilder extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FullWidgetStates>(
      valueListenable: create,
      builder: (context, FullWidgetStates value, child) =>
          builder(context, value),
    );
  }
}
