import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Widgets/bordered_input_field.dart';
import 'package:splitr/Widgets/manual_payee_vpa_sheet.dart';

import '../helpers/component_test_harness.dart';

void main() {
  tearDown(ComponentTestHarness.tearDownGetX);

  group('ManualPayeeVpaSheet', () {
    testWidgets('shows manual VPA entry when payee has no saved accounts',
        (tester) async {
      await ComponentTestHarness.pump(
        tester,
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => ManualPayeeVpaSheet.show(
                    context,
                    payeeName: 'Rahul',
                  ),
                  child: const Text('open'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.groups.receiverUpiId), findsOneWidget);
      expect(
        find.text(AppStringFormat.payeeNoUpiManualEntry('Rahul')),
        findsOneWidget,
      );
      expect(find.byType(BorderedInputField), findsOneWidget);
      expect(find.text(AppStrings.groups.openUpi), findsOneWidget);
    });

    testWidgets('returns normalized VPA on submit', (tester) async {
      String? result;

      await ComponentTestHarness.pump(
        tester,
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await ManualPayeeVpaSheet.show(
                      context,
                      payeeName: 'Rahul',
                    );
                  },
                  child: const Text('open'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(BorderedInputField),
        'Rahul@OkHDFCBank',
      );
      await tester.tap(find.text(AppStrings.groups.openUpi));
      await tester.pumpAndSettle();

      expect(result, 'rahul@okhdfcbank');
    });
  });
}
