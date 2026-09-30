---
name: flutter-falconx-package
description: Use when a Flutter project lists flutter_falconx, flutter_falconnect, flutter_falmodel, flutter_falstore, or flutter_faltool in pubspec.yaml and you are about to write BLoC/state, routing, connectivity, secure storage, platform detection, image compression, or logging code, add a pub dependency, or call any public API of those packages.
---

# flutter-falconx package

Answers "does flutter-falconx already provide this?" here and routes "how do I call it?" to one file under `references/`. HTTP, WebSocket, JSON-RPC, `Result`, and exceptions come from dart-falconx; use the `dart-falconx-package` skill for those.

## Setup

```yaml
dependencies:
  flutter_falconx:                   # or only flutter_falconnect / flutter_falmodel / flutter_falstore / flutter_faltool
    git:
      url: https://github.com/Nextzy/flutter-falconx
      ref: <latest_tag>              # e.g. 4.0.0 — see `git ls-remote --tags`
      path: flutter_falconx
environment:
  sdk: ">=3.13.0 <4.0.0"
  flutter: ">=3.44.0"
```

Since 4.0.1, a package no longer brings the packages below it: `flutter_falconnect` alone gives you only `flutter_falconnect`'s own API, not `flutter_falmodel`'s or `flutter_faltool`'s; `flutter_falmodel` and `flutter_falstore` alone no longer give you `flutter_faltool`'s. List and import every package you use directly, or depend on `flutter_falconx` alone — the umbrella still re-exports all four. List any mix of packages with the same tag and copy the `url` exactly; pub treats a `.git` suffix or SSH URL as a different source. Every package also brings its `dart_fal*` counterpart at the tag pinned inside this repository.

`flutter: ">=3.44.0"` and Android `compileSdk 36` are floors set by `app_links` and `flutter_local_notifications`, both pulled in through `flutter_falconx`; raise your app's `compileSdk` if it is lower.

To build against a local clone, put `dependency_overrides` with `path:` entries in a gitignored `pubspec_overrides.yaml` beside the app's `pubspec.yaml`.

```dart
import 'package:flutter_falconx/flutter_falconx.dart';        // umbrella
import 'package:flutter_falconnect/flutter_falconnect.dart';  // single-package consumers
import 'package:flutter_falmodel/flutter_falmodel.dart';
import 'package:flutter_falstore/flutter_falstore.dart';
import 'package:flutter_faltool/flutter_faltool.dart';
```

## Capability map

| Need | Use | Package | Ref |
|---|---|---|---|
| BLoC with Either and stream fetching | `FalconBloc`, `FalconWidgetDataStateBloc`, `FalconNullableWidgetDataStateBloc` | flutter_falconx | `references/state.md` |
| Behaviour/replay/publish subjects as BLoC | `BehaviorBloc`, `PublishBloc`, `ReplayBloc` | flutter_falconx | `references/state.md` |
| Single-value cubits | `BoolCubit`, `IntCubit`, `StringCubit`, `EnumCubit<T>`, `TypeCubit<T>` | flutter_falconx | `references/state.md` |
| Form validation widgets | `ValidateBuilder`, `DisabledBuilder`, `ValidatorCubit`, `ValidateState<DATA>` | flutter_falconx | `references/state.md` |
| Widget-state data holder | `WidgetDataState<T>`, `FullWidgetState`, `FullWidgetStates` | flutter_falmodel | `references/state.md` |
| Loading/success/fail UI from state | `FullWidgetStatesBuilder`, `ContentState<T>`, `NullableContentState<T>`, `FalconApplicationState`, `FalconBlocState` family, `FullWidgetStatesNotifier`, `PopResult` | flutter_falconx | `references/state.md` |
| Routing | flutter-falconx ships no router today | — | `references/routing.md` |
| Connectivity-aware requests, stream/future fetch lifecycle | `ConnectivityInterceptor`, `EitherStreamFetcher<T>`, `EitherStreamFetcherList`, `NLog` | flutter_falconnect | `references/network.md` |
| Internet reachability BLoC | `InternetConnectionBloc` | flutter_falconx | `references/network.md` |
| Secure key-value storage | `SecureStorage.instance.save/load/loadSafe` | flutter_falstore | `references/storage.md` |
| Platform detection | `PlatformChecker.isAndroid/isIosNative/isDesktopOnWeb/...` | flutter_faltool | `references/utils.md` |
| Stable device id | `DeviceIdGenerator.getDeviceId()` | flutter_faltool | `references/utils.md` |
| Image compression on every platform | `ImageCompressTool.compressFile/compressBytes/compressAndSaveFile/batchCompressFiles` with `XFile` | flutter_faltool | `references/utils.md` |
| Debug logging | `Log.i/d/w/e/f`, `printInfo`, `printError`, `printSuccess` | flutter_faltool | `references/utils.md` |
| Third-party libs, free with the import | `flutter_bloc`, `provider`, `bloc_concurrency`, `app_links`, `flutter_local_notifications`, `connectivity_plus`, `flutter_secure_storage`, `device_info_plus`, `package_info_plus`, `share_plus`, `shared_preferences`, `path_provider`, `flutter_udid`, `leak_tracker`, `rate_limiter`, `cross_file` | see ref | `references/third-party.md` |

## Do not reinvent

