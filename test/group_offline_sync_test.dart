import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Utils/group_balance_mutator.dart';
import 'package:splitr/Utils/group_expense_builder.dart';

void main() {
  test('applySplitDebts adds payer-to-member debt entries', () {
    final updated = applySplitDebts(
      balances: [],
      payerId: 'alice',
      splits: {'bob': 300, 'carol': 200},
    );

    expect(updated, hasLength(2));
    expect(updated[0]['donor_id'], 'alice');
    expect(updated[0]['receiver_id'], 'bob');
    expect(updated[0]['amount'], 300);
  });

  test('applySettlement reduces creditor-to-debtor balance', () {
    final updated = applySettlement(
      balances: [
        {
          'donor': 'Bob',
          'donor_id': 'bob',
          'receiver': 'Alice',
          'receiver_id': 'alice',
          'amount': 500,
        }
      ],
      fromUserId: 'alice',
      toUserId: 'bob',
      amount: 200,
    );

    expect(updated, hasLength(1));
    expect(updated.first['amount'], 300);
  });

  test('GroupExpenseBuilder creates one row per split', () {
    final rows = GroupExpenseBuilder.buildExpenseRows(
      groupId: 'g1',
      paidByUserId: 'alice',
      totalAmount: 1000,
      description: 'Dinner',
      category: 'Food',
      splits: {'bob': 500, 'carol': 500},
      currency: 'INR',
    );

    expect(rows, hasLength(2));
    expect(rows.first.syncPayload['transaction_id'], isNotEmpty);
    expect(rows.first.syncPayload['group_id'], 'g1');
  });

  test('GroupExpenseBuilder settlement row is marked settled', () {
    final row = GroupExpenseBuilder.buildSettlementRow(
      groupId: 'g1',
      fromUserId: 'alice',
      toUserId: 'bob',
      amount: 250,
      currency: 'INR',
    );

    expect(row.sharingType, 'settlement');
    expect(row.syncPayload['is_settled_up'], isTrue);
  });
}
