import 'package:dio/dio.dart';

typedef OnRequestCallback = void Function(
  RequestOptions options,
);

typedef OnErrorCallback = void Function(
  DioException error,
);

typedef OnResponseCallback = void Function(
  Response<dynamic> response,
);

class ApiProviderConfig{
  final String baseUrl;
  final dynamic authorization;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final ResponseType responseType;
  final String contentType;
  final bool requestLogger;
  final int maxRedirects;
  final bool showResultMessage;
  final ListFormat? listFormat;
  final Map<String, dynamic>? extra;
  final OnRequestCallback? onRequest;
  final OnErrorCallback? onError;
  final OnResponseCallback? onResponse;
  final Map<String, dynamic>? headers;

  const ApiProviderConfig(this.baseUrl, {
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.responseType = ResponseType.json,
    this.requestLogger = true,
    this.maxRedirects = 1,
    this.showResultMessage = false,
    this.contentType = 'application/json',
    this.headers,
    this.authorization,
    this.listFormat,
    this.extra,
    this.onRequest,
    this.onError,
    this.onResponse
  });
}