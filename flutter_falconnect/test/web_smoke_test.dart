// Proves flutter_falconnect compiles standalone (VM and web/Chrome) after
// the 4.0.1 barrel change removed the sibling re-export chain that
// test/barrel_test.dart used to exercise. Only this package's own barrel
// is imported; every symbol referenced is defined by flutter_falconnect
// itself (never a sibling), so a compile failure here is a real regression
// in this package's own export surface, not a missing sibling.
import 'package:flutter_falconnect/flutter_falconnect.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('flutter_falconnect compiles and its own symbols are reachable', () {
    final interceptor = ConnectivityInterceptor();
    expect(interceptor, isA<ConnectivityInterceptor>());

    final fetcher = EitherStreamFetcher<int>();
    expect(fetcher.isClosed, isFalse);

    final fetcherList = EitherStreamFetcherList();
    expect(fetcherList.hasActiveFetchers, isFalse);
    expect(fetcherList.activeCount, 0);

    expect(NLog.i, isA<Function>());
  });
}
