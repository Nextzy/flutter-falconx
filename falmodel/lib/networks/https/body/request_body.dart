import 'package:falmodel/lib.dart';

/// Base class for HTTP request bodies.
/// 
/// Provides a common interface for all request bodies that need to be
/// serialized to JSON for HTTP POST/PUT/PATCH operations.
/// 
/// Example:
/// ```dart
/// class LoginRequestBody extends BaseRequestBody {
///   const LoginRequestBody({
///     required this.email,
///     required this.password,
///   });
///   
///   final String email;
///   final String password;
///   
///   @override
///   Map<String, Object?> toJson() => {
///     'email': email,
///     'password': password,
///   };
///   
///   @override
///   List<Object?> get props => [email, password];
/// }
/// ```
abstract class BaseRequestBody extends BaseRequest {
  /// Creates a base request body.
  const BaseRequestBody();

  /// Converts this request body to a JSON map.
  /// 
  /// This method must be implemented by subclasses to define
  /// how the request body should be serialized.
  Map<String, Object?> toJson();

  /// Converts this request body to a JSON string.
  /// 
  /// Uses [toJson] to create the map representation first,
  /// then encodes it as a JSON string.
  String toJsonStr() => json.encode(toJson());
}
