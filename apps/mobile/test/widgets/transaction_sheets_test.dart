import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:splitr/Controller/all_transactions_controller.dart';
import 'package:splitr/Model/group_model.dart';
import 'package:splitr/Screen/HomeScreen/widgets/transaction_filter_sheet.dart';
import 'package:splitr/Screen/HomeScreen/widgets/transaction_sort_sheet.dart';
import 'package:splitr/Services/transaction_list_helper.dart';
import 'package:splitr/Widgets/bordered_input_field.dart';

import '../helpers/component_test_harness.dart';

void main() {
  tearDown(ComponentTestHarness.tearDownGetX);

  group('TransactionSortSheet', () {
    late AllTransactionsController controller;

    setUp(() {
      controller = AllTransactionsController(forTest: true);
      Get.put(controller);
    });

    testWidgets('shows all sort options', (tester) async {
      await ComponentTestHarness.pump(
        tester,
        TransactionSortSheet(controller: controller),
        withGetX: true,
      );

      expect(find.text('Sort by'), findsOneWidget);
      for (final option in TransactionSortOption.values) {
        expect(
          find.text(TransactionListHelper.sortLabel(option)),
          findsOneWidget,
        );
      }
    });

    testWidgets('updates controller sort on selection', (tester) async {
      await ComponentTestHarness.pump(
        tester,
        TransactionSortSheet(controller: controller),
        withGetX: true,
      );

      await tester.tap(find.text('Largest first'));
      await tester.pump();

      expect(controller.sortOption.value, TransactionSortOption.largestFirst);
    });
  });

  group('TransactionFilterSheet', () {
    late AllTransactionsController controller;

    setUp(() {
      controller = AllTransactionsController(forTest: true);
      Get.put(controller);
    });

    Future<void> pumpFilterSheet(WidgetTester tester) {
      return ComponentTestHarness.pump(
        tester,
        TransactionFilterSheet(controller: controller),
        withGetX: true,
        surfaceSize: const Size(390, 900),
      );
    }

    testWidgets('shows filter sections and apply action', (tester) async {
      controller.seedFilterOptionsForTest(
        categories: ['Food'],
        groups: [GroupModel(groupID: 'g1', groupName: 'Roommates')],
      );

      await pumpFilterSheet(tester);
      await tester.pumpAndSettle();

      expect(find.text('Filters'), findsOneWidget);
      expect(find.text('Quick range'), findsOneWidget);
      expect(find.text('Price range (₹)'), findsOneWidget);
      expect(find.text('Payment method'), findsOneWidget);
      expect(find.text('Apply'), findsOneWidget);
    });

    testWidgets('shows price validation when min exceeds max', (tester) async {
      await pumpFilterSheet(tester);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.descendant(
          of: find.byType(BorderedInputField).at(0),
          matching: find.byType(TextField),
        ),
        '500',
      );
      await tester.enterText(
        find.descendant(
          of: find.byType(BorderedInputField).at(1),
          matching: find.byType(TextField),
        ),
        '100',
      );
      await tester.pump();

      expect(find.text('Min cannot be greater than max'), findsOneWidget);
    });

    testWidgets('apply persists quick range preset', (tester) async {
      await pumpFilterSheet(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('30 days'));
      await tester.pump();
      await tester.tap(find.text('Apply'));
      await tester.pump();

      expect(controller.customSince.value, isNotNull);
      expect(controller.customUntil.value, isNotNull);
    });
  });
}
