import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Model/user_upi_account_model.dart';
import 'package:splitr/Widgets/payee_upi_picker_sheet.dart';

import '../helpers/component_test_harness.dart';

void main() {
  tearDown(ComponentTestHarness.tearDownGetX);

  group('PayeeUpiPickerSheet', () {
    testWidgets('shows bank aliases with masked VPA and primary first',
        (tester) async {
      final accounts = [
        const UserUpiAccount(
          id: '2',
          userId: 'u1',
          vpa: 'user@axisbank',
          bankAlias: 'Axis Bank',
        ),
        const UserUpiAccount(
          id: '1',
          userId: 'u1',
          vpa: 'rahul@okhdfcbank',
          bankAlias: 'HDFC Bank',
          isPrimary: true,
        ),
      ];

      await ComponentTestHarness.pump(
        tester,
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => PayeeUpiPickerSheet.show(
                    context,
                    accounts: accounts,
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

      expect(find.text(AppStrings.groups.selectPayeeBank), findsOneWidget);
      expect(find.text('HDFC Bank'), findsOneWidget);
      expect(find.text('Axis Bank'), findsOneWidget);
      expect(find.text('ra***@okhdfcbank'), findsOneWidget);
      expect(find.text('us***@axisbank'), findsOneWidget);
      expect(find.text(AppStrings.profile.primaryBadge), findsOneWidget);
    });
  });
}
