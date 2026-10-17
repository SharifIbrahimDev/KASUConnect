import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasuconnect/core/theme/app_theme.dart';
import 'package:kasuconnect/data/repositories/auth_repository.dart';

void main() {
  testWidgets('KASUConnect theme and provider smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Consumer(
            builder: (context, ref, child) {
              final user = ref.watch(currentUserProvider);
              return Scaffold(
                body: Center(
                  child: Text(user?.fullName ?? 'KASU Student'),
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('Fatima Bello'), findsOneWidget);
  });
}
