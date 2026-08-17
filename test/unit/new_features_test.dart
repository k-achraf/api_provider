import 'package:easy_api_provider/easy_api_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RetryConfig', () {
    test('default values', () {
      const config = RetryConfig();
      expect(config.attempts, 3);
      expect(config.delay, const Duration(seconds: 1));
      expect(config.useExponentialBackoff, isFalse);
      expect(config.isDisabled, isFalse);
    });

    test('custom values', () {
      const config = RetryConfig(
        attempts: 5,
        delay: Duration(milliseconds: 500),
        useExponentialBackoff: true,
      );
      expect(config.attempts, 5);
      expect(config.delay, const Duration(milliseconds: 500));
      expect(config.useExponentialBackoff, isTrue);
    });

    test('RetryConfig.none is disabled', () {
      expect(RetryConfig.none.isDisabled, isTrue);
      expect(RetryConfig.none.attempts, 0);
    });

    test('delayFor with constant delay', () {
      const config = RetryConfig(delay: Duration(seconds: 2));
      expect(config.delayFor(1), const Duration(seconds: 2));
      expect(config.delayFor(2), const Duration(seconds: 2));
      expect(config.delayFor(3), const Duration(seconds: 2));
    });

    test('delayFor with exponential backoff', () {
      const config = RetryConfig(
        delay: Duration(seconds: 1),
        useExponentialBackoff: true,
      );
      expect(config.delayFor(1), const Duration(seconds: 1)); // 1 * 2^0
      expect(config.delayFor(2), const Duration(seconds: 2)); // 1 * 2^1
      expect(config.delayFor(3), const Duration(seconds: 4)); // 1 * 2^2
    });
  });

  group('CacheConfig', () {
    test('stores TTL and maxSize', () {
      const config = CacheConfig(ttl: Duration(minutes: 5));
      expect(config.ttl, const Duration(minutes: 5));
      expect(config.maxSize, 100);
    });

    test('custom maxSize', () {
      const config = CacheConfig(ttl: Duration(minutes: 1), maxSize: 50);
      expect(config.maxSize, 50);
    });
  });

  group('ApiCache', () {
    test('stores and retrieves a value', () {
      final cache = ApiCache(const CacheConfig(ttl: Duration(minutes: 5)));
      cache.set('key1', {'data': 'value'});
      expect(cache.get('key1'), {'data': 'value'});
    });

    test('returns null for missing key', () {
      final cache = ApiCache(const CacheConfig(ttl: Duration(minutes: 5)));
      expect(cache.get('missing'), isNull);
    });

    test('clear() removes all entries', () {
      final cache = ApiCache(const CacheConfig(ttl: Duration(minutes: 5)));
      cache.set('a', 1);
      cache.set('b', 2);
      expect(cache.size, 2);
      cache.clear();
      expect(cache.size, 0);
      expect(cache.get('a'), isNull);
    });

    test('evicts oldest entry when maxSize exceeded', () {
      final cache = ApiCache(const CacheConfig(
        ttl: Duration(minutes: 5),
        maxSize: 2,
      ));
      cache.set('first', 1);
      cache.set('second', 2);
      cache.set('third', 3); // should evict 'first'
      expect(cache.get('first'), isNull);
      expect(cache.get('second'), 2);
      expect(cache.get('third'), 3);
    });
  });

  group('MultiApiProvider', () {
    setUp(() => MultiApiProvider.clear());
    tearDown(() => MultiApiProvider.clear());

    test('register and retrieve a provider', () {
      final provider = ApiProvider.create()
        ..init(const ApiProviderConfig('https://example.com'));
      MultiApiProvider.register('main', provider);
      expect(MultiApiProvider.of('main'), same(provider));
    });

    test('has() returns correct boolean', () {
      expect(MultiApiProvider.has('main'), isFalse);
      MultiApiProvider.register(
        'main',
        ApiProvider.create()..init(const ApiProviderConfig('https://a.com')),
      );
      expect(MultiApiProvider.has('main'), isTrue);
    });

    test('unregister() removes provider', () {
      MultiApiProvider.register(
        'test',
        ApiProvider.create()..init(const ApiProviderConfig('https://b.com')),
      );
      MultiApiProvider.unregister('test');
      expect(MultiApiProvider.has('test'), isFalse);
    });

    test('of() throws StateError for unknown name', () {
      expect(
        () => MultiApiProvider.of('unknown'),
        throwsA(isA<StateError>()),
      );
    });

    test('registeredNames returns all names', () {
      MultiApiProvider.register(
        'a',
        ApiProvider.create()..init(const ApiProviderConfig('https://a.com')),
      );
      MultiApiProvider.register(
        'b',
        ApiProvider.create()..init(const ApiProviderConfig('https://b.com')),
      );
      expect(MultiApiProvider.registeredNames, containsAll(['a', 'b']));
    });
  });

  group('ApiPaginator', () {
    late ApiProvider provider;

    setUp(() {
      provider = ApiProvider.create()
        ..init(const ApiProviderConfig('https://jsonplaceholder.typicode.com'));
    });

    test('initial state', () {
      final paginator = ApiPaginator(provider: provider, path: '/posts');
      expect(paginator.currentPage, 1);
      expect(paginator.hasMore, isTrue);
      expect(paginator.isLoading, isFalse);
      expect(paginator.items, isEmpty);
    });

    test('reset() restores initial state', () {
      final paginator = ApiPaginator(provider: provider, path: '/posts');
      // Manually manipulate state via reset
      paginator.reset();
      expect(paginator.currentPage, 1);
      expect(paginator.hasMore, isTrue);
      expect(paginator.items, isEmpty);
    });
  });
}
