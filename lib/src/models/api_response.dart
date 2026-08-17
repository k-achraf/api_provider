/// A strongly-typed class that represents a standardized API response.
///
/// The type parameter [T] is the decoded data type. When no [decoder] is
/// provided to an HTTP method, [T] defaults to `dynamic` which preserves
/// backward compatibility.
///
/// ### Typed usage
/// ```dart
/// final ApiResponse<List<Post>> response = await ApiProvider.instance.get<List<Post>>(
///   '/posts',
///   decoder: (data) => (data['posts'] as List).map(Post.fromJson).toList(),
/// );
///
/// if (response.success) {
///   final List<Post> posts = response.data!; // fully typed, no cast needed
/// }
/// ```
///
/// ### Untyped usage (backward compatible)
/// ```dart
/// final ApiResponse response = await ApiProvider.instance.get('/posts');
/// print(response.data); // dynamic
/// ```
class ApiResponse<T> {
  /// Indicates whether the request was successful or not.
  final bool success;

  /// The HTTP status code returned by the server (e.g., 200, 404, 500).
  final int? statusCode;

  /// The decoded response data.
  ///
  /// When a [decoder] was provided to the HTTP method this is strongly typed
  /// as [T]. Otherwise it is the raw `dynamic` value from Dio.
  final T? data;

  /// The URL that was called to get this response.
  final String? url;

  /// A message describing the result of the API call.
  ///
  /// This could be an error message, success confirmation, or null.
  final String? message;

  /// The HTTP response headers returned by the server.
  ///
  /// Useful for reading pagination cursors, cache-control directives,
  /// rate-limit info, or any other server-sent metadata.
  final Map<String, List<String>>? headers;

  /// The total duration of the request from send to response receipt.
  ///
  /// Useful for client-side performance monitoring. Will be `null` if the
  /// request did not complete (e.g., was cancelled or timed out before
  /// a response was received).
  final Duration? requestDuration;

  /// Creates an [ApiResponse] instance.
  ///
  /// The [success] field is required to determine the result status.
  /// Other fields are optional and can hold additional context.
  const ApiResponse({
    required this.success,
    this.data,
    this.statusCode,
    this.url,
    this.message,
    this.headers,
    this.requestDuration,
  });

  /// Returns a copy of this [ApiResponse] with the specified fields replaced.
  ///
  /// Useful for transforming responses in middleware, tests, or mapping layers
  /// without mutating the original object.
  ApiResponse<T> copyWith({
    bool? success,
    int? statusCode,
    T? data,
    String? url,
    String? message,
    Map<String, List<String>>? headers,
    Duration? requestDuration,
  }) {
    return ApiResponse<T>(
      success: success ?? this.success,
      statusCode: statusCode ?? this.statusCode,
      data: data ?? this.data,
      url: url ?? this.url,
      message: message ?? this.message,
      headers: headers ?? this.headers,
      requestDuration: requestDuration ?? this.requestDuration,
    );
  }

  @override
  String toString() {
    final parts = <String>[
      'success: $success',
      if (statusCode != null) 'statusCode: $statusCode',
      if (url != null) 'url: $url',
      if (message != null) 'message: $message',
      if (requestDuration != null)
        'duration: ${requestDuration!.inMilliseconds}ms',
    ];
    return 'ApiResponse<$T>(${parts.join(', ')})';
  }
}
