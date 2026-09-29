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

- A package depends only on packages below it. `flutter_faltool` lists no sibling; `flutter_falstore` lists only `flutter_faltool`.
- Declare a sibling as a git dependency on `https://github.com/Nextzy/flutter-falconx` with `ref:` equal to the repository version and `path:` equal to the package folder; never `path: ../`. Inside the workspace pub resolves it to the local folder anyway; outside, an app receives the tag it wrote for every package.
- Never declare a dependency that a `dart_fal*` package already re-exports (`dio`, `retrofit`, `web_socket_channel`, `dio_cache_interceptor`, `freezed_annotation`, `rxdart`, `fpdart`, `equatable`, `intl`, ...); it arrives transitively. Before adding a dependency, grep the dart-falconx barrels.
- Each package has one public barrel `lib/<package>.dart` (ordered `dart:` → `package:` → local) and one internal prelude `lib/src/src.dart`. Internal files import the prelude; the barrel never exports `src/`. There is no `lib/lib.dart`.
- Each barrel re-exports the sibling one level below it, so an app that lists only `flutter_falconnect` can name `WidgetDataState`.
- `flutter_falconx/test/internal_dependencies_test.dart` fails when a version drifts, a sibling is not a git dependency at the current version, a dependency points up the diagram, or a barrel breaks the prelude rule.

## Platform support

- Every package compiles and runs on Android, iOS, macOS, Windows, Linux, and web.
- Never `import 'dart:io'` under `lib/` except in the `if (dart.library.io)` branch of a conditional import (see `flutter_faltool/lib/tools/src/directory_io.dart`). Detect platforms with `PlatformChecker`, which uses `defaultTargetPlatform` and `kIsWeb`. Handle files as `XFile` from `cross_file`.
- Feature gaps that remain, and how they fail:

| Feature | Platform | Behaviour |
|---|---|---|
| `ImageCompressTool` HEIC output | Windows, Linux | throws `UnsupportedError` |
| `ImageCompressTool.compressAndSaveFile` | web | throws `UnsupportedError`; use `compressFile` |
| `flutter_udid` | web | plugin absent; `DeviceIdGenerator` never calls it on web |
| `path_provider` | web | plugin absent; `ImageCompressTool` returns a bytes-backed `XFile` on web |

- `ImageCompressTool` uses `flutter_image_compress` on Android, iOS, macOS, web and `package:image` inside `compute()` on Windows and Linux. Keep both engines' resize semantics identical (`minWidth`/`minHeight` are a floor; 0 disables resizing; never upscale).
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
- `flutter_falconx.dart` keeps `hide Path, RefreshCallback, TextDirection` on its `flutter_falconnect` export (Retrofit's `@Path` collides with `dart:ui`'s `Path`; dart_falconnect's `RefreshCallback` collides with material's; intl's `TextDirection` collides with `dart:ui`'s) and `hide TextDirection` on its `flutter_falmodel`, `flutter_falstore`, and `flutter_faltool` exports for the same intl/`dart:ui` collision.
- On native platforms `cross_file` ignores `name` in `XFile.fromData` (the name comes from the path), so pass `format:` to `ImageCompressTool.compressFile` for byte-backed XFiles.
- Apps that want path URLs on web call `usePathUrlStrategy()` from `flutter_web_plugins` themselves; this repo no longer depends on `url_strategy`.
- `app_links` ^7.2.1 requires Flutter >=3.44.0 (the floor for this repo); `flutter_local_notifications` ^22.3.1 requires Flutter >=3.38.1. Both plugins build with Android `compileSdk` 36, so apps need `compileSdk` 36 or higher.
