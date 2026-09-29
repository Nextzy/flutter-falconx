import 'package:flutter/foundation.dart';
import 'package:flutter_faltool/flutter_faltool.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test('fallbackFingerprint names the platform without dart:io', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    final fp = DeviceIdGenerator.fallbackFingerprint();
    expect(fp, contains('linux'));
    expect(fp, contains(DateTime.now().timeZoneName));
  });
}
