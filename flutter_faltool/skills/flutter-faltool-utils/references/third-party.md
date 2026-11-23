# Third-party

Every package here reaches your app once you depend on `flutter_faltool`. Do not add a duplicate direct dependency for what it already brings in, and do not pin a different version than the constraint in `flutter_faltool/pubspec.yaml` without checking it resolves against the git-pinned `flutter_faltool`. The libraries that `dart_faltool` brings (`rxdart`, `fpdart`, `intl`, ...) are listed by the skill shipped for that package.

| Package | For | Platform gaps |
|---|---|---|
| `device_info_plus` | Per-OS device metadata for `DeviceIdGenerator` | web returns browser info, not OS device info |
| `flutter_udid` | Stable per-install UDID, part of `DeviceIdGenerator`'s fingerprint | no web implementation — `DeviceIdGenerator` skips it on web |
| `package_info_plus` | App version/build info, backs `PlatformChecker.isChromeOS` | none |
| `share_plus` | OS share sheet | none |
| `shared_preferences` | Local key-value cache; backs `DeviceIdGenerator`'s cached ID | none |
| `path_provider` | Filesystem paths (temp dir for `ImageCompressTool.compressFile`'s non-web output) | no web implementation — `ImageCompressTool` avoids it on web |
| `leak_tracker` | Memory leak detection in debug/test builds | none |
| `rate_limiter` | Debounce/throttle primitives | none |
| `restart_app` | `Restart.restartApp()` relaunches the app; returns `RestartResult` (`success`, `code`, `message`); `Restart.restartCapability()` reports what the platform supports | iOS restarts the Flutter engine only (native process stays) and needs `RestartAppPlugin.configureEngineRestart` in `AppDelegate.swift`; web reloads the page (`webOrigin:` picks the URL) |
| `cross_file` | `XFile`, the cross-platform file handle `ImageCompressTool` takes and returns | none |

## Not re-exported

These are direct or transitive dependencies of `flutter_faltool` but are never `export`ed by its barrel (the one exception is `flutter_image_compress`'s `CompressFormat`) — import them yourself and add them to your own `pubspec.yaml` if you reference their types directly (otherwise `flutter analyze` flags `depend_on_referenced_packages`):

| Package | Why you might import it |
|---|---|
| `flutter_image_compress` | `FlutterImageCompress` and the rest of the plugin API; `CompressFormat` alone is re-exported |
| `ansicolor` | Only used internally by `Log`/`printInfo`/`printError`/`printSuccess`; no public API needs it |
| `image` (`package:image`) | Only used internally by the Dart image-compress engine (Windows/Linux) |
| `path` | Only used internally for filename handling in `ImageCompressTool` |
| `web` (`package:web`) | Only used internally to read the browser's user agent for `PlatformChecker` |
