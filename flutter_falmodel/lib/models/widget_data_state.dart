import 'package:flutter/material.dart';
import 'package:flutter_falmodel/lib.dart';

/// An optimized version of WidgetDataState that reduces code duplication
/// and improves performance using Dart 3 features.
///
/// This state management class combines widget state, data, and feedback
/// into a single immutable object suitable for BLoC pattern.
///
/// Example:
/// ```dart
/// // Create initial state
/// final state = WidgetDataState.initial(UserData());
///
/// // Transition to loading
/// final loadingState = state.toState(FullWidgetState.loading);
///
/// // Update with success and new data
/// final successState = state.toSuccess(
///   data: updatedUserData,
///   feedback: Success(message: 'Profile updated'),
/// );
/// ```
@immutable
class WidgetDataState<T> {

  /// Creates a widget data state with the specified parameters.
  const WidgetDataState._({
    required this.state,
    required this.data,
    required this.feedback,
    this.id,
    this.event,
    this.build = true,
  });

  /// Factory constructor that creates a state with default feedback based on state type.
  factory WidgetDataState.create(
      FullWidgetState state,
      T data, {
        String? id,
        UserFeedback? feedback,
        bool build = true,
      }) {
    // Default feedback based on state
    final defaultFeedback = switch (state) {
      FullWidgetState.warning => const Warning(),
      FullWidgetState.fail => const Failure(),
      _ => const Information(),
    };

    return WidgetDataState._(
      state: state,
      id: id,
      data: data,
      feedback: feedback ?? defaultFeedback,
      build: build,
    );
  }

  // Optimized factory constructors using the create method
  factory WidgetDataState.initial(T data,
      {String? id, UserFeedback? feedback, bool build = true}) =>
      WidgetDataState.create(FullWidgetState.initial, data,
          id: id, feedback: feedback, build: build);

  factory WidgetDataState.normal(T data,
      {String? id, UserFeedback? feedback, bool build = true}) =>
      WidgetDataState.create(FullWidgetState.normal, data,
          id: id, feedback: feedback, build: build);

  factory WidgetDataState.empty(T data,
      {String? id, UserFeedback? feedback, bool build = true}) =>
      WidgetDataState.create(FullWidgetState.empty, data,
          id: id, feedback: feedback, build: build);

  factory WidgetDataState.loading(T data,
      {String? id, UserFeedback? feedback, bool build = true}) =>
      WidgetDataState.create(FullWidgetState.loading, data,
          id: id, feedback: feedback, build: build);

  factory WidgetDataState.success(T data,
      {String? id, UserFeedback? feedback, bool build = true}) =>
      WidgetDataState.create(FullWidgetState.success, data,
          id: id, feedback: feedback, build: build);

  factory WidgetDataState.warning(T data,
      {String? id, UserFeedback? feedback, bool build = true}) =>
      WidgetDataState.create(FullWidgetState.warning, data,
          id: id, feedback: feedback ?? const Warning(), build: build);

  factory WidgetDataState.fail(T data,
      {String? id, UserFeedback? feedback, bool build = true}) =>
      WidgetDataState.create(FullWidgetState.fail, data,
          id: id, feedback: feedback ?? const Failure(), build: build);

  // Additional factory constructors for all FullWidgetState values
  factory WidgetDataState.hovered(T data,
      {String? id, UserFeedback? feedback, bool build = true}) =>
      WidgetDataState.create(FullWidgetState.hovered, data,
          id: id, feedback: feedback, build: build);

  factory WidgetDataState.focused(T data,
      {String? id, UserFeedback? feedback, bool build = true}) =>
      WidgetDataState.create(FullWidgetState.focused, data,
          id: id, feedback: feedback, build: build);

  // factory WidgetDataState.focusedVisible(T data,
  //     {String? id, UserFeedback? feedback, bool build = true}) =>
  //     WidgetDataState.create(FullWidgetState.focusedVisible, data,
  //         id: id, feedback: feedback, build: build);

  factory WidgetDataState.pressed(T data,
      {String? id, UserFeedback? feedback, bool build = true}) =>
      WidgetDataState.create(FullWidgetState.pressed, data,
          id: id, feedback: feedback, build: build);

  factory WidgetDataState.dragged(T data,
      {String? id, UserFeedback? feedback, bool build = true}) =>
      WidgetDataState.create(FullWidgetState.dragged, data,
          id: id, feedback: feedback, build: build);

