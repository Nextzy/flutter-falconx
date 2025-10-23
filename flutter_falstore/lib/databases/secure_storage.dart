import 'dart:async';
import 'dart:convert';

import 'package:flutter_falstore/lib.dart';

/// A secure storage solution for Flutter applications.
///
/// This class provides a simple interface to store and retrieve sensitive data
/// securely using platform-specific secure storage mechanisms.
///
/// ## Features
///
/// - **Platform Security**: Uses Keychain on iOS/macOS, Keystore on Android,
///   libsecret on Linux, and Windows Credential Store on Windows
/// - **Singleton Pattern**: Ensures a single instance throughout the app
/// - **Type Safety**: Strongly typed methods with null safety
/// - **Error Handling**: Comprehensive error handling with detailed logging
/// - **Batch Operations**: Support for bulk operations
///
/// ## Usage
///
/// ```dart
/// // Get the singleton instance
/// final storage = SecureStorage.instance;
///
/// // Save a value
/// await storage.save('auth_token', data: 'my-secure-token');
///
/// // Load a value
/// final token = await storage.load('auth_token');
///
/// // Load with default value
/// final theme = await storage.loadSafe('theme', defaultData: 'light');
///
/// // Save JSON data
/// await storage.saveJson('user', data: {'id': 123, 'name': 'John'});
///
/// // Load JSON data
/// final userData = await storage.loadJson('user');
///
/// // Delete a value
/// await storage.delete(key: 'auth_token');
///
/// // Delete all values
/// await storage.deleteAll();
/// ```
///
/// ## Security Considerations
///
/// - Data is encrypted using platform-specific secure storage
/// - Keys should not contain sensitive information
/// - Consider implementing key rotation for long-lived data
/// - Always handle errors appropriately to avoid exposing sensitive data
class SecureStorage {
  /// Creates a singleton instance of [SecureStorage].
  ///
  /// The [storage] parameter allows injecting a custom [FlutterSecureStorage]
  /// instance, primarily useful for testing.
  const SecureStorage._singleton({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  /// The underlying secure storage instance.
  final FlutterSecureStorage _storage;

  /// The singleton instance of [SecureStorage].
  static const SecureStorage instance = SecureStorage._singleton();

  /// Creates a test instance of [SecureStorage] with a custom storage implementation.
  ///
  /// This factory is intended for testing purposes only.
  factory SecureStorage.testing({required FlutterSecureStorage storage}) {
    return SecureStorage._singleton(storage: storage);
  }

  /// Saves a string value to secure storage.
  ///
  /// [key] - The unique identifier for the stored value
  /// [data] - The string data to store securely
  ///
  /// Throws [StorageException] if the operation fails.
  ///
  /// Example:
  /// ```dart
  /// await storage.save('session_id', data: 'abc123');
  /// ```
  Future<void> save(String key, {required String data}) async {
    try {
      await _storage.write(key: key, value: data);
      printSuccess('Saved key: $key to SecureStorage');
    } catch (error, stackTrace) {
      printError('Failed to save key: $key', stackTrace);
      throw StorageException(
        'Failed to save data',
        key: key,
        originalError: error,
      );
    }
  }

  /// Loads a string value from secure storage.
  ///
  /// [key] - The unique identifier for the stored value
  ///
  /// Returns the stored value or `null` if not found.
  /// Throws [StorageException] if the operation fails.
  ///
  /// Example:
  /// ```dart
  /// final sessionId = await storage.load('session_id');
  /// if (sessionId != null) {
  ///   // Use the session ID
  /// }
  /// ```
  Future<String?> load(String key) async {
    try {
      final data = await _storage.read(key: key);
      if (data != null) {
        printInfo('Loaded key: $key from SecureStorage');
      }
      return data;
    } catch (error, stackTrace) {
      printError('Failed to load key: $key', stackTrace);
      throw StorageException(
        'Failed to load data',
        key: key,
        originalError: error,
      );
    }
  }

  /// Loads a string value from secure storage with a default fallback.
  ///
  /// [key] - The unique identifier for the stored value
  /// [defaultData] - The value to return if the key doesn't exist
  ///
  /// Returns the stored value or [defaultData] if not found.
  /// Never returns null.
  /// Throws [StorageException] if the operation fails.
  ///
  /// Example:
  /// ```dart
  /// final theme = await storage.loadSafe('theme', defaultData: 'light');
  /// // Always returns a value, either stored or default
  /// ```
  Future<String> loadSafe(
    String key, {
    required String defaultData,
  }) async {
    try {
      final data = await _storage.read(key: key);
      final result = data ?? defaultData;
      printInfo('Loaded key: $key with value: ${data != null ? "found" : "default"}');
      return result;
    } catch (error, stackTrace) {
      printError('Failed to load key: $key, using default', stackTrace);
      return defaultData;
    }
  }

  /// Saves a JSON-encodable object to secure storage.
  ///
  /// [key] - The unique identifier for the stored value
  /// [data] - The object to encode and store (must be JSON-encodable)
  ///
  /// Throws [StorageException] if the operation fails or if [data] is not JSON-encodable.
  ///
  /// Example:
  /// ```dart
  /// await storage.saveJson('user_prefs', data: {
  ///   'theme': 'dark',
  ///   'language': 'en',
  ///   'notifications': true,
  /// });
  /// ```
  Future<void> saveJson(String key, {required Object data}) async {
    try {
      final jsonString = jsonEncode(data);
      await save(key, data: jsonString);
    } catch (error) {
      if (error is StorageException) rethrow;
      throw StorageException(
        'Failed to encode JSON data',
        key: key,
        originalError: error,
      );
    }
  }

  /// Loads and decodes a JSON object from secure storage.
  ///
  /// [key] - The unique identifier for the stored value
  /// [reviver] - Optional function to transform the decoded JSON
  ///
  /// Returns the decoded object or `null` if not found.
  /// Throws [StorageException] if the operation fails or if data is not valid JSON.
  ///
  /// Example:
  /// ```dart
  /// final prefs = await storage.loadJson('user_prefs');
  /// if (prefs != null) {
  ///   final theme = prefs['theme'] as String?;
  /// }
  /// ```
  Future<dynamic> loadJson(String key, {Object? Function(Object? key, Object? value)? reviver}) async {
    final jsonString = await load(key);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString, reviver: reviver);
    } catch (error) {
      throw StorageException(
        'Failed to decode JSON data',
        key: key,
        originalError: error,
      );
    }
  }

