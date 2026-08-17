import 'package:easy_api_provider/src/models/api_response.dart';
import 'package:easy_api_provider/src/resources/api_provider.dart';

/// A utility that wraps a paginated GET endpoint and manages page state.
///
/// [ApiPaginator] keeps track of the current page, whether more data is
/// available, and accumulates all loaded items across pages. It works with
/// any offset/page-based API.
///
/// ### Example
/// ```dart
/// final paginator = ApiPaginator(
///   provider: ApiProvider.instance,
///   path: '/posts',
///   pageParamKey: 'page',
///   limitParamKey: 'limit',
///   limit: 20,
/// );
///
/// // Load first page
/// final response = await paginator.loadNext();
///
/// // Load subsequent pages
/// if (paginator.hasMore) {
///   await paginator.loadNext();
/// }
///
/// // Access all accumulated items
/// print(paginator.items);
///
/// // Reset to start over
/// paginator.reset();
/// ```
class ApiPaginator {
  /// The [ApiProvider] instance used to make requests.
  final ApiProvider provider;

  /// The API path to paginate (e.g., `/posts`).
  final String path;

  /// The query parameter name for the current page number.
  ///
  /// Defaults to `'page'`.
  final String pageParamKey;

  /// The query parameter name for the page size.
  ///
  /// Defaults to `'limit'`.
  final String limitParamKey;

  /// The number of items to request per page.
  final int limit;

  /// Additional query parameters to include in every request.
  final Map<String, dynamic>? extraParams;

  /// A function that extracts the list of items from the [ApiResponse].
  ///
  /// Defaults to treating `response.data` as a `List<dynamic>`.
  ///
  /// Override this when the items are nested inside the response:
  /// ```dart
  /// itemsExtractor: (res) => (res.data as Map)['posts'] as List,
  /// ```
  final List<dynamic> Function(ApiResponse response)? itemsExtractor;

  int _page = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  final _items = <dynamic>[];

  /// Creates an [ApiPaginator].
  ApiPaginator({
    required this.provider,
    required this.path,
    this.pageParamKey = 'page',
    this.limitParamKey = 'limit',
    this.limit = 20,
    this.extraParams,
    this.itemsExtractor,
  });

  /// The current page number (1-indexed).
  int get currentPage => _page;

  /// `true` if there are more pages to load.
  bool get hasMore => _hasMore;

  /// `true` if a request is currently in progress.
  bool get isLoading => _isLoading;

  /// All items accumulated across all loaded pages.
  List<dynamic> get items => List.unmodifiable(_items);

  /// Loads the next page and appends the results to [items].
  ///
  /// Returns the [ApiResponse] from the network. If there are no more pages
  /// or a request is already in progress, returns `null`.
  Future<ApiResponse?> loadNext() async {
    if (!_hasMore || _isLoading) return null;

    _isLoading = true;

    final params = <String, dynamic>{
      pageParamKey: _page,
      limitParamKey: limit,
      ...?extraParams,
    };

    final response = await provider.get(path, params: params);

    _isLoading = false;

    if (!response.success) return response;

    final newItems = itemsExtractor != null
        ? itemsExtractor!(response)
        : _defaultExtractor(response);

    _items.addAll(newItems);

    if (newItems.length < limit) {
      _hasMore = false; // received fewer items than requested → last page
    } else {
      _page++;
    }

    return response;
  }

  /// Resets the paginator to its initial state.
  ///
  /// Clears all accumulated [items] and resets the page counter.
  void reset() {
    _page = 1;
    _hasMore = true;
    _isLoading = false;
    _items.clear();
  }

  List<dynamic> _defaultExtractor(ApiResponse response) {
    final data = response.data;
    if (data is List) return data;
    if (data is Map) {
      // Try common wrapper keys
      for (final key in ['data', 'items', 'results', 'records']) {
        if (data[key] is List) return data[key] as List;
      }
    }
    return [];
  }
}
