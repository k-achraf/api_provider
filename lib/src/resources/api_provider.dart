import 'dart:async';

import 'package:ansicolor/ansicolor.dart';
import 'package:dio/dio.dart';
import 'package:easy_api_provider/src/controllers/api_provider_controller.dart';
import 'package:easy_api_provider/src/models/api_provider_config.dart';
import 'package:easy_api_provider/src/models/api_response.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

/// A class that provides a configured Dio instance for making HTTP requests.
///
/// This class supports custom configuration, request/response/error
/// interceptors, and optional logging using [TalkerDioLogger].
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

  /// Returns `true` if [init] has been called and the Dio client is ready.
  ///
  /// Use this to guard against calling methods before initialisation or after
  /// the provider has been closed.
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
  ///
  /// This method configures base options, adds interceptors for request,
  /// response, and error handling, sets authorization headers, and enables
  /// request logging if configured.
  void init(ApiProviderConfig config) {
    _dio?.close(force: true); // P1: dispose previous instance
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
    )..interceptors.add(
        InterceptorsWrapper(
          onRequest:
              (RequestOptions options, RequestInterceptorHandler handler) {
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

    if (config.authorization != null) {
      dio.options.headers['Authorization'] = config.authorization;
    }

    if (config.listFormat != null) {
      dio.options.listFormat = config.listFormat!;
    }

    if (config.extra != null) {
      dio.options.extra = config.extra!;
    }

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

  /// Sends a GET request to the specified [path].
  ///
  /// Returns an [ApiResponse] which contains the result of the request.
  Future<ApiResponse> get(
    String path, {
    Map<String, dynamic>? params,
    Options? requestOptions,
    CancelToken? cancelToken,
    ProgressCallback? progressCallback,
    ApiProviderController? controller,
  }) {
    return _request(
      path: path,
      controller: controller,
      request: () => dio.get(
        path,
        queryParameters: params,
        cancelToken: cancelToken,
        onReceiveProgress: progressCallback,
        options: requestOptions,
      ),
    );
  }

  /// Sends a HEAD request to the specified [path].
  ///
  /// Returns an [ApiResponse] with no body — useful for checking whether a
  /// resource exists or inspecting its headers without downloading the content.
  Future<ApiResponse> head(
    String path, {
    Map<String, dynamic>? params,
    Options? requestOptions,
    CancelToken? cancelToken,
    ApiProviderController? controller,
  }) {
    return _request(
      path: path,
      controller: controller,
      request: () => dio.head(
        path,
        queryParameters: params,
        cancelToken: cancelToken,
        options: requestOptions,
      ),
    );
  }

  /// Sends a POST request to the specified [path].
  ///
  /// Returns an [ApiResponse] that contains either the result of the request
  /// or error details.
  Future<ApiResponse> post(
    String path, {
    Map<String, dynamic>? params,
    dynamic data,
    Options? requestOptions,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    ProgressCallback? onSendProgress,
    ApiProviderController? controller,
  }) {
    return _request(
      path: path,
      controller: controller,
      request: () => dio.post(
        path,
        data: data,
        queryParameters: params,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
        options: requestOptions,
      ),
    );
  }

  /// Sends a PATCH request to the specified [path].
  ///
  /// Returns an [ApiResponse] that contains either the result of the request
  /// or error details.
  Future<ApiResponse> patch(
    String path, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? data,
    Options? requestOptions,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    ProgressCallback? onSendProgress,
    ApiProviderController? controller,
  }) {
    return _request(
      path: path,
      controller: controller,
      request: () => dio.patch(
        path,
        data: data,
        queryParameters: params,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
        options: requestOptions,
      ),
    );
  }

  /// Sends a PUT request to the specified [path].
  ///
  /// Returns an [ApiResponse] that contains either the result of the request
  /// or error details.
  Future<ApiResponse> put(
    String path, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? data,
    Options? requestOptions,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    ProgressCallback? onSendProgress,
    ApiProviderController? controller,
  }) {
    return _request(
      path: path,
      controller: controller,
      request: () => dio.put(
        path,
        data: data,
        queryParameters: params,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
        options: requestOptions,
      ),
    );
  }

  /// Sends a DELETE request to the specified [path].
  ///
  /// Returns an [ApiResponse] that contains either the result of the request
  /// or error details.
  Future<ApiResponse> delete(
    String path, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? data,
    Options? requestOptions,
    CancelToken? cancelToken,
    ApiProviderController? controller,
  }) {
    return _request(
      path: path,
      controller: controller,
      request: () => dio.delete(
        path,
        data: data,
        queryParameters: params,
        cancelToken: cancelToken,
        options: requestOptions,
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
  ///     'userId': '42',
  ///   }),
  ///   onSendProgress: (sent, total) {
  ///     print('${(sent / total * 100).toStringAsFixed(1)}%');
  ///   },
  /// );
  /// ```
  Future<ApiResponse> upload(
    String path,
    FormData formData, {
    Map<String, dynamic>? params,
    Options? requestOptions,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    ApiProviderController? controller,
  }) {
    return _request(
      path: path,
      controller: controller,
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
  /// Returns an [ApiResponse] with either the result of the download or error
  /// details.
  ///
  /// > **Note:** This method is not supported on Web. Calling it on a Web
  /// > target will result in an error response.
  Future<ApiResponse> download(
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
    return _request(
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

  /// Executes an HTTP request with unified error handling, timing, and optional
  /// controller state management.
  Future<ApiResponse> _request({
    required String path,
    required Future<Response<dynamic>> Function() request,
    ApiProviderController? controller,
  }) async {
    if (controller != null) {
      controller.loading();
    }

    final url = '${dio.options.baseUrl}$path';
    final stopwatch = Stopwatch()..start();

    try {
      final response = await request();
      stopwatch.stop();
      final result = _handleResponse(response, url, stopwatch.elapsed);

      if (controller != null) {
        controller.success(apiResponse: result);
      }

      return result;
    } on DioException catch (e) {
      stopwatch.stop();
      final error = _handleDioError(e, url, stopwatch.elapsed);

      if (controller != null) {
        controller.error(apiResponse: error);
      }

      return error;
    } on TimeoutException {
      stopwatch.stop();
      final error = _handleTimeOutException(url, stopwatch.elapsed);

      if (controller != null) {
        controller.error(apiResponse: error);
      }

      return error;
    } catch (e) {
      stopwatch.stop();
      final error = _handleUnexpectedException(e, url, stopwatch.elapsed);

      if (controller != null) {
        controller.error(apiResponse: error);
      }

      return error;
    }
  }

  ApiResponse _handleResponse(
    Response<dynamic> response,
    String? url,
    Duration duration,
  ) {
    // P3: guard against non-Map response bodies (arrays, strings, binary)
    final message =
        response.data is Map ? response.data['message'] as String? : null;

    // Extract headers into a plain Map<String, List<String>>
    final headers = response.headers.map;

    return ApiResponse(
      success: true,
      statusCode: response.statusCode,
      data: response.data,
      url: url,
      message: message ?? 'Success',
      headers: headers,
      requestDuration: duration,
    );
  }

  ApiResponse _handleDioError(
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
    };

    // Extract structured error data when the body is a Map
    final errorData = error.response?.data is Map
        ? error.response?.data
        : error.response?.data;

    return ApiResponse(
      success: false,
      statusCode: error.response?.statusCode,
      data: errorData,
      url: url,
      message: errorMessage,
      headers: error.response?.headers.map,
      requestDuration: duration,
    );
  }

  ApiResponse _handleTimeOutException(String? url, Duration duration) {
    return ApiResponse(
      success: false,
      message: 'Server not responding',
      url: url,
      requestDuration: duration,
    );
  }

  ApiResponse _handleUnexpectedException(
    Object? error,
    String? url,
    Duration duration,
  ) {
    return ApiResponse(
      success: false,
      url: url,
      data: error,
      message: error.toString(),
      requestDuration: duration,
    );
  }
}
