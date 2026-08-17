import 'package:dio/dio.dart';
import 'package:easy_api_provider/src/models/retry_config.dart';

/// A Dio interceptor that automatically retries failed requests according to
/// the provided [RetryConfig].
///
/// Retries are triggered on:
/// - [DioExceptionType.connectionTimeout]
/// - [DioExceptionType.receiveTimeout]
/// - [DioExceptionType.sendTimeout]
/// - [DioExceptionType.connectionError]
/// - HTTP 5xx server errors
///
/// Retries are **not** triggered on:
/// - 4xx client errors
/// - [DioExceptionType.cancel] (cancelled by caller)
/// - [DioExceptionType.badCertificate]
class RetryInterceptor extends Interceptor {
  /// The Dio instance used to replay failed requests.
  final Dio dio;

  /// The global retry configuration. May be overridden per-request via the
  /// `retryConfig` key in [RequestOptions.extra].
  final RetryConfig config;

  /// Creates a [RetryInterceptor] attached to [dio].
  RetryInterceptor({required this.dio, required this.config});

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Resolve the effective config for this request
    final effectiveConfig = _resolveConfig(err.requestOptions);

    if (effectiveConfig == null || effectiveConfig.isDisabled) {
      return handler.next(err);
    }

    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    final attempt = _getAttempt(err.requestOptions);
    if (attempt >= effectiveConfig.attempts) {
      return handler.next(err);
    }

    // Wait before retrying
    final delay = effectiveConfig.delayFor(attempt + 1);
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    // Increment the attempt counter
    final options = err.requestOptions;
    options.extra[_kAttemptKey] = attempt + 1;

    try {
      final response = await dio.fetch<dynamic>(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static const _kAttemptKey = '_retry_attempt';
  static const _kConfigKey = '_retry_config';

  RetryConfig? _resolveConfig(RequestOptions options) {
    final override = options.extra[_kConfigKey];
    if (override != null && override is RetryConfig) return override;
    return config;
  }

  int _getAttempt(RequestOptions options) {
    return (options.extra[_kAttemptKey] as int?) ?? 0;
  }

  bool _shouldRetry(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final code = err.response?.statusCode ?? 0;
        return code >= 500; // only 5xx, not 4xx
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return false;
    }
  }

  /// Injects the per-request [RetryConfig] into request options.
  ///
  /// Called by [ApiProvider] when a `retryConfig` is provided to a method.
  static Options optionsWithConfig(RetryConfig cfg, [Options? base]) {
    final extra = Map<String, dynamic>.from(base?.extra ?? {});
    extra[_kConfigKey] = cfg;
    return (base ?? Options()).copyWith(extra: extra);
  }
}
