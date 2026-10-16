import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasuconnect/app.dart';

void main() {
  testWidgets('KASUConnect app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: KasuConnectApp()));
    expect(find.byType(KasuConnectApp), findsOneWidget);
  });
}
