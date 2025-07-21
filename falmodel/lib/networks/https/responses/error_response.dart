import 'package:falmodel/lib.dart';

/// Base class for API error responses.
/// 
/// Provides a standardized structure for handling API errors with
/// support for error codes, messages, and additional details.
/// 
/// Example:
/// ```dart
/// class ValidationErrorResponse extends ErrorResponse {
///   const ValidationErrorResponse({
///     required super.message,
///     super.code,
///     this.fields = const {},
///   }) : super(details: fields);
///   
///   final Map<String, List<String>> fields;
///   
///   @override
///   List<Object?> get props => [message, code, fields];
/// }
/// ```
class ErrorResponse extends BaseRequest {
  /// Creates an error response.
  /// 
  /// [message] is the human-readable error message.
  /// [code] is the error code for programmatic handling.
  /// [details] contains additional error information.
  const ErrorResponse({
    required this.message,
    this.code,
    this.details,
  });

  /// Creates an error response from a JSON map.
  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      message: json['message'] as String? ?? 'Unknown error',
      code: json['code'] as String?,
      details: json['details'],
    );
  }

  /// The human-readable error message.
  final String message;

  /// The error code for programmatic handling.
  final String? code;

  /// Additional error details (field errors, metadata, etc.).
  final dynamic details;

  /// Converts this error response to a JSON map.
  Map<String, dynamic> toJson() => {
    'message': message,
    if (code != null) 'code': code,
    if (details != null) 'details': details,
  };

  @override
  List<Object?> get props => [message, code, details];
}

/// Represents a paginated error response.
/// 
/// Used when errors occur during paginated API calls, preserving
/// pagination context for retry mechanisms.
class PaginatedErrorResponse extends ErrorResponse {
  /// Creates a paginated error response.
  const PaginatedErrorResponse({
    required super.message,
    super.code,
    super.details,
    this.page,
    this.pageSize,
  });

  /// The page number where the error occurred.
  final int? page;

  /// The page size used when the error occurred.
  final int? pageSize;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    if (page != null) 'page': page,
    if (pageSize != null) 'page_size': pageSize,
  };

  @override
  List<Object?> get props => [...super.props, page, pageSize];
}

/// Represents validation errors with field-specific messages.
/// 
/// Commonly used for form validation errors where each field
/// may have multiple validation messages.
/// 
/// Example:
/// ```dart
/// final error = ValidationErrorResponse(
///   message: 'Validation failed',
///   code: 'VALIDATION_ERROR',
///   fields: {
///     'email': ['Email is required', 'Email format is invalid'],
///     'password': ['Password must be at least 8 characters'],
///   },
/// );
/// ```
class ValidationErrorResponse extends ErrorResponse {
  /// Creates a validation error response.
  const ValidationErrorResponse({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    this.fields = const {},
  }) : super(details: fields);

  /// Creates a validation error response from JSON.
  factory ValidationErrorResponse.fromJson(Map<String, dynamic> json) {
    final fieldsJson = json['fields'] as Map<String, dynamic>? ?? {};
    final fields = <String, List<String>>{};
    
    fieldsJson.forEach((key, value) {
      if (value is List) {
        fields[key] = value.cast<String>();
      } else if (value is String) {
        fields[key] = [value];
      }
    });

    return ValidationErrorResponse(
      message: json['message'] as String? ?? 'Validation failed',
      code: json['code'] as String? ?? 'VALIDATION_ERROR',
      fields: fields,
    );
  }

  /// Field-specific validation errors.
  final Map<String, List<String>> fields;

  /// Gets all validation messages for a specific field.
  List<String> getFieldErrors(String fieldName) => fields[fieldName] ?? [];

  /// Whether a specific field has validation errors.
  bool hasFieldError(String fieldName) => fields.containsKey(fieldName);

  /// Gets the first error message for a field, if any.
  String? getFirstFieldError(String fieldName) {
    final errors = getFieldErrors(fieldName);
    return errors.isEmpty ? null : errors.first;
  }

  @override
  Map<String, dynamic> toJson() => {
    'message': message,
    'code': code,
    'fields': fields,
  };

  @override
  List<Object?> get props => [message, code, fields];
}
