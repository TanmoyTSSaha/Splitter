import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Utils/group_balance_mutator.dart';

void main() {
  group('applySettlement', () {
    test('removes balance when settled in full', () {
      final updated = applySettlement(
        balances: [
          {
            'donor': 'Bob',
            'donor_id': 'bob',
            'receiver': 'Alice',
            'receiver_id': 'alice',
            'amount': 500,
          },
        ],
        fromUserId: 'alice',
        toUserId: 'bob',
        amount: 500,
      );

      expect(updated, isEmpty);
    });

    test('ignores unrelated balance rows', () {
      final updated = applySettlement(
        balances: [
          {
            'donor': 'Bob',
            'donor_id': 'bob',
            'receiver': 'Alice',
            'receiver_id': 'alice',
            'amount': 500,
          },
          {
            'donor': 'Carol',
            'donor_id': 'carol',
            'receiver': 'Alice',
            'receiver_id': 'alice',
            'amount': 100,
          },
        ],
        fromUserId: 'alice',
        toUserId: 'bob',
        amount: 200,
      );

      expect(updated, hasLength(2));
      expect(
        updated.firstWhere((e) => e['donor_id'] == 'bob')['amount'],
        300,
      );
      expect(
        updated.firstWhere((e) => e['donor_id'] == 'carol')['amount'],
        100,
      );
    });
  });

  group('applyDebtEntry', () {
    test('nets against reverse balance instead of duplicating', () {
      final balances = <Map<String, dynamic>>[
        {
          'donor': 'Bob',
          'donor_id': 'bob',
          'receiver': 'Alice',
          'receiver_id': 'alice',
          'amount': 100,
        },
      ];

      applyDebtEntry(
        balances,
        donorId: 'alice',
        receiverId: 'bob',
        amountToAdd: 40,
      );

      expect(balances, hasLength(1));
      expect(balances.first['donor_id'], 'bob');
      expect(balances.first['receiver_id'], 'alice');
      expect(balances.first['amount'], 60);
    });

    test('flips direction when new debt exceeds reverse balance', () {
      final balances = <Map<String, dynamic>>[
        {
          'donor': 'Bob',
          'donor_id': 'bob',
          'receiver': 'Alice',
          'receiver_id': 'alice',
          'amount': 50,
        },
      ];

      applyDebtEntry(
        balances,
        donorId: 'alice',
        receiverId: 'bob',
        amountToAdd: 80,
      );

      expect(balances, hasLength(1));
      expect(balances.first['donor_id'], 'alice');
      expect(balances.first['receiver_id'], 'bob');
      expect(balances.first['amount'], 30);
    });
  });
}