  factory WidgetDataState.selected(T data,
      {String? id, UserFeedback? feedback, bool build = true}) =>
      WidgetDataState.create(FullWidgetState.selected, data,
          id: id, feedback: feedback, build: build);

  factory WidgetDataState.scrolledUnder(T data,
      {String? id, UserFeedback? feedback, bool build = true}) =>
      WidgetDataState.create(FullWidgetState.scrolledUnder, data,
          id: id, feedback: feedback, build: build);

  factory WidgetDataState.disabled(T data,
      {String? id, UserFeedback? feedback, bool build = true}) =>
      WidgetDataState.create(FullWidgetState.disabled, data,
          id: id, feedback: feedback, build: build);

  factory WidgetDataState.cancel(T data,
      {String? id, UserFeedback? feedback, bool build = true}) =>
      WidgetDataState.create(FullWidgetState.cancel, data,
          id: id, feedback: feedback, build: build);

  /// The current widget state.
  final FullWidgetState state;

  /// Optional identifier for this state instance.
  final String? id;

  /// User feedback associated with this state.
  final UserFeedback feedback;

  /// Optional event for BLoC to Widget communication.
  /// Note: Events are not copied during state transitions.
  final WidgetEvent? event;

  /// The data contained in this state.
  final T data;

  /// Whether this state change should trigger a widget rebuild.
  final bool build;

  // State check getters using pattern matching
  bool get isInitial => state.isInitial; //
  bool get isNormal => state.isNormal; //
  bool get isEmpty => state.isEmpty; //
  bool get isHovered => state.isHovered; //
  bool get isFocused => state.isFocused; //
  // bool get isFocusedVisible => state.isFocusedVisible; //
  bool get isPressed => state.isPressed; //
  bool get isDragged => state.isDragged; //
  bool get isSelected => state.isSelected; //
  bool get isScrolledUnder => state.isScrolledUnder; //
  bool get isDisabled => state.isDisabled; //
  bool get isLoading => state.isLoading; //
  bool get isSuccess => state.isSuccess; //
  bool get isFail => state.isFail; //
  bool get isWarning => state.isWarning; //
  bool get isCancel => state.isCancel; //

  bool get isNotInitial => !isInitial; //
  bool get isNotNormal => !isNormal; //
  bool get isNotEmpty => !isEmpty; //
  bool get isNotHovered => !isHovered; //
  bool get isNotFocused => !isFocused; //
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

  // Data check getters
  bool get hasData => data != null; //
  bool get noData => data == null; //

  /// Applies a function to the state and data.
  R apply<R>(R Function(FullWidgetState state, T data) f) => f(state, data);

  /// Converts the current FullWidgetState to Flutter's WidgetState if applicable.
  WidgetState? get toWidgetState => state.toWidgetState;

  /// Maps the data to a new type.
  WidgetDataState<R> mapData<R>(R Function(T data) mapper) {
    return WidgetDataState._(
      state: state,
      id: id,
      data: mapper(data),
      feedback: feedback,
      build: build,
      event: event,
    );
  }

  /// Maps the state using a transformation function.
  WidgetDataState<T> mapState(
      FullWidgetState Function(FullWidgetState) mapper) {
    return WidgetDataState._(
      state: mapper(state),
      id: id,
      data: data,
      feedback: feedback,
      build: build,
      event: event,
    );
  }

  /// Generic state transition method that reduces duplication.
  WidgetDataState<T> toState(
      FullWidgetState newState, {
        T? data,
        String? id,
        UserFeedback? feedback,
        bool? build,
      }) {
    return WidgetDataState.create(
      newState,
      data ?? this.data,
      id: id ?? this.id,
      feedback: feedback,
      build: build ?? true,
    );
  }

  /// Convenience methods for common state transitions.
  WidgetDataState<T> toInitial(
      {T? data, String? id, UserFeedback? feedback, bool? build}) =>
      toState(FullWidgetState.initial,
          data: data, id: id, feedback: feedback, build: build);

  WidgetDataState<T> toNormal(
      {T? data, String? id, UserFeedback? feedback, bool? build}) =>
      toState(FullWidgetState.normal,
          data: data, id: id, feedback: feedback, build: build);

