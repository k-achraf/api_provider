import 'dart:async';

import 'package:ansicolor/ansicolor.dart';
import 'package:dio/dio.dart';
import 'package:easy_api_provider/src/controllers/api_provider_controller.dart';
import 'package:easy_api_provider/src/interceptors/cache_interceptor.dart';
import 'package:easy_api_provider/src/interceptors/dedup_interceptor.dart';
import 'package:easy_api_provider/src/interceptors/retry_interceptor.dart';
import 'package:easy_api_provider/src/interceptors/token_refresh_interceptor.dart';
import 'package:easy_api_provider/src/models/api_provider_config.dart';
import 'package:easy_api_provider/src/models/api_response.dart';
import 'package:easy_api_provider/src/models/cache_config.dart';
import 'package:easy_api_provider/src/models/retry_config.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

/// A class that provides a configured Dio instance for making HTTP requests.
///
/// This class supports custom configuration, request/response/error
/// interceptors, optional logging, retry, caching, deduplication, and
/// transparent token refresh via [TalkerDioLogger].
///
/// Use [ApiProvider.instance] for the global singleton, or [ApiProvider.create]
/// to obtain an independent instance when you need separate configurations
/// (e.g., talking to two different backends simultaneously).
class ApiProvider {
  /// Private constructor.
  ApiProvider._();

  /// Global singleton instance of [ApiProvider].
  ///
  /// Call [init] once at app startup before making any requests.
  static final instance = ApiProvider._();

  /// Creates a new, independent [ApiProvider] instance.
  ///
  /// Use this when you need multiple providers with different base URLs,
  /// headers, or timeout settings running concurrently.
  ///
  /// ```dart
  /// final authApi = ApiProvider.create()
  ///   ..init(ApiProviderConfig('https://auth.example.com'));
  /// final contentApi = ApiProvider.create()
  ///   ..init(ApiProviderConfig('https://content.example.com'));
  /// ```
  factory ApiProvider.create() => ApiProvider._();

  /// Internal Dio client instance.
  Dio? _dio;

  /// Internal cache instance (non-null when [ApiProviderConfig.cache] is set).
  ApiCache? _cache;

  /// Returns `true` if [init] has been called and the Dio client is ready.
  bool get isInitialized => _dio != null;

  /// Returns the initialized Dio instance.
  ///
  /// Throws an [Exception] if [init] has not been called yet.
  Dio get dio {
    if (_dio == null) {
      throw Exception('You need to call "init" function first');
    }
    return _dio!;
  }

