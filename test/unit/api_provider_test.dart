import 'package:dio/dio.dart';
import 'package:easy_api_provider/easy_api_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiProvider configuration', () {
    late ApiProvider provider;

    setUp(() {
      provider = ApiProvider.instance;
      provider.init(
        const ApiProviderConfig(
          'https://example.com',
          requestLogger: false,
        ),
      );
    });

    test('init configures Dio with correct baseUrl', () {
      expect(provider.dio.options.baseUrl, 'https://example.com');
    });

    test('init sets authorization header', () {
      provider.init(
        const ApiProviderConfig(
          'https://example.com',
          authorization: 'Bearer test-token',
          requestLogger: false,
        ),
      );

      expect(
        provider.dio.options.headers['Authorization'],
        'Bearer test-token',
      );
    });

    test('setAuthorisation updates header', () {
      provider.setAuthorisation('Bearer new-token');
      expect(
        provider.dio.options.headers['Authorization'],
        'Bearer new-token',
      );
    });

    test('setAuthorisation removes header when null', () {
      provider.setAuthorisation('Bearer token');
      provider.setAuthorisation(null);
      expect(
        provider.dio.options.headers.containsKey('Authorization'),
        isFalse,
      );
    });

    test('setBaseUrl updates base URL', () {
      provider.setBaseUrl('https://new-api.example.com');
      expect(provider.dio.options.baseUrl, 'https://new-api.example.com');
    });

    test('init sets custom headers', () {
      provider.init(
        const ApiProviderConfig(
          'https://example.com',
          headers: {'X-Custom': 'value'},
          requestLogger: false,
        ),
      );

      expect(provider.dio.options.headers['X-Custom'], 'value');
    });

    test('init with authorization and headers preserves both', () {
      provider.init(
        const ApiProviderConfig(
          'https://example.com',
          headers: {'X-Custom': 'value'},
          authorization: 'Bearer token',
          requestLogger: false,
        ),
      );

      expect(provider.dio.options.headers['X-Custom'], 'value');
      expect(
        provider.dio.options.headers['Authorization'],
        'Bearer token',
      );
    });

    test('init sets listFormat', () {
      provider.init(
        const ApiProviderConfig(
          'https://example.com',
          listFormat: ListFormat.multi,
          requestLogger: false,
        ),
      );

      expect(provider.dio.options.listFormat, ListFormat.multi);
    });

    test('init sets extra', () {
      provider.init(
        const ApiProviderConfig(
          'https://example.com',
          extra: {'key': 'value'},
          requestLogger: false,
        ),
      );

      expect(provider.dio.options.extra['key'], 'value');
    });
  });
}
