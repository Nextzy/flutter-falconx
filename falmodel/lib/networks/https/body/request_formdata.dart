import 'package:falmodel/lib.dart';

/// Base class for multipart/form-data request bodies.
/// 
/// Extends [BaseRequest] to provide form data functionality for file uploads
/// and multipart form submissions.
/// 
/// Example:
/// ```dart
/// class UploadAvatarBody extends BaseFormDataBody {
///   const UploadAvatarBody({
///     required this.userId,
///     required this.file,
///   });
///   
///   final String userId;
///   final File file;
///   
///   @override
///   Map<String, Object?> toJson() => {
///     'user_id': userId,
///     'file_name': file.path.split('/').last,
///   };
///   
///   @override
///   Future<FormData> toFormData() async {
///     return FormData.fromMap({
///       'user_id': userId,
///       'avatar': await MultipartFile.fromFile(
///         file.path,
///         filename: file.path.split('/').last,
///       ),
///     });
///   }
///   
///   @override
///   List<Object?> get props => [userId, file];
/// }
/// ```
abstract class BaseFormDataBody extends BaseRequest {
  /// Creates a base form data body.
  const BaseFormDataBody();

  /// Converts this request body to a JSON map.
  /// 
  /// Used for logging or debugging purposes. The actual request
  /// will use [toFormData] for multipart encoding.
  Map<String, Object?> toJson();

  /// Converts this request body to a JSON string.
  /// 
  /// Primarily used for debugging and logging. The actual HTTP
  /// request will use the [toFormData] method.
  String toJsonStr() => json.encode(toJson());

  /// Converts this request body to FormData for multipart requests.
  /// 
  /// This method must be implemented by subclasses to define
  /// how the request should be encoded as multipart/form-data.
  Future<FormData> toFormData();
}
