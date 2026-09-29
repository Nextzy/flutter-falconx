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

Each package brings the packages below it: `flutter_falconnect` brings `flutter_falmodel` and `flutter_faltool`; `flutter_falmodel` and `flutter_falstore` bring `flutter_faltool`. List any mix of packages with the same tag and copy the `url` exactly; pub treats a `.git` suffix or SSH URL as a different source. Every package also brings its `dart_fal*` counterpart at the tag pinned inside this repository.

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
- Never `import 'dart:io'` in shared code; these packages compile to web. Use `PlatformChecker`, `XFile`, or `package:universal_io/io.dart` added to your own pubspec.
- Do not write a `File`-based compressor; `ImageCompressTool` already handles Windows and Linux through `package:image`.
- Do not write a router; `flutter_falconx/lib/routers/routers.dart` is empty at 4.0.0 — see `references/routing.md`.

## Gotchas

- `ImageCompressTool.compressAndSaveFile` throws `UnsupportedError` on web (no filesystem); the Dart engine (Windows, Linux) throws `UnsupportedError` for HEIC input or output — only the native engine (Android, iOS, macOS, web) handles HEIC.
- On native platforms `XFile.fromData(bytes, name: ...)` ignores `name` (a `cross_file` limitation), so `ImageCompressTool`'s extension-based format detection cannot see it: pass `format:` explicitly whenever the input `XFile` is byte-backed rather than disk-backed.
- `numberOfRetries` on `compressFile`, `compressAndSaveFile`, and `batchCompressFiles` is `@Deprecated` (no effect since 4.0.0, removed in 5.0.0); `compressBytes` never had this parameter.
- `flutter_falconx` hides `Path`, `RefreshCallback`, and `TextDirection` on its `flutter_falconnect` export, and `TextDirection` on its `flutter_falmodel`, `flutter_falstore`, and `flutter_faltool` exports. `Path` is Retrofit's annotation; `RefreshCallback` is `dart_falconnect`'s auth typedef. Import `package:retrofit/retrofit.dart` directly for `@Path`/`@Headers`, or `package:dart_falconnect/dart_falconnect.dart` for `RefreshCallback`.
- `CompressFormat` (from `flutter_image_compress`) is never re-exported by any barrel in this repo; import `package:flutter_image_compress/flutter_image_compress.dart` directly to reference it (for example to pass `format: CompressFormat.png`).
- An app that imports a hidden or non-re-exported package directly (`retrofit`, `dart_falconnect`, `flutter_image_compress`, ...) must also list that package in its own `pubspec.yaml`; otherwise `flutter analyze` flags `depend_on_referenced_packages`.
- `flutter_local_notifications` 22 uses named parameters in `initialize()` and `show()`.

## Out of scope

HTTP, WebSocket, JSON-RPC, `Result`, general exceptions, and Dart-only extensions — see the `dart-falconx-package` skill.
