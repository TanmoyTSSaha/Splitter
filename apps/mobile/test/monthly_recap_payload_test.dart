import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Model/monthly_recap_payload.dart';

void main() {
  test('MonthlyRecapPayload round-trips map and exposes getters', () {
    final month = DateTime(2026, 7, 1);
    final source = {
      RecapDataKeys.month: month,
      RecapDataKeys.totalSpent: 1200.5,
      RecapDataKeys.lastMonthTotal: 900,
      RecapDataKeys.topCategory: 'Food',
      RecapDataKeys.hasGroupActivity: true,
      RecapDataKeys.groupCount: 2,
      RecapDataKeys.topFriendName: 'Alex',
      RecapDataKeys.groupFriendPeers: [
        {'id': 'f1', 'name': 'Alex'},
      ],
      RecapDataKeys.hasLendingActivity: true,
      RecapDataKeys.loansCompletedThisMonth: 1,
      RecapDataKeys.topLoanProgress: 0.65,
      RecapDataKeys.habitType: RecapHabitTypes.steadySpender,
      RecapDataKeys.spendingTrend: [
        {'month': month, 'total': 1200.5},
      ],
    };

    final payload = MonthlyRecapPayload.fromMap(source);
    final roundTrip = MonthlyRecapPayload.fromMap(payload.toMap());

    expect(roundTrip.month, month);
    expect(roundTrip.totalSpent, 1200.5);
    expect(roundTrip.hasGroupActivity, isTrue);
    expect(roundTrip.topFriendName, 'Alex');
    expect(roundTrip.groupFriendPeers.length, 1);
    expect(roundTrip.loansCompletedThisMonth, 1);
    expect(roundTrip.topLoanProgress, 0.65);
    expect(roundTrip.spendingTrend.length, 1);
    expect(roundTrip.hasSpendingData, isTrue);
  });
}
