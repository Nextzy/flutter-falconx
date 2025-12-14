import 'package:flutter_falconx/lib.dart';

class FullWidgetStatesNotifier extends ValueNotifier<FullWidgetStates> {
  FullWidgetStatesNotifier([dynamic state])
    : super(
        state is FullWidgetStates
            ? state
            : state is FullWidgetState
            ? FullWidgetStates({state})
            : const FullWidgetStates({FullWidgetState.normal}),
      );

  static const List<FullWidgetState> _displayStates = [
    FullWidgetState.initial,
    FullWidgetState.normal,
    FullWidgetState.empty,
    FullWidgetState.warning,
    FullWidgetState.fail,
    FullWidgetState.success,
    FullWidgetState.cancel,
    FullWidgetState.scrolledUnder,
  ];

  static const List<FullWidgetState> _actionStates = [
    FullWidgetState.pressed,
    FullWidgetState.hovered,
    FullWidgetState.dragged,
  ];

  bool _isDisposed = false; //
  bool get isDisposed => _isDisposed; //

  // Replace with single state (backward compatibility)
  set state(FullWidgetState state) {
    if (!_isDisposed) {
      removeState(FullWidgetState.disabled);
      removeState(FullWidgetState.loading);
      if (_displayStates.contains(state)) {
        removeAllState(_displayStates);
        addState(state);
      } else if (_actionStates.contains(state)) {
        removeAllState(_actionStates);
        addState(state);
      } else if (state == FullWidgetState.focused) {
        focus = true;
      } else if (state == FullWidgetState.disabled) {
        disabled = true;
      } else if (state == FullWidgetState.loading) {
        loading = true;
      } else if (state == FullWidgetState.selected) {
        select = true;
      } else {
        addState(state);
      }
    }
  }

  set hover(bool hover) {
    if (!_isDisposed) {
      if (hover) {
        addState(FullWidgetState.hovered);
      } else {
        removeState(FullWidgetState.hovered);
      }
    }
  }

  set select(bool select) {
    if (!_isDisposed) {
      if (select) {
        addState(FullWidgetState.selected);
      } else {
        removeState(FullWidgetState.selected);
      }
    }
  }

  set focus(bool focus) {
    if (!_isDisposed) {
      if (focus) {
        addState(FullWidgetState.focused);
      } else {
        removeState(FullWidgetState.focused);
      }
    }
  }

  set loading(bool loading) {
    if (!_isDisposed) {
      if (loading) {
        addState(FullWidgetState.loading);
      } else {
        removeState(FullWidgetState.loading);
      }
    }
  }

  set disabled(bool disabled) {
    if (!_isDisposed) {
      if (disabled) {
        value = const FullWidgetStates({FullWidgetState.disabled});
      } else {
        removeState(FullWidgetState.disabled);
      }
    }
  }

  // Add state to stack if not already present
  void addState(FullWidgetState state) {
    if (!_isDisposed && !hasState(state)) {
      value = value.copy({...value.value, state});
    }
  }

  // Remove state from stack
  void removeState(FullWidgetState state) {
    if (!_isDisposed && hasState(state)) {
      value = value.copy(value.value.where((s) => s != state).toSet());
    }
  }

  void removeAllState(List<FullWidgetState> states) {
    if (!_isDisposed) {
      value = value.copy(
        value.value.where((s) => !states.contains(s)).toSet(),
      );
    }
  }

  // Toggle state in stack
  void toggleState(FullWidgetState state) {
    if (!_isDisposed) {
      if (value.contains(state)) {
        removeState(state);
      } else {
        addState(state);
      }
    }
  }

  // Replace entire state stack (supports both single state and list)
  void setAllState(Set<FullWidgetState> newStates) {
    if (!_isDisposed) {
      value = FullWidgetStates(newStates);
    }
  }

  // Clear all states and set to normal
  void resetState() {
    if (!_isDisposed) {
      value = const FullWidgetStates({FullWidgetState.normal});
    }
  }

  // Check if has specific state
  bool hasState(FullWidgetState state) => value.contains(state); //

  // Check if has any of the states
  bool hasAnyState(List<FullWidgetState> states) {
    return states.any((state) => value.contains(state));
  }

  // Check if has all of the states
  bool hasAllStates(List<FullWidgetState> states) {
    return states.every((state) => value.contains(state));
  }

  @override
  void dispose() {
    if (!_isDisposed) {
      super.dispose();
    }
    _isDisposed = true;
  }
}
