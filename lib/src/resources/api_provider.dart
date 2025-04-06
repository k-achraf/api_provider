import 'dart:async';

import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:ansicolor/ansicolor.dart';

import '../../easy_api_provider.dart';

/// A singleton class that provides a configured Dio instance for making HTTP requests.
///
/// This class supports custom configuration, request/response/error interceptors,
/// and optional logging using [TalkerDioLogger].
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
  /// This method configures base options, adds interceptors for request, response,
  /// and error handling, sets authorization headers, and enables request logging
  /// if configured.
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
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          config.onRequest?.call(options);
          return handler.next(options);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) {
          config.onError?.call(error);
          return handler.next(error);
        },
        onResponse: (Response<dynamic> response, ResponseInterceptorHandler handler) {
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

  /// Sends a GET request to the specified [path] using Dio.
  ///
  /// You can optionally pass:
  /// - [params]: A map of query parameters.
  /// - [requestOptions]: Custom request options.
  /// - [cancelToken]: A token to cancel the request.
  /// - [progressCallback]: A callback to track progress while receiving data.
  /// - [controller]: An [ApiProviderController] to manage UI state like loading, success, or error.
  ///
  /// Returns an [ApiResponse] which contains the result of the request.
  /// If an error occurs, the [ApiResponse] will include the appropriate error data.
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

  /// Sends a POST request to the specified [path] using Dio.
  ///
  /// Optional parameters:
  /// - [params]: A map of query parameters to be appended to the URL.
  /// - [data]: A map of data to be sent in the request body.
  /// - [requestOptions]: Custom [Options] such as headers or content type.
  /// - [cancelToken]: A [CancelToken] to cancel the request if needed.
  /// - [onReceiveProgress]: A callback to track download progress.
  /// - [onSendProgress]: A callback to track upload progress.
  /// - [controller]: An [ApiProviderController] to handle loading, success, or error states.
  ///
  /// Returns an [ApiResponse] that contains either the result of the request or error details.

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

  /// Sends a PATCH request to the specified [path] using Dio.
  ///
  /// Optional parameters:
  /// - [params]: A map of query parameters to be appended to the URL.
  /// - [data]: A map of data to be sent in the request body.
  /// - [requestOptions]: Custom [Options] such as headers or content type.
  /// - [cancelToken]: A [CancelToken] to cancel the request if needed.
  /// - [onReceiveProgress]: A callback to track download progress.
  /// - [onSendProgress]: A callback to track upload progress.
  /// - [controller]: An [ApiProviderController] to handle loading, success, or error states.
  ///
  /// Returns an [ApiResponse] that contains either the result of the request or error details.

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

  /// Sends a PUT request to the specified [path] using Dio.
  ///
  /// Optional parameters:
  /// - [params]: A map of query parameters to be appended to the URL.
  /// - [data]: A map of data to be sent in the request body.
  /// - [requestOptions]: Custom [Options] such as headers or content type.
  /// - [cancelToken]: A [CancelToken] to cancel the request if needed.
  /// - [onReceiveProgress]: A callback to track download progress.
  /// - [onSendProgress]: A callback to track upload progress.
  /// - [controller]: An [ApiProviderController] to handle loading, success, or error states.
  ///
  /// Returns an [ApiResponse] that contains either the result of the request or error details.

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

  /// Sends a DELETE request to the specified [path] using Dio.
  ///
  /// Optional parameters:
  /// - [params]: A map of query parameters to be appended to the URL.
  /// - [data]: A map of data to be sent in the request body.
  /// - [requestOptions]: Custom [Options] such as headers or content type.
  /// - [cancelToken]: A [CancelToken] to cancel the request if needed.
  /// - [onReceiveProgress]: A callback to track download progress.
  /// - [onSendProgress]: A callback to track upload progress.
  /// - [controller]: An [ApiProviderController] to handle loading, success, or error states.
  ///
  /// Returns an [ApiResponse] that contains either the result of the request or error details.

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

  /// Downloads a file from the given [urlPath] and saves it to [savePath].
  ///
  /// Optional parameters:
  /// - [params]: A map of query parameters to be appended to the URL.
  /// - [data]: A map of data to be sent with the request.
  /// - [requestOptions]: Custom Dio [Options] such as headers.
  /// - [cancelToken]: A [CancelToken] to cancel the request if needed.
  /// - [onReceiveProgress]: A callback to track download progress.
  /// - [onSendProgress]: A callback to track upload progress (if any).
  /// - [deleteOnError]: If true (default), deletes the file if an error occurs during download.
  /// - [controller]: An [ApiProviderController] to handle loading, success, or error states.
  ///
  /// Returns an [ApiResponse] with either the result of the download or error details.
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

  /// Handles the response from the API request and returns an [ApiResponse].
  ///
  /// This function takes the [Response] from Dio and processes the status code,
  /// data, and message from the response. It returns an [ApiResponse] indicating
  /// whether the request was successful or not.
  ///
  /// - [response]: The [Response] object returned by the Dio request.
  /// - [url]: The URL of the request to be included in the [ApiResponse] for logging or debugging.
  ///
  /// Returns an [ApiResponse] object with the following fields:
  /// - `success`: A boolean indicating the success of the request.
  /// - `statusCode`: The HTTP status code from the response.
  /// - `data`: The data returned from the API.
  /// - `url`: The URL of the request.
  /// - `message`: The message from the response data or a default 'Success' message.
  ApiResponse _handleResponse(Response response, String? url) {
    return ApiResponse(
      success: true,
      statusCode: response.statusCode,
      data: response.data,
      url: url,
      message: response.data?['message'] ?? 'Success',
    );
  }


  /// Handles errors from Dio requests and returns an [ApiResponse].
  ///
  /// This function processes the error type and generates an appropriate error message.
  ///
  /// - [error]: The [DioException] object that was thrown during the request.
  /// - [url]: The URL of the request, which can be used for logging or debugging.
  ///
  /// Returns an [ApiResponse] object with the following fields:
  /// - `success`: A boolean indicating the success of the request (always `false` for errors).
  /// - `statusCode`: The HTTP status code from the error response.
  /// - `data`: The data from the error response.
  /// - `url`: The URL of the request.
  /// - `message`: A string describing the error.
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

  /// Handles timeout exceptions and returns an [ApiResponse].
  ///
  /// This function generates a custom message when the server does not respond.
  ///
  /// - [url]: The URL of the request to include in the response.
  ///
  /// Returns an [ApiResponse] object with the following fields:
  /// - `success`: A boolean indicating the success of the request (always `false` for errors).
  /// - `message`: A custom message indicating that the server is not responding.
  /// - `url`: The URL of the request.
  ApiResponse _handleTimeOutException(String? url) {
    return ApiResponse(
      success: false,
      message: 'Server not responding',
      url: url,
    );
  }

  /// Handles unexpected exceptions and returns an [ApiResponse].
  ///
  /// This function catches any unexpected errors and returns them as part of the response.
  ///
  /// - [error]: The error object that was thrown during the request.
  /// - [url]: The URL of the request to include in the response.
  ///
  /// Returns an [ApiResponse] object with the following fields:
  /// - `success`: A boolean indicating the success of the request (always `false` for errors).
  /// - `data`: The error data.
  /// - `message`: A string describing the error.
  /// - `url`: The URL of the request.
  ApiResponse _handleUnexpectedException(Object? error, String? url) {
    return ApiResponse(
      success: false,
      url: url,
      data: error,
      message: error.toString(),
    );
  }

}
