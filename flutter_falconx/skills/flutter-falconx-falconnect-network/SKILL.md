---
name: flutter-falconx-falconnect-network
description: Use when writing or changing network code with flutter_falconnect, including ConnectivityInterceptor on a Dio client, EitherStreamFetcher and EitherStreamFetcherList stream and future fetching that emits WidgetDataState, and NLog, or before adding a connectivity dependency, since it already re-exports connectivity_plus and dart_falconnect.
---

# flutter_falconnect network

Answers "does flutter_falconnect already provide this?" here and routes "how do I call it?" to one file under `references/`. `package: flutter_falconnect`; its barrel is also where `connectivity_plus` and `dart_falconnect` come from. HTTP, WebSocket, JSON-RPC, Retrofit and Dio clients, interceptors, and exceptions belong to `dart_falconnect`; see the skill shipped for `dart_falconnect` (installed with this package).

## Capability map

| Need | Use | Ref |
|---|---|---|
| Reject requests while offline | `ConnectivityInterceptor` added to a Dio client's interceptors | `references/network.md` |
| Stream/future fetch lifecycle with loading, success, fail states | `EitherStreamFetcher<T>`, `EitherStreamFetcherList` (emit `WidgetDataState` from `flutter_falmodel`) | `references/network.md` |
| Boxed console logging for network code | `NLog.i/e` | `references/network.md` |
| Third-party lib, free with this package | `connectivity_plus` | `references/third-party.md` |

## Do not reinvent

- Before adding a pub dependency or writing a connectivity check, scan the map above and `references/third-party.md`.
- When this package's barrel is imported, do not also import `connectivity_plus` or any library `dart_falconnect` re-exports; the symbols are already in scope.
- Never `import 'dart:io'` in shared code; this package targets web. Use `PlatformChecker` from `flutter_faltool`, `XFile`, or `package:universal_io/io.dart` added to your own pubspec.

## Gotchas

- `ConnectivityInterceptor` checks connectivity per request; it does not cache the result. For a continuous connectivity stream for UI banners, use `InternetConnectionBloc` from `flutter_falconx`.
- Importing this package's barrel next to `package:flutter/material.dart` (4.0.1, re-derived with the analyzer): `hide Path` on the import — Retrofit's `@Path` silently shadows `dart:ui`'s without an analyzer error, so `Path()..moveTo(...)` fails with `undefined_method` instead.
- Since 4.0.1 this package no longer re-exports `flutter_falmodel`, which supplies `WidgetDataState<T?>`, the state type `EitherStreamFetcher` returns.
- An app that imports a package this barrel does not re-export (`dart_falmodel`, ...) must also list that package in its own `pubspec.yaml`; otherwise `flutter analyze` flags `depend_on_referenced_packages`.

## Out of scope

HTTP, WebSocket, JSON-RPC, `Result`, and general exceptions (see the skill shipped for `dart_falconnect`), and package internals.
