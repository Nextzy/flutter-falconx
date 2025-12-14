import 'package:flutter_falconx/lib.dart';

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
  late final FullWidgetStatesNotifier stateNotifier;

  bool get debug => false;

  FullWidgetStates get states => stateNotifier.value;

  String get tag => '${widget.runtimeType} State';

  Key? get key => widget.key;

  bool get disabled => stateNotifier.value.isDisabled; //

  bool get loading => stateNotifier.value.isLoading; //

  bool get isHovered => stateNotifier.value.isHovered; //

  bool get isFocused => stateNotifier.value.isFocused; //

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
    stateNotifier = FullWidgetStatesNotifier(_initState);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        postFrame(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return stateBuilder(buildStates);
  }

  Widget buildStates(BuildContext context, FullWidgetStates states) {
    return const Placeholder();
  }

  Widget stateBuilder(
    Widget Function(
      BuildContext context,
      FullWidgetStates states,
    )
    builder,
  ) => FullWidgetStatesBuilder(
    create: stateNotifier,
    builder: (context, states) => builder(context, states),
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

  void setFullWidgetState(FullWidgetState state, [VoidCallback? fn]) {
    if (mounted) {
      stateNotifier.state = state;
      fn.let(setState);
    }
  }

  void setWidgetStates(Set<FullWidgetState> states, [VoidCallback? fn]) {
    if (mounted) {
      stateNotifier.value = FullWidgetStates(states);
      fn.let(setState);
    }
  }

  void setNormalState([VoidCallback? fn]) =>
      setFullWidgetState(FullWidgetState.normal, fn);

  void setLoadingState(bool loading, [VoidCallback? fn]) {
    if (mounted) {
      stateNotifier.loading = loading;
      fn.let(setState);
    }
  }

  void setHoveredState(bool hover, [VoidCallback? fn]) {
    if (mounted) {
      stateNotifier.hover = hover;
      fn.let(setState);
    }
  }

  void setFocusedState(bool focus, [VoidCallback? fn]) {
    if (mounted) {
      stateNotifier.focus = focus;
      fn.let(setState);
    }
  }

  void setDisabledState(bool disabled, [VoidCallback? fn]) {
    if (mounted) {
      stateNotifier.disabled = disabled;
      fn.let(setState);
    }
  }

  void setWarningState([VoidCallback? fn]) =>
      setFullWidgetState(FullWidgetState.warning, fn);

  void setEmptyState([VoidCallback? fn]) =>
      setFullWidgetState(FullWidgetState.empty, fn);

  void setSelectedState(bool select, [VoidCallback? fn]) {
    if (mounted) {
      stateNotifier.select = select;
      fn.let(setState);
    }
  }

  void setSuccessState([VoidCallback? fn]) =>
      setFullWidgetState(FullWidgetState.success, fn);

  void setCancelState([VoidCallback? fn]) =>
      setFullWidgetState(FullWidgetState.cancel, fn);

  void setFailState([VoidCallback? fn]) =>
      setFullWidgetState(FullWidgetState.fail, fn);
}
