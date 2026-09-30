# flutter-falconx

## Project overview

Flutter monorepo managed with Melos (scripts under the `melos:` key of the root `pubspec.yaml`; there is no `melos.yaml`), holding five packages:

- **flutter_falconx**: umbrella; BLoC base classes, cubits, validators, routers, `WidgetDataState` view builders; re-exports the four packages below plus `flutter_bloc`, `provider`, `app_links`, `flutter_local_notifications`, `bloc_concurrency`.
- **flutter_falconnect**: Dio/Retrofit/WebSocket engine on top of `dart_falconnect`, `ConnectivityInterceptor`, stream fetchers, `NLog`.
- **flutter_falmodel**: `WidgetDataState<T>` and its extensions on top of `dart_falmodel`.
- **flutter_falstore**: `SecureStorage` over `flutter_secure_storage`.
- **flutter_faltool**: `PlatformChecker`, `DeviceIdGenerator`, `ImageCompressTool`, `Log`, `printInfo/printError/printSuccess`, re-exported plugins, on top of `dart_faltool`.

```
flutter_falconx      (umbrella)
    ↓
flutter_falconnect   → dart_falconnect
    ↓
flutter_falmodel     → dart_falmodel
    ↓
flutter_faltool      → dart_faltool

flutter_falstore     → flutter_faltool only
```

- A package depends only on packages below it (pubspec `dependencies` or `dev_dependencies`, either counts). `flutter_faltool` lists no sibling; `flutter_falstore` lists only `flutter_faltool`.
- Declare a sibling as a git dependency on `https://github.com/Nextzy/flutter-falconx` with `ref:` equal to the repository version and `path:` equal to the package folder; never `path: ../`. Inside the workspace pub resolves it to the local folder anyway; outside, an app receives the tag it wrote for every package.
- Never declare a dependency that a `dart_fal*` package already re-exports (`dio`, `retrofit`, `web_socket_channel`, `dio_cache_interceptor`, `freezed_annotation`, `rxdart`, `fpdart`, `equatable`, `intl`, ...); it arrives transitively. Before adding a dependency, grep the dart-falconx barrels.
- Each package has one public barrel `lib/<package>.dart` (ordered `dart:` → `package:` → local) and one internal prelude `lib/src/src.dart`. Internal files import the prelude; the barrel never exports `src/`. There is no `lib/lib.dart`.
- Since 4.0.1, a non-umbrella barrel (`flutter_faltool`, `flutter_falmodel`, `flutter_falconnect`, `flutter_falstore`) never exports a sibling package; only the umbrella `flutter_falconx` exports all four. An app that lists only `flutter_falconnect` no longer gets `WidgetDataState` or `PlatformChecker` for free — list and import every package it uses, or depend on `flutter_falconx` alone. A package's own internal files still reach a sibling through that package's `lib/src/src.dart` prelude, never through the public barrel.
- `flutter_falconx/test/internal_dependencies_test.dart` fails when a version drifts, a sibling declared under `dependencies` or `dev_dependencies` is not a git dependency at the current version or points up the diagram, a barrel breaks the prelude rule, a non-umbrella barrel re-exports a sibling, or the umbrella barrel is missing one.

## Platform support

- Every package targets Android, iOS, macOS, Windows, Linux, and web. Web compilation is proven only by the Chrome test runs: `flutter_faltool` (`flutter test --platform chrome test/tools/ test/utils/`), `flutter_falstore` (`flutter test --platform chrome`), `flutter_falconnect` (`flutter test --platform chrome test/web_smoke_test.dart`), and `flutter_falconx` (`flutter test --platform chrome test/web_smoke_test.dart`). The two `web_smoke_test.dart` files exist solely to prove each package's own barrel compiles for web; `flutter_falconx`'s also touches a symbol from each re-exported sibling layer.
- Never `import 'dart:io'` under `lib/` except in the `if (dart.library.io)` branch of a conditional import (see `flutter_faltool/lib/tools/src/directory_io.dart`). Detect platforms with `PlatformChecker`, which uses `defaultTargetPlatform` and `kIsWeb`. In a browser `defaultTargetPlatform` is the browser's OS, so `PlatformChecker.platform` and `isAndroid`/`isIos`/`isMacOs`/... report that OS; test `isWeb` first, and use the `*OnWeb` getters for the browser's OS. Handle files as `XFile` from `cross_file`.
- Feature gaps that remain, and how they fail:

