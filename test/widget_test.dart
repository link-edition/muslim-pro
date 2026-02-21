import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:muslim_pro/main.dart';

void main() {
  testWidgets('App should render MainScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MuslimProApp(),
      ),
    );

    // Verify that the app title shows
    expect(find.text('Namoz Vaqtlari'), findsOneWidget);

    // Verify bottom navigation exists
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
