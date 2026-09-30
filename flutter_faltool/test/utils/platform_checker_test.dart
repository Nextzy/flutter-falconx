import 'package:flutter/foundation.dart';
import 'package:flutter_faltool/flutter_faltool.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test('isAndroid follows defaultTargetPlatform', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(PlatformChecker.isAndroid, isTrue);
    expect(PlatformChecker.isIos, isFalse);
    expect(PlatformChecker.platform, DevicePlatform.android);
  });

  test('isWindows and isLinux are desktop', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    expect(PlatformChecker.isWindows, isTrue);
    expect(PlatformChecker.isDesktop, isTrue);
    expect(PlatformChecker.isMobile, isFalse);
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    expect(PlatformChecker.isLinux, isTrue);
    expect(PlatformChecker.isDesktopNative, !kIsWeb);
  });

  test('isFuchsia follows defaultTargetPlatform', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
    expect(PlatformChecker.isFuchsia, isTrue);
  });

  test('isWeb equals kIsWeb', () {
    expect(PlatformChecker.isWeb, kIsWeb);
    expect(PlatformChecker.isNotWeb, !kIsWeb);
  });
}
