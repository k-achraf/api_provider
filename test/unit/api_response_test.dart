import 'package:easy_api_provider/easy_api_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiResponse', () {
    test('creates with required success field', () {
      const response = ApiResponse<dynamic>(success: true);

      expect(response.success, isTrue);
      expect(response.statusCode, isNull);
      expect(response.data, isNull);
      expect(response.url, isNull);
      expect(response.message, isNull);
      expect(response.headers, isNull);
      expect(response.requestDuration, isNull);
    });

    test('creates with all fields', () {
      const response = ApiResponse<dynamic>(
        success: false,
        statusCode: 404,
        data: {'error': 'not found'},
        url: 'https://api.example.com/users/1',
        message: 'User not found',
      );

      expect(response.success, isFalse);
      expect(response.statusCode, 404);
      expect(response.data, {'error': 'not found'});
      expect(response.url, 'https://api.example.com/users/1');
      expect(response.message, 'User not found');
    });

    test('is const constructible', () {
      const response = ApiResponse<dynamic>(success: true, message: 'ok');
      expect(response.success, isTrue);
      expect(response.message, 'ok');
    });

    test('accepts dynamic data types', () {
      const listResponse = ApiResponse<dynamic>(success: true, data: [1, 2, 3]);
      expect(listResponse.data, [1, 2, 3]);

      const stringResponse = ApiResponse<dynamic>(success: true, data: 'hello');
      expect(stringResponse.data, 'hello');

      const nullResponse = ApiResponse<dynamic>(success: true);
      expect(nullResponse.data, isNull);
    });

    // ── New v2.5.0 / v3.0.0 features ─────────────────────────────────────

    test('copyWith preserves unset fields', () {
      const original = ApiResponse<dynamic>(
        success: true,
        statusCode: 200,
        data: {'id': 1},
        url: 'https://example.com',
        message: 'OK',
      );

      final copy = original.copyWith(statusCode: 404, message: 'Not Found');

      expect(copy.success, isTrue);
      expect(copy.statusCode, 404);
      expect(copy.data, {'id': 1});
      expect(copy.url, 'https://example.com');
      expect(copy.message, 'Not Found');
    });

    test('toString includes key fields', () {
      const response = ApiResponse<dynamic>(
        success: true,
        statusCode: 200,
        url: 'https://example.com',
        message: 'OK',
      );

      final str = response.toString();
      expect(str, contains('success: true'));
      expect(str, contains('statusCode: 200'));
      expect(str, contains('url: https://example.com'));
      expect(str, contains('message: OK'));
    });

    test('is generic — ApiResponse<String> works correctly', () {
      const response = ApiResponse<String>(success: true, data: 'hello world');
      expect(response.data, isA<String>());
      expect(response.data, 'hello world');
    });

    test('is generic — ApiResponse<List<int>> works correctly', () {
      const response = ApiResponse<List<int>>(success: true, data: [1, 2, 3]);
      expect(response.data, isA<List<int>>());
      expect(response.data, [1, 2, 3]);
    });

    test('requestDuration is stored correctly', () {
      final duration = const Duration(milliseconds: 250);
      final response = ApiResponse<dynamic>(
        success: true,
        requestDuration: duration,
      );
      expect(response.requestDuration, duration);
      expect(response.toString(), contains('250ms'));
    });
  });
}
