# Third-party

Every package here reaches your app already, re-exported by whichever `flutter_fal*` package brings it in — do not add a duplicate direct dependency, and do not pin a different version than the one below without checking it resolves against the git-pinned `flutter_fal*` packages.

| Package | Version constraint | Brought in by | For | Platform gaps |
|---|---|---|---|---|
| `flutter_bloc` | `^9.1.1` | flutter_falconx | BLoC/Cubit base classes underlying every state class in `references/state.md` | none |
| `provider` | `^6.1.5+1` | flutter_falconx | `context.read`/`context.watch`, used by `FalconBlocState.bloc` | none |
| `bloc_concurrency` | `^0.3.0` | flutter_falconx | Event transformers (`droppable`, `restartable`, `sequential`, `concurrent`) for `on<EVENT>(..., transformer: ...)` | none |
| `app_links` | `^7.2.1` | flutter_falconx | Deep link / universal link handling | sets this repo's `flutter: ">=3.44.0"` floor |
| `flutter_local_notifications` | `^22.3.1` | flutter_falconx | Local push notifications | `initialize()`/`show()` use named parameters in v22; Android needs `compileSdk 36`+ |
| `connectivity_plus` | `^7.0.0` | flutter_falconnect | Connectivity type stream backing `ConnectivityInterceptor` and `InternetConnectionBloc` | none |
| `flutter_secure_storage` | `^11.2.0` | flutter_falstore | Platform-native secure storage backing `SecureStorage` | web uses encrypted IndexedDB, not the Keychain/Keystore path |
| `device_info_plus` | `^13.2.0` | flutter_faltool | Per-OS device metadata for `DeviceIdGenerator` | web returns browser info, not OS device info |
| `flutter_udid` | `^4.1.6` | flutter_faltool | Stable per-install UDID, part of `DeviceIdGenerator`'s fingerprint | no web implementation — `DeviceIdGenerator` skips it on web |
| `package_info_plus` | `^10.2.1` | flutter_faltool | App version/build info, backs `FalconState.currentVersion` and `PlatformChecker.isChromeOS` | none |
| `share_plus` | `^13.3.0` | flutter_faltool | OS share sheet | none |
| `shared_preferences` | `^2.5.5` | flutter_faltool | Local key-value cache; backs `DeviceIdGenerator`'s cached ID | none |
| `path_provider` | `^2.1.6` | flutter_faltool | Filesystem paths (temp dir for `ImageCompressTool.compressFile`'s non-web output) | no web implementation — `ImageCompressTool` avoids it on web |
| `leak_tracker` | `^11.0.2` | flutter_faltool | Memory leak detection in debug/test builds | none |
| `rate_limiter` | `^1.1.1` | flutter_faltool | Debounce/throttle primitives | none |
| `cross_file` | `^0.3.5+5` | flutter_faltool | `XFile`, the cross-platform file handle `ImageCompressTool` takes and returns | none |

## Not re-exported

These are direct or transitive dependencies of a `flutter_fal*` package but are never `export`ed by any barrel (the one exception is `flutter_image_compress`'s `CompressFormat`) — import them yourself and add them to your own `pubspec.yaml` if you reference their types directly (otherwise `flutter analyze` flags `depend_on_referenced_packages`):

| Package | Why you might import it | Brought in transitively by |
|---|---|---|
| `retrofit` | `@Path`, `@Headers`, `@noToken` annotations (`flutter_falconx` hides Retrofit's `Path`) | dart_falconnect → flutter_falconnect |
| `dart_falconnect` | `RefreshCallback` typedef (hidden by `flutter_falconx`'s `flutter_falconnect` export) | flutter_falconnect |
| `flutter_image_compress` | `FlutterImageCompress` and the rest of the plugin API; `CompressFormat` alone is re-exported by `flutter_faltool` | flutter_faltool (only `CompressFormat` exported) |
| `ansicolor` | Only used internally by `Log`/`printInfo`/`printError`/`printSuccess`; no public API needs it | flutter_faltool (never exported) |
| `image` (`package:image`) | Only used internally by the Dart image-compress engine (Windows/Linux) | flutter_faltool (never exported) |
| `path` | Only used internally for filename handling in `ImageCompressTool` | flutter_faltool (never exported) |
| `web` (`package:web`) | Only used internally to read the browser's user agent for `PlatformChecker` | flutter_faltool (never exported) |
