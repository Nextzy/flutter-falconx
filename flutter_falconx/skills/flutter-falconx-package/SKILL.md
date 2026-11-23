---
name: flutter-falconx-package
description: Use when a Flutter project lists flutter_falconx in pubspec.yaml, or you are choosing which flutter_fal* package to list, adding its git dependency, or importing it, before writing BLoC, cubit, form-validation, stateful-screen, pop-result, routing, or connectivity-banner code with it.
---

# flutter-falconx package

Answers "which flutter-falconx package do I list and import?" and "does flutter_falconx already provide this?" here, routes "how do I call it?" to one file under `references/` for what `flutter_falconx` owns, and to the skill that each other package ships for the rest. `flutter_falconx` ships a copy of the skill of each package it re-exports.

## Setup

```yaml
dependencies:
  flutter_falconx:                   # or only flutter_falconnect / flutter_falmodel / flutter_falstore / flutter_faltool
    git:
      url: https://github.com/Nextzy/flutter-falconx
      ref: <latest_tag>              # see `git ls-remote --tags`
      path: flutter_falconx
environment:
  sdk: ">=3.13.0 <4.0.0"            # not below the constraint in flutter_falconx/pubspec.yaml
  flutter: ">=3.47.0"                # when you list flutter_falconx; the other packages do not raise it
```

Since 4.0.1, a package no longer brings the packages below it: `flutter_falconnect` alone gives you only `flutter_falconnect`'s own API, not `flutter_falmodel`'s or `flutter_faltool`'s; `flutter_falmodel` and `flutter_falstore` alone no longer give you `flutter_faltool`'s. List and import every package you use directly, or depend on `flutter_falconx` alone — the umbrella still re-exports all four. List any mix of packages with the same tag and copy the `url` exactly; pub treats a `.git` suffix or SSH URL as a different source. Only `flutter_falconnect`, `flutter_falmodel`, and `flutter_faltool` re-export a `dart_fal*` counterpart, at the tag pinned inside this repository; `flutter_falstore` has none.

`flutter: ">=3.47.0"` (set by `material_ui`; `app_links` and `flutter_local_notifications` need 3.44.0) and Android `compileSdk 37` (set by `flutter_local_notifications`; `app_links` needs 36) are floors, both pulled in through `flutter_falconx`; raise your app's `compileSdk` if it is lower. `flutter_local_notifications` 23 also builds with Android Gradle plugin 9.1.1; use that version or higher in your app.

To build against a local clone, put `dependency_overrides` with `path:` entries in a gitignored `pubspec_overrides.yaml` beside the app's `pubspec.yaml`.

```dart
import 'package:flutter_falconx/flutter_falconx.dart';        // umbrella
import 'package:flutter_falconnect/flutter_falconnect.dart';  // single-package consumers
import 'package:flutter_falmodel/flutter_falmodel.dart';
import 'package:flutter_falstore/flutter_falstore.dart';
import 'package:flutter_faltool/flutter_faltool.dart';
```

## Which package

`flutter_falconx` re-exports the barrels of the four packages below and ships a copy of the skill that each of them ships, plus the skills of their `dart_fal*` counterparts. A project that lists a single package gets that package's skill only; read the skill shipped for the package in the table.

| Need | Package |
|---|---|
| BLoC with Either and stream fetching, behaviour/replay/publish BLoCs, value cubits, form validation, loading/success/fail view builders, lifecycle-aware `State`, `PopResult`, internet reachability BLoC | `flutter_falconx` (this skill) |
| `WidgetDataState<T>`, `FullWidgetState`, `FullWidgetStates`, the `UserFeedback` a state carries | `flutter_falmodel` |
| Connectivity-aware requests, stream/future fetch lifecycle, `NLog` | `flutter_falconnect` |
| Secure key-value storage | `flutter_falstore` |
| Platform detection, stable device id, image compression, logging, re-exported device, share, path, and preference plugins | `flutter_faltool` |
| Re-exported third-party libs: `material_ui`, `flutter_bloc`, `provider`, `bloc_concurrency`, `app_links`, `flutter_local_notifications` | `flutter_falconx` |
| Re-exported third-party libs: `connectivity_plus` | `flutter_falconnect` |
| Re-exported third-party libs: `flutter_secure_storage` | `flutter_falstore` |
| Re-exported third-party libs: `device_info_plus`, `flutter_udid`, `package_info_plus`, `share_plus`, `shared_preferences`, `path_provider`, `leak_tracker`, `rate_limiter`, `restart_app`, `cross_file` | `flutter_faltool` |
| HTTP, WebSocket, JSON-RPC, Retrofit, interceptors | `dart_falconnect` |
| `Result`, exceptions, models, `UserFeedback` | `dart_falmodel` |
| String, DateTime, collection, Future, and Stream extensions; IDs and security helpers | `dart_faltool` |

## Capability map

