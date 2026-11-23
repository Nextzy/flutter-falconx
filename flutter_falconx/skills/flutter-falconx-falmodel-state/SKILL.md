---
name: flutter-falconx-falmodel-state
description: Use when writing or changing widget-state code with flutter_falmodel, including WidgetDataState<T>, FullWidgetState, FullWidgetStates, the UserFeedback a state carries, one-shot WidgetEvent, and conversion between FullWidgetState and Flutter's WidgetState, or before adding a loading/success/fail state holder of your own.
---

# flutter_falmodel state

Answers "does flutter_falmodel already provide this?" here and routes "how do I call it?" to one file under `references/`. `package: flutter_falmodel`; its barrel also re-exports `dart_falmodel`, so `UserFeedback` (`Success`, `Warning`, `Failure`, `Information`), `Result`, and the exceptions come with it; see the skill shipped for `dart_falmodel` (installed with this package).

## Capability map

| Need | Use | Ref |
|---|---|---|
| Widget-state data holder | `WidgetDataState<T>`: `.initial/.loading/.success/.warning/.fail/.cancel/...`, `toLoading/toSuccess/toFail/...`, `copyWith`, `mapData`, `mapState`, `addEvent` | `references/state.md` |
| State enum and state set | `FullWidgetState`, `FullWidgetStates` | `references/state.md` |
| One-shot BLoC-to-widget event | `WidgetDataState.addEvent`, `WidgetEvent` | `references/state.md` |
| User feedback inside a state | `UserFeedback` from `dart_falmodel` | `references/state.md` |
| Flutter `WidgetState` conversion | `FullWidgetState.toWidgetState`, `WidgetState.toFullWidgetState` | `references/state.md` |
| Listen to a state stream | `Stream<WidgetDataState>.listen(onData:, onError:)` (`FalModelStreamResourceExtension`) | `references/state.md` |

## Do not reinvent

- Before writing a loading/success/fail state class, scan the map above.
- The BLoCs, cubits, and builders that emit and render `WidgetDataState` are in `flutter_falconx`; the stream fetchers that produce it are in `flutter_falconnect`. This package holds only the state types.
- Never `import 'dart:io'` in shared code; this package targets web. Use `PlatformChecker` from `flutter_faltool`, `XFile`, or `package:universal_io/io.dart` added to your own pubspec.

## Gotchas

- `copyWith` on `WidgetDataState` never copies `event`; events are one-shot by design. `toState` and the `toX` transitions do not carry it either; `mapData` and `mapState` do.
- `WidgetDataState.warning` defaults `feedback` to `Warning()` and `.fail` to `Failure()`; every other state defaults to `Information()`.
- Importing this package's barrel next to `package:flutter/material.dart` needs no `hide` (4.0.1, verified with the analyzer); its own export chain carries no colliding name.

## Out of scope

`UserFeedback`, `Result`, and exception details (see the skill shipped for `dart_falmodel`), and package internals.
