import 'package:falstore/falstore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mock implementation of FlutterSecureStorage for testing.
class MockFlutterSecureStorage implements FlutterSecureStorage {
  final Map<String, String> _storage = {};
  final bool _shouldThrow;
  
  MockFlutterSecureStorage({bool shouldThrow = false}) : _shouldThrow = shouldThrow;

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (_shouldThrow) {
      throw Exception('Storage write failed');
    }
    if (value != null) {
      _storage[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (_shouldThrow) {
      throw Exception('Storage read failed');
    }
    return _storage[key];
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (_shouldThrow) {
      throw Exception('Storage delete failed');
    }
    _storage.remove(key);
  }

  @override
  Future<Map<String, String>> readAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (_shouldThrow) {
      throw Exception('Storage readAll failed');
    }
    return Map.from(_storage);
  }

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (_shouldThrow) {
      throw Exception('Storage deleteAll failed');
    }
    _storage.clear();
  }

  @override
  Future<bool> containsKey({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (_shouldThrow) {
      throw Exception('Storage containsKey failed');
    }
    return _storage.containsKey(key);
  }

  @override
  IOSOptions get iOptions => const IOSOptions();

  @override
  AndroidOptions get aOptions => const AndroidOptions();

  @override
  LinuxOptions get lOptions => const LinuxOptions();

  @override
  MacOsOptions get mOptions => const MacOsOptions();

  @override
  WindowsOptions get wOptions => const WindowsOptions();

  @override
  WebOptions get webOptions => const WebOptions();

  @override
  Future<bool?> isCupertinoProtectedDataAvailable() async => true;

  @override
  Stream<bool>? get onCupertinoProtectedDataAvailabilityChanged => null;

  @override
  void registerListener({
    required String key,
    required void Function(String?) listener,
  }) {
    // No-op for testing
  }

  @override
  void unregisterListener({
    required String key,
    required void Function(String?) listener,
  }) {
    // No-op for testing
  }

  @override
  void unregisterAllListenersForKey({required String key}) {
    // No-op for testing
  }

  @override
  void unregisterAllListeners() {
    // No-op for testing
  }
}

/// Mock that fails on the second write operation for testing rollback.
class _FailOnSecondWriteMockStorage extends MockFlutterSecureStorage {
  int _writeCount = 0;

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _writeCount++;
    if (_writeCount == 2) {
      throw Exception('Write failed');
    }
    if (value != null) {
      _storage[key] = value;
    }
  }
}

