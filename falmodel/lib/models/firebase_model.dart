import 'package:falmodel/lib.dart';

/// Base class for models that interact with Firebase.
/// 
/// Provides common functionality for Firebase documents including:
/// - Conversion to Map for Firestore storage via [toMap]
/// - Equality comparison through [EquatableMixin]
/// - String representation for debugging
/// 
/// Consider extending [FirebaseTimestampModel] if you need automatic
/// timestamp tracking for created/updated times.
/// 
/// Example:
/// ```dart
/// class UserProfile extends FirebaseModel {
///   const UserProfile({
///     required this.uid,
///     required this.displayName,
///     required this.email,
///   });
///   
///   final String uid;
///   final String displayName;
///   final String email;
///   
///   @override
///   Map<String, dynamic> toMap() {
///     return {
///       'uid': uid,
///       'displayName': displayName,
///       'email': email,
///     };
///   }
///   
///   factory UserProfile.fromMap(Map<String, dynamic> map) {
///     return UserProfile(
///       uid: map['uid'] as String,
///       displayName: map['displayName'] as String,
///       email: map['email'] as String,
///     );
///   }
///   
///   @override
///   List<Object?> get props => [uid, displayName, email];
/// }
/// ```
abstract class FirebaseModel with EquatableMixin {
  /// Creates a Firebase model instance.
  const FirebaseModel();

  /// Converts this model to a Map for storage in Firestore.
  /// 
  /// The returned map should contain only types that Firestore supports:
  /// - String, int, double, bool, null
  /// - List, Map
  /// - Timestamp, GeoPoint, DocumentReference
  Map<String, dynamic> toMap();

  /// Enables automatic string representation for debugging.
  @override
  bool get stringify => true;
}

/// Extended Firebase model with automatic timestamp tracking.
/// 
/// Provides [createdAt] and [updatedAt] fields that should be managed
/// by Firebase Functions or client-side code.
/// 
/// Example:
/// ```dart
/// class Article extends FirebaseTimestampModel {
///   const Article({
///     required this.id,
///     required this.title,
///     required this.content,
///     super.createdAt,
///     super.updatedAt,
///   });
///   
///   final String id;
///   final String title;
///   final String content;
///   
///   @override
///   Map<String, dynamic> toMap() {
///     return {
///       'id': id,
///       'title': title,
///       'content': content,
///       'createdAt': createdAt?.millisecondsSinceEpoch,
///       'updatedAt': updatedAt?.millisecondsSinceEpoch,
///     };
///   }
///   
///   @override
///   List<Object?> get props => [id, title, content, createdAt, updatedAt];
/// }
/// ```
abstract class FirebaseTimestampModel extends FirebaseModel {
  /// Creates a Firebase model with timestamp tracking.
  const FirebaseTimestampModel({
    this.createdAt,
    this.updatedAt,
  });

  /// When this document was first created.
  final DateTime? createdAt;

  /// When this document was last updated.
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [createdAt, updatedAt];
}
