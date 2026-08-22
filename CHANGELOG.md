# Changelog

## [3.0.0] - 2026-08-22
### Breaking Changes
- `ApiResponse` is now generic: `ApiResponse<T>`. The `data` field changes from
  `dynamic` to `T?`. Existing code using `ApiResponse` without a type parameter
  continues to work as `ApiResponse<dynamic>` — **no changes required** for
  callers that do not use the new `decoder` param.
- All HTTP methods (`get`, `post`, `put`, `patch`, `delete`, `upload`, `download`)
  are now generic: `Future<ApiResponse<T>>`. Type inference means existing call
  sites need no changes.

### Added
- `decoder` optional parameter on all HTTP methods — pass a function to decode
  the raw response body into a strongly-typed object with zero casts:
  ```dart
  final ApiResponse<List<Post>> res = await ApiProvider.instance.get<List<Post>>(
    '/posts',
    decoder: (data) => (data['posts'] as List).map(Post.fromJson).toList(),
  );
  ```

### Fixed
- Non-exhaustive `DioExceptionType` switch statements in `ApiProvider._handleDioError`
  and `RetryInterceptor._shouldRetry` that failed static analysis after dio added
  `DioExceptionType.transformTimeout`. Both now fall back to a safe default, so
  future `DioExceptionType` additions won't break analysis again.
- Applied `dart format` across the package for a clean `pub.dev` static analysis
  score.

### Changed
- Reworded the package description and README intro to explicitly mention
  "REST API client" and "API provider" for better `pub.dev` search relevance.
- Swapped the `request` topic for `rest` to match how comparable packages are
  tagged.

---

## [2.8.0] - 2026-08-17
### Added
- **Token refresh interceptor** — transparent 401 → refresh → replay flow.
  Configure via `ApiProviderConfig.tokenRefresh: TokenRefreshConfig(...)`:
  - Queues all concurrent requests on 401, performs a single refresh, then
    replays all queued requests with the new token
  - Calls `onLogout` if refresh fails or returns `null`
  - Configurable `refreshStatusCodes` (default `[401]`)
- **`ApiPaginator`** — stateful pagination helper for offset/page APIs:
  - `loadNext()` fetches the next page and appends to `items`
  - `hasMore`, `isLoading`, `currentPage`, `reset()` state accessors
  - Smart `itemsExtractor` with auto-detection of common wrapper keys
    (`data`, `items`, `results`, `records`)

---

## [2.7.0] - 2026-08-17
### Added
- **In-memory GET response cache** — configure via `ApiProviderConfig.cache: CacheConfig(ttl: ...)`:
  - TTL-based expiry, LRU eviction when `maxSize` is exceeded
  - `ApiProvider.clearCache()` to invalidate all entries
  - `ApiProvider.cacheSize` getter to inspect current cache size
  - `ApiCache` is exported for advanced use / testing
- **`MultiApiProvider`** — named registry for independent `ApiProvider` instances:
  - `MultiApiProvider.register(name, provider)` — register by name
  - `MultiApiProvider.of(name)` — retrieve anywhere, throws `StateError` if missing
  - `MultiApiProvider.has(name)`, `unregister(name)`, `clear()`, `registeredNames`

---

## [2.6.0] - 2026-08-17
### Added
- **Auto-retry interceptor** — configure via `ApiProviderConfig.retry: RetryConfig(...)`:
  - Retries on `connectionTimeout`, `receiveTimeout`, `sendTimeout`,
    `connectionError`, and HTTP 5xx errors
  - Does **not** retry on 4xx client errors or cancelled requests
  - Supports constant delay (default) or exponential back-off
    (`useExponentialBackoff: true`)
  - **Per-request override**: pass `retryConfig:` to any HTTP method to
    override the global config for that call
  - **Disable for one request**: `retryConfig: RetryConfig.none`
- **Request deduplication** — enable via `ApiProviderConfig.deduplicateRequests: true`:
  - Identical in-flight GET requests (same URL + params) are coalesced into
    one network call; all callers receive the same response
- **`RetryConfig` model** — exported for use in config and per-request overrides

---

## [2.5.0] - 2026-08-17

### Added
- `upload()` — dedicated multipart/`FormData` POST method with `onSendProgress`
  and `onReceiveProgress` tracking; sets `multipart/form-data` content type
  automatically, keeping it distinct from the generic `post()` method
- `head()` — HTTP HEAD method for checking resource existence or inspecting
  headers without downloading the response body
- `isInitialized` getter on `ApiProvider` — safe guard against calling methods
  before `init()` or after the provider has been closed
- `sendTimeout` in `ApiProviderConfig` (default 30 s) — wired into
  `BaseOptions.sendTimeout` so upload/send stalls are caught correctly
- `followRedirects` in `ApiProviderConfig` (default `true`) — exposes the
  Dio on/off redirect toggle alongside the existing `maxRedirects`
- `validateStatus` in `ApiProviderConfig` — lets callers decide which HTTP
  status codes count as success (e.g., treat 201/204 as success)
- `headers` field on `ApiResponse` — exposes the raw response headers
  (`Map<String, List<String>>`) for cache-control, pagination cursors, etc.
- `requestDuration` field on `ApiResponse` — records the total elapsed time
  of the request via `Stopwatch` for client-side performance monitoring
- `copyWith()` on `ApiResponse` — immutable transform helper for tests and
  middleware layers
- `toString()` override on `ApiResponse` — human-readable summary for logging
- `isLoading`, `isSuccess`, `isError`, `isEmpty`, `isIdle` boolean getters on
  `ApiProviderController` — convenient shorthands for the most common
  status checks
