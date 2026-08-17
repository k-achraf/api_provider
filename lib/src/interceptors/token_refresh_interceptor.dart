import 'dart:async';

import 'package:dio/dio.dart';
import 'package:easy_api_provider/src/models/token_refresh_config.dart';

/// A Dio interceptor that transparently handles token expiry.
///
/// When a response status code matches one of the [TokenRefreshConfig.refreshStatusCodes]
/// (default: 401), this interceptor:
///
/// 1. Pauses all subsequent outgoing requests
/// 2. Calls [TokenRefreshConfig.onRefresh] to obtain a new token
/// 3. Updates the Dio `Authorization` header with the new token
/// 4. Replays all queued and the original failed requests
/// 5. Calls [TokenRefreshConfig.onLogout] if refresh fails or returns `null`
///
/// Only one refresh attempt is made concurrently — multiple simultaneous 401
/// responses are batched and all resolved with a single refresh call.
class TokenRefreshInterceptor extends Interceptor {
  /// The Dio instance used to replay queued requests.
  final Dio dio;

  /// Token refresh configuration.
  final TokenRefreshConfig config;

  bool _isRefreshing = false;
  final _queue = <_QueuedRequest>[];

  /// Creates a [TokenRefreshInterceptor] attached to [dio].
  TokenRefreshInterceptor({required this.dio, required this.config});

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;

    if (!config.refreshStatusCodes.contains(statusCode)) {
      return handler.next(err);
    }

    // Avoid infinite loop if the refresh endpoint itself returns 401
    if (_isRefreshRequest(err.requestOptions)) {
      _failAll(err);
      config.onLogout();
      return handler.next(err);
    }

    if (_isRefreshing) {
      // Queue this request to be replayed after refresh completes
      final completer = Completer<Response<dynamic>>();
      _queue.add(_QueuedRequest(
        options: err.requestOptions,
        completer: completer,
      ));
      try {
        final response = await completer.future;
        return handler.resolve(response);
      } on DioException catch (e) {
        return handler.next(e);
      }
    }

    _isRefreshing = true;

    try {
      final newToken = await config.onRefresh();

      if (newToken == null) {
        _failAll(err);
        config.onLogout();
        return handler.next(err);
      }

      // Update the Authorization header on the Dio instance
      dio.options.headers['Authorization'] = newToken;

      // Replay the original failed request with the new token
      err.requestOptions.headers['Authorization'] = newToken;
      final response = await dio.fetch<dynamic>(err.requestOptions);

      // Replay all queued requests
      _resolveAll(newToken);

      return handler.resolve(response);
    } catch (e) {
      _failAll(err);
      config.onLogout();
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  bool _isRefreshRequest(RequestOptions options) {
    // Detect if this is a re-try of a refresh that failed
    return options.extra['_is_refresh_replay'] == true;
  }

  void _resolveAll(String newToken) {
    final pending = List<_QueuedRequest>.from(_queue);
    _queue.clear();
    for (final req in pending) {
      req.options.headers['Authorization'] = newToken;
      req.options.extra['_is_refresh_replay'] = true;
      dio
          .fetch<dynamic>(req.options)
          .then(req.completer.complete)
          .catchError((Object e) {
        if (e is DioException) {
          req.completer.completeError(e);
        } else {
          req.completer.completeError(
            DioException(requestOptions: req.options, error: e),
          );
        }
      });
    }
  }

  void _failAll(DioException err) {
    final pending = List<_QueuedRequest>.from(_queue);
    _queue.clear();
    for (final req in pending) {
      req.completer.completeError(err);
    }
  }
}

class _QueuedRequest {
  final RequestOptions options;
  final Completer<Response<dynamic>> completer;
  _QueuedRequest({required this.options, required this.completer});
}
