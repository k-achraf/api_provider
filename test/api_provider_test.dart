import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_api_provider/easy_api_provider.dart';

void main() {
  late ApiProviderController controller;

  setUp(() {
    controller = ApiProviderController();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: ApiProviderUi(
          controller: controller,
          idleWidget: (context) => const Text('Idle'),
          loadingWidget: (context) => const Text('Loading...'),
          successWidget: (context, res) => const Text('Success!'),
          errorWidget: (context, res) => const Text('Error occurred'),
          emptyWidget: (context) => const Text('Nothing here'),
        ),
      ),
    );
  }

  testWidgets('Shows Idle Widget by default', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Idle'), findsOneWidget);
  });

  testWidgets('Shows Loading Widget when status is loading', (WidgetTester tester) async {
    controller.loading();
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    expect(find.text('Loading...'), findsOneWidget);
  });

  testWidgets('Shows Success Widget when status is success', (WidgetTester tester) async {
    controller.success();
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    expect(find.text('Success!'), findsOneWidget);
  });

  testWidgets('Shows Error Widget when status is error', (WidgetTester tester) async {
    controller.error();
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    expect(find.text('Error occurred'), findsOneWidget);
  });

  testWidgets('Shows Empty Widget when status is empty', (WidgetTester tester) async {
    controller.empty();
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    expect(find.text('Nothing here'), findsOneWidget);
  });
}