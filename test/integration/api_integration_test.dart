@Tags(['integration'])
library;

import 'package:easy_api_provider/easy_api_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiProvider HTTP integration', () {
    late ApiProvider provider;

    setUp(() {
      provider = ApiProvider.instance;
      provider.init(
        const ApiProviderConfig(
          'https://jsonplaceholder.typicode.com',
          requestLogger: false,
        ),
      );
    });

    test('GET returns success response', () async {
      final response = await provider.get('/posts/1');

      expect(response.success, isTrue);
      expect(response.statusCode, 200);
      expect(response.data, isNotNull);
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('GET with controller manages state', () async {
      final controller = ApiProviderController();
      addTearDown(controller.dispose);

      final response = await provider.get(
        '/posts/1',
        controller: controller,
      );

      expect(response.success, isTrue);
      expect(controller.status, ApiProviderStatus.success);
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('GET handles 404 error', () async {
      final response = await provider.get('/nonexistent-endpoint-404');

      expect(response.success, isFalse);
      expect(response.statusCode, 404);
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('POST returns success response', () async {
      final response = await provider.post(
        '/posts',
        data: {'title': 'test', 'body': 'body', 'userId': 1},
      );

      expect(response.success, isTrue);
      expect(response.statusCode, 201);
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('PUT returns success response', () async {
      final response = await provider.put(
        '/posts/1',
        data: {'title': 'updated', 'body': 'body', 'userId': 1},
      );

      expect(response.success, isTrue);
      expect(response.statusCode, 200);
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('PATCH returns success response', () async {
      final response = await provider.patch(
        '/posts/1',
        data: {'title': 'patched'},
      );

      expect(response.success, isTrue);
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('DELETE returns success response', () async {
      final response = await provider.delete('/posts/1');

      expect(response.success, isTrue);
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('handles connection error gracefully', () async {
      provider.init(
        const ApiProviderConfig(
          'https://nonexistent.invalid.domain.example',
          connectTimeout: Duration(seconds: 2),
          receiveTimeout: Duration(seconds: 2),
          requestLogger: false,
        ),
      );

      final response = await provider.get('/test');

      expect(response.success, isFalse);
    }, timeout: const Timeout(Duration(seconds: 15)));

    test('error controller state on failed request', () async {
      final controller = ApiProviderController();
      addTearDown(controller.dispose);

      provider.init(
        const ApiProviderConfig(
          'https://nonexistent.invalid.domain.example',
          connectTimeout: Duration(seconds: 2),
          receiveTimeout: Duration(seconds: 2),
          requestLogger: false,
        ),
      );

      await provider.get('/test', controller: controller);

      expect(controller.status, ApiProviderStatus.error);
      expect(controller.response!.success, isFalse);
    }, timeout: const Timeout(Duration(seconds: 15)));
  });
}