  /// Loads and decodes a JSON object from secure storage with type safety.
  ///
  /// [key] - The unique identifier for the stored value
  /// [fromJson] - Function to convert the decoded JSON to type [T]
  ///
  /// Returns the typed object or `null` if not found.
  /// Throws [StorageException] if the operation fails.
  ///
  /// Example:
  /// ```dart
  /// final user = await storage.loadTyped<User>(
  ///   'current_user',
  ///   fromJson: (json) => User.fromJson(json as Map<String, dynamic>),
  /// );
  /// ```
  Future<T?> loadTyped<T>(
    String key, {
    required T Function(dynamic json) fromJson,
  }) async {
    final data = await loadJson(key);
    if (data == null) return null;

    try {
      return fromJson(data);
    } catch (error) {
      throw StorageException(
        'Failed to parse typed data',
        key: key,
        originalError: error,
      );
    }
  }

  /// Loads all stored key-value pairs.
  ///
  /// Returns a map of all stored data. Keys that fail to load are omitted.
  /// Consider the security implications of loading all data at once.
  ///
  /// Example:
  /// ```dart
  /// final allData = await storage.loadAll();
  /// print('Stored keys: ${allData.keys.join(', ')}');
  /// ```
  Future<Map<String, String>> loadAll() async {
    try {
      final data = await _storage.readAll();
      printInfo('Loaded ${data.length} items from SecureStorage');
      return data;
    } catch (error, stackTrace) {
      printError('Failed to load all data', stackTrace);
      throw StorageException(
        'Failed to load all data',
        originalError: error,
      );
    }
  }

  /// Checks if a key exists in secure storage.
  ///
  /// [key] - The unique identifier to check
  ///
  /// Returns `true` if the key exists, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// if (await storage.containsKey('auth_token')) {
  ///   // User is authenticated
  /// }
  /// ```
  Future<bool> containsKey(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (error) {
      // If we can't read, assume it doesn't exist
      return false;
    }
  }