- `reset()` on `ApiProviderController` — restores to `idle` and clears
  `response` in a single call
- `previousStatus` field on `ApiProviderController` — tracks the state before
  the latest transition, useful for conditional UI (e.g., "was loading before")
- Auto-`empty` detection in `ApiProviderController.success()` — automatically
  transitions to `empty` when `data` is `null`, an empty `List`, or an empty
  `Map`, removing the need for manual `controller.empty()` calls
- `transitionDuration`, `switchInCurve`, `switchOutCurve` params on
  `ApiProviderUi` — lets callers control the `AnimatedSwitcher` timing and
  easing without forking the widget
- `transitionBuilder` param on `ApiProviderUi` — expose the full
  `AnimatedSwitcher.transitionBuilder` for custom slide/scale/fade effects

### Fixed
- `ApiProviderUi.didUpdateWidget` — the widget now correctly removes the old
  controller listener and attaches to the new one when the controller instance
  is swapped at runtime, preventing stale listener leaks
- `post()` `data` parameter widened from `Map<String, dynamic>?` to `dynamic`
  to avoid a type error when callers pass a `FormData` object directly

## [2.4.0] - 2026-08-17
### Security
- `requestLogger` now defaults to `false` — prevents Authorization tokens and
  response bodies from being logged in production builds (S2)
- Added `assert` on `ApiProviderConfig.authorization` to catch non-String
  values at development time (S1)
- Narrowed `setAuthorisation()` parameter from `dynamic` to `String?` (S1)

### Performance
- `init()` now calls `_dio?.close(force: true)` before creating a new Dio
  instance, preventing resource leaks on repeated initialisation (P1)
- Fixed `listen()` memory leak — callbacks are now stored in a `Map` and can
  be removed via the new `unlisten()` method; repeated `listen()` calls with
  the same callback are idempotent (P2)
- Fixed crash when API response body is a `List`, `String`, or binary blob —
  `response.data['message']` is now guarded with an `is Map` check (P3)
- `ApiProviderUi` now skips `setState` when the controller status hasn't
  actually changed, eliminating redundant widget rebuilds (P4)

### Added
- `ApiProvider.create()` factory for creating independent instances when
  multiple backends with different configs are needed concurrently (D1)
- `ApiProviderController.unlisten()` — pair to `listen()` for removing
  callbacks without holding a closure reference (P2)
- `ApiProviderController.dispose()` override that clears all wrapped
  listeners on teardown (P2)

### Fixed
- Added `assert(savePath.isNotEmpty)` to `download()` and documented that
  the method is not supported on Web (D3)
- Updated stale widget tests for `IdleWidget` and `EmptyWidget` to match
  the output introduced in v2.3.0 (D2)

## [2.3.0] - 2026-08-17
### Added
- Library-level dartdoc comment for the `easy_api_provider` export file
- Constructor-level doc comments on `ApiProviderController` and `ApiProviderUi` for 100% public API documentation coverage

### Fixed
- Default widgets (`IdleWidget`, `LoadingWidget`, `SuccessWidget`, `ApiErrorWidget`, `EmptyWidget`) now have complete dartdoc comments
- `EmptyWidget` displayed incorrect "Success" text — now correctly shows "Empty"
- `IdleWidget` now renders `SizedBox.shrink()` instead of a visible `Text('Idle')` label
- Made `SuccessWidget` and `ApiErrorWidget` bodies `const` for better performance

## [2.2.0] - 2026-06-03
### Added
- Animated preview GIF showcasing the example application
- Preview section in README

## [2.1.0] - 2026-06-02
### Added
- Full example application demonstrating all package features (CRUD, download, interceptors, auth)
- SEO-friendly pub.dev metadata and documentation

### Fixed
- Static analysis issues resolved
- Removed unused local variables in config tests

### Changed
- Excluded coverage directory from published package

## [2.0.0] - 2026-06-02
### Breaking Changes
- Bumped minimum Dart SDK from `>=2.18.0` to `>=3.0.0` (enables Dart 3 features)

### Added
- Comprehensive test suite: 42 unit/widget tests + integration test suite
- `AnimatedSwitcher` for smooth cross-fade transitions between UI states in `ApiProviderUi`
- Exhaustive `DioExceptionType` error handling covering all 8 cases (connectionTimeout, sendTimeout, receiveTimeout, badResponse, cancel, connectionError, badCertificate, unknown)

### Fixed
- **Header overwrite bug**: `init()` no longer overwrites all headers including Authorization when `config.headers` is provided
- **URL double-slash bug**: request URLs are now correctly constructed without duplicate slashes
- **Listener leak in `ApiProviderUi`**: properly removes listeners in `dispose()` with `mounted` guard
- **Circular imports**: all internal files now use direct `package:` imports instead of barrel file imports

### Changed
- Refactored HTTP methods (`get`, `post`, `put`, `patch`, `delete`, `download`) to use a shared `_request` helper, eliminating ~400 lines of duplicated try/catch logic
- Default widgets (`IdleWidget`, `LoadingWidget`, etc.) now include `ValueKey` for proper widget reconciliation

## [1.0.0] - 2025-03-29
### Added
- Initial release 🎉
- Full support for [get, post, put, update, delete, download].
- Comprehensive documentation for usage.
- Performance improvements and optimizations.

### Fixed
- Resolved initial issues and enhanced package stability.

## [1.0.1] - 2025-03-29
### Fixed
- Fix wasm support issue.

## [1.1.0] - 2025-04-04
### Added
- add ApiProviderUi to handle api states: idle, loading, empty, success, error
- Automatically handle api states

## [1.1.1] - 2025-04-06
### Added
- add full documentation and comments to our code
- add test units