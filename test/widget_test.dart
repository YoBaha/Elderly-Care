import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pim/main.dart';

void main() {
  testWidgets('App has a login screen', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Login button navigates to signup screen', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    await tester.tap(find.text("If you don't have an account, signup"));
    await tester.pumpAndSettle();

    expect(find.byType(ElevatedButton), findsOneWidget); // Check for the signup button
  });
}
