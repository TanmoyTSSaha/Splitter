import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Services/transaction_list_helper.dart';
import 'package:splitr/Utils/transaction_date_formatter.dart';
import 'package:splitr/Utils/transaction_section_grouper.dart';

Map<String, dynamic> _txn({
  required DateTime date,
  double amount = 100,
  String category = 'Food',
  String type = 'personal',
  String? groupId,
  String? paymentMethod,
}) {
  return {
    'date': date,
    'amount': amount,
    'category': category,
    'type': type,
    'group_id': groupId,
    if (paymentMethod != null) 'payment_method': paymentMethod,
    'dedupe_key': 'test_${date.toIso8601String()}_$amount',
  };
}

void main() {
  final ref = DateTime(2026, 7, 1);

  group('TransactionDateFormatter', () {
    test('formats Today and Yesterday', () {
      expect(
        TransactionDateFormatter.formatRelative(
          DateTime(2026, 7, 1, 14, 30),
          reference: ref,
        ),
        'Today',
      );
      expect(
        TransactionDateFormatter.formatRelative(
          DateTime(2026, 6, 30),
          reference: ref,
        ),
        'Yesterday',
      );
    });

    test('formats same-year and older dates', () {
      expect(
        TransactionDateFormatter.formatRelative(
          DateTime(2026, 1, 15),
          reference: ref,
        ),
        'Thu, Jan 15',
      );
      expect(
        TransactionDateFormatter.formatRelative(
          DateTime(2025, 1, 15),
          reference: ref,
        ),
        'Jan 15, 2025',
      );
    });
  });

  group('TransactionSectionGrouper', () {
    test('uses daily buckets for 0-6 days ago', () {
      final txns = [
        _txn(date: DateTime(2026, 7, 1)),
        _txn(date: DateTime(2026, 6, 25)),
      ];
      final sections = TransactionSectionGrouper.group(txns, reference: ref);
      expect(sections.length, 2);
      expect(sections[0].header, 'Today');
      expect(sections[1].granularity, TransactionSectionGranularity.daily);
    });

    test('uses weekly bucket at 7 days ago', () {
      final txns = [_txn(date: DateTime(2026, 6, 24))];
      final sections = TransactionSectionGrouper.group(txns, reference: ref);
      expect(sections.single.granularity, TransactionSectionGranularity.weekly);
      expect(sections.single.header, contains('–'));
    });

    test('uses monthly bucket at 28 days ago', () {
      final txns = [_txn(date: DateTime(2026, 6, 3))];
      final sections = TransactionSectionGrouper.group(txns, reference: ref);
      expect(
          sections.single.granularity, TransactionSectionGranularity.monthly);
      expect(sections.single.header, 'June 2026');
    });

    test('uses yearly bucket beyond 12 months', () {
      final txns = [_txn(date: DateTime(2024, 5, 1))];
      final sections = TransactionSectionGrouper.group(txns, reference: ref);
      expect(sections.single.granularity, TransactionSectionGranularity.yearly);
      expect(sections.single.header, '2024');
    });
  });

  group('TransactionListHelper', () {
    test('sorts by absolute amount largest first', () {
      final txns = [
        _txn(date: DateTime(2026, 7, 1), amount: 50),
        _txn(date: DateTime(2026, 6, 30), amount: -200),
        _txn(date: DateTime(2026, 6, 29), amount: 100),
      ];
      final sorted = TransactionListHelper.applySort(
        txns,
        TransactionSortOption.largestFirst,
      );
      expect(
        (sorted[0]['amount'] as num).abs(),
        200,
      );
      expect(
        (sorted[1]['amount'] as num).abs(),
        100,
      );
    });

    test('filters by category and price range', () {
      final txns = [
        _txn(date: DateTime(2026, 7, 1), category: 'Food', amount: 50),
        _txn(date: DateTime(2026, 7, 1), category: 'Travel', amount: 500),
        _txn(date: DateTime(2026, 7, 1), category: 'Food', amount: 1500),
      ];
      final filtered = TransactionListHelper.applyFilters(
        txns,
        const TransactionFilterCriteria(
          categories: {'Food'},
          minAmount: 100,
          maxAmount: 1000,
        ),
      );
      expect(filtered.length, 0);

      final filtered2 = TransactionListHelper.applyFilters(
        txns,
        const TransactionFilterCriteria(
          categories: {'Food'},
          maxAmount: 100,
        ),
      );
      expect(filtered2.length, 1);
      expect(filtered2.first['amount'], 50);
    });

    test('filters by payment method on personal transactions only', () {
      final txns = [
        _txn(
          date: DateTime(2026, 7, 1),
          paymentMethod: 'UPI',
          amount: 50,
        ),
        _txn(
          date: DateTime(2026, 7, 1),
          paymentMethod: 'Cash',
          amount: 30,
        ),
        _txn(
          date: DateTime(2026, 7, 1),
          type: 'group',
          groupId: 'g1',
          amount: 100,
        ),
      ];
      final filtered = TransactionListHelper.applyFilters(
        txns,
        const TransactionFilterCriteria(paymentMethods: {'UPI'}),
      );
      expect(filtered.length, 1);
      expect(filtered.first['payment_method'], 'UPI');
    });

    test('mergeDeduped skips duplicate keys', () {
      final a = [_txn(date: DateTime(2026, 7, 1), amount: 10)];
      final b = [
        _txn(date: DateTime(2026, 7, 1), amount: 10),
        _txn(date: DateTime(2026, 6, 1), amount: 20),
      ];
      b[0]['dedupe_key'] = a[0]['dedupe_key'];
      b[1]['dedupe_key'] = 'unique_2';
      final merged = TransactionListHelper.mergeDeduped(a, b);
      expect(merged.length, 2);
    });
  });
}
