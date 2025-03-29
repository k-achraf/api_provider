class ApiResponse{
  final bool success;
  final int? statusCode;
  final dynamic data;
  final String? url;
  final String? message;

  const ApiResponse({
    required this.success,
    this.data,
    this.statusCode,
    this.url,
    this.message,
  });
}