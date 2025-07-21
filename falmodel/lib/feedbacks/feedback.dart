import 'package:falmodel/lib.dart';

/// Type alias for void callback that receives a Failure.
typedef VoidFailureCallback = void Function(Failure failure);

/// Sealed class hierarchy for user feedback using Dart 3 features.
///
/// This provides a type-safe way to handle different types of feedback
/// with exhaustive pattern matching.
///
/// Example:
/// ```dart
/// UserFeedback processFeedback(UserFeedback feedback) {
///   return switch (feedback) {
///     Success(:final message) => print('Success: $message'),
///     Warning(:final message) => print('Warning: $message'),
///     Failure(:final exception) => print('Error: $exception'),
///     Information() => print('Info'),
///   };
/// }
/// ```
sealed class UserFeedback<T> extends Equatable {
  const UserFeedback({
    this.code,
    this.message,
    this.data,
  });

  /// An optional code identifying the feedback type.
  final Object? code;

  /// A human-readable message describing the feedback.
  final String? message;

  /// Optional data associated with the feedback.
  final T? data;

  @override
  List<Object?> get props => [code, message, data];
}

/// Represents a successful operation.
class Success<T> extends UserFeedback<T> {
  const Success({
    super.code,
    super.message,
    super.data,
  });

  /// Creates a copy of this Success with the given fields replaced.
  Success<T> copyWith({
    Object? code,
    String? message,
    T? data,
  }) =>
      Success(
        code: code ?? this.code,
        message: message ?? this.message,
        data: data ?? this.data,
      );
}

/// Represents an informational message.
class Information<T> extends UserFeedback<T> {
  const Information({
    super.code,
    super.message,
    super.data,
  });

  /// Creates a copy of this Information with the given fields replaced.
  Information<T> copyWith({
    Object? code,
    String? message,
    T? data,
  }) =>
      Information(
        code: code ?? this.code,
        message: message ?? this.message,
        data: data ?? this.data,
      );
}

/// Represents a warning that doesn't prevent operation completion.
class Warning<T> extends UserFeedback<T> {
  const Warning({
    super.code,
    super.message,
    super.data,
    this.developerMessage,
    this.exception,
    this.stackTrace,
    this.warningList,
    this.severity = WarningSeverity.medium,
  });

  /// Creates a Warning from an Error object.
  factory Warning.fromError(
    Error? error, {
    String? code,
    String? message,
    String? developerMessage,
    StackTrace? stackTrace,
    List<Warning>? warningList,
    T? data,
    WarningSeverity severity = WarningSeverity.medium,
  }) =>
      Warning(
        code: code,
        message: message,
        developerMessage: developerMessage ?? error.toString(),
        exception: error,
        stackTrace: stackTrace ?? error?.stackTrace ?? StackTrace.current,
        warningList: warningList,
        data: data,
        severity: severity,
      );

  /// Creates a Warning from an Exception object.
  factory Warning.fromException(
    Object? exception, {
    String? code,
    String? message,
    String? developerMessage,
    StackTrace? stackTrace,
    List<Warning>? warningList,
    T? data,
    WarningSeverity severity = WarningSeverity.medium,
  }) =>
      Warning(
        code: code,
        message: message,
        developerMessage: developerMessage ?? exception.toString(),
        exception: exception,
        stackTrace: stackTrace ?? StackTrace.current,
        warningList: warningList,
        data: data,
        severity: severity,
      );

  /// A technical message for developers (not shown to users).
  final String? developerMessage;

  /// The exception that caused the warning.
  final Object? exception;

  /// The stack trace at the point of warning.
  final StackTrace? stackTrace;

  /// List of nested warnings for composite warning scenarios.
  final List<Warning>? warningList;

  /// The severity level of the warning.
  final WarningSeverity severity;

  /// Creates a copy of this Warning with the given fields replaced.
  Warning<T> copyWith({
    Object? code,
    String? message,
    String? developerMessage,
    Object? exception,
    StackTrace? stackTrace,
    List<Warning>? warningList,
    T? data,
    WarningSeverity? severity,
  }) =>
      Warning(
        code: code ?? this.code,
        message: message ?? this.message,
        developerMessage: developerMessage ?? this.developerMessage,
        exception: exception ?? this.exception,
        stackTrace: stackTrace ?? this.stackTrace,
        warningList: warningList ?? this.warningList,
        data: data ?? this.data,
        severity: severity ?? this.severity,
      );