- Before adding a pub dependency, scan the map above, `references/third-party.md`, and the `dart-falconx-package` skill.
- Never `import 'dart:io'` in shared code; these packages target web. Use `PlatformChecker`, `XFile`, or `package:universal_io/io.dart` added to your own pubspec.
- Do not write a `File`-based compressor; `ImageCompressTool` already handles Windows and Linux through `package:image`.
- Do not write a router; `flutter_falconx/lib/routers/routers.dart` is empty at 4.0.0 — see `references/routing.md`.

## Gotchas

- `ImageCompressTool.compressAndSaveFile` throws `UnsupportedError` on web (no filesystem).
- The plugin accepts HEIC output on Android (API 28+), iOS (11+), and macOS. The Dart engine (Windows, Linux) throws `UnsupportedError` for HEIC output, which a `.heic` file name selects when `format:` is omitted; on web the plugin throws `UnimplementedError`, a subtype of `UnsupportedError`. A HEIC input with `format: CompressFormat.jpeg` on the Dart engine fails to decode and throws `ImageCompressException`.
- WebP output on macOS throws `UnsupportedError` (the plugin rejects it before encoding). On web the plugin ignores `keepExif` and `autoCorrectionAngle`.
- `compressBytes`, `compressFile`, and `compressAndSaveFile` rethrow `UnsupportedError` and wrap every other compression failure in `ImageCompressException`; catch both.
- On native platforms `XFile.fromData(bytes, name: ...)` ignores `name` (a `cross_file` limitation; the name comes from `path` instead). Since 4.0.1, when the name has no extension or an unrecognized one, `ImageCompressTool` falls back to `XFile.mimeType` before defaulting to jpeg — pass `mimeType:` to `XFile.fromData`, or pass `format:` explicitly, whenever the input `XFile` is byte-backed rather than disk-backed. A known name extension still wins over a conflicting `mimeType`. `batchCompressFiles` also keys its result map by `file.path`, else `file.name`, else `'#$i'` (de-duplicated with a `'#$i'` suffix on a repeat) — do not assume the key is always `file.path`.
- `numberOfRetries` on `compressFile`, `compressAndSaveFile`, and `batchCompressFiles` is Android only: after an `OutOfMemoryError` the plugin decodes again with a doubled sample size. It takes effect when the `XFile` has a path, because only then does `ImageCompressTool` compress by path (`compressWithFile`); iOS, macOS, and web ignore it, and `compressBytes` has no such parameter.
- In a browser `PlatformChecker.platform` and `isAndroid`/`isIos`/`isMacOs`/... report the browser's OS, never `DevicePlatform.web`. Test `PlatformChecker.isWeb` first; use `isAndroidOnWeb`, `isIosOnWeb`, ... for the browser's OS.
- `flutter_falconx` hides `Path` on its `flutter_falconnect` export, `TextDirection` on its `flutter_faltool` export, and `log` on `dart:math`. `Path` is Retrofit's annotation; `TextDirection` is intl's; `log` would collide with `dart:developer`'s. Import `package:retrofit/retrofit.dart` directly for `@Path`/`@Headers`, `package:intl/intl.dart` for intl's `TextDirection`, or write `import 'dart:math' as math;` for `math.log`. `dart_falconnect`'s auth typedef is `TokenRefreshCallback` since 4.1.0 and is exported.
- Importing a single package next to `package:flutter/material.dart` (4.0.1, re-derived per package with the analyzer): `flutter_falconnect` should `hide Path` — `Path` silently shadows `dart:ui`'s without one (`Path()..moveTo(...)` fails with `undefined_method` instead). `flutter_faltool` should `hide TextDirection` — intl's silently shadows `dart:ui`'s the same way (`TextDirection.ltr` fails with `undefined_getter`; intl's constants are `TextDirection.LTR`/`.RTL`/`.UNKNOWN`). `flutter_falmodel` and `flutter_falstore` need no hide for a bare import; neither package's own export chain carries a colliding name anymore.
- `flutter_falconx` hides `Badge`, `ImageDecoderCallback`, and `Notification` on its `flutter/material.dart` export, because it also exports `dart:ui` directly: `ImageDecoderCallback` collides with `dart:ui`'s, and `Badge`/`Notification` are hidden so apps using the `badges` package or their own `Notification` model do not hit an ambiguous import. Import `package:flutter/material.dart` directly with `show Badge` to get Material's. This is umbrella-only — no non-umbrella package exports `dart:ui` or `material.dart`.
- `CompressFormat` is re-exported by `flutter_faltool`, and by the umbrella `flutter_falconx`; pass `format: CompressFormat.png` without importing `flutter_image_compress` when you depend on one of those two. Since 4.0.1 `flutter_falmodel` and `flutter_falstore` no longer chain to `flutter_faltool`, so they no longer carry `CompressFormat`.
- An app that imports a hidden or non-re-exported package directly (`retrofit`, `dart_falconnect`, `flutter_image_compress`, ...) must also list that package in its own `pubspec.yaml`; otherwise `flutter analyze` flags `depend_on_referenced_packages`.
- `flutter_local_notifications` 22 uses named parameters in `initialize()` and `show()`.

## Out of scope

HTTP, WebSocket, JSON-RPC, `Result`, general exceptions, and Dart-only extensions — see the `dart-falconx-package` skill.
