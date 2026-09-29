# Storage

`package: flutter_falstore` (re-exports `flutter_secure_storage`). Platform-native secure storage: Keychain (iOS/macOS), Keystore (Android), libsecret (Linux), Credential Store (Windows), encrypted IndexedDB (web).

## `SecureStorage`

Singleton; every method wraps `flutter_secure_storage` with logging and throws `StorageException` on failure (except `loadSafe`, which falls back to `defaultData` instead of throwing).

```dart
class SecureStorage {
  static const SecureStorage instance;
  factory SecureStorage.testing({required FlutterSecureStorage storage}); // inject a fake for tests

  Future<void> save(String key, {required String data});
  Future<String?> load(String key);
  Future<String> loadSafe(String key, {required String defaultData}); // never throws, never returns null

  Future<void> saveJson(String key, {required Object data});
  Future<dynamic> loadJson(String key, {Object? Function(Object? key, Object? value)? reviver});
  Future<T?> loadTyped<T>(String key, {required T Function(dynamic json) fromJson});

  Future<Map<String, String>> loadAll();
  Future<bool> containsKey(String key);
  Future<void> delete({required String key});
  Future<void> deleteAll();

  Future<void> saveMultiple(Map<String, String> data);            // rolls back all keys on partial failure
  Future<Map<String, String>> loadMultiple(List<String> keys);    // omits keys that fail to load, does not throw
  Future<String> update(String key, {required String Function(String? current) updater});
}
```

```dart
await SecureStorage.instance.save('auth_token', data: token);
final token = await SecureStorage.instance.load('auth_token');
final theme = await SecureStorage.instance.loadSafe('theme', defaultData: 'light');

await SecureStorage.instance.saveJson('user_prefs', data: {'theme': 'dark', 'notifications': true});
final user = await SecureStorage.instance.loadTyped<User>(
  'current_user',
  fromJson: (json) => User.fromJson(json as Map<String, dynamic>),
);

await SecureStorage.instance.deleteAll(); // e.g. on logout
```

## `StorageException`

```dart
class StorageException implements Exception {
  const StorageException(String message, {String? key, Object? originalError});
  String get message;
  String? get key;
  Object? get originalError;
}
```

## Gotchas

- `loadSafe` swallows every error and returns `defaultData`; it never throws `StorageException`. Use `load` when you need to distinguish "not found" from "storage read failed".
- `saveMultiple` rolls back by deleting the keys it already wrote if a later key fails — it does not restore their previous values, only removes the partial write.
- `SecureStorage.testing` is for tests only; production code always uses `SecureStorage.instance`.
