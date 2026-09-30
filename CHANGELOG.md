# Changelog

## 4.0.0 — 2026-09-30

### Breaking

1. `flutter_falkit` is removed. `ImageCompressTool` now lives in `flutter_faltool`; the falkit widgets, animations, styles, and extensions are no longer provided.
2. `ImageCompressTool` takes and returns `XFile` (from `cross_file`, re-exported by `flutter_faltool`) instead of `dart:io` `File`. `compressAndSaveFile` throws `UnsupportedError` on web. On Android, iOS, and macOS a disk-backed `XFile` still reaches `flutter_image_compress` by path (`compressWithFile`), so `numberOfRetries` keeps the Android `OutOfMemoryError` retry with a doubled sample size.
3. `Platform`, `File`, `HttpClient`, and other `dart:io` names are no longer re-exported by any package; import `dart:io` or `universal_io` in the app. `ansicolor` is no longer re-exported.
4. `url_strategy` is removed; call `usePathUrlStrategy()` from `flutter_web_plugins` in the app.
5. `flutter_local_notifications` ^22.3.1 (named parameters since 20.0.0; web support; requires Flutter >=3.38.1) and `app_links` ^7.2.1 (requires Flutter >=3.44.0, the floor for this repo). Both build with Android `compileSdk` 36; apps need `compileSdk` 36 or higher.
6. Packages in this repository depend on each other through git tags. An app lists any mix of `flutter_falconx`, `flutter_falconnect`, `flutter_falmodel`, `flutter_falstore`, `flutter_faltool` with the same `ref:` and `url: https://github.com/Nextzy/flutter-falconx`.
7. `flutter_falconnect` no longer declares `dio`, `retrofit`, `web_socket_channel`, `dio_cache_interceptor`, or `freezed_annotation` directly; they still arrive through `dart_falconnect` and `dart_faltool`, so app code is unchanged.
8. `ValidatorCubit.emitErrorMessage` no longer takes a `data` parameter or a `<T>` type argument (`dart_falmodel` 2.3.1's `Failure` has no `data`).
9. `flutter_falconx` no longer exports `dart_falconnect`'s `RefreshCallback` (hidden on its `flutter_falconnect` export) or intl's `TextDirection` (hidden on its `flutter_falconnect`, `flutter_falmodel`, `flutter_falstore`, and `flutter_faltool` exports); import them directly if needed.
10. `flutter_falmodel` no longer re-exports `dio`.
11. `flutter_falconx` no longer re-exports `flutter_falkit`'s third-party packages: `extended_image`, `flutter_animate`, `flutter_svg`, `gap`, `smooth_page_indicator`. Add the ones you use to your app's `pubspec.yaml`.
12. `ImageCompressTool.compressBytes`, `compressFile`, and `compressAndSaveFile` let `UnsupportedError` escape. That covers the Dart engine's HEIC rejection, the `UnimplementedError` the web plugin throws for HEIC output, and the macOS plugin's WebP rejection. Before 4.0.0 every failure became `ImageCompressException`; catch both. `batchCompressFiles` still maps any per-file failure to `null`.
13. An app that imports a single package next to `package:flutter/material.dart` must hide the names that shadow Flutter's: `flutter_falconnect` needs `hide Path, RefreshCallback, TextDirection`; `flutter_falmodel`, `flutter_falstore`, and `flutter_faltool` need `hide TextDirection`. Without the hide, intl's `TextDirection` and Retrofit's `Path` replace `dart:ui`'s (`TextDirection.ltr` and `Path()..moveTo(...)` stop compiling), and `RefreshCallback` is an ambiguous import.
14. `WillPopListener` is removed, along with the `onWillPop` parameter of `buildWithBloc` (`FalconWidgetBlocState`, `FalconNullableWidgetBlocState`) and of `FalconBlocState.buildCompatPopScope`, which now builds only `PopScope`. Pass `canPop` and `onPop` instead.
15. `DeviceIdGenerator` falls back to its fingerprint only when device info throws an `Exception`; an `Error` from a device-info plugin now propagates.

### Added

- `ImageCompressTool` runs on Windows and Linux through `package:image` (JPEG, PNG, WebP).
- The Dart engine (`ImageCompressTool` on Windows and Linux) honors `keepExif`, matching the native engine.
- Each package barrel re-exports the sibling below it; `flutter_falconnect` alone gives you `WidgetDataState` and `PlatformChecker`.
- `flutter_falconx/test/internal_dependencies_test.dart` guards version and dependency drift.
- `skills/flutter-falconx-package/` consumer skill.
- `flutter_faltool` re-exports `CompressFormat` from `flutter_image_compress`, so every barrel provides it.
- `NativeImageCompressEngine.compressPath` compresses a file by path through `FlutterImageCompress.compressWithFile`.

### Fixed

- `ImageCompressProfile.original` (0 × 0) keeps the source size on Android, iOS, macOS, and web. `flutter_image_compress` 2.5.1 has no "no resize" value and turns a 0 bound into a 0x0 target, so the native engine sends `1 << 20` instead, which the plugin never scales up to. A 0 in either dimension now disables resizing on both engines.
- `DeviceIdGenerator` checks `PlatformChecker.isWeb` before the OS branches, so on web it hashes `device_info_plus`'s `webBrowserInfo` and never calls `flutter_udid`. In a browser `defaultTargetPlatform` is the browser's OS, so an OS branch used to match first.

### Upgrading from 3.11.4

- The packages were renamed: `falconx` → `flutter_falconx`, `falconnect` → `flutter_falconnect`, `falmodel` → `flutter_falmodel`, `falstore` → `flutter_falstore`, `faltool` → `flutter_faltool`. Rename the pubspec entries and the imports (`package:falconx/falconx.dart` → `package:flutter_falconx/flutter_falconx.dart`). `falkit` was removed (Breaking 1).
- The HTTP engine left `falconnect` (commit `4871756`): `BaseHttpClient` and the Dio interceptors now live in `dart_falconnect`, and the HTTP exceptions in `dart_falmodel`. `flutter_falconnect` re-exports both; only `ConnectivityInterceptor` stayed in this repo. See the `dart-falconx-package` skill for the current names.
