/// Configuration for automatic request retry behaviour.
///
/// Pass a [RetryConfig] to [ApiProviderConfig.retry] to enable global
/// auto-retry, or to individual request methods to override the global config
/// on a per-request basis. Use [RetryConfig.none] to disable retry for a
/// specific request even when a global config is set.
///
/// ### Example
/// ```dart
/// ApiProvider.instance.init(ApiProviderConfig(
///   'https://api.example.com',
///   retry: RetryConfig(
///     attempts: 3,
///     delay: Duration(seconds: 1),
///     useExponentialBackoff: true,
///   ),
/// ));
///
/// // Per-request override
/// ApiProvider.instance.get('/fragile', retryConfig: RetryConfig(attempts: 5));
///
/// // Disable for one request
/// ApiProvider.instance.get('/one-shot', retryConfig: RetryConfig.none);
/// ```
class RetryConfig {
  /// A sentinel instance that disables retry for a specific request,
  /// even when a global [RetryConfig] is set on [ApiProviderConfig].
  static const none = RetryConfig._disabled();

  /// Number of retry attempts after the initial failure.
  ///
  /// A value of `3` means up to 4 total requests (1 original + 3 retries).
  final int attempts;

  /// Base delay between retry attempts.
  ///
  /// When [useExponentialBackoff] is `true`, the actual delay is
  /// `delay * 2^(attempt - 1)` — e.g. 1 s, 2 s, 4 s for `attempts: 3`.
  final Duration delay;

  /// Whether to use exponential back-off between retries.
  ///
  /// Defaults to `false` (constant delay). Set to `true` to apply
  /// doubling delays to avoid thundering-herd scenarios.
  final bool useExponentialBackoff;

  /// Whether this config is the [RetryConfig.none] sentinel (retry disabled).
  final bool _disabled;

  /// Creates a [RetryConfig] with the given parameters.
  const RetryConfig({
    this.attempts = 3,
    this.delay = const Duration(seconds: 1),
    this.useExponentialBackoff = false,
  }) : _disabled = false;

  const RetryConfig._disabled()
      : attempts = 0,
        delay = Duration.zero,
        useExponentialBackoff = false,
        _disabled = true;

  /// Returns `true` if retry is disabled (i.e. this is [RetryConfig.none]).
  bool get isDisabled => _disabled;

  /// Calculates the actual delay for the given [attempt] (1-indexed).
  Duration delayFor(int attempt) {
    if (!useExponentialBackoff) return delay;
    final factor = 1 << (attempt - 1); // 2^(attempt-1)
    return delay * factor.toDouble();
  }
}