void main() {
  group('SecureStorage', () {
    late MockFlutterSecureStorage mockStorage;
    late SecureStorage secureStorage;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      secureStorage = SecureStorage.testing(storage: mockStorage);
    });

    group('save and load', () {
      test('should save and load string data', () async {
        const key = 'test_key';
        const value = 'test_value';

        await secureStorage.save(key, data: value);
        final loaded = await secureStorage.load(key);

        expect(loaded, equals(value));
      });

      test('should return null for non-existent key', () async {
        final loaded = await secureStorage.load('non_existent');
        expect(loaded, isNull);
      });

      test('should handle empty string', () async {
        const key = 'empty_key';
        const value = '';

        await secureStorage.save(key, data: value);
        final loaded = await secureStorage.load(key);

        expect(loaded, equals(value));
      });
    });

    group('loadSafe', () {
      test('should return stored value when key exists', () async {
        const key = 'existing_key';
        const value = 'stored_value';
        const defaultValue = 'default_value';

        await secureStorage.save(key, data: value);
        final loaded = await secureStorage.loadSafe(key, defaultData: defaultValue);

        expect(loaded, equals(value));
      });

      test('should return default value when key does not exist', () async {
        const key = 'non_existent_key';
        const defaultValue = 'default_value';

        final loaded = await secureStorage.loadSafe(key, defaultData: defaultValue);

        expect(loaded, equals(defaultValue));
      });

      test('should return default value on error', () async {
        final errorStorage = MockFlutterSecureStorage(shouldThrow: true);
        final errorSecureStorage = SecureStorage.testing(storage: errorStorage);
        const defaultValue = 'fallback';

        final loaded = await errorSecureStorage.loadSafe('key', defaultData: defaultValue);

        expect(loaded, equals(defaultValue));
      });
    });

    group('JSON operations', () {
      test('should save and load JSON object', () async {
        const key = 'json_key';
        final data = {
          'name': 'John Doe',
          'age': 30,
          'active': true,
          'tags': ['flutter', 'dart'],
        };

        await secureStorage.saveJson(key, data: data);
        final loaded = await secureStorage.loadJson(key);

        expect(loaded, equals(data));
      });

      test('should handle complex nested JSON', () async {
        const key = 'complex_json';
        final data = {
          'user': {
            'id': 123,
            'profile': {
              'name': 'John',
              'settings': {
                'theme': 'dark',
                'notifications': true,
              },
            },
          },
          'metadata': ['tag1', 'tag2'],
        };

        await secureStorage.saveJson(key, data: data);
        final loaded = await secureStorage.loadJson(key);

        expect(loaded, equals(data));
      });

      test('should return null for non-existent JSON key', () async {
        final loaded = await secureStorage.loadJson('non_existent_json');
        expect(loaded, isNull);
      });

      test('should throw when saving non-JSON-encodable object', () async {
        final nonEncodable = Object();
        
        expect(
          () => secureStorage.saveJson('key', data: nonEncodable),
          throwsA(isA<StorageException>()),
        );
      });
    });

    group('typed JSON operations', () {
      test('should load typed JSON object', () async {
        const key = 'user_key';
        final userData = {'id': 1, 'name': 'Alice', 'email': 'alice@example.com'};

        await secureStorage.saveJson(key, data: userData);
        final user = await secureStorage.loadTyped<Map<String, dynamic>>(
          key,
          fromJson: (json) => json as Map<String, dynamic>,
        );

        expect(user, equals(userData));
      });

      test('should return null for non-existent typed key', () async {
        final user = await secureStorage.loadTyped<String>(
          'non_existent',
          fromJson: (json) => json as String,
        );
        expect(user, isNull);
      });

      test('should throw on type conversion error', () async {
        const key = 'string_key';
        await secureStorage.save(key, data: 'not a map');

        expect(
          () => secureStorage.loadTyped<Map<String, dynamic>>(
            key,
            fromJson: (json) => json as Map<String, dynamic>,
          ),
          throwsA(isA<StorageException>()),
        );
      });
    });

    group('batch operations', () {
      test('should save multiple values', () async {
        final data = {
          'key1': 'value1',
          'key2': 'value2',
          'key3': 'value3',
        };

        await secureStorage.saveMultiple(data);

        for (final entry in data.entries) {
          final loaded = await secureStorage.load(entry.key);
          expect(loaded, equals(entry.value));
        }
      });

      test('should rollback on failure during saveMultiple', () async {
        // Create a storage that fails on the second write
        final customMock = _FailOnSecondWriteMockStorage();
        final customStorage = SecureStorage.testing(storage: customMock);
        final data = {
          'key1': 'value1',
          'key2': 'value2',
          'key3': 'value3',
        };

        expect(
          () => customStorage.saveMultiple(data),
          throwsA(isA<StorageException>()),
        );

        // Verify first key was rolled back
        final value1 = await customStorage.load('key1');
        expect(value1, isNull);
      });

      test('should load multiple values', () async {
        final data = {
          'key1': 'value1',
          'key2': 'value2',
          'key3': 'value3',
        };

        // Save data first
        for (final entry in data.entries) {
          await secureStorage.save(entry.key, data: entry.value);
        }

        final loaded = await secureStorage.loadMultiple(data.keys.toList());
        expect(loaded, equals(data));
      });

      test('should skip non-existent keys in loadMultiple', () async {
        await secureStorage.save('existing', data: 'value');

        final loaded = await secureStorage.loadMultiple(['existing', 'non_existent']);
        
        expect(loaded.length, equals(1));
        expect(loaded['existing'], equals('value'));
        expect(loaded.containsKey('non_existent'), isFalse);
      });
    });

    group('containsKey', () {
      test('should return true for existing key', () async {
        const key = 'existing_key';
        await secureStorage.save(key, data: 'value');

        final exists = await secureStorage.containsKey(key);
        expect(exists, isTrue);
      });

      test('should return false for non-existent key', () async {
        final exists = await secureStorage.containsKey('non_existent');
        expect(exists, isFalse);
      });

      test('should return false on error', () async {
        final errorStorage = MockFlutterSecureStorage(shouldThrow: true);
        final errorSecureStorage = SecureStorage.testing(storage: errorStorage);

        final exists = await errorSecureStorage.containsKey('any_key');
        expect(exists, isFalse);
      });
    });

    group('update', () {
      test('should update existing value', () async {
        const key = 'counter';
        await secureStorage.save(key, data: '5');

        final newValue = await secureStorage.update(
          key,
          updater: (current) {
            final count = int.parse(current ?? '0');
            return (count + 1).toString();
          },
        );

        expect(newValue, equals('6'));
        final stored = await secureStorage.load(key);
        expect(stored, equals('6'));
      });

      test('should create value if not exists', () async {
        const key = 'new_counter';

        final newValue = await secureStorage.update(
          key,
          updater: (current) => current ?? 'initial',
        );

        expect(newValue, equals('initial'));
        final stored = await secureStorage.load(key);
        expect(stored, equals('initial'));
      });
    });

    group('delete operations', () {
      test('should delete specific key', () async {
        const key = 'to_delete';
        await secureStorage.save(key, data: 'value');

        await secureStorage.delete(key: key);

        final loaded = await secureStorage.load(key);
        expect(loaded, isNull);
      });

      test('should delete all keys', () async {
        final data = {
          'key1': 'value1',
          'key2': 'value2',
          'key3': 'value3',
        };

        for (final entry in data.entries) {
          await secureStorage.save(entry.key, data: entry.value);
        }

        await secureStorage.deleteAll();

        for (final key in data.keys) {
          final loaded = await secureStorage.load(key);
          expect(loaded, isNull);
        }
      });

      test('should throw StorageException on delete error', () async {
        final errorStorage = MockFlutterSecureStorage(shouldThrow: true);
        final errorSecureStorage = SecureStorage.testing(storage: errorStorage);

        expect(
          () => errorSecureStorage.delete(key: 'any_key'),
          throwsA(isA<StorageException>()),
        );
      });
    });

    group('loadAll', () {
      test('should load all stored values', () async {
        final data = {
          'key1': 'value1',
          'key2': 'value2',
          'key3': 'value3',
        };

        for (final entry in data.entries) {
          await secureStorage.save(entry.key, data: entry.value);
        }

        final allData = await secureStorage.loadAll();
        expect(allData, equals(data));
      });

      test('should return empty map when no data', () async {
        final allData = await secureStorage.loadAll();
        expect(allData, isEmpty);
      });

      test('should throw StorageException on error', () async {
        final errorStorage = MockFlutterSecureStorage(shouldThrow: true);
        final errorSecureStorage = SecureStorage.testing(storage: errorStorage);

        expect(
          () => errorSecureStorage.loadAll(),
          throwsA(isA<StorageException>()),
        );
      });
    });

    group('error handling', () {
      test('save should throw StorageException on error', () async {
        final errorStorage = MockFlutterSecureStorage(shouldThrow: true);
        final errorSecureStorage = SecureStorage.testing(storage: errorStorage);

        expect(
          () => errorSecureStorage.save('key', data: 'value'),
          throwsA(isA<StorageException>()),
        );
      });

      test('load should throw StorageException on error', () async {
        final errorStorage = MockFlutterSecureStorage(shouldThrow: true);
        final errorSecureStorage = SecureStorage.testing(storage: errorStorage);

        expect(
          () => errorSecureStorage.load('key'),
          throwsA(isA<StorageException>()),
        );
      });

      test('StorageException should include key and original error', () async {
        const key = 'test_key';
        const message = 'Test error';
        final originalError = Exception('Original error');

        final exception = StorageException(
          message,
          key: key,
          originalError: originalError,
        );

        expect(exception.message, equals(message));
        expect(exception.key, equals(key));
        expect(exception.originalError, equals(originalError));
        expect(
          exception.toString(),
          contains('StorageException: $message (key: $key)'),
        );
        expect(exception.toString(), contains('Original error'));
      });
    });
  });
}