import 'package:flutter_falmodel/lib.dart';
import 'package:flutter/widgets.dart';

extension FullWidgetStateExtension on WidgetState {
  FullWidgetState? get toFullWidgetState => switch (this) {
        WidgetState.hovered => FullWidgetState.hovered,
        WidgetState.focused => FullWidgetState.focused,
        WidgetState.pressed => FullWidgetState.pressed,
        WidgetState.dragged => FullWidgetState.dragged,
        WidgetState.selected => FullWidgetState.selected,
        WidgetState.scrolledUnder => FullWidgetState.scrolledUnder,
        WidgetState.disabled => FullWidgetState.disabled,
        WidgetState.error => FullWidgetState.fail,
      };
}
