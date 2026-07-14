import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Constants/app_themes.dart';

void main() {
  testWidgets('App theme exposes Splitr branding colors', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemes.light,
        home: const Scaffold(
          body: Center(child: Text(AppBranding.brandName)),
        ),
      ),
    );

    expect(find.text(AppBranding.brandName), findsOneWidget);

    final theme = Theme.of(tester.element(find.byType(Scaffold)));
    expect(theme.colorScheme.primary, AppThemes.light.colorScheme.primary);
    expect(theme.useMaterial3, isTrue);
  });
}
