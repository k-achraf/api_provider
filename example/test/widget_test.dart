import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home screen renders feature cards', (WidgetTester tester) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.text('easy_api_provider'), findsOneWidget);
    expect(find.text('GET & UI States'), findsOneWidget);
    expect(find.text('POST Create'), findsOneWidget);
    expect(find.text('PUT & PATCH'), findsOneWidget);
    expect(find.text('DELETE'), findsOneWidget);
    expect(find.text('Auth & Config'), findsOneWidget);
  });
}
