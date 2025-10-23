import 'package:flutter_falconx/lib.dart';

class InternetConnectionBloc extends BlocBase<List<ConnectivityResult>> {
  InternetConnectionBloc({
    required List<ConnectivityResult> initialResult,
    Connectivity? connectivity,
  })  : _connectivity = connectivity ?? Connectivity(),
        super(initialResult) {
    _subscription = stream.listen(onConnectivityChanged);
  }

  final Connectivity _connectivity;
  late final _stateController =
      StreamController<List<ConnectivityResult>>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  List<ConnectivityResult> get result => state;

  bool get isConnectedInternet =>
      state.contains(ConnectivityResult.wifi) ||
      state.contains(ConnectivityResult.ethernet) ||
      state.contains(ConnectivityResult.mobile) ||
      state.contains(ConnectivityResult.vpn);

  bool get isNotConnectedInternet => !isConnectedInternet;

  @override
  Stream<List<ConnectivityResult>> get stream =>
      _connectivity.onConnectivityChanged;

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }

  void onConnectivityChanged(List<ConnectivityResult> result) {
    printInfo('Connectivity: $result');
    if (_stateController.isClosed) return;
    emit(result);
  }
}
