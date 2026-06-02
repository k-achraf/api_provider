import 'package:easy_api_provider/easy_api_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiResponse', () {
    test('creates with required success field', () {
      const response = ApiResponse(success: true);

      expect(response.success, isTrue);
      expect(response.statusCode, isNull);
      expect(response.data, isNull);
      expect(response.url, isNull);
      expect(response.message, isNull);
    });

    test('creates with all fields', () {
      const response = ApiResponse(
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
      const response = ApiResponse(success: true, message: 'ok');
      expect(response.success, isTrue);
      expect(response.message, 'ok');
    });

    test('accepts dynamic data types', () {
      const listResponse = ApiResponse(success: true, data: [1, 2, 3]);
      expect(listResponse.data, [1, 2, 3]);

      const stringResponse = ApiResponse(success: true, data: 'hello');
      expect(stringResponse.data, 'hello');

      const nullResponse = ApiResponse(success: true);
      expect(nullResponse.data, isNull);
    });
  });
}
