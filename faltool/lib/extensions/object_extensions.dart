import 'package:faltool/lib.dart';

/// Extension methods for nullable objects with enhanced functionality.
///
/// Provides comprehensive utilities for nullable object operations including
/// safe transformations, conditional execution, and type conversions.
extension FalconToolNullableObject<T> on T? {
  /// Executes a function if the object is not null.
  ///
  /// This method is now provided by dartx package.
  /// Use: object.let((value) => action)
  ///
  /// This is similar to Kotlin's `let` function, providing a safe way
  /// to work with nullable values.
  ///
  /// Example:
  /// ```dart
  /// String? name = getName();
  /// name.let((value) => print('Hello, $value'));
  /// ```
  void let(void Function(T data) let) {
    final data = this;
    if (data != null) let(data);
  }

  /// Transforms the value if not null, otherwise returns null.
  ///
  /// Example:
  /// ```dart
  /// String? name = getName();
  /// int? length = name.map((value) => value.length);
  /// ```
  R? map<R>(R Function(T value) transform) {
    final value = this;
    if (value != null) {
      return transform(value);
    }
    return null;
  }

  /// Transforms the value if not null, otherwise returns a default value.
  ///
  /// Example:
  /// ```dart
  /// String? name = getName();
  /// int length = name.mapOr((value) => value.length, 0);
  /// ```
  R mapOr<R>(R Function(T value) transform, R defaultValue) {
    final value = this;
    if (value != null) {
      return transform(value);
    }
    return defaultValue;
  }

  /// Transforms the value if not null, otherwise calls a default function.
  ///
  /// Example:
  /// ```dart
  /// String? name = getName();
  /// String message = name.mapOrElse(
  ///   (value) => 'Hello, $value',
  ///   () => 'Hello, guest',
  /// );
  /// ```
  R mapOrElse<R>(R Function(T value) transform, R Function() orElse) {
    final value = this;
    if (value != null) {
      return transform(value);
    }
    return orElse();
  }

  /// Returns the value if not null, otherwise returns the default value.
  ///
  /// Example:
  /// ```dart
  /// String? name = getName();
  /// String displayName = name.orDefault('Anonymous');
  /// ```
  T orDefault(T defaultValue) {
    return this ?? defaultValue;
  }

  /// Returns the value if not null, otherwise calls a function to get the
  /// default.
  ///
  /// Example:
  /// ```dart
  /// String? cachedName;
  /// String name = cachedName.orElse(() => fetchNameFromDatabase());
  /// ```
  T orElse(T Function() defaultProvider) {
    return this ?? defaultProvider();
  }

  /// Returns the value if not null and satisfies the predicate, otherwise null.
  ///
  /// This method is now provided by dartx package.
  /// Use: object.takeIf((value) => condition)
  ///
  /// Example:
  /// ```dart
  /// int? age = getAge();
  /// int? adultAge = age.takeIf((value) => value >= 18);
  /// ```
  T? takeIf(bool Function(T value) predicate) {
    final value = this;
    if (value != null && predicate(value)) {
      return value;
    }
    return null;
  }

  /// Returns the value if not null and doesn't satisfy the predicate,
  /// otherwise null.
  ///
  /// This method is now provided by dartx package.
  /// Use: object.takeUnless((value) => condition)
  ///
  /// Example:
  /// ```dart
  /// String? input = getUserInput();
  /// String? validInput = input.takeUnless((value) => value.isEmpty);
  /// ```
  T? takeUnless(bool Function(T value) predicate) {
    final value = this;
    if (value != null && !predicate(value)) {
      return value;
    }
    return null;
  }

  /// Executes one of two functions based on whether the value is null.
  ///
  /// Example:
  /// ```dart
  /// String? name = getName();
  /// name.fold(
  ///   onNull: () => print('No name provided'),
  ///   onValue: (value) => print('Hello, $value'),
  /// );
  /// ```
  void fold({
    required void Function() onNull,
    required void Function(T value) onValue,
  }) {
    final value = this;
    if (value != null) {
      onValue(value);
    } else {
      onNull();
    }
  }

  /// Transforms to one of two values based on whether this is null.
  ///
  /// Example:
  /// ```dart
  /// String? name = getName();
  /// String message = name.match(
  ///   onNull: () => 'Hello, guest',
  ///   onValue: (value) => 'Hello, $value',
  /// );
  /// ```
  R match<R>({
    required R Function() onNull,
    required R Function(T value) onValue,
  }) {
    final value = this;
    if (value != null) {
      return onValue(value);
    } else {
      return onNull();
    }
  }

