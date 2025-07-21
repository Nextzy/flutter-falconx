import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// A widget to calculate it's size after being built and attached to a widget tree
/// [onChange] get changed [Size] of the Widget
/// [child] Widget to get size of it at runtime
class WidgetMeasureSize extends StatefulWidget {
  const WidgetMeasureSize({
    super.key,
    required this.onChange,
    required this.child,
  });

  final Widget child;
  final void Function(Size) onChange;

  @override
  State<WidgetMeasureSize> createState() => _WidgetMeasureSizeState();
}

class _WidgetMeasureSizeState extends State<WidgetMeasureSize> {
  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    return Container(
      key: widgetKey,
      child: widget.child,
    );
  }

  GlobalKey<State<StatefulWidget>> widgetKey = GlobalKey();
  Size? oldSize;

  void postFrameCallback(_) {
    final context = widgetKey.currentContext;
    if (!mounted || context == null) return;

    final newSize = context.size;
    if (newSize == null || oldSize == newSize) return;

    oldSize = newSize;
    widget.onChange(newSize);
  }
}
