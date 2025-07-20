import 'package:falkit/lib.dart';

export 'color_extensions.dart';
export 'context_extensions.dart';
export 'icons_extensions.dart';
export 'images_extensions.dart';

extension WidgetStateExtension on WidgetState? {
  bool get isNormal => this == null;
  bool get isHovered => this == WidgetState.hovered;
  bool get isFocused => this == WidgetState.focused;
  bool get isPressed => this == WidgetState.pressed;
  bool get isDragged => this == WidgetState.dragged;
  bool get isSelected => this == WidgetState.selected;
  bool get isScrolledUnder => this == WidgetState.scrolledUnder;
  bool get isDisabled => this == WidgetState.disabled;
  bool get isError => this == WidgetState.error;

  bool get isNotNormal => !isNormal;
  bool get isNotHovered => !isHovered;
  bool get isNotFocused => !isFocused;
  bool get isNotPressed => !isPressed;
  bool get isNotDragged => !isDragged;
  bool get isNotSelected => !isSelected;
  bool get isNotScrolledUnder => !isScrolledUnder;
  bool get isNotDisabled => !isDisabled;
  bool get isNotError => !isError;
}