  WidgetDataState<T> toEmpty(
      {T? data, String? id, UserFeedback? feedback, bool? build}) =>
      toState(FullWidgetState.empty,
          data: data, id: id, feedback: feedback, build: build);

  WidgetDataState<T> toLoading(
      {T? data, String? id, UserFeedback? feedback, bool? build}) =>
      toState(FullWidgetState.loading,
          data: data, id: id, feedback: feedback, build: build);

  WidgetDataState<T> toSuccess(
      {T? data, String? id, UserFeedback? feedback, bool? build}) =>
      toState(FullWidgetState.success,
          data: data, id: id, feedback: feedback, build: build);

  WidgetDataState<T> toWarning(
      {T? data, String? id, UserFeedback? feedback, bool? build}) =>
      toState(FullWidgetState.warning,
          data: data,
          id: id,
          feedback: feedback ?? const Warning(),
          build: build);

  WidgetDataState<T> toFail(
      {T? data, String? id, UserFeedback? feedback, bool? build}) =>
      toState(FullWidgetState.fail,
          data: data,
          id: id,
          feedback: feedback ?? const Failure(),
          build: build);

  // Additional convenience methods for all state transitions
  WidgetDataState<T> toHovered(
      {T? data, String? id, UserFeedback? feedback, bool? build}) =>
      toState(FullWidgetState.hovered,
          data: data, id: id, feedback: feedback, build: build);

  WidgetDataState<T> toFocused(
      {T? data, String? id, UserFeedback? feedback, bool? build}) =>
      toState(FullWidgetState.focused,
          data: data, id: id, feedback: feedback, build: build);

  WidgetDataState<T> toPressed(
      {T? data, String? id, UserFeedback? feedback, bool? build}) =>
      toState(FullWidgetState.pressed,
          data: data, id: id, feedback: feedback, build: build);

  WidgetDataState<T> toDragged(
      {T? data, String? id, UserFeedback? feedback, bool? build}) =>
      toState(FullWidgetState.dragged,
          data: data, id: id, feedback: feedback, build: build);

  WidgetDataState<T> toSelected(
      {T? data, String? id, UserFeedback? feedback, bool? build}) =>
      toState(FullWidgetState.selected,
          data: data, id: id, feedback: feedback, build: build);

  WidgetDataState<T> toScrolledUnder(
      {T? data, String? id, UserFeedback? feedback, bool? build}) =>
      toState(FullWidgetState.scrolledUnder,
          data: data, id: id, feedback: feedback, build: build);

  WidgetDataState<T> toDisabled(
      {T? data, String? id, UserFeedback? feedback, bool? build}) =>
      toState(FullWidgetState.disabled,
          data: data, id: id, feedback: feedback, build: build);

  WidgetDataState<T> toCancel(
      {T? data, String? id, UserFeedback? feedback, bool? build}) =>
      toState(FullWidgetState.cancel,
          data: data, id: id, feedback: feedback, build: build);

  /// Creates a copy of this state with optional parameter updates.
  /// Note: Events are never copied as they should be used only once.
  WidgetDataState<T> copyWith({
    FullWidgetState? state,
    String? id,
    UserFeedback? feedback,
    T? data,
    bool? build,
  }) {
    return WidgetDataState._(
      state: state ?? this.state,
      id: id ?? this.id,
      data: data ?? this.data,
      feedback: feedback ?? this.feedback,
      build: build ?? true,
      event: null, // Events are not copied
    );
  }

  /// Adds a one-time event to this state.
  ///
  /// Events are used for BLoC to Widget communication and should not
  /// trigger rebuilds. Configure your BLoC's buildWhen accordingly.
  WidgetDataState<T> addEvent(Object eventName, [Object? eventData]) {
    return WidgetDataState._(
      state: state,
      id: id,
      data: data,
      feedback: feedback,
      build: build,
      event: WidgetEvent(eventName, eventData),
    );
  }

  @override
  String toString() => 'WidgetDataStateV2('
      'state: $state, '
      'id: $id, '
      'data: $data, '
      'feedback: $feedback, '
      'event: $event, '
      'build: $build)';
}

/// Event class for one-time communication from BLoC to Widget.
@immutable
class WidgetEvent {
  const WidgetEvent(this.name, [this.data]);

  /// The name/type of the event.
  final Object name;

  /// Optional data associated with the event.
  final Object? data;

  @override
  String toString() => 'WidgetEvent(name: $name, data: $data)';
}


