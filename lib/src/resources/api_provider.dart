import 'dart:async';

import 'package:ansicolor/ansicolor.dart';
import 'package:dio/dio.dart';
import 'package:easy_api_provider/src/controllers/api_provider_controller.dart';
import 'package:easy_api_provider/src/models/api_provider_config.dart';
import 'package:easy_api_provider/src/models/api_response.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

/// A singleton class that provides a configured Dio instance for making HTTP
/// requests.
///
/// This class supports custom configuration, request/response/error
/// interceptors, and optional logging using [TalkerDioLogger].
class ApiProvider {
  /// Private constructor for the singleton pattern.
  ApiProvider._();

  /// Singleton instance of [ApiProvider].
  static final instance = ApiProvider._();

  /// Internal Dio client instance.
  Dio? _dio;

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
  /// This method configures base options, adds interceptors for request,
  /// response, and error handling, sets authorization headers, and enables
  /// request logging if configured.
  void init(ApiProviderConfig config) {
    _dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        responseType: config.responseType,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        contentType: config.contentType,
        maxRedirects: config.maxRedirects,
        headers: config.headers,
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
  void setAuthorisation(dynamic authorization) {
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

  /// Sends a POST request to the specified [path].
  ///
  /// Returns an [ApiResponse] that contains either the result of the request
  /// or error details.
  Future<ApiResponse> post(
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

  /// Downloads a file from the given [urlPath] and saves it to [savePath].
  ///
  /// Returns an [ApiResponse] with either the result of the download or error
  /// details.
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

  /// Executes an HTTP request with unified error handling and optional
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

    try {
      final response = await request();
      final result = _handleResponse(response, url);

      if (controller != null) {
        controller.success(apiResponse: result);
      }

      return result;
    } on DioException catch (e) {
      final error = _handleDioError(e, url);

      if (controller != null) {
        controller.error(apiResponse: error);
      }

      return error;
    } on TimeoutException {
      final error = _handleTimeOutException(url);

      if (controller != null) {
        controller.error(apiResponse: error);
      }

      return error;
    } catch (e) {
      final error = _handleUnexpectedException(e, url);

      if (controller != null) {
        controller.error(apiResponse: error);
      }

      return error;
    }
  }

  ApiResponse _handleResponse(Response<dynamic> response, String? url) {
    return ApiResponse(
      success: true,
      statusCode: response.statusCode,
      data: response.data,
      url: url,
      message: response.data?['message'] ?? 'Success',
    );
  }

  ApiResponse _handleDioError(DioException error, String? url) {
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

    return ApiResponse(
      success: false,
      statusCode: error.response?.statusCode,
      data: error.response?.data,
      url: url,
      message: errorMessage,
    );
  }

  ApiResponse _handleTimeOutException(String? url) {
    return ApiResponse(
      success: false,
      message: 'Server not responding',
      url: url,
    );
  }

  ApiResponse _handleUnexpectedException(Object? error, String? url) {
    return ApiResponse(
      success: false,
      url: url,
      data: error,
      message: error.toString(),
    );
  }
}
