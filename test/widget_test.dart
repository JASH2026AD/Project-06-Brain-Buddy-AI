import 'package:ai_college_companion/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the localized application name', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text(AppStrings.appName))),
    );

    expect(find.text(AppStrings.appName), findsOneWidget);
  });
}
