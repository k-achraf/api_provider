import 'package:dio/dio.dart';
import 'package:easy_api_provider/src/models/cache_config.dart';
import 'package:easy_api_provider/src/models/retry_config.dart';
import 'package:easy_api_provider/src/models/token_refresh_config.dart';

/// A callback that is triggered before a request is sent.
///
/// Provides access to the [RequestOptions] allowing inspection or modification.
typedef OnRequestCallback = void Function(RequestOptions options);

/// A callback that is triggered when a request encounters an error.
///
/// Provides access to the [DioException] for custom error handling.
typedef OnErrorCallback = void Function(DioException error);

/// A callback that is triggered after a successful response is received.
///
/// Provides access to the [Response] object for inspection or modification.
typedef OnResponseCallback = void Function(Response<dynamic> response);

/// Configuration class for customizing Dio-based API requests.
///
/// This class provides flexible options for setting headers, timeouts,
/// content types, request logging, retry, caching, token-refresh, and more.
class ApiProviderConfig {
  /// The base URL of the API (e.g., `https://api.example.com`).
  final String baseUrl;

  /// Authorization value to be sent in the `Authorization` header (e.g.,
  /// `'Bearer my_token'` or `'Basic dXNlcjpwYXNz'`).
  ///
  /// Must be a [String] or `null`. Passing any other type will throw an
  /// [AssertionError] in debug mode.
  final dynamic authorization;

  /// Timeout duration for establishing a connection.
  final Duration connectTimeout;

  /// Timeout duration for receiving data from the server.
  final Duration receiveTimeout;

  /// Timeout duration for sending data to the server.
  ///
  /// If the request body takes longer than this to be sent, the request will
  /// fail with a [DioExceptionType.sendTimeout] error.
  final Duration sendTimeout;

  /// The expected response type from the server.
  final ResponseType responseType;

  /// The content type to be used in requests (e.g., `application/json`).
  final String contentType;

  /// Enables request/response logging via [TalkerDioLogger].
  ///
  /// Defaults to `false`. Enable only in **debug builds** — when `true` the
  /// logger prints full request headers (including `Authorization` tokens)
  /// and response bodies to the console.
  final bool requestLogger;

  /// Maximum number of redirects allowed during a request.
  final int maxRedirects;

  /// Whether to follow redirects.
  final bool followRedirects;

  /// Whether to show the result message after API operations.
  final bool showResultMessage;

  /// Optional list format for handling query parameters with arrays.
  final ListFormat? listFormat;

  /// Extra metadata to be passed to Dio's request options.
  final Map<String, dynamic>? extra;

  /// Callback executed before sending the request.
  final OnRequestCallback? onRequest;

  /// Callback executed when an error occurs.
  final OnErrorCallback? onError;

  /// Callback executed when a response is successfully received.
  final OnResponseCallback? onResponse;

  /// Optional headers to be included in all requests.
  final Map<String, dynamic>? headers;

  /// A predicate that determines which HTTP status codes are treated as
  /// successful. Defaults to `null`, which uses Dio's built-in rule
  /// (status code >= 200 && < 300).
  ///
  /// Example — treat 200, 201, and 204 as success:
  /// ```dart
  /// validateStatus: (status) => status != null && [200, 201, 204].contains(status),
  /// ```
  final bool Function(int?)? validateStatus;

  /// Auto-retry configuration.
  ///
  /// When set, failed requests are automatically retried according to the
  /// [RetryConfig]. Can be overridden per-request by passing `retryConfig`
  /// to individual HTTP methods.
  ///
  /// Set to [RetryConfig.none] to disable retry globally.
  final RetryConfig? retry;

  /// In-memory GET response cache configuration.
  ///
  /// When set, successful GET responses are cached for the configured [CacheConfig.ttl].
  /// Call [ApiProvider.clearCache] to invalidate the entire cache.
  final CacheConfig? cache;

  /// Transparent token-refresh configuration.
  ///
  /// When set, 401 (or other configured) responses trigger an automatic
  /// token refresh followed by a transparent replay of the failed request.
  final TokenRefreshConfig? tokenRefresh;

  /// Whether to deduplicate identical in-flight GET requests.
  ///
  /// When `true`, if the same GET URL is requested while a previous request
  /// is still pending, only one network call is made and all callers receive
  /// the same response. Defaults to `false`.
  final bool deduplicateRequests;

  /// Creates a new instance of [ApiProviderConfig] with optional overrides.
  const ApiProviderConfig(
    this.baseUrl, {
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.responseType = ResponseType.json,
    this.requestLogger = false,
    this.maxRedirects = 1,
    this.followRedirects = true,
    this.showResultMessage = false,
    this.contentType = 'application/json',
    this.headers,
    this.authorization,
    this.listFormat,
    this.extra,
    this.onRequest,
    this.onError,
    this.onResponse,
    this.validateStatus,
    this.retry,
    this.cache,
    this.tokenRefresh,
    this.deduplicateRequests = false,
  }) : assert(
          authorization == null || authorization is String,
          'authorization must be a String (e.g. "Bearer token") or null.',
        );
}
