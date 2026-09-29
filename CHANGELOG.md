# Changelog

## 4.0.0 — 2026-09-29

### Breaking

1. `flutter_falkit` is removed. `ImageCompressTool` now lives in `flutter_faltool`; the falkit widgets, animations, styles, and extensions are no longer provided.
2. `ImageCompressTool` takes and returns `XFile` (from `cross_file`, re-exported by `flutter_faltool`) instead of `dart:io` `File`. `compressAndSaveFile` throws `UnsupportedError` on web.
3. `Platform`, `File`, `HttpClient`, and other `dart:io` names are no longer re-exported by any package; import `dart:io` or `universal_io` in the app. `ansicolor` is no longer re-exported.
4. `url_strategy` is removed; call `usePathUrlStrategy()` from `flutter_web_plugins` in the app.
5. `flutter_local_notifications` ^22.3.1 (named parameters since 20.0.0; web support; requires Flutter >=3.38.1) and `app_links` ^7.2.1 (requires Flutter >=3.44.0, the floor for this repo). Both build with Android `compileSdk` 36; apps need `compileSdk` 36 or higher.
6. Packages in this repository depend on each other through git tags. An app lists any mix of `flutter_falconx`, `flutter_falconnect`, `flutter_falmodel`, `flutter_falstore`, `flutter_faltool` with the same `ref:` and `url: https://github.com/Nextzy/flutter-falconx`.
7. `flutter_falconnect` no longer declares `dio`, `retrofit`, `web_socket_channel`, `dio_cache_interceptor`, or `freezed_annotation` directly; they still arrive through `dart_falconnect` and `dart_faltool`, so app code is unchanged.
8. `ValidatorCubit.emitErrorMessage` no longer takes a `data` parameter or a `<T>` type argument (`dart_falmodel` 2.3.1's `Failure` has no `data`).
9. `flutter_falconx` no longer re-exports `flutter_falconnect`'s `RefreshCallback` or intl's `TextDirection` from its `flutter_falconnect`/`flutter_falmodel`/`flutter_falstore`/`flutter_faltool` exports; import them directly.
10. `flutter_falmodel` no longer re-exports `dio`.

### Deprecated

- `numberOfRetries` on `ImageCompressTool.compressFile`, `compressAndSaveFile`, and `batchCompressFiles` has no effect since 4.0.0 and will be removed in 5.0.0.

### Added

- `ImageCompressTool` runs on Windows and Linux through `package:image` (JPEG, PNG, WebP).
- The Dart engine (`ImageCompressTool` on Windows and Linux) honors `keepExif`, matching the native engine.
- Each package barrel re-exports the sibling below it; `flutter_falconnect` alone gives you `WidgetDataState` and `PlatformChecker`.
- `flutter_falconx/test/internal_dependencies_test.dart` guards version and dependency drift.
- `skills/flutter-falconx-package/` consumer skill.
