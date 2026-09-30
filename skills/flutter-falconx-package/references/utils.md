# Utils

`package: flutter_faltool` (re-exports `cross_file`, `dart_faltool`, `device_info_plus`, `flutter_udid`, `leak_tracker`, `package_info_plus`, `path_provider`, `rate_limiter`, `share_plus`, `shared_preferences`, and `CompressFormat` from `flutter_image_compress`).

## `PlatformChecker`

All-static; grouped `bool` getters plus `platform` (a `DevicePlatform` enum: `android`, `ios`, `windows`, `macOs`, `linux`, `web`).

`platform` and the per-OS getters read `defaultTargetPlatform`, which in a browser is the browser's OS. On web `platform` therefore returns `android`, `ios`, `windows`, `macOs`, or `linux`, never `DevicePlatform.web` (it returns `web` only for Fuchsia). Test `isWeb` first.

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
final label = PlatformChecker.isWeb
    ? 'Web'
    : switch (PlatformChecker.platform) {
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

Derives a SHA-256 hash from `flutter_udid` plus `device_info_plus` fields per platform (Android: ID/brand/model/device/product/hardware/display; iOS: vendor ID/model/name/system name+version; macOS/Windows/Linux: analogous machine identifiers). On web it uses `device_info_plus`'s `webBrowserInfo` instead of `flutter_udid` (which has no web implementation); the web check runs before the OS checks, because in a browser `defaultTargetPlatform` is the browser's OS. Falls back to a timestamp-and-timezone fingerprint if `flutter_udid` or `device_info_plus` throws.

## `ImageCompressTool`

All-static; compiles on every platform via `XFile` (`cross_file`). Picks a backend per platform (`ImageCompressTool.engine`, overridable in tests via `debugEngineOverride`):

| Platform | Engine | Output formats | Not supported |
|---|---|---|---|
| Android, iOS | native (`flutter_image_compress`) | jpeg, png, webp, heic | heic needs Android API 28+ or iOS 11+; the plugin rejects it below that |
| macOS | native | jpeg, png, heic | webp throws `UnsupportedError` |
| web | native | jpeg, png, webp | heic throws `UnimplementedError` (an `UnsupportedError`); `keepExif` and `autoCorrectionAngle` are ignored |
| Windows, Linux | Dart (`package:image` 4.10.1, runs in `compute`) | jpeg, png, webp | heic throws `UnsupportedError`; HEIC input fails to decode (`ImageCompressException`) |

On Android, iOS, and macOS, `compressFile`, `compressAndSaveFile`, and `batchCompressFiles` pass an `XFile` with a non-empty `path` to `NativeImageCompressEngine.compressPath`, which calls `FlutterImageCompress.compressWithFile` so the file is never read into Dart memory. On web, and for `XFile`s without a path or `compressBytes` on those three platforms, the native engine sends bytes through `compressWithList`.

```dart
class NativeImageCompressEngine implements ImageCompressEngine {
  Future<Uint8List> compress({required Uint8List bytes, required ImageCompressConfig config, required CompressFormat format, bool autoCorrectionAngle = true, bool keepExif = false});
  Future<Uint8List> compressPath({required String path, required ImageCompressConfig config, required CompressFormat format, bool autoCorrectionAngle = true, bool keepExif = false, int numberOfRetries = 5}); // not on web; throws ImageCompressException on a null result
}
```

```dart
static Future<XFile?> compressFile({
  required XFile file,
  ImageCompressProfile profile = ImageCompressProfile.standard,
  ImageCompressConfig? customConfig,
  CompressFormat? format,                 // re-exported by flutter_faltool
  bool autoCorrectionAngle = true,
  bool keepExif = false,
  int numberOfRetries = 5,                // Android only: retries after OutOfMemoryError with a doubled sample size
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
  int numberOfRetries = 5,
}); // throws UnsupportedError on web

static Future<Map<String, XFile?>> batchCompressFiles({
  required List<XFile> files,
  ImageCompressProfile profile = ImageCompressProfile.standard,
  ImageCompressConfig? customConfig,
  CompressFormat? format,
  bool autoCorrectionAngle = true,
  bool keepExif = false,
  int numberOfRetries = 5,
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

A 0 in either dimension disables resizing on every engine. `flutter_image_compress` turns a 0 bound into a 0x0 target, so the native engine sends `1 << 20` instead; the plugin never scales up, so the source size is kept.

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

`keepExif` is honored on Android, iOS, macOS, Windows, and Linux: the native engine passes it to `flutter_image_compress`; the Dart engine clears EXIF unless `keepExif: true`, for JPEG and WebP output only — `package:image`'s PNG encoder never writes EXIF, so `keepExif` has no observable effect for `CompressFormat.png` on Windows/Linux. The web plugin ignores `keepExif` and `autoCorrectionAngle`.

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
- The Dart engine throws `UnsupportedError` for `CompressFormat.heic` output, whether detected from a `.heic`/`.heif` file name or passed as `format:`. A HEIC input with another `format:` fails to decode (`package:image` has no HEIC decoder) and throws `ImageCompressException`.
- `compressBytes`, `compressFile`, and `compressAndSaveFile` rethrow `UnsupportedError` (including the web plugin's `UnimplementedError` for HEIC and the macOS plugin's WebP rejection) and wrap every other compression failure in `ImageCompressException`. `batchCompressFiles` maps any per-file failure to `null`.
- `numberOfRetries` on `compressFile`/`compressAndSaveFile`/`batchCompressFiles` is Android only and takes effect when the `XFile` has a path (compressed through `compressWithFile`); iOS, macOS, and web ignore it. `compressBytes` has no such parameter.
- `CompressFormat` is re-exported by `flutter_faltool` (and so by every barrel); no `flutter_image_compress` import is needed to pass `format:`.
- On native platforms `XFile.fromData(bytes, name: ...)` ignores `name`; when the input `XFile` you build for `compressFile`/`compressAndSaveFile`/`batchCompressFiles` is byte-backed rather than disk-backed, pass `format:` explicitly instead of relying on filename-extension detection.
- `flutter_udid` and `path_provider` have no web implementation; `DeviceIdGenerator` and `ImageCompressTool` route around this per-platform (see above) rather than calling them on web.
