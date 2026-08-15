import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:splitr/Controller/all_transactions_controller.dart';
import 'package:splitr/Utils/transaction_section_grouper.dart';

void main() {
  group('AllTransactionsController flat list index', () {
    late AllTransactionsController controller;

    setUp(() {
      Get.testMode = true;
      controller = AllTransactionsController(forTest: true);
      controller.sections.assignAll([
        const TransactionSection(
          header: 'Today',
          granularity: TransactionSectionGranularity.daily,
          transactions: [
            {'title': 'Coffee', 'amount': 120},
            {'title': 'Lunch', 'amount': 300},
          ],
        ),
        const TransactionSection(
          header: 'Yesterday',
          granularity: TransactionSectionGranularity.daily,
          transactions: [
            {'title': 'Ride', 'amount': 80},
          ],
        ),
      ]);
    });

    tearDown(() {
      Get.reset();
    });

    test('flatItemCount includes headers and transactions', () {
      expect(controller.flatItemCount, 5);
    });

    test('flatItemAt returns headers and transactions in order', () {
      expect(controller.flatItemAt(0).isHeader, isTrue);
      expect(controller.flatItemAt(0).header, 'Today');
      expect(controller.flatItemAt(1).txn?['title'], 'Coffee');
      expect(controller.flatItemAt(3).header, 'Yesterday');
      expect(controller.flatItemAt(4).txn?['title'], 'Ride');
    });
  });
}
