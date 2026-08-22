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

    test('success() with data sets status to success', () {
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

    test('success() with no data auto-transitions to empty', () {
      controller.success();
      expect(controller.status, ApiProviderStatus.empty);
      expect(controller.response, isNull);
    });

    test('success() with null data auto-transitions to empty', () {
      controller.success(
          apiResponse: const ApiResponse(success: true, data: null));
      expect(controller.status, ApiProviderStatus.empty);
    });

    test('success() with empty List auto-transitions to empty', () {
      controller.success(
          apiResponse: const ApiResponse(success: true, data: []));
      expect(controller.status, ApiProviderStatus.empty);
    });

    test('success() with empty Map auto-transitions to empty', () {
      controller.success(
          apiResponse: const ApiResponse(success: true, data: {}));
      expect(controller.status, ApiProviderStatus.empty);
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
      controller.success(
        apiResponse: const ApiResponse(success: true, data: {'key': 'value'}),
      );

      expect(statuses, [
        ApiProviderStatus.loading,
        ApiProviderStatus.success,
      ]);
    });

    test('full lifecycle: idle -> loading -> empty (no data)', () {
      final statuses = <ApiProviderStatus>[];
      controller.listen((status) => statuses.add(status));

      controller.loading();
      controller.success(); // no data -> auto empty

      expect(statuses, [
        ApiProviderStatus.loading,
        ApiProviderStatus.empty,
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

    // ── New v2.5.0 features ──────────────────────────────────────────────

    test('isLoading is true only when loading', () {
      expect(controller.isLoading, isFalse);
      controller.loading();
      expect(controller.isLoading, isTrue);
    });

    test('isSuccess is true only when success', () {
      controller.success(
        apiResponse: const ApiResponse(success: true, data: {'x': 1}),
      );
      expect(controller.isSuccess, isTrue);
      expect(controller.isError, isFalse);
    });

    test('isError is true only when error', () {
      controller.error();
      expect(controller.isError, isTrue);
      expect(controller.isSuccess, isFalse);
    });

    test('isEmpty is true only when empty', () {
      controller.empty();
      expect(controller.isEmpty, isTrue);
    });

    test('isIdle is true only when idle', () {
      expect(controller.isIdle, isTrue);
      controller.loading();
      expect(controller.isIdle, isFalse);
    });

    test('reset() restores idle and clears response', () {
      controller.success(
        apiResponse: const ApiResponse(success: true, data: [1, 2, 3]),
      );
      expect(controller.isSuccess, isTrue);

      controller.reset();

      expect(controller.status, ApiProviderStatus.idle);
      expect(controller.response, isNull);
    });

    test('previousStatus is null initially', () {
      expect(controller.previousStatus, isNull);
    });

    test('previousStatus is updated on transition', () {
      controller.loading();
      expect(controller.previousStatus, ApiProviderStatus.idle);

      controller.error();
      expect(controller.previousStatus, ApiProviderStatus.loading);
    });
  });
}