  /// Initializes the Dio client with the given [config].
  ///
  /// Any previously initialised Dio instance is closed before the new one is
  /// created, preventing resource leaks when [init] is called more than once.
  void init(ApiProviderConfig config) {
    _dio?.close(force: true);
    _cache = null;

    _dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        responseType: config.responseType,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        sendTimeout: config.sendTimeout,
        contentType: config.contentType,
        maxRedirects: config.maxRedirects,
        followRedirects: config.followRedirects,
        headers: config.headers,
        validateStatus: config.validateStatus,
      ),
    );

    // 1. User interceptors (onRequest / onResponse / onError callbacks)
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          config.onRequest?.call(options);
          return handler.next(options);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) {
          config.onError?.call(error);
          return handler.next(error);
        },
        onResponse:
            (Response<dynamic> response, ResponseInterceptorHandler handler) {
          config.onResponse?.call(response);
          return handler.next(response);
        },
      ),
    );

    // 2. Deduplication interceptor
    if (config.deduplicateRequests) {
      dio.interceptors.add(DedupInterceptor());
    }

    // 3. In-memory cache interceptor
    if (config.cache != null) {
      _cache = ApiCache(config.cache!);
      dio.interceptors.add(CacheInterceptor(cache: _cache!));
    }

    // 4. Retry interceptor
    if (config.retry != null && !config.retry!.isDisabled) {
      dio.interceptors.add(
        RetryInterceptor(dio: dio, config: config.retry!),
      );
    }

    // 5. Token refresh interceptor
    if (config.tokenRefresh != null) {
      dio.interceptors.add(
        TokenRefreshInterceptor(dio: dio, config: config.tokenRefresh!),
      );
    }

    // Auth header
    if (config.authorization != null) {
      dio.options.headers['Authorization'] = config.authorization;
    }

    if (config.listFormat != null) {
      dio.options.listFormat = config.listFormat!;
    }

    if (config.extra != null) {
      dio.options.extra = config.extra!;
    }

    // 6. Request logger (last so it sees the final request)
    if (config.requestLogger) {
      dio.interceptors.add(
        TalkerDioLogger(
          settings: TalkerDioLoggerSettings(
            enabled: true,
            printErrorData: true,
            printErrorHeaders: true,
            printErrorMessage: true,
            printRequestData: true,
            printRequestHeaders: true,
            printResponseData: true,
            printResponseMessage: true,
            responsePen: AnsiPen()..blue(),
            errorPen: AnsiPen()..red(),
          ),
        ),
      );
    }
  }

  /// Sets or removes the authorization header.
  ///
  /// If [authorization] is `null`, the `Authorization` header will be removed.
  /// Otherwise, it will be set to the provided value.
  void setAuthorisation(String? authorization) {
    if (authorization == null) {
      dio.options.headers.remove('Authorization');
    } else {
      dio.options.headers['Authorization'] = authorization;
    }
  }

  /// Updates the base URL used by the Dio client.
  void setBaseUrl(String baseUrl) {
    dio.options.baseUrl = baseUrl;
  }

  /// Clears all entries from the in-memory response cache.
  ///
  /// Has no effect if caching was not enabled in [ApiProviderConfig].
  void clearCache() => _cache?.clear();

  /// Returns the number of entries currently in the cache.
  ///
  /// Returns `0` if caching is not enabled.
  int get cacheSize => _cache?.size ?? 0;

  // ── HTTP Methods ─────────────────────────────────────────────────────────

  /// Sends a GET request to the specified [path].
  ///
  /// Optionally provide a [decoder] to get a strongly-typed [ApiResponse<T>]
  /// back instead of `ApiResponse<dynamic>`:
  /// ```dart
  /// final ApiResponse<List<Post>> res = await provider.get<List<Post>>(
  ///   '/posts',
  ///   decoder: (data) => (data['posts'] as List).map(Post.fromJson).toList(),
  /// );
  /// ```
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? params,
    Options? requestOptions,
    CancelToken? cancelToken,
    ProgressCallback? progressCallback,
    ApiProviderController? controller,
    RetryConfig? retryConfig,
    T Function(dynamic data)? decoder,
  }) {
    return _request<T>(
      path: path,
      controller: controller,
      decoder: decoder,
      request: () => dio.get(
        path,
        queryParameters: params,
        cancelToken: cancelToken,
        onReceiveProgress: progressCallback,
        options: _applyRetry(requestOptions, retryConfig),
      ),
    );
  }

  /// Sends a HEAD request to the specified [path].
  Future<ApiResponse<T>> head<T>(
    String path, {
    Map<String, dynamic>? params,
    Options? requestOptions,
    CancelToken? cancelToken,
    ApiProviderController? controller,
    RetryConfig? retryConfig,
  }) {
    return _request<T>(
      path: path,
      controller: controller,
      request: () => dio.head(
        path,
        queryParameters: params,
        cancelToken: cancelToken,
        options: _applyRetry(requestOptions, retryConfig),
      ),
    );
  }

  /// Sends a POST request to the specified [path].
  Future<ApiResponse<T>> post<T>(
    String path, {
    Map<String, dynamic>? params,
    dynamic data,
    Options? requestOptions,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    ProgressCallback? onSendProgress,
    ApiProviderController? controller,
    RetryConfig? retryConfig,
    T Function(dynamic data)? decoder,
  }) {
    return _request<T>(
      path: path,
      controller: controller,
      decoder: decoder,
      request: () => dio.post(
        path,
        data: data,
        queryParameters: params,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
        options: _applyRetry(requestOptions, retryConfig),
      ),
    );
  }

  /// Sends a PATCH request to the specified [path].
  Future<ApiResponse<T>> patch<T>(
    String path, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? data,
    Options? requestOptions,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    ProgressCallback? onSendProgress,
    ApiProviderController? controller,
    RetryConfig? retryConfig,
    T Function(dynamic data)? decoder,
  }) {
    return _request<T>(
      path: path,
      controller: controller,
      decoder: decoder,
      request: () => dio.patch(
        path,
        data: data,
        queryParameters: params,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
        options: _applyRetry(requestOptions, retryConfig),
      ),
    );
  }

  /// Sends a PUT request to the specified [path].
  Future<ApiResponse<T>> put<T>(
    String path, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? data,
    Options? requestOptions,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    ProgressCallback? onSendProgress,
    ApiProviderController? controller,
    RetryConfig? retryConfig,
    T Function(dynamic data)? decoder,
  }) {
    return _request<T>(
      path: path,
      controller: controller,
      decoder: decoder,
      request: () => dio.put(
        path,
        data: data,
        queryParameters: params,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
        options: _applyRetry(requestOptions, retryConfig),
      ),
    );
  }

  /// Sends a DELETE request to the specified [path].
  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? data,
    Options? requestOptions,
    CancelToken? cancelToken,
    ApiProviderController? controller,
    RetryConfig? retryConfig,
    T Function(dynamic data)? decoder,
  }) {
    return _request<T>(
      path: path,
      controller: controller,
      decoder: decoder,
      request: () => dio.delete(
        path,
        data: data,
        queryParameters: params,
        cancelToken: cancelToken,
        options: _applyRetry(requestOptions, retryConfig),
      ),
    );
  }

  /// Uploads a [FormData] payload to [path] using a multipart POST request.
  ///
  /// This is the preferred method for file uploads or any `multipart/form-data`
  /// request. Use [onSendProgress] to track upload progress.
  ///
  /// ```dart
  /// final response = await ApiProvider.instance.upload(
  ///   '/profile/avatar',
  ///   FormData.fromMap({
  ///     'file': await MultipartFile.fromFile('/path/to/image.jpg'),
  ///   }),
  ///   onSendProgress: (sent, total) {
  ///     print('${(sent / total * 100).toStringAsFixed(1)}%');
  ///   },
  /// );
  /// ```
  Future<ApiResponse<T>> upload<T>(
    String path,
    FormData formData, {
    Map<String, dynamic>? params,
    Options? requestOptions,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    ApiProviderController? controller,
    RetryConfig? retryConfig,
    T Function(dynamic data)? decoder,
  }) {
    return _request<T>(
      path: path,
      controller: controller,
      decoder: decoder,
      request: () => dio.post(
        path,
        data: formData,
        queryParameters: params,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        options: Options(
          contentType: 'multipart/form-data',
          headers: requestOptions?.headers,
          receiveTimeout: requestOptions?.receiveTimeout,
          sendTimeout: requestOptions?.sendTimeout,
        ),
      ),
    );
  }

  /// Downloads a file from the given [urlPath] and saves it to [savePath].
  ///
  /// > **Note:** This method is not supported on Web.
  Future<ApiResponse<T>> download<T>(
    String urlPath,
    String savePath, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? data,
    Options? requestOptions,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    ProgressCallback? onSendProgress,
    bool deleteOnError = true,
    ApiProviderController? controller,
  }) {
    assert(savePath.isNotEmpty, 'savePath must not be empty.');
    return _request<T>(
      path: urlPath,
      controller: controller,
      request: () => dio.download(
        urlPath,
        savePath,
        options: requestOptions,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
        data: data,
        deleteOnError: deleteOnError,
        fileAccessMode: FileAccessMode.write,
        queryParameters: params,
      ),
    );
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  /// Executes an HTTP request with unified error handling, timing, optional
  /// controller state management, and optional response decoding.
  Future<ApiResponse<T>> _request<T>({
    required String path,
    required Future<Response<dynamic>> Function() request,
    ApiProviderController? controller,
    T Function(dynamic data)? decoder,
  }) async {
    controller?.loading();

    final url = '${dio.options.baseUrl}$path';
    final stopwatch = Stopwatch()..start();

    try {
      final response = await request();
      stopwatch.stop();
      final result =
          _handleResponse<T>(response, url, stopwatch.elapsed, decoder);
      controller?.success(apiResponse: result);
      return result;
    } on DioException catch (e) {
      stopwatch.stop();
      final error = _handleDioError<T>(e, url, stopwatch.elapsed);
      controller?.error(apiResponse: error);
      return error;
    } on TimeoutException {
      stopwatch.stop();
      final error = _handleTimeOutException<T>(url, stopwatch.elapsed);
      controller?.error(apiResponse: error);
      return error;
    } catch (e) {
      stopwatch.stop();
      final error = _handleUnexpectedException<T>(e, url, stopwatch.elapsed);
      controller?.error(apiResponse: error);
      return error;
    }
  }

  ApiResponse<T> _handleResponse<T>(
    Response<dynamic> response,
    String? url,
    Duration duration,
    T Function(dynamic data)? decoder,
  ) {
    final message =
        response.data is Map ? response.data['message'] as String? : null;
    final headers = response.headers.map;

    final decodedData =
        decoder != null ? decoder(response.data) : response.data;

    return ApiResponse<T>(
      success: true,
      statusCode: response.statusCode,
      data: decodedData as T?,
      url: url,
      message: message ?? 'Success',
      headers: headers,
      requestDuration: duration,
    );
  }

  ApiResponse<T> _handleDioError<T>(
    DioException error,
    String? url,
    Duration duration,
  ) {
    final errorMessage = switch (error.type) {
      DioExceptionType.connectionTimeout => 'Connection timeout',
      DioExceptionType.sendTimeout => 'Send timeout',
      DioExceptionType.receiveTimeout => 'Receive timeout',
      DioExceptionType.badResponse =>
        'Server error: ${error.response?.statusCode}',
      DioExceptionType.cancel => 'Request cancelled',
      DioExceptionType.connectionError => 'Connection error',
      DioExceptionType.badCertificate => 'Bad certificate',
      DioExceptionType.unknown => 'Unexpected error occurred',
      _ => 'Unexpected error occurred',
    };

    return ApiResponse<T>(
      success: false,
      statusCode: error.response?.statusCode,
      data: null,
      url: url,
      message: errorMessage,
      headers: error.response?.headers.map,
      requestDuration: duration,
    );
  }

  ApiResponse<T> _handleTimeOutException<T>(String? url, Duration duration) {
    return ApiResponse<T>(
      success: false,
      message: 'Server not responding',
      url: url,
      requestDuration: duration,
    );
  }

  ApiResponse<T> _handleUnexpectedException<T>(
    Object? error,
    String? url,
    Duration duration,
  ) {
    return ApiResponse<T>(
      success: false,
      url: url,
      message: error.toString(),
      requestDuration: duration,
    );
  }

  /// Merges a per-request [RetryConfig] override into [Options.extra].
  Options? _applyRetry(Options? base, RetryConfig? retryConfig) {
    if (retryConfig == null) return base;
    return RetryInterceptor.optionsWithConfig(retryConfig, base);
  }
}
