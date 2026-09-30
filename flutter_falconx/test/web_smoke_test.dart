// Proves the flutter_falconx umbrella compiles standalone (VM and
// web/Chrome). No other test in this package compiles it for web. Only
// package:flutter_falconx/flutter_falconx.dart is imported; the symbols
// touched span each layer the umbrella re-exports (flutter_falconnect,
// flutter_falmodel, flutter_falstore, flutter_faltool, and falconx's own
// networks/), so a compile failure here catches a break in any of them.
import 'package:flutter_falconx/flutter_falconx.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('flutter_falconx compiles and re-exports each sibling layer', () async {
    // flutter_falconx's own API.
    final bloc = InternetConnectionBloc(
      initialResult: const [ConnectivityResult.none],
    );
    expect(bloc.isConnectedInternet, isFalse);
    await bloc.close();

    // flutter_falmodel, re-exported.
    final state = WidgetDataState<int>.initial(1);
    expect(state.data, 1);

    // flutter_faltool, re-exported.
    expect(PlatformChecker.isWeb, isA<bool>());

    // flutter_falstore, re-exported.
    expect(SecureStorage.instance, isA<SecureStorage>());

    // flutter_falconnect, re-exported.
    final interceptor = ConnectivityInterceptor();
    expect(interceptor, isA<ConnectivityInterceptor>());
  });
}
