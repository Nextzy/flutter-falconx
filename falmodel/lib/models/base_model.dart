import 'package:falmodel/lib.dart';

/// Base class for all data models in the application.
/// 
/// Provides common functionality including:
/// - Equality comparison through [EquatableMixin]
/// - String representation with [stringify]
/// - Immutable updates through [copyWith]
/// 
/// Example:
/// ```dart
/// class User extends BaseModel<User> {
///   const User({required this.name, required this.email});
///   
///   final String name;
///   final String email;
///   
///   @override
///   User copyWith({String? name, String? email}) {
///     return User(
///       name: name ?? this.name,
///       email: email ?? this.email,
///     );
///   }
///   
///   @override
///   List<Object?> get props => [name, email];
/// }
/// ```
abstract class BaseModel<T> with EquatableMixin {
  /// Creates a base model instance.
  const BaseModel();

  /// Enables automatic string representation for debugging.
  @override
  bool? get stringify => true;

  /// Creates a copy of this model with updated fields.
  /// 
  /// Subclasses should implement this method to support immutable updates.
  /// The method should accept optional parameters for each field that can be updated.
  T copyWith();
}
