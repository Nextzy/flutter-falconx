# Utils

`package: flutter_faltool` (re-exports `cross_file`, `dart_faltool`, `device_info_plus`, `flutter_udid`, `leak_tracker`, `package_info_plus`, `path_provider`, `rate_limiter`, `share_plus`, `shared_preferences`).

## `PlatformChecker`

All-static; grouped `bool` getters plus `platform` (a `DevicePlatform` enum: `android`, `ios`, `windows`, `macOs`, `linux`, `web`).

| Group | Getters |
|---|---|
| Category | `isMobile`/`isNotMobile`, `isMobileNative`, `isMobileOnWeb`, `isDesktop`/`isNotDesktop`, `isDesktopNative`, `isDesktopOnWeb`, `isNativeApplicaation` *(sic)*/`isNotNativeApplicaation` |
| Runtime | `isWeb`/`isNotWeb` (`kIsWeb`) |
| Per-OS | `isAndroid`, `isIos`, `isLinux`, `isWindows`, `isMacOs`, `isFuchsia` — each with `isNot*`, `is*Native` (OS match and not web), and `is*OnWeb` (browser user-agent match while `isWeb`) |
| Browser (web only) | `isChromeWeb`, `isChromiumWeb`, `isFirefoxWeb`, `isInternetExplorerWeb`, `isBraveWeb`, `isInAppBrowser` (Instagram/Facebook/KakaoTalk/WhatsApp/Line in-app browsers) |
| Async | `Future<bool> get isChromeOS` (Android + a `dev.flutter` package name + major version ≥ 50) |

```dart
if (PlatformChecker.isIosNative) requestApplePush();
if (PlatformChecker.isDesktopOnWeb) showDesktopWebBanner();
final label = switch (PlatformChecker.platform) {
  DevicePlatform.web => 'Web',
  DevicePlatform.android || DevicePlatform.ios => 'Mobile',
  _ => 'Desktop',
};
```

`*NativeXxx` means "this OS, and not running inside a browser"; `*XxxOnWeb` means "running inside a browser whose user agent claims this OS" — the two are mutually exclusive per OS.

## `DeviceIdGenerator`

A stable, cached device fingerprint, persisted through `shared_preferences`.

```dart
class DeviceIdGenerator {
  static Future<String> getDeviceId();
}
```

```dart
final deviceId = await DeviceIdGenerator.getDeviceId(); // cached after first call
```

Derives a SHA-256 hash from `flutter_udid` plus `device_info_plus` fields per platform (Android: ID/brand/model/device/product/hardware/display; iOS: vendor ID/model/name/system name+version; macOS/Windows/Linux: analogous machine identifiers). On web it uses `device_info_plus`'s `webBrowserInfo` instead of `flutter_udid` (which has no web implementation). Falls back to a timestamp-and-timezone fingerprint if `device_info_plus` throws.

## `ImageCompressTool`

All-static; compiles on every platform via `XFile` (`cross_file`). Picks a backend per platform (`ImageCompressTool.engine`, overridable in tests via `debugEngineOverride`):

| Platform | Engine | Formats | HEIC |
|---|---|---|---|
| Android, iOS, macOS, web | native (`flutter_image_compress`) | jpeg, png, webp, heic | supported |
| Windows, Linux | Dart (`package:image` 4.10.1, runs in `compute`) | jpeg, png, webp | throws `UnsupportedError` |

```dart
static Future<XFile?> compressFile({
  required XFile file,
  ImageCompressProfile profile = ImageCompressProfile.standard,
  ImageCompressConfig? customConfig,
  CompressFormat? format,                 // from flutter_image_compress — not re-exported, import it directly
  bool autoCorrectionAngle = true,
  bool keepExif = false,
  @Deprecated('Has no effect since 4.0.0; removed in 5.0.0.') int numberOfRetries = 5,
});

static Future<Uint8List?> compressBytes({
  required Uint8List bytes,
  ImageCompressProfile profile = ImageCompressProfile.standard,
  ImageCompressConfig? customConfig,
  CompressFormat format = CompressFormat.jpeg,
  bool autoCorrectionAngle = true,
  bool keepExif = false,
});

static Future<XFile?> compressAndSaveFile({
  required XFile file,
  required String targetPath,
  ImageCompressProfile profile = ImageCompressProfile.standard,
  ImageCompressConfig? customConfig,
  CompressFormat? format,
  bool autoCorrectionAngle = true,
  bool keepExif = false,
  @Deprecated('Has no effect since 4.0.0; removed in 5.0.0.') int numberOfRetries = 5,
}); // throws UnsupportedError on web

static Future<Map<String, XFile?>> batchCompressFiles({
  required List<XFile> files,
  ImageCompressProfile profile = ImageCompressProfile.standard,
  ImageCompressConfig? customConfig,
  CompressFormat? format,
  bool autoCorrectionAngle = true,
  bool keepExif = false,
  @Deprecated('Has no effect since 4.0.0; removed in 5.0.0.') int numberOfRetries = 5,
  int concurrency = 3,
  void Function(int completed, int total)? onProgress,
}); // per-file failure maps to a null value, never throws

static Future<CompressionResult> getCompressionResult({required XFile originalFile, required XFile compressedFile});
static Future<int> estimateCompressedSize({required XFile file, ImageCompressProfile profile = ImageCompressProfile.standard, ImageCompressConfig? customConfig});
```

