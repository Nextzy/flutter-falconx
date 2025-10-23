import 'package:flutter/widgets.dart';
import 'package:flutter_falmodel/models/constants.dart';

enum FullWidgetState {
  initial,
  normal,
  empty,
  hovered,
  focused,
  focusedVisible,
  pressed,
  dragged,
  selected,
  scrolledUnder,
  disabled,
  loading,
  success,
  cancel,
  warning,
  fail;

  bool get isInitial => this == FullWidgetState.initial; //
  bool get isNormal => this == FullWidgetState.normal; //
  bool get isEmpty => this == FullWidgetState.empty; //
  bool get isHovered => this == FullWidgetState.hovered; //
  bool get isFocused => this == FullWidgetState.focused; //
  bool get isFocusedVisible => this == FullWidgetState.focusedVisible; //
  bool get isPressed => this == FullWidgetState.pressed; //
  bool get isDragged => this == FullWidgetState.dragged; //
  bool get isSelected => this == FullWidgetState.selected; //
  bool get isScrolledUnder => this == FullWidgetState.scrolledUnder; //
  bool get isDisabled => this == FullWidgetState.disabled; //
  bool get isLoading => this == FullWidgetState.loading; //
  bool get isSuccess => this == FullWidgetState.success; //
  bool get isFail => this == FullWidgetState.fail; //
  bool get isWarning => this == FullWidgetState.warning; //
  bool get isCancel => this == FullWidgetState.cancel; //

  bool get isNotInitial => !isInitial; //
  bool get isNotNormal => !isNormal; //
  bool get isNotEmpty => !isEmpty; //
  bool get isNotHovered => !isHovered; //
  bool get isNotFocused => !isFocused; //
  bool get isNotFocusedVisible => !isFocusedVisible; //
  bool get isNotPressed => !isPressed; //
  bool get isNotDragged => !isDragged; //
  bool get isNotSelected => !isSelected; //
  bool get isNotScrolledUnder => !isScrolledUnder; //
  bool get isNotDisabled => !isDisabled; //
  bool get isNotLoading => !isLoading; //
  bool get isNotSuccess => !isSuccess; //
  bool get isNotFail => !isFail; //
  bool get isNotWarning => !isWarning; //
  bool get isNotCancel => !isCancel; //

  WidgetState? get toWidgetState => switch (this) {
    FullWidgetState.hovered => WidgetState.hovered,
    FullWidgetState.focused => WidgetState.focused,
    FullWidgetState.pressed => WidgetState.pressed,
    FullWidgetState.dragged => WidgetState.dragged,
    FullWidgetState.selected => WidgetState.selected,
    FullWidgetState.scrolledUnder => WidgetState.scrolledUnder,
    FullWidgetState.disabled => WidgetState.disabled,
    FullWidgetState.fail => WidgetState.error,
    _ => null,
  };
}

class FullWidgetStates {
  const FullWidgetStates(this._value);

  final Set<FullWidgetState> _value;

  bool get isInitial => _value.contains(FullWidgetState.initial); //
  bool get isNormal => _value.contains(FullWidgetState.normal); //
  bool get isEmpty => _value.contains(FullWidgetState.empty); //
  bool get isHovered => _value.contains(FullWidgetState.hovered); //
  bool get isFocused => _value.contains(FullWidgetState.focused); //
  bool get isFocusedVisible =>
      _value.contains(FullWidgetState.focusedVisible); //
  bool get isPressed => _value.contains(FullWidgetState.pressed); //
  bool get isDragged => _value.contains(FullWidgetState.dragged); //
  bool get isSelected => _value.contains(FullWidgetState.selected); //
  bool get isScrolledUnder => _value.contains(FullWidgetState.scrolledUnder); //
  bool get isDisabled => _value.contains(FullWidgetState.disabled); //
  bool get isLoading => _value.contains(FullWidgetState.loading); //
  bool get isSuccess => _value.contains(FullWidgetState.success); //
  bool get isFail => _value.contains(FullWidgetState.fail); //
  bool get isWarning => _value.contains(FullWidgetState.warning); //
  bool get isCancel => _value.contains(FullWidgetState.cancel); //

  bool get isNotInitial => !isInitial; //
  bool get isNotNormal => !isNormal; //
  bool get isNotEmpty => !isEmpty; //
  bool get isNotHovered => !isHovered; //
  bool get isNotFocused => !isFocused; //
  bool get isNotFocusedVisible => !isFocusedVisible; //
  bool get isNotPressed => !isPressed; //
  bool get isNotDragged => !isDragged; //
  bool get isNotSelected => !isSelected; //
  bool get isNotScrolledUnder => !isScrolledUnder; //
  bool get isNotDisabled => !isDisabled; //
  bool get isNotLoading => !isLoading; //
  bool get isNotSuccess => !isSuccess; //
  bool get isNotFail => !isFail; //
  bool get isNotWarning => !isWarning;

  bool get isNotCancel => !isCancel; //

  Set<FullWidgetState> get value => _value;

  bool contains(FullWidgetState state) {
    return _value.contains(state);
  }

  FullWidgetStates copy(Set<FullWidgetState>? value) =>
      FullWidgetStates(value ?? _value);
}
