import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Utils/recurring_merchant_detector.dart';
import 'package:splitr/Utils/sync_operation_planner.dart';

void main() {
  test('planSyncOperation maps UPDATE to primary key filter', () {
    final plan = planSyncOperation(
      targetTable: 'personal_transaction',
      operation: 'UPDATE',
      recordId: 'abc',
      payload: {'id': 'abc', 'amount': 42},
    );

    expect(plan.filterField, 'id');
    expect(plan.filterValue, 'abc');
  });

  test('planSyncOperation maps DELETE to record id', () {
    final plan = planSyncOperation(
      targetTable: 'group_transaction',
      operation: 'DELETE',
      recordId: 'tx-1',
      payload: {},
    );

    expect(plan.filterField, 'transaction_id');
    expect(plan.filterValue, 'tx-1');
  });

  test('detectRecurringMerchants finds stable monthly merchant', () {
    final base = DateTime(2026, 1, 15);
    final txns = List.generate(4, (i) {
      final month = DateTime(base.year, base.month + i, base.day);
      return {
        'type': 'personal',
        'is_credit': false,
        'title': 'Netflix Subscription',
        'amount': 499.0 + (i == 1 ? 5 : 0),
        'date': month,
      };
    });

    final hits = detectRecurringMerchants(txns);
    expect(hits, hasLength(1));
    expect(hits.first.label, 'Netflix Subscription');
    expect(hits.first.occurrenceCount, 4);
  });

  test('detectRecurringMerchants ignores one-off merchants', () {
    final hits = detectRecurringMerchants([
      {
        'type': 'personal',
        'is_credit': false,
        'title': 'Coffee Shop',
        'amount': 120,
        'date': DateTime(2026, 1, 1),
      },
      {
        'type': 'personal',
        'is_credit': false,
        'title': 'Coffee Shop',
        'amount': 180,
        'date': DateTime(2026, 2, 10),
      },
    ]);

    expect(hits, isEmpty);
  });
}
