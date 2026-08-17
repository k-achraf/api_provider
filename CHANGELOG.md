# Changelog

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