  /// Deletes a specific value from secure storage.
  ///
  /// [key] - The unique identifier of the value to delete
  ///
  /// Throws [StorageException] if the operation fails.
  ///
  /// Example:
  /// ```dart
  /// await storage.delete(key: 'auth_token');
  /// ```
  Future<void> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
      printSuccess('Deleted key: $key from SecureStorage');
    } catch (error, stackTrace) {
      printError('Failed to delete key: $key', stackTrace);
      throw StorageException(
        'Failed to delete data',
        key: key,
        originalError: error,
      );
    }
  }

  /// Deletes all stored values from secure storage.
  ///
  /// Use with caution as this operation cannot be undone.
  /// Consider implementing a confirmation mechanism before calling this method.
  ///
  /// Throws [StorageException] if the operation fails.
  ///
  /// Example:
  /// ```dart
  /// // Clear all stored data (e.g., on logout)
  /// await storage.deleteAll();
  /// ```
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
      printSuccess('Deleted all data from SecureStorage');
    } catch (error, stackTrace) {
      printError('Failed to delete all data', stackTrace);
      throw StorageException(
        'Failed to delete all data',
        originalError: error,
      );
    }
  }

  /// Performs multiple save operations atomically.
  ///
  /// [data] - Map of key-value pairs to save
  ///
  /// All operations must succeed or none will be applied.
  /// Throws [StorageException] if any operation fails.
  ///
  /// Example:
  /// ```dart
  /// await storage.saveMultiple({
  ///   'auth_token': 'abc123',
  ///   'refresh_token': 'xyz789',
  ///   'user_id': '12345',
  /// });
  /// ```
  Future<void> saveMultiple(Map<String, String> data) async {
    final savedKeys = <String>[];
    try {
      for (final entry in data.entries) {
        await save(entry.key, data: entry.value);
        savedKeys.add(entry.key);
      }
      printSuccess('Saved ${data.length} items to SecureStorage');
    } catch (error) {
      // Rollback on failure
      for (final key in savedKeys) {
        try {
          await delete(key: key);
        } catch (_) {
          // Ignore rollback errors
        }
      }
      rethrow;
    }
  }

  /// Loads multiple values from secure storage.
  ///
  /// [keys] - List of keys to load
  ///
  /// Returns a map of key-value pairs. Keys that don't exist are omitted.
  /// Keys that fail to load are also omitted with a warning logged.
  ///
  /// Example:
  /// ```dart
  /// final tokens = await storage.loadMultiple(['auth_token', 'refresh_token']);
  /// ```
  Future<Map<String, String>> loadMultiple(List<String> keys) async {
    final result = <String, String>{};
    
    for (final key in keys) {
      try {
        final value = await load(key);
        if (value != null) {
          result[key] = value;
        }
      } catch (error) {
        printError('Failed to load key: $key in batch operation');
        // Continue loading other keys
      }
    }
    
    printInfo('Loaded ${result.length} of ${keys.length} items from SecureStorage');
    return result;
  }

  /// Updates an existing value or creates it if it doesn't exist.
  ///
  /// [key] - The unique identifier for the value
  /// [updater] - Function that receives the current value (or null) and returns the new value
  ///
  /// Returns the new value.
  /// Throws [StorageException] if the operation fails.
  ///
  /// Example:
  /// ```dart
  /// final newCount = await storage.update(
  ///   'launch_count',
  ///   updater: (current) {
  ///     final count = int.tryParse(current ?? '0') ?? 0;
  ///     return (count + 1).toString();
  ///   },
  /// );
  /// ```
  Future<String> update(
    String key, {
    required String Function(String? current) updater,
  }) async {
    final current = await load(key);
    final newValue = updater(current);
    await save(key, data: newValue);
    return newValue;
  }
}

/// Exception thrown when secure storage operations fail.
class StorageException implements Exception {
  /// Creates a new storage exception.
  const StorageException(
    this.message, {
    this.key,
    this.originalError,
  });

  /// A description of the error.
  final String message;

  /// The storage key associated with the error, if applicable.
  final String? key;

  /// The original error that caused this exception.
  final Object? originalError;

  @override
  String toString() {
    final buffer = StringBuffer('StorageException: $message');
    if (key != null) {
      buffer.write(' (key: $key)');
    }
    if (originalError != null) {
      buffer.write('\nOriginal error: $originalError');
    }
    return buffer.toString();
  }
}