| Feature | Platform | Behaviour |
|---|---|---|
| `ImageCompressTool` HEIC output | Windows, Linux | throws `UnsupportedError` |
| `ImageCompressTool` HEIC output | web | the web plugin throws `UnimplementedError` (an `UnsupportedError`); `ImageCompressTool` rethrows it |
| `ImageCompressTool` WebP output | macOS | the macOS plugin throws `UnsupportedError` before encoding; after `FlutterImageCompress.ignoreCheckSupportPlatform(true)` it encodes JPEG while `ImageCompressTool` names the file `.webp` with MIME type `image/webp` |
| `ImageCompressTool` `keepExif`, `autoCorrectionAngle` | web | ignored; the web plugin does not forward them |
| `ImageCompressTool.compressAndSaveFile` | web | throws `UnsupportedError`; use `compressFile` |
| `flutter_udid` | web | plugin absent; `DeviceIdGenerator` never calls it on web |
| `path_provider` | web | plugin absent; `ImageCompressTool` returns a bytes-backed `XFile` on web |

- `ImageCompressTool` uses `flutter_image_compress` on Android, iOS, macOS, web and `package:image` inside `compute()` on Windows and Linux. Keep both engines' resize semantics identical: `minWidth`/`minHeight` are a floor, a 0 in either disables resizing on every engine, and nothing is upscaled. The native engine sends a 0 bound to the plugin as `1 << 20`, because the plugin turns 0 into a 0x0 target.
- On Android, iOS, and macOS, `compressFile` (and so `batchCompressFiles`) and `compressAndSaveFile` hand an `XFile` with a non-empty `path` to `NativeImageCompressEngine.compressPath` (`FlutterImageCompress.compressWithFile`), so `numberOfRetries` keeps Android's `OutOfMemoryError` retry. Web, `XFile`s without a path, `compressBytes`, and a `debugEngineOverride` that is not a `NativeImageCompressEngine` go through the engine's `compress` with bytes.
- Run `cd flutter_faltool && flutter test --platform chrome test/tools/ test/utils/` after touching any `lib/` code that could behave differently on web.

## Commands

| Script | Runs |
|---|---|
| `melos run get` / `upgrade` / `outdated` | `flutter pub get` / `upgrade` / `outdated` in every package |
| `melos run analyze` | `flutter analyze` (concurrency 4) |
| `melos run format` | `dart format --set-exit-if-changed .` |
| `melos run fix` | `dart fix --apply` with the curated `--code=` allowlist |
| `melos run fix:format` | runs `fix`, then `format` |
| `melos run test` | `flutter test` in every package with a `test/` dir, fail-fast |
| `melos run build_runner` / `:check` / `:watch` | code generation; no package in this repo generates code today |

- Run one test file from its package: `cd flutter_faltool && flutter test test/tools/dart_image_compress_engine_test.dart`.
- Reset dependencies with `melos clean`, then `melos bootstrap`.

## Release

Feature work lands on `develop`. A release carries only the version bump:

```bash
git flow release start X.Y.Z
# set version: in the root and the five package pubspecs; set every sibling ref: to X.Y.Z
melos run get && melos run analyze && melos run test
git commit -am "chore: release X.Y.Z"
git flow release finish X.Y.Z      # tags X.Y.Z (empty tag prefix), merges into main and back to develop
git push origin main develop --tags
```

Bump the major version when a public symbol is removed or its signature changes. Update `CHANGELOG.md` in the same release commit.

## Architecture