  /// Chains multiple nullable operations.
  ///
  /// Example:
  /// ```dart
  /// String? firstName = getFirstName();
  /// String? upperName = firstName
  ///     .chain((name) => name.isNotEmpty ? name : null)
  ///     .chain((name) => name.toUpperCase());
  /// ```
  R? chain<R>(R? Function(T value) transform) {
    final value = this;
    if (value != null) {
      return transform(value);
    }
    return null;
  }

  /// Checks if the value is null.
  ///
  /// Example:
  /// ```dart
  /// String? name = getName();
  /// if (name.isNull) {
  ///   print('Name is not provided');
  /// }
  /// ```
  bool get isNull => this == null;

  /// Checks if the value is not null.
  ///
  /// Example:
  /// ```dart
  /// String? name = getName();
  /// if (name.isNotNull) {
  ///   print('Name is: $name');
  /// }
  /// ```
  bool get isNotNull => this != null;

  /// Converts the nullable value to a Future.
  ///
  /// Example:
  /// ```dart
  /// String? cachedValue = cache.get('key');
  /// Future<String?> futureValue = cachedValue.toFuture();
  /// ```
  Future<T?> toFuture() => Future.value(this);

  /// Converts the nullable value to a successful Future or a failed one
  /// if null.
  ///
  /// Example:
  /// ```dart
  /// String? token = getAuthToken();
  /// Future<String> authFuture = token.toFutureOr(
  ///   () => Exception('Not authenticated'),
  /// );
  /// ```
  Future<T> toFutureOr(Object Function() errorProvider) {
    final value = this;
    if (value != null) {
      return Future.value(value);
    }
    return Future.error(errorProvider());
  }
}

/// Extension methods for non-nullable objects.
extension FalconToolObject<T> on T {
  /// Allows chaining operations on the object.
  ///
  /// Similar to Kotlin's `also` function.
  ///
  /// Example:
  /// ```dart
  /// final user = User('John')
  ///     .also((user) => user.age = 30)
  ///     .also((user) => user.email = 'john@example.com');
  /// ```
  T also(void Function(T value) action) {
    action(this);
    return this;
  }

  /// Transforms the object and returns the result.
  ///
  /// Similar to Kotlin's `let` function for non-null values.
  ///
  /// Example:
  /// ```dart
  /// final length = 'Hello'.run((str) => str.length);
  /// ```
  R run<R>(R Function(T value) transform) {
    return transform(this);
  }

  /// Conditionally transforms the object.
  ///
  /// Example:
  /// ```dart
  /// final number = 5
  ///     .applyIf(true, (n) => n * 2)
  ///     .applyIf(false, (n) => n + 10); // Result: 10
  /// ```
  T applyIf(bool condition, T Function(T value) transform) {
    if (condition) {
      return transform(this);
    }
    return this;
  }

  /// Conditionally transforms the object with a lazy condition.
  ///
  /// Example:
  /// ```dart
  /// final config = loadConfig()
  ///     .applyIfLazy(
  ///       () => isDevelopment(),
  ///       (cfg) => cfg.withDebugMode(),
  ///     );
  /// ```
  T applyIfLazy(bool Function() condition, T Function(T value) transform) {
    if (condition()) {
      return transform(this);
    }
    return this;
  }

  /// Wraps the value in a list.
  ///
  /// Example:
  /// ```dart
  /// final numbers = 42.asList(); // [42]
  /// ```
  List<T> asList() => [this];

  /// Wraps the value in a set.
  ///
  /// Example:
  /// ```dart
  /// final uniqueNumbers = 42.asSet(); // {42}
  /// ```
  Set<T> asSet() => {this};

  /// Wraps the value in a Future.
  ///
  /// Example:
  /// ```dart
  /// final futureValue = 'Hello'.asFuture();
  /// ```
  Future<T> asFuture() => Future.value(this);

  /// Wraps the value in a Stream.
  ///
  /// Example:
  /// ```dart
  /// final stream = 'Hello'.asStream();
  /// ```
  Stream<T> asStream() => Stream.value(this);

  /// Checks if this object is equal to any of the provided values.
  ///
  /// Example:
  /// ```dart
  /// final status = 'active';
  /// if (status.isIn(['active', 'pending'])) {
  ///   print('Status is valid');
  /// }
  /// ```
  bool isIn(Iterable<T> values) => values.contains(this);

  /// Checks if this object is not equal to any of the provided values.
  ///
  /// Example:
  /// ```dart
  /// final status = 'deleted';
  /// if (status.isNotIn(['active', 'pending'])) {
  ///   print('Status is not valid');
  /// }
  /// ```
  bool isNotIn(Iterable<T> values) => !values.contains(this);
}
