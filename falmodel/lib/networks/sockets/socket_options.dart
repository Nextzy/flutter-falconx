/// Configuration options for WebSocket connections.
/// 
/// Contains all necessary parameters for establishing and managing
/// WebSocket connections including URI, retry behavior, and protocols.
/// 
/// Example:
/// ```dart
/// final options = SocketOptions(
///   uri: 'wss://api.example.com/ws',
///   retryLimit: 5,
///   protocol: 'chat-v1',
///   data: 'initial-handshake-data',
/// );
/// ```
class SocketOptions {
  /// Creates socket options with the given parameters.
  /// 
  /// [uri] is the WebSocket endpoint URL (ws:// or wss://).
  /// [retryLimit] is the maximum number of reconnection attempts (default: 3).
  /// [protocol] is the optional sub-protocol for the WebSocket handshake.
  /// [data] is optional initial data to send upon connection.
  SocketOptions({
    this.uri = '',
    this.retryLimit = 3,
    this.protocol,
    this.data,
  });

  /// The WebSocket endpoint URL.
  /// 
  /// Should use 'ws://' for non-secure or 'wss://' for secure connections.
  String uri;

  /// Maximum number of reconnection attempts.
  /// 
  /// Set to 0 to disable automatic reconnection.
  int retryLimit;

  /// Optional sub-protocol for the WebSocket handshake.
  /// 
  /// Used to specify the application-level protocol that the client
  /// wishes to use. The server will select one from the list provided.
  String? protocol;

  /// Optional initial data to send upon connection.
  /// 
  /// Can be used for authentication tokens or initial handshake data.
  String? data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SocketOptions &&
          runtimeType == other.runtimeType &&
          uri == other.uri &&
          retryLimit == other.retryLimit &&
          protocol == other.protocol &&
          data == other.data);

  @override
  int get hashCode =>
      uri.hashCode ^ retryLimit.hashCode ^ data.hashCode ^ protocol.hashCode;

  @override
  String toString() {
    return 'SocketOptions{ uri: $uri, retryLimit: $retryLimit, protocol: $protocol, data: $data,}';
  }

  /// Whether this connection uses secure WebSocket (wss://).
  bool get isSecure => uri.startsWith('wss://');

  /// Whether automatic reconnection is enabled.
  bool get hasRetry => retryLimit > 0;

  /// Creates a copy of these options with the given fields replaced.
  SocketOptions copyWith({
    String? uri,
    int? retryLimit,
    String? protocol,
    String? data,
  }) {
    return SocketOptions(
      uri: uri ?? this.uri,
      retryLimit: retryLimit ?? this.retryLimit,
      protocol: protocol ?? this.protocol,
      data: data ?? this.data,
    );
  }
}
