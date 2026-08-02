import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:splitr/Controller/add_transaction_controller.dart';
import 'package:splitr/Utils/expense_split_calculator.dart';

void main() {
  group('ExpenseSplitCalculator', () {
    test('evenSplit divides total among involved members', () {
      final splits = ExpenseSplitCalculator.evenSplit(
        totalAmount: 100,
        involvedUserIds: ['a', 'b', 'c'],
      );

      expect(splits.length, 3);
      expect(
          splits.values.fold<double>(0, (a, b) => a + b), closeTo(100, 0.001));
      expect(splits['a'], closeTo(100 / 3, 0.001));
    });

    test('evenSplit returns empty when nobody involved', () {
      expect(
        ExpenseSplitCalculator.evenSplit(totalAmount: 50, involvedUserIds: []),
        isEmpty,
      );
    });

    test('unevenSplit maps explicit amounts', () {
      final splits = ExpenseSplitCalculator.unevenSplit([
        {'user_id': 'a', 'amount': '30'},
        {'user_id': 'b', 'amount': '70'},
      ]);

      expect(splits, {'a': 30, 'b': 70});
    });

    test('percentageSplit applies percent of total', () {
      final splits = ExpenseSplitCalculator.percentageSplit(
        totalAmount: 200,
        percentageSplitDetails: [
          {'user_id': 'a', 'percentage': '25'},
          {'user_id': 'b', 'percentage': '75'},
        ],
      );

      expect(splits, {'a': 50, 'b': 150});
    });

    test('sharesSplit weights by share count', () {
      final splits = ExpenseSplitCalculator.sharesSplit(
        totalAmount: 100,
        totalShares: 4,
        sharesSplitDetails: [
          {'user_id': 'a', 'shares': '2'},
          {'user_id': 'b', 'shares': '1'},
          {'user_id': 'c', 'shares': '1'},
        ],
      );

      expect(splits, {'a': 50, 'b': 25, 'c': 25});
    });

    test('sharesSplit returns empty when total shares is zero', () {
      expect(
        ExpenseSplitCalculator.sharesSplit(
          totalAmount: 100,
          totalShares: 0,
          sharesSplitDetails: [
            {'user_id': 'a', 'shares': '1'},
          ],
        ),
        isEmpty,
      );
    });

    test('byItemSplit splits item price across assignees', () {
      final splits = ExpenseSplitCalculator.byItemSplit([
        {
          'price': '60',
          'assignees': ['a', 'b'],
        },
        {
          'price': '40',
          'assignees': ['b'],
        },
      ]);

      expect(splits['a'], 30);
      expect(splits['b'], 70);
    });

    test('forTab dispatches by tab index', () {
      expect(
        ExpenseSplitCalculator.forTab(
          tabIndex: 2,
          totalAmount: 80,
          percentageSplitDetails: [
            {'user_id': 'x', 'percentage': '50'},
            {'user_id': 'y', 'percentage': '50'},
          ],
        ),
        {'x': 40, 'y': 40},
      );
    });
  });

  group('AddTransactionScreenController.validateSplit', () {
    late AddTransactionScreenController controller;

    setUp(() {
      Get.testMode = true;
      controller = AddTransactionScreenController();
    });

    tearDown(() {
      Get.reset();
    });

    test('rejects uneven split that does not match total', () {
      controller.totalAddedAmount.value = 90;

      expect(
        controller.validateSplit(tabIndex: 1, totalAmount: 100),
        contains('must equal'),
      );
    });

    test('rejects percentage split not summing to 100', () {
      controller.totalPercentage.value = 90;

      expect(
        controller.validateSplit(tabIndex: 2, totalAmount: 100),
        contains('100%'),
      );
    });

    test('rejects by-item split with unassigned priced item', () {
      controller.totalItemPrice.value = 100;
      final item = <String, dynamic>{}.obs;
      item['price'] = '50';
      item['assignees'] = <String>[];
      controller.itemSplitDetails.add(item);

      expect(
        controller.validateSplit(tabIndex: 4, totalAmount: 100),
        contains('Assign each item'),
      );
    });

    test('sharingTypeForTab maps indices to sharing types', () {
      expect(controller.sharingTypeForTab(0), 'evenly');
      expect(controller.sharingTypeForTab(1), 'unevenly');
      expect(controller.sharingTypeForTab(2), 'percentage');
      expect(controller.sharingTypeForTab(3), 'shares');
      expect(controller.sharingTypeForTab(4), 'by_item');
    });
  });
}
