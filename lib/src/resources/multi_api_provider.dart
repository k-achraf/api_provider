import 'package:easy_api_provider/src/resources/api_provider.dart';

/// A registry for named [ApiProvider] instances.
///
/// Use [MultiApiProvider] when your app talks to multiple backends with
/// different base URLs, headers, or auth configurations.
/// Register each provider once (e.g., in `main.dart`) and retrieve it
/// anywhere without passing instances down the widget tree.
///
/// ### Example
/// ```dart
/// // Registration (in main.dart)
/// MultiApiProvider.register('auth', ApiProvider.create()
///   ..init(ApiProviderConfig('https://auth.example.com')));
/// MultiApiProvider.register('content', ApiProvider.create()
///   ..init(ApiProviderConfig('https://content.example.com')));
///
/// // Usage (anywhere)
/// final response = await MultiApiProvider.of('auth').get('/me');
/// final posts   = await MultiApiProvider.of('content').get('/posts');
/// ```
class MultiApiProvider {
  MultiApiProvider._();

  static final _registry = <String, ApiProvider>{};

  /// Registers [provider] under [name].
  ///
  /// If a provider is already registered under [name] it will be replaced.
  static void register(String name, ApiProvider provider) {
    _registry[name] = provider;
  }

  /// Returns the [ApiProvider] registered under [name].
  ///
  /// Throws a [StateError] if no provider is registered under [name].
  static ApiProvider of(String name) {
    final provider = _registry[name];
    if (provider == null) {
      throw StateError(
        'No ApiProvider registered under "$name". '
        'Call MultiApiProvider.register("$name", ...) first.',
      );
    }
    return provider;
  }

  /// Returns `true` if a provider is registered under [name].
  static bool has(String name) => _registry.containsKey(name);

  /// Unregisters the provider under [name].
  ///
  /// Does nothing if [name] is not registered.
  static void unregister(String name) => _registry.remove(name);

  /// Clears all registered providers.
  static void clear() => _registry.clear();

  /// All currently registered provider names.
  static Iterable<String> get registeredNames => _registry.keys;
}
