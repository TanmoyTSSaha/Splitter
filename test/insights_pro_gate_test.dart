import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:splitter/Widgets/insights_pro_gate.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('InsightsProGate shows lock overlay for free users',
      (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: InsightsProGate(
            featureLabel: 'Test Feature',
            testIsPremium: false,
            child: Text('Secret content'),
          ),
        ),
      ),
    );

    expect(find.text('Unlock Test Feature'), findsOneWidget);
    expect(find.text('Secret content'), findsOneWidget);
  });

  testWidgets('InsightsProGate shows child without lock for pro users',
      (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: InsightsProGate(
            featureLabel: 'Test Feature',
            testIsPremium: true,
            child: Text('Secret content'),
          ),
        ),
      ),
    );

    expect(find.text('Unlock Test Feature'), findsNothing);
    expect(find.text('Secret content'), findsOneWidget);
  });
}
