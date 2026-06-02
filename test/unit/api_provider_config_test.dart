import 'package:dio/dio.dart';
import 'package:easy_api_provider/easy_api_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiProviderConfig', () {
    test('creates with required baseUrl', () {
      const config = ApiProviderConfig('https://api.example.com');

      expect(config.baseUrl, 'https://api.example.com');
      expect(config.connectTimeout, const Duration(seconds: 30));
      expect(config.receiveTimeout, const Duration(seconds: 30));
      expect(config.responseType, ResponseType.json);
      expect(config.requestLogger, isTrue);
      expect(config.maxRedirects, 1);
      expect(config.showResultMessage, isFalse);
      expect(config.contentType, 'application/json');
      expect(config.headers, isNull);
      expect(config.authorization, isNull);
      expect(config.listFormat, isNull);
      expect(config.extra, isNull);
      expect(config.onRequest, isNull);
      expect(config.onError, isNull);
      expect(config.onResponse, isNull);
    });

    test('creates with custom timeouts', () {
      const config = ApiProviderConfig(
        'https://api.example.com',
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 60),
      );

      expect(config.connectTimeout, const Duration(seconds: 10));
      expect(config.receiveTimeout, const Duration(seconds: 60));
    });

    test('creates with custom headers', () {
      const config = ApiProviderConfig(
        'https://api.example.com',
        headers: {'Accept': 'application/json', 'X-Custom': 'value'},
      );

      expect(
        config.headers,
        {'Accept': 'application/json', 'X-Custom': 'value'},
      );
    });

    test('creates with authorization', () {
      const config = ApiProviderConfig(
        'https://api.example.com',
        authorization: 'Bearer token123',
      );

      expect(config.authorization, 'Bearer token123');
    });

    test('creates with callbacks', () {
      final config = ApiProviderConfig(
        'https://api.example.com',
        onRequest: (_) {},
        onError: (_) {},
        onResponse: (_) {},
      );

      expect(config.onRequest, isNotNull);
      expect(config.onError, isNotNull);
      expect(config.onResponse, isNotNull);
    });

    test('creates with all options', () {
      const config = ApiProviderConfig(
        'https://api.example.com',
        connectTimeout: Duration(seconds: 5),
        receiveTimeout: Duration(seconds: 15),
        responseType: ResponseType.plain,
        requestLogger: false,
        maxRedirects: 3,
        showResultMessage: true,
        contentType: 'text/plain',
        headers: {'X-Api-Key': 'key'},
        authorization: 'Bearer token',
        listFormat: ListFormat.multi,
        extra: {'key': 'value'},
      );

      expect(config.baseUrl, 'https://api.example.com');
      expect(config.connectTimeout, const Duration(seconds: 5));
      expect(config.receiveTimeout, const Duration(seconds: 15));
      expect(config.responseType, ResponseType.plain);
      expect(config.requestLogger, isFalse);
      expect(config.maxRedirects, 3);
      expect(config.showResultMessage, isTrue);
      expect(config.contentType, 'text/plain');
      expect(config.listFormat, ListFormat.multi);
      expect(config.extra, {'key': 'value'});
    });
  });
}
