@TestOn('browser')
library;

// The analyzer resolves device_info_plus's conditional export to the native
// branch, so import the web plugin from its own library.
import 'package:device_info_plus/src/device_info_plus_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_faltool/flutter_faltool.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const udidChannel = MethodChannel('flutter_udid');
  late int udidCalls;

  setUpAll(() {
    // `flutter test` does not run the generated web plugin registrant, so
    // install device_info_plus's web implementation the way an app build does.
    DeviceInfoPlusWebPlugin.registerWith(webPluginRegistrar);
  });

  setUp(() {
    udidCalls = 0;
    // flutter_udid has no web implementation; in a web app its call fails
    // with MissingPluginException.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(udidChannel, (call) {
          udidCalls++;
          throw MissingPluginException();
        });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(udidChannel, null);
  });

  test(
    'getDeviceId hashes webBrowserInfo and never calls flutter_udid',
    () async {
      // In a browser defaultTargetPlatform is the browser's OS.
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      SharedPreferences.setMockInitialValues({});
      final first = await DeviceIdGenerator.getDeviceId();

      // Drop the cached id and regenerate a few milliseconds later. The
      // fallback fingerprint embeds the current time, so only an id built
      // from webBrowserInfo comes out identical.
      SharedPreferences.setMockInitialValues({});
      await Future<void>.delayed(const Duration(milliseconds: 5));
      final second = await DeviceIdGenerator.getDeviceId();

      expect(first, matches(RegExp(r'^[0-9a-f]{64}$')));
      expect(second, first);
      expect(udidCalls, 0);
    },
  );
}
