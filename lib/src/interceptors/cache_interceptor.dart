import 'package:dio/dio.dart';
import 'package:easy_api_provider/src/models/cache_config.dart';

/// A Dio interceptor that provides transparent in-memory response caching
/// for GET requests.
///
/// Responses are stored in an [ApiCache] instance and served from cache
/// while the entry is still within its TTL. Expired or missing entries
/// trigger a real network request.
///
/// Only GET requests are cached. POST, PUT, PATCH, DELETE, and HEAD
/// requests always bypass the cache.
class CacheInterceptor extends Interceptor {
  /// The cache storage used by this interceptor.
  final ApiCache cache;

  /// Creates a [CacheInterceptor] backed by the given [cache].
  CacheInterceptor({required this.cache});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (options.method.toUpperCase() != 'GET') {
      return handler.next(options);
    }

    final key = _buildKey(options);
    final cached = cache.get(key);

    if (cached != null) {
      // Build a synthetic response from the cached data
      final response = Response<dynamic>(
        requestOptions: options,
        data: cached,
        statusCode: 200,
        statusMessage: 'OK (cached)',
      );
      return handler.resolve(response, true);
    }

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (response.requestOptions.method.toUpperCase() == 'GET') {
      final key = _buildKey(response.requestOptions);
      cache.set(key, response.data);
    }
    handler.next(response);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _buildKey(RequestOptions options) => options.uri.toString();
}
