import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Services/monthly_recap_aggregator.dart';

void main() {
  const userId = 'user-1';

  test('computeMonthlyGroupSocial returns inactive when no rows', () {
    final snapshot = MonthlyRecapAggregator.computeMonthlyGroupSocial(
      [],
      userId,
    );

    expect(snapshot[RecapDataKeys.hasGroupActivity], isFalse);
  });

  test('computeMonthlyGroupSocial counts groups and payer ratio', () {
    final rows = [
      {
        'group_id': 'g1',
        'paid_by': userId,
        'shared_with': 'friend-a',
        'shared_transaction_amount': 100,
        'category': CategoryDefaults.foodAndDining,
      },
      {
        'group_id': 'g1',
        'paid_by': 'friend-b',
        'shared_with': userId,
        'shared_transaction_amount': 50,
        'category': CategoryDefaults.foodAndDining,
      },
      {
        'group_id': 'g2',
        'paid_by': userId,
        'shared_with': 'friend-a',
        'shared_transaction_amount': 50,
        'category': CategoryDefaults.general,
      },
    ];

    final snapshot = MonthlyRecapAggregator.computeMonthlyGroupSocial(
      rows,
      userId,
    );

    expect(snapshot[RecapDataKeys.hasGroupActivity], isTrue);
    expect(snapshot[RecapDataKeys.groupCount], 2);
    expect(snapshot[RecapDataKeys.payerRatio], closeTo(75, 0.1));
    expect(snapshot[RecapDataKeys.topFriendId], 'friend-a');
    expect(
      snapshot[RecapDataKeys.groupFriendPeerIds],
      ['friend-a', 'friend-b'],
    );
  });
}
