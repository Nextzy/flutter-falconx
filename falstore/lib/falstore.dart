/// FalStore - Secure storage solution for Flutter applications.
///
/// This library provides a simple and secure way to store sensitive data
/// in Flutter applications using platform-specific secure storage mechanisms.
///
/// ## Features
///
/// - **Secure Storage**: Uses platform-specific secure storage (Keychain on iOS, Keystore on Android)
/// - **Simple API**: Easy-to-use methods for storing and retrieving data
/// - **Type Safety**: Strongly typed methods ensure data integrity
/// - **Singleton Pattern**: Efficient resource usage with singleton instance
///
/// ## Getting Started
///
/// ```dart
/// import 'package:falstore/falstore.dart';
///
/// // Save data
/// await SecureStorage.instance.save('token', data: 'my-secret-token');
///
/// // Load data
/// final token = await SecureStorage.instance.load('token');
///
/// // Load with default value
/// final theme = await SecureStorage.instance.loadSafe(
///   'theme',
///   defaultData: 'light',
/// );
/// ```
///
/// ## Platform Support
///
/// - ✅ iOS (Keychain)
/// - ✅ Android (Keystore)
/// - ✅ Linux (libsecret)
/// - ✅ macOS (Keychain)
/// - ✅ Windows (Windows Credential Store)
/// - ✅ Web (IndexedDB with encryption)
library falstore;

export 'databases/databases.dart';
