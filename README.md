# flutter-falconx

Flutter packages for BLoC state management, network requests, view state, secure storage, and everyday tools. They build on [dart-falconx](https://github.com/Nextzy/dart-falconx) and run on Android, iOS, macOS, Windows, Linux, and web.

## Packages

- `flutter_falconx`: umbrella package. It re-exports the four packages below, so one import covers them all.
- `flutter_falconnect`: Dio, Retrofit, and WebSocket engine, connectivity handling, and stream fetchers.
- `flutter_falmodel`: `WidgetDataState<T>` and its extensions.
- `flutter_falstore`: `SecureStorage` over `flutter_secure_storage`.
- `flutter_faltool`: `PlatformChecker`, `DeviceIdGenerator`, `ImageCompressTool`, logging, and re-exported plugins.

Each package depends only on the packages below it, so you can list any of them on its own. `flutter_falconnect`, `flutter_falmodel`, and `flutter_falstore` do not re-export their siblings: list and import every package you use, or depend on `flutter_falconx` alone.

## Add a dependency

The packages are not on pub.dev. Add them as git dependencies in `pubspec.yaml`:

```yaml
dependencies:
  flutter_falconx:                   # or only flutter_falconnect / flutter_falmodel / flutter_falstore / flutter_faltool
    git:
      url: https://github.com/Nextzy/flutter-falconx
      ref: <version>                 # the release tag you want
      path: flutter_falconx
environment:
  sdk: ">=3.13.0 <4.0.0"
  flutter: ">=3.47.0"                # when you list flutter_falconx; the other packages do not raise it
```

Use the same `ref` for every falconx package you list, and copy the `url` exactly. Android apps need `compileSdk` 37 or higher. Only `flutter_falconx` brings `material_ui`, so only an app that lists it needs Flutter 3.47.0 or higher.

Then run:

```sh
flutter pub get
```

`flutter_falconx` exports `material_ui` instead of `package:flutter/material.dart`. To switch an app over, run `dart fix --apply --code=migrate_design_widgets`; the Breaking section of `CHANGELOG.md` covers third-party packages that still use the old library.

## Agent skills

Each package ships agent skills that tell a coding agent which falconx package to use and how to call it. They install with the Dart [`skills`](https://pub.dev/packages/skills) CLI. The CLI scans only the packages your `pubspec.yaml` lists in `dependencies` or `dev_dependencies`, so you get the skills of the packages you list.

Run this from your project:

```sh
dart run skills@ get
```

Add `--all` to install every skill without prompting.

If you copied `flutter-falconx-package` into `.claude/skills/` by hand and your app lists `flutter_falconx`, `dart run skills@ get` replaces that copy for Claude. Otherwise, or for another agent, delete `.claude/skills/flutter-falconx-package/` first, then run `get`.

| Package you list      | Skills you get |
|-----------------------|----------------|
| `flutter_falconx`     | `flutter-falconx-package`, `flutter-falconx-falconnect-network`, `flutter-falconx-falmodel-state`, `flutter-falconx-falstore-storage`, `flutter-falconx-faltool-utils`, `flutter-falconx-dart-falconnect-network`, `flutter-falconx-dart-falmodel-models`, `flutter-falconx-dart-faltool-utils` |
| `flutter_falconnect`  | `flutter-falconnect-network`, `flutter-falconnect-dart-falconnect-network` |
| `flutter_falmodel`    | `flutter-falmodel-state`, `flutter-falmodel-dart-falmodel-models` |
| `flutter_falstore`    | `flutter-falstore-storage` |
| `flutter_faltool`     | `flutter-faltool-utils`, `flutter-faltool-dart-faltool-utils` |

The `flutter_falconx` skills include generated copies of the other four skills and of the three `dart_fal*` skills, because the CLI does not follow transitive dependencies. The `dart_fal*` skills come from dart-falconx at the version each package pins.
