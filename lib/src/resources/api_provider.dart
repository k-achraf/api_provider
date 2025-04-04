import 'dart:async';

import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:ansicolor/ansicolor.dart';

import '../../easy_api_provider.dart';

class ApiProvider {
  ApiProvider._();

  static final instance = ApiProvider._();

  Dio? _dio;

  Dio get dio {
    if (_dio == null) {
      throw Exception('You need to call "init" function first');
    }
    return _dio!;
  }

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
      )
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (
            RequestOptions options,
            RequestInterceptorHandler handler,
          ) {
            config.onRequest?.call(options);

            return handler.next(options);
          },
          onError: (DioException error, ErrorInterceptorHandler handler) {
            config.onError?.call(error);
            return handler.next(error);
          },
          onResponse: (
            Response<dynamic> response,
            ResponseInterceptorHandler handler,
          ) {
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
    if (config.headers != null) {
      dio.options.headers = config.headers;
    }
  }

  void setAuthorisation(dynamic authorization) {
    if (authorization == null) {
      dio.options.headers.remove('Authorization');
    } else {
      dio.options.headers['Authorization'] = authorization;
    }
  }

  void setBaseUrl(String baseUrl) {
    dio.options.baseUrl = baseUrl;
  }

  /*
    Handle request types
   */

  // Get method
  Future<ApiResponse> get(
    String path, {
    Map<String, dynamic>? params,
    Options? requestOptions,
    CancelToken? cancelToken,
    ProgressCallback? progressCallback,
    ApiProviderController? controller,
  }) async {
    if (controller != null) {
      controller.loading();
    }
    try {
      final Response response = await dio.get(
        path,
        queryParameters: params,
        cancelToken: cancelToken,
        onReceiveProgress: progressCallback,
        options: requestOptions,
      );

      ApiResponse r = _handleResponse(response, '${dio.options.baseUrl}/$path');
      if (controller != null) {
        controller.success(apiResponse: r);
      }

      return r;
    } on DioException catch (e) {
      ApiResponse error = _handleDioError(e, '${dio.options.baseUrl}/$path');
      if (controller != null) {
        controller.error(apiResponse: error);
      }

      return error;
    } on TimeoutException {
      ApiResponse error = _handleTimeOutException(
        '${dio.options.baseUrl}/$path',
      );
      if (controller != null) {
        controller.error(apiResponse: error);
      }

      return error;
    } catch (e) {
      ApiResponse error = _handleUnexpectedException(
        e,
        '${dio.options.baseUrl}/$path',
      );
      if (controller != null) {
        controller.error(apiResponse: error);
      }

      return error;
    }
  }

  // Post method
  Future<ApiResponse> post(
    String path, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? data,
    Options? requestOptions,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    ProgressCallback? onSendProgress,
    ApiProviderController? controller,
  }) async {
    if (controller != null) {
      controller.loading();
    }
    try {
      final Response response = await dio.post(
        path,
        data: data,
        queryParameters: params,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
        options: requestOptions,
      );

      ApiResponse r = _handleResponse(response, '${dio.options.baseUrl}/$path');
      if (controller != null) {
        controller.success(apiResponse: r);
      }

      return r;
    } on DioException catch (e) {
      ApiResponse error = _handleDioError(e, '${dio.options.baseUrl}/$path');
      if (controller != null) {
        controller.error(apiResponse: error);
      }

      return error;
    } on TimeoutException {
      ApiResponse error = _handleTimeOutException(
        '${dio.options.baseUrl}/$path',
      );
      if (controller != null) {
        controller.error(apiResponse: error);
      }

      return error;
    } catch (e) {
      ApiResponse error = _handleUnexpectedException(
        e,
        '${dio.options.baseUrl}/$path',
      );
      if (controller != null) {
        controller.error(apiResponse: error);
      }

      return error;
    }
  }

  // Patch method
  Future<ApiResponse> patch(
    String path, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? data,
    Options? requestOptions,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    ProgressCallback? onSendProgress,
    ApiProviderController? controller,
  }) async {
    if (controller != null) {
      controller.loading();
    }
    try {
      final Response response = await dio.patch(
        path,
        data: data,
        queryParameters: params,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
        options: requestOptions,
      );

      ApiResponse r = _handleResponse(response, '${dio.options.baseUrl}/$path');
      if (controller != null) {
        controller.success(apiResponse: r);
      }

      return r;
    } on DioException catch (e) {
      ApiResponse error = _handleDioError(e, '${dio.options.baseUrl}/$path');
      if (controller != null) {
        controller.error(apiResponse: error);
      }

      return error;
    } on TimeoutException {
      ApiResponse error = _handleTimeOutException(
        '${dio.options.baseUrl}/$path',
      );
      if (controller != null) {
        controller.error(apiResponse: error);
      }

      return error;
    } catch (e) {
      ApiResponse error = _handleUnexpectedException(
        e,
        '${dio.options.baseUrl}/$path',
      );
      if (controller != null) {
        controller.error(apiResponse: error);
      }

      return error;
    }
  }

  // Put method
  Future<ApiResponse> put(
    String path, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? data,
    Options? requestOptions,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    ProgressCallback? onSendProgress,
    ApiProviderController? controller,
  }) async {
    if (controller != null) {
      controller.loading();
    }
    try {
      final Response response = await dio.put(
        path,
        data: data,
        queryParameters: params,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
        options: requestOptions,
      );

      ApiResponse r = _handleResponse(response, '${dio.options.baseUrl}/$path');
      if (controller != null) {
        controller.success(apiResponse: r);
      }

      return r;
    } on DioException catch (e) {
      ApiResponse error = _handleDioError(e, '${dio.options.baseUrl}/$path');
      if (controller != null) {
        controller.error(apiResponse: error);
      }

      return error;
    } on TimeoutException {
      ApiResponse error = _handleTimeOutException(
        '${dio.options.baseUrl}/$path',
      );
      if (controller != null) {
        controller.error(apiResponse: error);
      }

      return error;
    } catch (e) {
      ApiResponse error = _handleUnexpectedException(
        e,
        '${dio.options.baseUrl}/$path',
      );
      if (controller != null) {
        controller.error(apiResponse: error);
      }

      return error;
    }
  }

  // Delete method
  Future<ApiResponse> delete(
    String path, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? data,
    Options? requestOptions,
    CancelToken? cancelToken,
    ApiProviderController? controller,
  }) async {
    if (controller != null) {
      controller.loading();
    }
    try {
      final Response response = await dio.delete(
        path,
        data: data,
        queryParameters: params,
        cancelToken: cancelToken,
        options: requestOptions,
      );

      ApiResponse r = _handleResponse(response, '${dio.options.baseUrl}/$path');
      if (controller != null) {
        controller.success(apiResponse: r);
      }

      return r;
    } on DioException catch (e) {
      ApiResponse error = _handleDioError(e, '${dio.options.baseUrl}/$path');
      if (controller != null) {
        controller.error(apiResponse: error);
      }

      return error;
    } on TimeoutException {
      ApiResponse error = _handleTimeOutException(
        '${dio.options.baseUrl}/$path',
      );
      if (controller != null) {
        controller.error(apiResponse: error);
      }

      return error;
    } catch (e) {
      ApiResponse error = _handleUnexpectedException(
        e,
        '${dio.options.baseUrl}/$path',
      );
      if (controller != null) {
        controller.error(apiResponse: error);
      }

      return error;
    }
  }

  // Download method
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
  }) async {
    if (controller != null) {
      controller.loading();
    }
    try {
      final Response response = await dio.download(
        urlPath,
        savePath,
        options: requestOptions,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
        data: data,
        deleteOnError: deleteOnError,
        fileAccessMode: FileAccessMode.write,
        queryParameters: params,
      );

      ApiResponse r = _handleResponse(
        response,
        '${dio.options.baseUrl}/$urlPath',
      );
      if (controller != null) {
        controller.success(apiResponse: r);
      }

      return r;
    } on DioException catch (e) {
      ApiResponse error = _handleDioError(e, '${dio.options.baseUrl}/$urlPath');
      if (controller != null) {
        controller.error(apiResponse: error);
      }

      return error;
    } on TimeoutException {
      ApiResponse error = _handleTimeOutException(
        '${dio.options.baseUrl}/$urlPath',
      );
      if (controller != null) {
        controller.error(apiResponse: error);
      }

      return error;
    } catch (e) {
      ApiResponse error = _handleUnexpectedException(
        e,
        '${dio.options.baseUrl}/$urlPath',
      );
      if (controller != null) {
        controller.error(apiResponse: error);
      }

      return error;
    }
  }

  ApiResponse _handleResponse(Response response, String? url) {
    return ApiResponse(
      success: true,
      statusCode: response.statusCode,
      data: response.data,
      url: url,
      message: response.data?['message'] ?? 'Success',
    );
  }

  ApiResponse _handleDioError(DioException error, String? url) {
    String errorMessage = 'Unexpected error occurred';
    if (error.type == DioExceptionType.connectionTimeout) {
      errorMessage = 'Connection timeout';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Receive timeout';
    } else if (error.type == DioExceptionType.badResponse) {
      errorMessage = 'Server error: ${error.response?.statusCode}';
    }

    return ApiResponse(
      success: false,
      statusCode: error.response?.statusCode,
      data: error.response?.data,
      url: url,
      message: errorMessage,
    );
  }

  // ApiResponse _handleSocketException(String? url) {
  //   return ApiResponse(
  //     success: false,
  //     url: url,
  //     message: 'No internet connection',
  //   );
  // }

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
