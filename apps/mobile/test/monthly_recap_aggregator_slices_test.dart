import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Services/monthly_recap_aggregator.dart';
import 'package:splitr/Widgets/recap_settlement_tick.dart';

void main() {
  test('RecapSettlementTick shows at score 70+', () {
    expect(RecapSettlementTick.shouldShow(69), isFalse);
    expect(RecapSettlementTick.shouldShow(70), isTrue);
    expect(RecapSettlementTick.shouldShow(90), isTrue);
  });

  test('mergeSlicesForTest composes monthly group slice over social fallback', () {
    final base = {
      RecapDataKeys.month: DateTime(2026, 7, 1),
      RecapDataKeys.totalSpent: 500.0,
      RecapDataKeys.topCategory: 'Food',
      RecapDataKeys.categoryBreakdown: {'Food': 500.0},
    };

    final merged = MonthlyRecapAggregator.mergeSlicesForTest(
      base: Map<String, dynamic>.from(base),
      trend: const [],
      habit: {
        RecapDataKeys.habitType: RecapHabitTypes.steadySpender,
        RecapDataKeys.habitTransactionCount: 4,
      },
      social: {
        RecapDataKeys.groupCount: 1,
        RecapDataKeys.payerRatio: 40.0,
        RecapDataKeys.openExposure: 100.0,
        RecapDataKeys.settlementAvgDays: 5,
        'topGroupName': 'Trip',
      },
      lending: {RecapDataKeys.hasLendingActivity: false},
      goals: {RecapDataKeys.hasGoalsActivity: false},
      monthlyGroup: {
        RecapDataKeys.hasGroupActivity: true,
        RecapDataKeys.groupCount: 2,
        RecapDataKeys.payerRatio: 72.0,
        RecapDataKeys.topFriendName: 'Sam',
      },
      persona: {RecapDataKeys.hasPersonaSlide: true},
      settleUpHealthScore: 82,
    );

    expect(merged[RecapDataKeys.hasGroupActivity], isTrue);
    expect(merged[RecapDataKeys.groupCount], 2);
    expect(merged[RecapDataKeys.payerRatio], 72.0);
    expect(merged[RecapDataKeys.topFriendName], 'Sam');
    expect(merged[RecapDataKeys.settleUpHealthScore], 82);
    expect(merged[RecapDataKeys.topCategoryRank], 1);
  });
}
