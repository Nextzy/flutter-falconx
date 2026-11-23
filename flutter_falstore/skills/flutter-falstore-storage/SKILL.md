---
name: flutter-falstore-storage
description: Use when writing or changing secure key-value storage code with flutter_falstore, including SecureStorage save, load, loadSafe, JSON and batch operations, StorageException handling, and testing with a fake FlutterSecureStorage, or before adding a secure-storage dependency, since it already re-exports flutter_secure_storage.
---

# flutter_falstore storage

Answers "does flutter_falstore already provide this?" here and routes "how do I call it?" to one file under `references/`. `package: flutter_falstore`; its barrel is also where `flutter_secure_storage` comes from.

## Capability map

| Need | Use | Ref |
|---|---|---|
| Secure key-value storage | `SecureStorage.instance.save/load/loadSafe` | `references/storage.md` |
| JSON and typed values | `saveJson`, `loadJson`, `loadTyped<T>` | `references/storage.md` |
| Batch and atomic update | `saveMultiple`, `loadMultiple`, `loadAll`, `update`, `containsKey`, `delete`, `deleteAll` | `references/storage.md` |
| Storage failure | `StorageException` | `references/storage.md` |
| Fake storage in tests | `SecureStorage.testing(storage: ...)` | `references/storage.md` |
| Third-party lib, free with this package | `flutter_secure_storage` | `references/third-party.md` |

## Do not reinvent

- Before adding a pub dependency or writing a storage wrapper, scan the map above and `references/third-party.md`.
- When this package's barrel is imported, do not also import `flutter_secure_storage`; its symbols are already in scope.
- Never `import 'dart:io'` in shared code; this package targets web. Use `PlatformChecker` from `flutter_faltool`, `XFile`, or `package:universal_io/io.dart` added to your own pubspec.

## Gotchas

- `loadSafe` swallows every error and returns `defaultData`; it never throws `StorageException`. Use `load` to tell "not found" from "storage read failed".
- `SecureStorage.testing` is for tests only; production code always uses `SecureStorage.instance`.
- Importing this package's barrel next to `package:material_ui/material_ui.dart` needs no `hide` (5.0.0, verified with the analyzer); its own export chain carries no colliding name.

## Out of scope

General `flutter_secure_storage` usage and package internals.
