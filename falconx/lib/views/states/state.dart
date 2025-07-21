import 'package:falconx/lib.dart';

/// [Android State]
/// - onCreate
/// - onStart
/// - onResume
/// ----------
/// - onPause
/// - onStop
/// - onDestroy
///
/// [iOS State]
/// - viewDidLoad
/// - viewWillAppear
/// - viewDidAppear
/// ----------
/// - viewWillDisappear
/// - viewDidDisappear
/// - viewDidUnload
///
/// [Flutter State with FalconX]
/// - initState
/// - didChangeDependencies
/// - resume (Came to foreground)
/// - build
/// - (didUpdateWidget)
/// ----------
/// - inactive
/// - deactivate
/// - dispose
///
/// - paused (Went to background)
/// - detached
///
/// Read more
/// - https://medium.com/flutter-community/flutter-lifecycle-for-android-and-ios-developers-8f532307e0c7
/// - https://stackoverflow.com/questions/41479255/life-cycle-in-flutter
///

abstract class FalconState<T extends StatefulWidget> extends State<T>
    with WidgetsBindingObserver {
  FalconState({FullWidgetState? initialWidgetState})
      : _initState = initialWidgetState;

  final FullWidgetState? _initState;
  late final FullWidgetStateNotifier stateNotifier;

  bool get debug => false;

  FullWidgetState get state => stateNotifier.value;

  String get tag => '${widget.runtimeType} State';

  Key? get key => widget.key;

  Future<Version> get currentVersion async {
    final packageInfo = await PackageInfo.fromPlatform();
    final versionStr = packageInfo.version;
    final buildNumber = packageInfo.buildNumber;
    final fullVersion = '$versionStr+$buildNumber';
    return Version.parse(fullVersion);
  }

  @override
  void initState() {
    super.initState(); // Should call first
    if (debug) {
      printInfo('$tag => Lifecycle State: initState');
    }
    stateNotifier = FullWidgetStateNotifier(_initState);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        postFrame(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return stateBuilder(
      (context, state, child) => buildState(context, state),
    );
  }

  Widget buildState(BuildContext context, FullWidgetState state) {
    return const Placeholder();
  }

  Widget stateBuilder(
    Widget Function(BuildContext context, FullWidgetState state, Widget? child)
        builder,
  ) =>
      FullWidgetStateBuilder(
        create: stateNotifier,
        builder: builder,
      );

  @override
  void dispose() {
    if (debug) {
      printInfo('$tag => Lifecycle State: dispose');
    }
    WidgetsBinding.instance.removeObserver(this);
    stateNotifier.dispose();
    super.dispose(); // Should call last
  }

  void postFrame(BuildContext context) {}

  void resumed() {}

  void inactive() {}

  void paused() {}

  void detached() {}

  void hidden() {}

  @protected
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        if (debug) {
          printInfo('$tag => Lifecycle State: resumed');
        }
        resumed();
      case AppLifecycleState.inactive:
        if (debug) {
          printInfo('$tag => Lifecycle State: inactive');
        }
        inactive();
      case AppLifecycleState.hidden:
        if (debug) {
          printInfo('$tag => Lifecycle State: hidden');
        }
        hidden();
      case AppLifecycleState.paused:
        if (debug) {
          printInfo('$tag => Lifecycle State: paused');
        }
        paused();
      case AppLifecycleState.detached:
        if (debug) {
          printInfo('$tag => Lifecycle State: detached');
        }
        detached();
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void updateState() => setState(() {});

  void clearFocus() => FocusScope.of(context).unfocus();

  /// Updates the widget state using [stateNotifier] if widget is mounted.
  ///
  /// The [state] parameter represents the new [FullWidgetState] to be set.
  /// Optionally executes a callback before setting the state.
  ///
  /// Example usage:
  /// ```dart
  /// changeState(FullWidgetState.loading); // Set loading state
  ///
  /// // With callback
  /// changeState(FullWidgetState.loading, () {
  ///   // Prepare for loading
  ///   data.clear();
  /// });
  ///
  /// // In async operations
  /// try {
  ///   changeState(FullWidgetState.loading);
  ///   await someOperation();
  ///   changeState(FullWidgetState.success);
  /// } catch (e) {
  ///   changeState(FullWidgetState.fail);
  /// }
  /// ```
  ///
  /// To handle states in the UI:
  /// ```dart
  /// buildState(context, state) {
  ///   switch (state) {
  ///     case FullWidgetState.loading:
  ///       return LoadingWidget();
  ///     case FullWidgetState.success:
  ///       return SuccessWidget();
  ///     case FullWidgetState.fail:
  ///       return ErrorWidget();
  ///   }
  /// }
  /// ```
  void changeFullWidgetState(FullWidgetState state, [VoidCallback? fn]) {
    if (mounted) {
      fn?.call();
      stateNotifier.value = state;
    }
  }

  void setFullWidgetState(FullWidgetState state, [VoidCallback? fn]) {
    if (mounted) {
      setState(() {
        fn?.call();
        stateNotifier.value = state;
      });
    }
  }

  void setNormalState([VoidCallback? fn]) =>
      setFullWidgetState(FullWidgetState.normal, fn);

  void setLoadingState([VoidCallback? fn]) =>
      setFullWidgetState(FullWidgetState.loading, fn);

  void setHoveredState([VoidCallback? fn]) =>
      setFullWidgetState(FullWidgetState.hovered, fn);

  void setFocusedState([VoidCallback? fn]) =>
      setFullWidgetState(FullWidgetState.focused, fn);

  void setFocusedVisibleState([VoidCallback? fn]) =>
      setFullWidgetState(FullWidgetState.focusedVisible, fn);

  void setDisabledState([VoidCallback? fn]) =>
      setFullWidgetState(FullWidgetState.disabled, fn);

  void setWarningState([VoidCallback? fn]) =>
      setFullWidgetState(FullWidgetState.warning, fn);

  void setEmptyState([VoidCallback? fn]) =>
      setFullWidgetState(FullWidgetState.empty, fn);

  void setSelectedState([VoidCallback? fn]) =>
      setFullWidgetState(FullWidgetState.selected, fn);

  void setSuccessState([VoidCallback? fn]) =>
      setFullWidgetState(FullWidgetState.success, fn);

  void setCancelState([VoidCallback? fn]) =>
      setFullWidgetState(FullWidgetState.cancel, fn);

  void setFailState([VoidCallback? fn]) =>
      setFullWidgetState(FullWidgetState.fail, fn);

  // Convenience methods for common states
  void changeToNormalState([VoidCallback? fn]) =>
      changeFullWidgetState(FullWidgetState.normal, fn);

  void changeToLoadingState([VoidCallback? fn]) =>
      changeFullWidgetState(FullWidgetState.loading, fn);

  void changeToSuccessState([VoidCallback? fn]) =>
      changeFullWidgetState(FullWidgetState.success, fn);

  void changeToFailState([VoidCallback? fn]) =>
      changeFullWidgetState(FullWidgetState.fail, fn);

  void changeToEmptyState([VoidCallback? fn]) =>
      changeFullWidgetState(FullWidgetState.empty, fn);

  void changeToWarningState([VoidCallback? fn]) =>
      changeFullWidgetState(FullWidgetState.warning, fn);

  void changeToDisabledState([VoidCallback? fn]) =>
      changeFullWidgetState(FullWidgetState.disabled, fn);

  void changeToSelectedState([VoidCallback? fn]) =>
      changeFullWidgetState(FullWidgetState.selected, fn);

  void changeToCancelState([VoidCallback? fn]) =>
      changeFullWidgetState(FullWidgetState.cancel, fn);

  void changeToHoveredState([VoidCallback? fn]) =>
      changeFullWidgetState(FullWidgetState.hovered, fn);

  void changeToFocusedState([VoidCallback? fn]) =>
      changeFullWidgetState(FullWidgetState.focused, fn);

  void changeToFocusedVisibleState([VoidCallback? fn]) =>
      changeFullWidgetState(FullWidgetState.focusedVisible, fn);
}
