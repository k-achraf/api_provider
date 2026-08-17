import 'dart:async';

import 'package:dio/dio.dart';

/// A Dio interceptor that deduplicates identical in-flight GET requests.
///
/// When two or more GET requests to the same URL (including query parameters)
/// are made while the first is still pending, only **one** actual network
/// request is sent. All callers receive the same response when it arrives.
///
/// This prevents wasteful parallel network calls caused by rapid UI rebuilds
/// or multiple widgets independently fetching the same endpoint.
///
/// Non-GET requests are always passed through unmodified.
class DedupInterceptor extends Interceptor {
  // key: full URL string -> pending completers waiting for the response
  final _pending = <String, List<Completer<Response<dynamic>>>>{};

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (options.method.toUpperCase() != 'GET') {
      return handler.next(options);
    }

    final key = _buildKey(options);

    if (_pending.containsKey(key)) {
      // Another identical request is in flight — queue this one
      final completer = Completer<Response<dynamic>>();
      _pending[key]!.add(completer);
      // Resolve or reject the handler when the in-flight response arrives
      completer.future.then(
        (response) => handler.resolve(response, true),
        onError: (Object e) {
          if (e is DioException) {
            handler.reject(e, true);
          } else {
            handler.reject(
              DioException(requestOptions: options, error: e),
              true,
            );
          }
        },
      );
      return;
    }

    // First request for this key — mark as pending and let it through
    _pending[key] = [];
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final key = _buildKey(response.requestOptions);
    _resolveWaiters(key, response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final key = _buildKey(err.requestOptions);
    _rejectWaiters(key, err);
    handler.next(err);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _buildKey(RequestOptions options) {
    final uri = options.uri.toString();
    return '${options.method.toUpperCase()}:$uri';
  }

  void _resolveWaiters(String key, Response<dynamic> response) {
    final waiters = _pending.remove(key) ?? [];
    for (final c in waiters) {
      c.complete(response);
    }
  }

  void _rejectWaiters(String key, DioException err) {
    final waiters = _pending.remove(key) ?? [];
    for (final c in waiters) {
      c.completeError(err);
    }
  }
}
