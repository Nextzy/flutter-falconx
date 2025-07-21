import 'package:falmodel/lib.dart';

/// Base class for all network request models.
/// 
/// Provides common functionality for HTTP requests including:
/// - Equality comparison through [EquatableMixin]
/// - String representation for debugging
/// - Common HTTP request properties
/// 
/// Example:
/// ```dart
/// class LoginRequest extends BaseRequest {
///   const LoginRequest({
///     required this.email,
///     required this.password,
///     this.rememberMe = false,
///   });
///   
///   final String email;
///   final String password;
///   final bool rememberMe;
///   
///   Map<String, dynamic> toJson() => {
///     'email': email,
///     'password': password,
///     'remember_me': rememberMe,
///   };
///   
///   @override
///   List<Object?> get props => [email, password, rememberMe];
/// }
/// ```
abstract class BaseRequest with EquatableMixin {
  /// Creates a base request instance.
  const BaseRequest();

  /// Enables automatic string representation for debugging.
  @override
  bool get stringify => true;
}

/// Base class for paginated requests.
/// 
/// Provides common pagination parameters that can be extended
/// for specific API endpoints.
/// 
/// Example:
/// ```dart
/// class GetProductsRequest extends PaginatedRequest {
///   const GetProductsRequest({
///     super.page,
///     super.pageSize,
///     this.category,
///     this.sortBy,
///   });
///   
///   final String? category;
///   final String? sortBy;
///   
///   @override
///   Map<String, dynamic> toQueryParameters() => {
///     ...super.toQueryParameters(),
///     if (category != null) 'category': category,
///     if (sortBy != null) 'sort_by': sortBy,
///   };
///   
///   @override
///   List<Object?> get props => [...super.props, category, sortBy];
/// }
/// ```
abstract class PaginatedRequest extends BaseRequest {
  /// Creates a paginated request.
  /// 
  /// [page] starts from 1. Defaults to 1.
  /// [pageSize] is the number of items per page. Defaults to 20.
  const PaginatedRequest({
    this.page = 1,
    this.pageSize = 20,
  });

  /// The current page number (1-indexed).
  final int page;

  /// The number of items per page.
  final int pageSize;

  /// Converts pagination parameters to query parameters.
  Map<String, dynamic> toQueryParameters() => {
    'page': page,
    'page_size': pageSize,
  };

  @override
  List<Object?> get props => [page, pageSize];
}
