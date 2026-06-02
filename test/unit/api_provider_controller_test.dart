import 'package:easy_api_provider/easy_api_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiProviderController', () {
    late ApiProviderController controller;

    setUp(() {
      controller = ApiProviderController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial status is idle', () {
      expect(controller.status, ApiProviderStatus.idle);
    });

    test('initial response is null', () {
      expect(controller.response, isNull);
    });

    test('loading() sets status to loading', () {
      controller.loading();
      expect(controller.status, ApiProviderStatus.loading);
    });

    test('success() sets status and stores response', () {
      const apiResponse = ApiResponse(
        success: true,
        statusCode: 200,
        data: {'id': 1},
        message: 'OK',
      );

      controller.success(apiResponse: apiResponse);

      expect(controller.status, ApiProviderStatus.success);
      expect(controller.response, apiResponse);
    });

    test('success() works without response', () {
      controller.success();
      expect(controller.status, ApiProviderStatus.success);
      expect(controller.response, isNull);
    });

    test('error() sets status and stores response', () {
      const apiResponse = ApiResponse(
        success: false,
        statusCode: 500,
        message: 'Server error',
      );

      controller.error(apiResponse: apiResponse);

      expect(controller.status, ApiProviderStatus.error);
      expect(controller.response, apiResponse);
    });

    test('error() works without response', () {
      controller.error();
      expect(controller.status, ApiProviderStatus.error);
      expect(controller.response, isNull);
    });

    test('empty() sets status to empty', () {
      controller.empty();
      expect(controller.status, ApiProviderStatus.empty);
    });

    test('idle() resets status to idle', () {
      controller.loading();
      expect(controller.status, ApiProviderStatus.loading);

      controller.idle();
      expect(controller.status, ApiProviderStatus.idle);
    });

    test('full lifecycle: idle -> loading -> success', () {
      final statuses = <ApiProviderStatus>[];
      controller.listen((status) => statuses.add(status));

      controller.loading();
      controller.success();

      expect(statuses, [
        ApiProviderStatus.loading,
        ApiProviderStatus.success,
      ]);
    });

    test('full lifecycle: idle -> loading -> error', () {
      final statuses = <ApiProviderStatus>[];
      controller.listen((status) => statuses.add(status));

      controller.loading();
      controller.error();

      expect(statuses, [
        ApiProviderStatus.loading,
        ApiProviderStatus.error,
      ]);
    });

    test('response is updated on successive calls', () {
      const first = ApiResponse(success: true, data: 'first');
      const second = ApiResponse(success: true, data: 'second');

      controller.success(apiResponse: first);
      expect(controller.response?.data, 'first');

      controller.success(apiResponse: second);
      expect(controller.response?.data, 'second');
    });

    test('multiple listeners all receive updates', () {
      final statusesA = <ApiProviderStatus>[];
      final statusesB = <ApiProviderStatus>[];

      controller.listen((status) => statusesA.add(status));
      controller.listen((status) => statusesB.add(status));

      controller.loading();

      expect(statusesA, [ApiProviderStatus.loading]);
      expect(statusesB, [ApiProviderStatus.loading]);
    });
  });
}
