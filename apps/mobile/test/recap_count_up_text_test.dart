import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Widgets/recap_count_up_text.dart';

void main() {
  testWidgets('updates count when value changes', (tester) async {
    var value = 10.0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return RecapCountUpText(
                value: value,
                style: const TextStyle(fontSize: 16),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(AppMotion.recapCountUp);

    value = 25.0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecapCountUpText(
            value: value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(AppMotion.recapCountUp);

    expect(find.textContaining('25'), findsOneWidget);
  });
}