| Need | Use | Ref |
|---|---|---|
| BLoC with Either and stream fetching | `FalconBloc`, `FalconWidgetDataStateBloc`, `FalconNullableWidgetDataStateBloc` | `references/state.md` |
| Behaviour/replay/publish subjects as BLoC | `BehaviorBloc`, `PublishBloc`, `ReplayBloc` | `references/state.md` |
| Single-value cubits | `BoolCubit`, `IntCubit`, `StringCubit`, `EnumCubit<T>`, `TypeCubit<T>` | `references/state.md` |
| Form validation widgets | `ValidateBuilder`, `DisabledBuilder`, `ValidatorCubit`, `ValidateState<DATA>` | `references/state.md` |
| Loading/success/fail UI from state | `FullWidgetStatesBuilder`, `ContentState<T>`, `NullableContentState<T>`, `FalconApplicationState`, `FalconBlocState` family, `FullWidgetStatesNotifier`, `PopResult` | `references/state.md` |
| Routing | flutter-falconx ships no router today | `references/routing.md` |
| Internet reachability BLoC | `InternetConnectionBloc` | `references/connectivity.md` |
| Third-party libs, free with the import | `material_ui`, `flutter_bloc`, `provider`, `bloc_concurrency`, `app_links`, `flutter_local_notifications` | `references/third-party.md` |

## Do not reinvent

- Before adding a pub dependency, scan the map above, `references/third-party.md`, and the skill shipped for the package that would own it; the third-party table in each skill lists what its package already re-exports.
- When the umbrella import is present, do not also import a library it re-exports; the symbols are already in scope.
- Never `import 'dart:io'` in shared code; these packages target web. Use `PlatformChecker`, `XFile`, or `package:universal_io/io.dart` added to your own pubspec.
- Do not write a router; `flutter_falconx/lib/routers/routers.dart` is empty — see `references/routing.md`.

## Gotchas

- `flutter_falconx` hides `Path` on its `flutter_falconnect` export, `TextDirection` on its `flutter_faltool` export, and `log` on `dart:math`. `Path` is Retrofit's annotation; `TextDirection` is intl's; `log` would collide with `dart:developer`'s. For Retrofit, write `import 'package:retrofit/retrofit.dart' as retrofit;` and use `@retrofit.Path(...)` / `@retrofit.Headers(...)`; an unprefixed import beside the umbrella makes `@Headers` an `ambiguous_import` with dio's. For intl's `TextDirection`, import `package:intl/intl.dart`. For `math.log`, write `import 'dart:math' as math;`. `dart_falconnect`'s auth typedef is `TokenRefreshCallback` since 4.1.0 and is exported.
- `flutter_falconx` exports `package:material_ui/material_ui.dart` (since 5.0.0; before, `package:flutter/material.dart`) and hides `Badge`, `ImageDecoderCallback`, and `Notification` on it, because it also exports `dart:ui` directly: `ImageDecoderCallback` collides with `dart:ui`'s, and `Badge`/`Notification` are hidden so apps using the `badges` package or their own `Notification` model do not hit an ambiguous import. Import `package:material_ui/material_ui.dart` directly with `show Badge` to get Material's. `RefreshCallback` is not hidden; it is ambiguous only in a file that also imports `package:cupertino_ui/cupertino_ui.dart` or the deprecated `package:flutter/cupertino.dart`, so `hide RefreshCallback` on one of them. This is umbrella-only — no non-umbrella package exports `dart:ui` or `material_ui`.
- `material_ui` declares its own copy of every Material class, so its `ThemeData`, `MaterialApp`, and the rest are different types from `package:flutter/material.dart`'s. Migrate an app with `dart fix --apply --code=migrate_design_widgets`; the fix adds `material_ui` to the app's `pubspec.yaml` and a `material_ui` import beside the umbrella import, so remove both unless the app needs `Badge` (then list `material_ui: ^1.11.1`, or `depend_on_referenced_packages` fires). If the app uses `flutter_localizations`, use `GlobalMaterialLocalizations.delegates` from `material_ui`. A third-party widget that still imports `package:flutter/material.dart` reads the legacy theme and localizations, so wrap the app with `MaterialUiCompatibilityBridge(child: child!)` in `MaterialApp.builder`, or wrap that one subtree. The bridge is a temporary, `@Deprecated` `material_ui` utility: add `// ignore: deprecated_member_use` on the line that uses it, and remove it once the dependencies migrate.
- `CompressFormat` is re-exported by `flutter_faltool`, and by the umbrella `flutter_falconx`; pass `format: CompressFormat.png` without importing `flutter_image_compress` when you depend on one of those two. Since 4.0.1 `flutter_falmodel` and `flutter_falstore` no longer chain to `flutter_faltool`, so they no longer carry `CompressFormat`.
- An app that imports a hidden or non-re-exported package directly (`retrofit`, `dart_falconnect`, `flutter_image_compress`, ...) must also list that package in its own `pubspec.yaml`; otherwise `flutter analyze` flags `depend_on_referenced_packages`.
- `flutter_local_notifications` 23 uses named parameters in `initialize()` and `show()`.

## Out of scope

HTTP, WebSocket, JSON-RPC, `Result`, general exceptions, and Dart-only extensions — see the skill shipped for `dart_falconnect`, `dart_falmodel`, and `dart_faltool`.
