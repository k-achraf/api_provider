# Changelog

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