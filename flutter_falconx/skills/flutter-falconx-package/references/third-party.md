# Third-party

Every package here reaches your app once you depend on `flutter_falconx`, which also exports all four sibling packages and so everything they bring; each sibling's skill lists its own third-party libraries. Do not add a duplicate direct dependency for what `flutter_falconx` already brings in, and do not pin a different version than the constraint in `flutter_falconx/pubspec.yaml` without checking it resolves against the git-pinned `flutter_fal*` packages.

| Package | For | Platform gaps |
|---|---|---|
| `flutter_bloc` | BLoC/Cubit base classes underlying every state class in `references/state.md` | none |
| `provider` | `context.read`/`context.watch`, used by `FalconBlocState.bloc` | none |
| `bloc_concurrency` | Event transformers (`droppable`, `restartable`, `sequential`, `concurrent`) for `on<EVENT>(..., transformer: ...)` | none |
| `app_links` | Deep link / universal link handling | requires Flutter >=3.44.0; Android needs `compileSdk` 36+ |
| `flutter_local_notifications` | Local push notifications | requires Flutter >=3.38.1; `initialize()`/`show()` use named parameters in v22; Android needs `compileSdk` 36+ |

## Not re-exported

These are direct or transitive dependencies of a `flutter_fal*` package but are never `export`ed by `flutter_falconx` — import them yourself and add them to your own `pubspec.yaml` if you reference their types directly (otherwise `flutter analyze` flags `depend_on_referenced_packages`):

| Package | Why you might import it | Brought in transitively by |
|---|---|---|
| `retrofit` | `@Path` (`flutter_falconx` hides Retrofit's `Path`); `@Headers`, `CacheControl`, and `Parser` (`dart_falconnect` hides all three) | dart_falconnect → flutter_falconnect |
| `flutter_image_compress` | `FlutterImageCompress` and the rest of the plugin API; `CompressFormat` alone is re-exported by `flutter_faltool` | flutter_faltool (only `CompressFormat` exported) |
| `ansicolor`, `image`, `path`, `web` | Only used internally by `flutter_faltool`; no public API needs them | flutter_faltool (never exported) |
