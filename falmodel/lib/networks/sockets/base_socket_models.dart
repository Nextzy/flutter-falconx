import 'package:falmodel/lib.dart';

/// Base class for all WebSocket-related models.
///
/// Provides common functionality for WebSocket requests and responses
/// with proper equality comparison and debugging support.
abstract class BaseSocketModel extends BaseRequest {
  /// Creates a base socket model.
  const BaseSocketModel();
}

/// Base class for WebSocket request bodies.
///
/// Similar to [BaseRequestBody] but specifically for WebSocket messages.
/// Provides JSON serialization for sending data through WebSocket connections.
///
/// Example:
/// ```dart
/// class ChatMessage extends BaseSocketRequestBody {
///   const ChatMessage({
///     required this.roomId,
///     required this.message,
///     required this.timestamp,
///   });
///
///   final String roomId;
///   final String message;
///   final DateTime timestamp;
///
///   @override
///   Map<String, Object?> toJson() => {
///     'room_id': roomId,
///     'message': message,
///     'timestamp': timestamp.toIso8601String(),
///   };
///
///   @override
///   List<Object?> get props => [roomId, message, timestamp];
/// }
/// ```
abstract class BaseSocketRequestBody extends BaseSocketModel {
  /// Creates a base socket request body.
  const BaseSocketRequestBody();

  /// Converts this request body to a JSON map.
  Map<String, Object?> toJson();

  /// Converts this request body to a JSON string.
  String toJsonStr() => json.encode(toJson());
}

/// Base class for typed WebSocket responses.
///
/// Provides a generic way to handle different types of WebSocket messages
/// with proper type safety and parsing support.
///
/// Type parameter [T] represents the data type of the response.
///
/// Example:
/// ```dart
/// class ChatMessageResponse extends BaseSocketResponse<ChatMessage> {
///   const ChatMessageResponse({
///     required super.data,
///     required super.requestOptions,
///     super.timestamp,
///   });
///
///   factory ChatMessageResponse.fromJson(
///     Map<String, dynamic> json,
///     SocketOptions options,
///   ) {
///     return ChatMessageResponse(
///       data: ChatMessage.fromJson(json),
///       requestOptions: options,
///       timestamp: DateTime.now(),
///     );
///   }
/// }
/// ```
abstract class BaseSocketResponse<T> extends BaseSocketModel {
  /// Creates a base socket response.
  ///
  /// [data] is the parsed response data.
  /// [requestOptions] contains the socket configuration.
  /// [timestamp] is when the message was received.
  const BaseSocketResponse({
    required this.data,
    required this.requestOptions,
    this.timestamp,
  });

  /// The parsed response data.
  final T data;

  /// The socket configuration used for this connection.
  final SocketOptions requestOptions;

  /// When this message was received.
  final DateTime? timestamp;

  /// The age of this message in milliseconds.
  /// Returns null if timestamp is not set.
  int? get ageInMilliseconds {
    if (timestamp == null) return null;
    return DateTime.now().difference(timestamp!).inMilliseconds;
  }

  @override
  List<Object?> get props => [data, requestOptions, timestamp];
}

/// Generic socket response for string-based messages.
///
/// This is the most basic socket response type, suitable for
/// simple text-based WebSocket protocols.
class SocketResponse extends BaseSocketResponse<String> {
  /// Creates a generic socket response.
  const SocketResponse({
    required super.data,
    required super.requestOptions,
    super.timestamp,
  });

  /// Creates a response with the current timestamp.
  factory SocketResponse.now({
    required String data,
    required SocketOptions requestOptions,
  }) {
    return SocketResponse(
      data: data,
      requestOptions: requestOptions,
      timestamp: DateTime.now(),
    );
  }
}

/// Socket response for JSON data.
///
/// Automatically parses JSON strings into Map<String, dynamic>
/// for easier manipulation of structured data.
class JsonSocketResponse extends BaseSocketResponse<Map<String, dynamic>> {
  /// Creates a JSON socket response.
  const JsonSocketResponse({
    required super.data,
    required super.requestOptions,
    super.timestamp,
  });

  /// Creates a response by parsing a JSON string.
  ///
  /// Throws [FormatException] if the string is not valid JSON.
  factory JsonSocketResponse.fromString({
    required String jsonString,
    required SocketOptions requestOptions,
  }) {
    return JsonSocketResponse(
      data: json.decode(jsonString) as Map<String, dynamic>,
      requestOptions: requestOptions,
      timestamp: DateTime.now(),
    );
  }

  /// Safely gets a value from the JSON data.
  ///
  /// Returns null if the key doesn't exist or if the type doesn't match.
  T? getValue<T>(String key) {
    try {
      return data[key] as T?;
    } catch (_) {
      return null;
    }
  }

  /// Gets a nested value using dot notation.
  ///
  /// Example: `getNestedValue('user.profile.name')`
  T? getNestedValue<T>(String path) {
    final keys = path.split('.');
    dynamic current = data;

    for (final key in keys) {
      if (current is Map<String, dynamic>) {
        current = current[key];
      } else {
        return null;
      }
    }

    return current as T?;
  }
}

/// Socket response for binary data.
///
/// Used for WebSocket protocols that send binary messages,
/// such as file transfers or binary protocols.
class BinarySocketResponse extends BaseSocketResponse<List<int>> {
  /// Creates a binary socket response.
  const BinarySocketResponse({
    required super.data,
    required super.requestOptions,
    super.timestamp,
  });

  /// Creates a response from a base64 string.
  factory BinarySocketResponse.fromBase64({
    required String base64String,
    required SocketOptions requestOptions,
  }) {
    return BinarySocketResponse(
      data: base64.decode(base64String),
      requestOptions: requestOptions,
      timestamp: DateTime.now(),
    );
  }

  /// The size of the binary data in bytes.
  int get sizeInBytes => data.length;

  /// Converts the binary data to a base64 string.
  String toBase64() => base64.encode(data);
}