  @override
  List<Object?> get props => [
        ...super.props,
        developerMessage,
        exception,
        stackTrace,
        warningList,
        severity,
      ];
}


/// Represents a failure or error condition.
class Failure<T> extends UserFeedback<T> {
  const Failure({
    super.code,
    super.message,
    super.data,
    this.developerMessage,
    this.exception,
    this.stackTrace,
    this.failureList,
  });

  /// Creates a Failure from an Error object.
  factory Failure.fromError(
    Error? error, {
    String? code,
    String? message,
    String? developerMessage,
    StackTrace? stackTrace,
    List<Failure>? failureList,
    T? data,
  }) =>
      Failure(
        code: code,
        message: message,
        developerMessage: developerMessage ?? error.toString(),
        exception: error,
        stackTrace: stackTrace ?? error?.stackTrace ?? StackTrace.current,
        failureList: failureList,
        data: data,
      );

  /// Creates a Failure from an Exception object.
  factory Failure.fromException(
    Object? exception, {
    String? code,
    String? message,
    String? developerMessage,
    StackTrace? stackTrace,
    List<Failure>? failureList,
    T? data,
  }) =>
      Failure(
        code: code,
        message: message,
        developerMessage: developerMessage ?? exception.toString(),
        exception: exception,
        stackTrace: stackTrace ?? StackTrace.current,
        failureList: failureList,
        data: data,
      );

  /// A technical message for developers (not shown to users).
  final String? developerMessage;

  /// The exception that caused the failure.
  final Object? exception;

  /// The stack trace at the point of failure.
  final StackTrace? stackTrace;

  /// List of nested failures for composite error scenarios.
  final List<Failure>? failureList;

  /// Creates a copy of this Failure with the given fields replaced.
  Failure<T> copyWith({
    Object? code,
    String? message,
    String? developerMessage,
    Object? exception,
    StackTrace? stackTrace,
    List<Failure>? failureList,
    T? data,
  }) =>
      Failure(
        code: code ?? this.code,
        message: message ?? this.message,
        developerMessage: developerMessage ?? this.developerMessage,
        exception: exception ?? this.exception,
        stackTrace: stackTrace ?? this.stackTrace,
        failureList: failureList ?? this.failureList,
        data: data ?? this.data,
      );

  @override
  List<Object?> get props => [
        ...super.props,
        developerMessage,
        exception,
        stackTrace,
        failureList,
      ];
}

/// Severity levels for warnings.
enum WarningSeverity {
  low,
  medium,
  high,
  critical;

  /// Whether this warning should be prominently displayed.
  bool get isProminent => this == high || this == critical;
}

/// Extension methods for pattern matching on feedback types.
extension UserFeedbackX<T> on UserFeedback<T> {
  /// Gets the message if this is a Success feedback.
  String? get successMessage => this is Success ? message : null;

  /// Gets the message if this is a Failure feedback.
  String? get errorMessage => this is Failure ? message : null;

  /// Gets the message if this is a Warning feedback.
  String? get warningMessage => this is Warning ? message : null;

  /// Gets the message if this is an Information feedback.
  String? get informationMessage => this is Information ? message : null;

  /// Executes the appropriate callback based on the feedback type.
  R when<R>({
    required R Function(Success<T> success) success,
    required R Function(Warning<T> warning) warning,
    required R Function(Failure<T> failure) failure,
    required R Function(Information<T> information) information,
  }) {
    return switch (this) {
      Success() => success(this as Success<T>),
      Warning() => warning(this as Warning<T>),
      Failure() => failure(this as Failure<T>),
      Information() => information(this as Information<T>),
    };
  }

  /// Maps the data contained in the feedback to a new type.
  UserFeedback<R> mapData<R>(R Function(T? data) mapper) {
    return switch (this) {
      Success(:final code, :final message) => Success<R>(
          code: code,
          message: message,
          data: mapper(data),
        ),
      Warning(:final code, :final message, :final severity) => Warning<R>(
          code: code,
          message: message,
          data: mapper(data),
          severity: severity,
        ),
      Failure(
        :final code,
        :final message,
        :final developerMessage,
        :final exception,
        :final stackTrace
      ) =>
        Failure<R>(
          code: code,
          message: message,
          data: mapper(data),
          developerMessage: developerMessage,
          exception: exception,
          stackTrace: stackTrace,
        ),
      Information(:final code, :final message) => Information<R>(
          code: code,
          message: message,
          data: mapper(data),
        ),
    };
  }
}
