import 'package:easy_api_provider/src/widgets/empty_widget.dart';
import 'package:easy_api_provider/src/widgets/error_widget.dart';
import 'package:easy_api_provider/src/widgets/idle_widget.dart';
import 'package:easy_api_provider/src/widgets/loading_widget.dart';
import 'package:easy_api_provider/src/widgets/success_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IdleWidget', () {
    testWidgets('renders Idle text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: IdleWidget()),
      );

      expect(find.text('Idle'), findsOneWidget);
    });
  });

  group('LoadingWidget', () {
    testWidgets('renders loading indicator and text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoadingWidget()),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Data loading ...'), findsOneWidget);
    });
  });

  group('SuccessWidget', () {
    testWidgets('renders check icon and Success text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SuccessWidget()),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Success'), findsOneWidget);
    });
  });

  group('ApiErrorWidget', () {
    testWidgets('renders error icon and Error text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ApiErrorWidget()),
      );

      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
    });
  });

  group('EmptyWidget', () {
    testWidgets('renders cancel icon and Success text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: EmptyWidget()),
      );

      expect(find.byIcon(Icons.cancel), findsOneWidget);
      expect(find.text('Success'), findsOneWidget);
    });
  });
}