- `flutter_falconx/lib/blocs/`: `FalconBloc` (Either + stream fetching via flutter_falconnect's `EitherStreamFetcherList`), `FalconWidgetDataStateBloc`, `FalconNullableWidgetDataStateBloc`, `BehaviorBloc`, `PublishBloc`, `ReplayBloc`, value cubits (`BoolCubit`, `IntCubit`, `StringCubit`, `EnumCubit`, `TypeCubit`), validators (`ValidateBuilder`, `DisabledBuilder`, `ValidateState`).
- `flutter_falconx/lib/views/builders/`: `FullWidgetStatesBuilder`. `flutter_falconx/lib/views/states/`: `FalconApplicationState`, `FalconBlocState` (plus the `FalconWidgetBlocState` and `FalconNullableWidgetBlocState` variants), `ContentState`, `NullableContentState`, `FullWidgetStatesNotifier`, `PopResult`.
- `flutter_falconnect/lib/engine/`: `https/interceptors/ConnectivityInterceptor`, `fetches/EitherStreamFetcher`, `EitherStreamFetcherList`; HTTP client configuration itself lives in `dart_falconnect`.
- `flutter_falmodel/lib/models/widget_data_state.dart`: `WidgetDataState<T>` with `initial`, `toState`, loading/success/fail/warning/cancel states and `UserFeedback`.
- `flutter_falstore/lib/databases/secure_storage.dart`: `SecureStorage.instance` with `save`, `load`, `loadSafe`, batch operations.
- `flutter_faltool/lib/utils/`: `PlatformChecker`, `DeviceIdGenerator`, print helpers; `lib/tools/`: `ImageCompressTool` and its engines; `lib/logger.dart`: `Log`.

## Skill maintenance

`skills/flutter-falconx-package/` is the consumer-facing skill. Downstream projects copy it into their own `.claude/skills/`.

**Rule:** whenever a change touches the public API of any package (new, renamed, or removed public class, method, or parameter; changed signature; an edit to an export or `hide` list in a barrel; a newly re-exported third-party package), update `skills/flutter-falconx-package/SKILL.md` and the matching file under `references/` in the same change. HTTP, WebSocket, JSON-RPC, `Result`, and exception details are documented by the `dart-falconx-package` skill; link to it instead of repeating.

## Configuration

- One root `analysis_options.yaml`, based on `very_good_analysis`, covers every package; `strict-casts` and `strict-inference` are on.
- `avoid_print` is on; `flutter_faltool/lib/utils/print_utils.dart` guards every `print` with `kDebugMode`, which the lint accepts.

## Gotchas

- `Undefined name 'Platform'` after bumping `dart_faltool` means code reached `dart:io` through a re-export that no longer exists; use `PlatformChecker` or `defaultTargetPlatform`.
- `flutter_falconx.dart` keeps `hide Path, RefreshCallback` on its `flutter_falconnect` export (Retrofit's `@Path` collides with `dart:ui`'s `Path`; `dart_falconnect`'s `RefreshCallback` collides with material's) and `hide TextDirection` on its `flutter_faltool` export (intl's `TextDirection` collides with `dart:ui`'s). Since 4.0.1 `flutter_falmodel` and `flutter_falstore` no longer chain to `flutter_faltool`, so falconx's exports of them carry no collision and need no `hide`. Re-derive this list from the analyzer, not by copying it forward: an `undefined_hidden_name` warning on a `hide` in `flutter_falconx.dart` means that entry no longer hides anything and should be dropped; a missing one shows up as `ambiguous_import` on whatever code references the colliding name.
- Single-package hide, re-derived per package for a bare `import 'package:flutter_fal.../flutter_fal....dart'` next to `package:flutter/material.dart` (4.0.1, verified with the analyzer): `flutter_falconnect` needs `hide RefreshCallback` (`ambiguous_import`, a real compile error) and should also `hide Path` — Retrofit's `@Path` silently shadows `dart:ui`'s without an analyzer error, so `Path()..moveTo(...)` fails with `undefined_method` instead. `flutter_faltool` should `hide TextDirection` — intl's silently shadows `dart:ui`'s the same way, so `TextDirection.ltr` fails with `undefined_getter` (intl's constants are `TextDirection.LTR`/`.RTL`/`.UNKNOWN`). `flutter_falmodel` and `flutter_falstore` need no hide; neither package's own export chain carries a colliding name anymore.
- `flutter_falconx.dart` hides `Badge`, `ImageDecoderCallback`, and `Notification` on its `flutter/material.dart` export because it also exports `dart:ui` directly: `ImageDecoderCallback` collides with `dart:ui`'s, and `Badge`/`Notification` are hidden so apps using the `badges` package or their own `Notification` model do not hit an ambiguous import. This is an umbrella-only concern — no non-umbrella package exports `dart:ui` or `material.dart`, so it never applies to a single-package import. Import `package:flutter/material.dart` directly with `show Badge` to get Material's.
- On native platforms `cross_file` ignores `name` in `XFile.fromData` (the name comes from the path). Since 4.0.1, `ImageCompressTool.compressFile`/`compressAndSaveFile` fall back to the `XFile.mimeType` when the name has no extension or an unrecognized one, so pass `mimeType:` to `XFile.fromData` (or `format:` directly to the `ImageCompressTool` call) for byte-backed XFiles; a known name extension still wins over a conflicting `mimeType`.
- Apps that want path URLs on web call `usePathUrlStrategy()` from `flutter_web_plugins` themselves; this repo no longer depends on `url_strategy`.
- `app_links` ^7.2.1 requires Flutter >=3.44.0 (the floor for this repo); `flutter_local_notifications` ^22.3.1 requires Flutter >=3.38.1. Both plugins build with Android `compileSdk` 36, so apps need `compileSdk` 36 or higher.
