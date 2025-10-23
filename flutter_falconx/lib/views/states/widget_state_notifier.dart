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

  bool _isDisposed = false; //
  bool get isDisposed => _isDisposed; //

  // Replace with single state (backward compatibility)
  set state(FullWidgetState state) {
    if (!_isDisposed) {
      if (state == FullWidgetState.initial ||
          state == FullWidgetState.normal ||
          state == FullWidgetState.empty ||
          state == FullWidgetState.warning ||
          state == FullWidgetState.fail ||
          state == FullWidgetState.success ||
          state == FullWidgetState.cancel ||
          state == FullWidgetState.scrolledUnder) {
        removeAllState([
          FullWidgetState.initial,
          FullWidgetState.normal,
          FullWidgetState.empty,
          FullWidgetState.warning,
          FullWidgetState.fail,
          FullWidgetState.success,
          FullWidgetState.cancel,
        ]);
        addState(state);
      } else if (state == FullWidgetState.pressed ||
          state == FullWidgetState.dragged ||
          state == FullWidgetState.hovered) {
        removeAllState([
          FullWidgetState.pressed,
          FullWidgetState.hovered,
          FullWidgetState.dragged,
        ]);
        addState(state);
      } else if (state == FullWidgetState.disabled) {
        value = const FullWidgetStates({FullWidgetState.disabled});
      } else if (state == FullWidgetState.focused ||
          state == FullWidgetState.focusedVisible) {
        removeAllState([
          FullWidgetState.focused,
          FullWidgetState.focusedVisible,
        ]);
        addState(state);
      } else if (state == FullWidgetState.loading) {
        addState(state);
      } else if (state == FullWidgetState.selected) {
        addState(state);
      } else {
        addState(state);
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
        removeState(FullWidgetState.focusedVisible);
        addState(FullWidgetState.focused);
      } else {
        removeAllState([
          FullWidgetState.focused,
          FullWidgetState.focusedVisible,
        ]);
      }
    }
  }

  set focusVisible(bool focus) {
    if (!_isDisposed) {
      if (focus) {
        removeState(FullWidgetState.focused);
        addState(FullWidgetState.focusedVisible);
      } else {
        removeAllState([
          FullWidgetState.focused,
          FullWidgetState.focusedVisible,
        ]);
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
        value = const FullWidgetStates({FullWidgetState.normal});
      }
    }
  }

  // Add state to stack if not already present
  void addState(FullWidgetState state) {
    if (!_isDisposed) {
      value = value.copy({...value.value, state});
    }
  }

  // Remove state from stack
  void removeState(FullWidgetState state) {
    if (!_isDisposed) {
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
