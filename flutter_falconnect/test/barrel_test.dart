// Proves the re-export chain: a consumer that lists only flutter_falconnect
// can name flutter_falmodel and flutter_faltool symbols.
import 'package:flutter/foundation.dart';
import 'package:flutter_falconnect/flutter_falconnect.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('flutter_falconnect re-exports flutter_falmodel and '
      'flutter_faltool', () {
    // WidgetDataState comes from flutter_falmodel.
    final state = WidgetDataState<int>.initial(1);
    expect(state.data, 1);
    // PlatformChecker comes from flutter_faltool.
    expect(PlatformChecker.isWeb, kIsWeb);
    // printInfo comes from flutter_faltool/utils/print_utils.dart.
    expect(printInfo, isA<Function>());
  });
}