`ImageCompressProfile` table (`ImageCompressTool.profiles`):

| Profile | minWidth × minHeight | quality |
|---|---|---|
| `thumbnail` | 150 × 150 | 70 |
| `preview` | 800 × 600 | 80 |
| `standard` (default) | 1920 × 1080 | 85 |
| `high` | 2560 × 1440 | 90 |
| `original` | 0 × 0 (no resize) | 95 |

Pass `customConfig: ImageCompressConfig(minWidth: ..., minHeight: ..., quality: ...)` to override a profile.

```dart
final compressed = await ImageCompressTool.compressFile(
  file: pickedFile,
  profile: ImageCompressProfile.preview,
  keepExif: true,
);

final results = await ImageCompressTool.batchCompressFiles(
  files: pickedFiles,
  concurrency: 4,
  onProgress: (done, total) => print('$done / $total'),
);
```

`keepExif` is honored on both engines: the native engine passes it straight to `flutter_image_compress`; the Dart engine clears EXIF unless `keepExif: true`, for JPEG and WebP output only — `package:image`'s PNG encoder never writes EXIF, so `keepExif` has no observable effect for `CompressFormat.png` on Windows/Linux.

`format` defaults to detection from the input `XFile.name`'s extension when omitted (`compressFile`/`compressAndSaveFile`/`batchCompressFiles`); `compressBytes` defaults to `CompressFormat.jpeg` since bytes carry no filename.

## `Log`

Static, `logger`-package-backed; every method is a no-op in release mode (`kReleaseMode`).

```dart
class Log {
  static void setup({LogFilter? filter, LogPrinter? printer, LogOutput? output, Level? level});
  static void t(Object? message, {String? tag, DateTime? time, Object? error, StackTrace? stackTrace});
  static void d(Object? message, {String? tag, DateTime? time, Object? error, StackTrace? stackTrace});
  static void i(Object? message, {String? tag, DateTime? time, Object? error, StackTrace? stackTrace});
  static void w(Object? message, {String? tag, DateTime? time, Object? error, StackTrace? stackTrace}); // auto-extracts stack trace from an Error/Exception message
  static void e(Object? message, {String? tag, DateTime? time, Object? error, StackTrace? stackTrace}); // same auto-extraction
  static void error(Object error, StackTrace? stackTrace, {String? tag, DateTime? time});
  static void f(Object? message, {String? tag, DateTime? time, Object? error, StackTrace? stackTrace});
  static void title(Object? message);    // white bold, pretty-printed
  static void success(Object? message);  // green bold, pretty-printed
}
```

```dart
Log.i('User signed in', tag: 'Auth');
try {
  await repo.save(user);
} catch (error, stackTrace) {
  Log.e('Save failed', error: error, stackTrace: stackTrace);
}
```

## Print helpers

Top-level functions, `kDebugMode`-gated, ANSI-colored, pretty-printed JSON when possible:

```dart
void printInfo(Object? message);                       // white
void printError(Object? message, [StackTrace? stacktrace]); // red
void printSuccess(Object? message);                     // green
```

## Gotchas

- `PlatformChecker.isNativeApplicaation` / `isNotNativeApplicaation` are misspelled ("Applicaation") in source; there is no correctly spelled alias.
- `ImageCompressTool.compressAndSaveFile` throws `UnsupportedError` on web (no filesystem) — use `compressFile` and keep the returned `XFile` instead.
- The Dart engine throws `UnsupportedError` for `CompressFormat.heic`, whether as input format detected from the file name or as an explicit `format:` — Windows and Linux never produce or accept HEIC through this tool.
- `numberOfRetries` on `compressFile`/`compressAndSaveFile`/`batchCompressFiles` is `@Deprecated` and has no effect since 4.0.0; it is scheduled for removal in 5.0.0. `compressBytes` never accepted it.
- `CompressFormat` is not re-exported by `flutter_faltool`; import `package:flutter_image_compress/flutter_image_compress.dart` directly (and list it in your own `pubspec.yaml`) to pass `format:` explicitly.
- On native platforms `XFile.fromData(bytes, name: ...)` ignores `name`; when the input `XFile` you build for `compressFile`/`compressAndSaveFile`/`batchCompressFiles` is byte-backed rather than disk-backed, pass `format:` explicitly instead of relying on filename-extension detection.
- `flutter_udid` and `path_provider` have no web implementation; `DeviceIdGenerator` and `ImageCompressTool` route around this per-platform (see above) rather than calling them on web.
