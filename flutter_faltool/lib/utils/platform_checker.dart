import 'package:flutter_faltool/lib.dart';
import 'package:flutter_faltool/utils/platform_checker_web.dart'
if (dart.library.io) 'platform_checker_stub.dart' as web_impl;
import 'package:flutter/foundation.dart';

enum DevicePlatform { android, ios, windows, macOs, linux, web }

class PlatformChecker {
  static DevicePlatform get platform {
    if (isAndroid) {
      return DevicePlatform.android;
    } else if (isIos) {
      return DevicePlatform.ios;
    } else if (isLinux) {
      return DevicePlatform.linux;
    } else if (isWindows) {
      return DevicePlatform.windows;
    } else if (isMacOs) {
      return DevicePlatform.macOs;
    } else {
      return DevicePlatform.web;
    }
  }

  static bool get isNativeApplicaation =>
      (isAndroid || isIos || isWindows || isLinux || isMacOs) && isNotWeb; //
  static bool get isNotNativeApplicaation => !isNativeApplicaation; //

  static bool get isMobile => isAndroid || isIos; //
  static bool get isNotMobile => !isMobile; //
  static bool get isMobileNative => (isAndroid || isIos) && isNotWeb; //
  static bool get isNotMobileNative => !isMobileNative; //
  static bool get isMobileOnWeb => (isAndroid || isIos) && isWeb; //
  static bool get isNotMobileOnWeb => !isMobileOnWeb; //

  static bool get isDesktop => isMacOs || isLinux || isWindows || isFuchsia; //
  static bool get isNotDesktop => !isDesktop; //
  static bool get isDesktopNative =>
      (isMacOs || isLinux || isWindows || isFuchsia) && isNotWeb; //
  static bool get isNotDesktopNative => !isDesktopNative; //
  static bool get isDesktopOnWeb =>
      (isMacOs || isLinux || isWindows || isFuchsia) && isWeb; //
  static bool get isNotDesktopOnWeb => !isDesktopOnWeb; //

  static bool get isWeb => kIsWeb; //
  static bool get isNotWeb => !kIsWeb; //

  ///========================= PLATFORM =========================///

  static bool get isAndroid => Platform.isAndroid; //
  static bool get isNotAndroid => !isAndroid; //
  static bool get isAndroidNative => isAndroid && isNotWeb; //
  static bool get isNotAndroidNative => !isAndroidNative; //
  static bool get isAndroidOnWeb =>
      isWeb && userAgent.toLowerCase().contains('android'); //
  static bool get isNotAndroidOnWeb => !isAndroidOnWeb; //

  static bool get isIos => Platform.isIOS; //
  static bool get isNotIos => !isIos; //
  static bool get isIosNative => isIos && isNotWeb; //
  static bool get isNotIosNative => !isIosNative; //
  static bool get isIosOnWeb => //
  isWeb && userAgent.toLowerCase().contains('iphone'); //
  static bool get isNotIosOnWeb => !isIosOnWeb; //

  static bool get isLinux => Platform.isLinux; //
  static bool get isNotLinux => !isLinux; //
  static bool get isLinuxNative => isLinux && isNotWeb; //
  static bool get isNotLinuxNative => !isLinuxNative; //
  static bool get isLinuxOnWeb =>
      isWeb && userAgent.toLowerCase().contains('linux'); //
  static bool get isNotLinuxOnWeb => !isLinuxOnWeb; //

  static bool get isWindows => Platform.isWindows; //
  static bool get isNotWindows => !isWindows; //
  static bool get isWindowsNative => isWindows && isNotWeb; //
  static bool get isNotWindowsNative => !isWindowsNative; //
  static bool get isWindowsOnWeb =>
      isWeb && userAgent.toLowerCase().contains('windows'); //
  static bool get isNotWindowsOnWeb => !isWindowsOnWeb; //

  static bool get isMacOs => Platform.isMacOS; //
  static bool get isNotMacOs => !isMacOs; //
  static bool get isMacOsNative => isMacOs && isNotWeb; //
  static bool get isNotMacOsNative => !isMacOsNative; //
  static bool get isMacOsOnWeb =>
      isWeb && userAgent.toLowerCase().contains('macintosh'); //
  static bool get isNotMacOsOnWeb => !isMacOsOnWeb; //

  static bool get isFuchsia => Platform.isFuchsia; //
  static bool get isNotFuchsia => !isFuchsia; //
  static bool get isFuchsiaNative => isFuchsia && isNotWeb; //
  static bool get isNotFuchsiaNative => !isFuchsiaNative; //

  static Future<bool> get isChromeOS async {
    final packageInfo = await PackageInfo.fromPlatform();

    // Check if the app is running on an Android device with a Chrome OS package
    if (Platform.isAndroid &&
        packageInfo.packageName.startsWith('dev.flutter')) {
      final version = packageInfo.version;
      final versionComponents = version.split('.');
      final majorVersion = int.parse(versionComponents[0]);

      return majorVersion >= 50;
    }

    return false;
  }

  ///========================= WEBSITE =========================///

  static String get userAgent => kIsWeb ? web_impl.getUserAgent() : '';

  static bool get isChromeWeb =>
      userAgent.contains('Chrome') && !userAgent.contains('Chromium'); //
  static bool get isChromiumWeb => !userAgent.contains('Chromium'); //
  static bool get isFirefoxWeb => userAgent.contains('Firefox'); //
  static bool get isInternetExplorerWeb => userAgent.contains('Trident/7.0'); //
  static bool get isBraveWeb => userAgent.contains('Brave'); //

  static bool get isInAppBrowser =>
      userAgent.contains('instagram') ||
          userAgent.contains('fbav') ||
          userAgent.contains('kakaotalk') ||
          userAgent.contains('whatsapp') ||
          userAgent.contains('line');
}
