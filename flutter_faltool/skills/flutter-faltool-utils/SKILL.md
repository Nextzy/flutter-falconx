---
name: flutter-faltool-utils
description: Use when writing or changing code with flutter_faltool, including platform detection with PlatformChecker, stable device ids, ImageCompressTool image compression with XFile, Log and print helpers, or before adding a device-info, share, path, shared-preferences, or app-restart dependency, since it already re-exports them.
---

# flutter_faltool utils

Answers "does flutter_faltool already provide this?" here and routes "how do I call it?" to one file under `references/`. `package: flutter_faltool`; its barrel is also where the third-party libraries listed in `references/third-party.md` come from, and it re-exports `dart_faltool`, so that package's extensions, `TypeId`, `UuidGenerator`, and libraries (`rxdart`, `fpdart`, `intl`, ...) come with it; see the skill shipped for `dart_faltool` (installed with this package).

## Capability map

| Need | Use | Ref |
|---|---|---|
| Platform detection | `PlatformChecker.isAndroid/isIosNative/isDesktopOnWeb/...` | `references/utils.md` |
| Stable device id | `DeviceIdGenerator.getDeviceId()` | `references/utils.md` |
| Image compression on every platform | `ImageCompressTool.compressFile/compressBytes/compressAndSaveFile/batchCompressFiles` with `XFile` | `references/utils.md` |
| Debug logging | `Log.i/d/w/e/f`, `printInfo`, `printError`, `printSuccess` | `references/utils.md` |
| Third-party libs, free with this package | `cross_file`, `device_info_plus`, `flutter_udid`, `leak_tracker`, `package_info_plus`, `path_provider`, `rate_limiter`, `restart_app`, `share_plus`, `shared_preferences`, `CompressFormat` from `flutter_image_compress` | `references/third-party.md` |

## Do not reinvent

- Before adding a pub dependency or writing a helper, scan the map above, `references/third-party.md`, and the skill shipped for `dart_faltool`.
- When this package's barrel is imported, do not also import a library it re-exports; the symbols are already in scope.
- Never `import 'dart:io'` in shared code; this package targets web. Use `PlatformChecker`, `XFile`, or `package:universal_io/io.dart` added to your own pubspec.
- Never `import 'dart:html'` or `dart:js`: dart2js tolerates them, dart2wasm fails to compile them. The browser API is `package:web`.
- Do not write a `File`-based compressor; `ImageCompressTool` already handles Windows and Linux through `package:image`.

## Gotchas

- `ImageCompressTool.compressAndSaveFile` throws `UnsupportedError` on web (no filesystem).
- The plugin accepts HEIC output on Android (API 28+), iOS (11+), and macOS. The Dart engine (Windows, Linux) throws `UnsupportedError` for HEIC output, which a `.heic` file name selects when `format:` is omitted; on web the plugin throws `UnimplementedError`, a subtype of `UnsupportedError`. A HEIC input with `format: CompressFormat.jpeg` on the Dart engine fails to decode and throws `ImageCompressException`.
- WebP output on macOS throws `UnsupportedError` (the plugin rejects it before encoding). After `FlutterImageCompress.ignoreCheckSupportPlatform(true)` the plugin encodes JPEG, yet `ImageCompressTool` still names the file `.webp` with MIME type `image/webp`, so do not call that method for WebP. On web the plugin ignores `keepExif` and `autoCorrectionAngle`.
- `compressBytes`, `compressFile`, and `compressAndSaveFile` rethrow `UnsupportedError` and wrap every other compression failure in `ImageCompressException`; catch both.
- On native platforms `XFile.fromData(bytes, name: ...)` ignores `name` (a `cross_file` limitation; the name comes from `path` instead). Since 4.0.1, when the name has no extension or an unrecognized one, `ImageCompressTool` falls back to `XFile.mimeType` before defaulting to jpeg — pass `mimeType:` to `XFile.fromData`, or pass `format:` explicitly, whenever the input `XFile` is byte-backed rather than disk-backed. A known name extension still wins over a conflicting `mimeType`. `batchCompressFiles` also keys its result map by `file.path`, else `file.name`, else `'#$i'` (de-duplicated with a `'#$i'` suffix on a repeat) — do not assume the key is always `file.path`.
- `numberOfRetries` on `compressFile`, `compressAndSaveFile`, and `batchCompressFiles` is Android only: after an `OutOfMemoryError` the plugin decodes again with a doubled sample size. It takes effect when the `XFile` has a path, because only then does `ImageCompressTool` compress by path (`compressWithFile`); iOS, macOS, and web ignore it, and `compressBytes` has no such parameter.
- In a browser `PlatformChecker.platform` and `isAndroid`/`isIos`/`isMacOs`/... report the browser's OS, never `DevicePlatform.web`. Test `PlatformChecker.isWeb` first; use `isAndroidOnWeb`, `isIosOnWeb`, ... for the browser's OS.
- `CompressFormat` is re-exported by this package; pass `format: CompressFormat.png` without importing `flutter_image_compress`.
- Importing this package's barrel next to `package:flutter/material.dart` (4.0.1, re-derived with the analyzer): `hide TextDirection` on the import — intl's (re-exported through `dart_faltool`) silently shadows `dart:ui`'s without an analyzer error (`TextDirection.ltr` fails with `undefined_getter`; intl's constants are `TextDirection.LTR`/`.RTL`/`.UNKNOWN`).
- An app that imports a package this barrel does not re-export (`flutter_image_compress`, ...) must also list that package in its own `pubspec.yaml`; otherwise `flutter analyze` flags `depend_on_referenced_packages`.

## Out of scope

General usage of the re-exported libraries, the extensions and helpers of `dart_faltool`, and package internals.
