/// Configuration for the transparent token-refresh interceptor.
///
/// When a request returns one of the [refreshStatusCodes] (default: 401),
/// the interceptor will:
/// 1. Pause all subsequent requests
/// 2. Call [onRefresh] to obtain a new token
/// 3. Update the `Authorization` header via [ApiProvider.setAuthorisation]
/// 4. Replay all queued requests with the new header
/// 5. Call [onLogout] if the refresh itself fails
///
/// ### Example
/// ```dart
/// ApiProvider.instance.init(ApiProviderConfig(
///   'https://api.example.com',
///   tokenRefresh: TokenRefreshConfig(
///     onRefresh: () async {
///       final token = await AuthService.refreshToken();
///       return 'Bearer $token';
///     },
///     onLogout: () => AuthService.logout(),
///   ),
/// ));
/// ```
class TokenRefreshConfig {
  /// Called when a refresh is needed. Must return the full new
  /// `Authorization` header value (e.g. `'Bearer new_token'`).
  ///
  /// Return `null` to signal that refresh is not possible — [onLogout]
  /// will be called immediately.
  final Future<String?> Function() onRefresh;

  /// Called when the refresh itself fails or [onRefresh] returns `null`.
  ///
  /// Typical usage: clear stored credentials and navigate to login.
  final void Function() onLogout;

  /// HTTP status codes that trigger a refresh attempt.
  ///
  /// Defaults to `[401]`.
  final List<int> refreshStatusCodes;

  /// Creates a [TokenRefreshConfig].
  const TokenRefreshConfig({
    required this.onRefresh,
    required this.onLogout,
    this.refreshStatusCodes = const [401],
  });
}
