/// A class that represents a standardized API response.
///
/// This model helps unify the format of responses returned from API calls,
/// making it easier to handle success, error, and other status conditions.
class ApiResponse {
  /// Indicates whether the request was successful or not.
  final bool success;

  /// The HTTP status code returned by the server (e.g., 200, 404, 500).
  final int? statusCode;

  /// The actual data returned from the API.
  ///
  /// This could be a map, list, or any other type depending on the endpoint.
  final dynamic data;

  /// The URL that was called to get this response.
  final String? url;

  /// A message describing the result of the API call.
  ///
  /// This could be an error message, success confirmation, or null.
  final String? message;

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
  });
}
