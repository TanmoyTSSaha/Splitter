import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Services/monthly_recap_aggregator.dart';
import 'package:splitr/Utils/persona_engine.dart';

void main() {
  test('load merges injected slices without Supabase IO', () async {
    final month = DateTime(2026, 7, 1);
    final aggregator = MonthlyRecapAggregator(
      testHooks: MonthlyRecapAggregatorTestHooks(
        generateBaseRecap: (m) async => {
          RecapDataKeys.month: m,
          RecapDataKeys.totalSpent: 1200.0,
          RecapDataKeys.lastMonthTotal: 900.0,
          RecapDataKeys.topCategory: 'Food',
          RecapDataKeys.topCategoryAmount: 600.0,
          RecapDataKeys.categoryBreakdown: {'Food': 600.0, 'Travel': 400.0},
        },
        fetchSpendingTrend: (_) async => [
          {'month': month, 'total': 1200.0},
        ],
        fetchWeekdayHabit: (_) async => {
          RecapDataKeys.habitType: RecapHabitTypes.weekendSplurger,
          RecapDataKeys.habitTransactionCount: 12,
        },
        fetchSocialTrust: () async => {
          RecapDataKeys.groupCount: 1,
          RecapDataKeys.payerRatio: 40.0,
          RecapDataKeys.openExposure: 200.0,
          RecapDataKeys.settlementAvgDays: 4,
          'topGroupName': 'Weekend Trip',
        },
        fetchLendingSnapshot: (_) async => {
          RecapDataKeys.hasLendingActivity: true,
          RecapDataKeys.activeLoanCount: 1,
          RecapDataKeys.totalLoanOutstanding: 500.0,
          RecapDataKeys.totalRepaidThisMonth: 100.0,
        },
        fetchGoalsSnapshot: (_) async => {
          RecapDataKeys.hasGoalsActivity: true,
          RecapDataKeys.activeGoalsCount: 1,
          RecapDataKeys.bestGoalTitle: 'Emergency Fund',
          RecapDataKeys.bestGoalProgress: 0.6,
        },
        fetchGroupActivity: (_) async => {
          RecapDataKeys.hasGroupActivity: true,
          RecapDataKeys.groupCount: 2,
          RecapDataKeys.payerRatio: 72.0,
          RecapDataKeys.topFriendName: 'Sam',
        },
        fetchPersonaSlice: (_, __) async => PersonaEngine.toRecapPayload(
          const PersonaResult(
            type: RecapPersonaTypes.settlementHero,
            statOneLabelKey: RecapPersonaStatKeys.settlements,
            statOneValue: '4',
            statTwoLabelKey: RecapPersonaStatKeys.spent,
            statTwoValue: '1200',
          ),
        ),
        fetchSettleUpHealthScore: () async => 85,
        fetchSettlementsClosed: (_) async => 3,
      ),
    );

    final result = await aggregator.load(month);

    expect(result[RecapDataKeys.totalSpent], 1200.0);
    expect(result[RecapDataKeys.expenseTotal], 1200.0);
    expect(result[RecapDataKeys.settlementsClosedCount], 3);
    expect(result[RecapDataKeys.habitType], RecapHabitTypes.weekendSplurger);
    expect(result[RecapDataKeys.hasGroupActivity], isTrue);
    expect(result[RecapDataKeys.groupCount], 2);
    expect(result[RecapDataKeys.topFriendName], 'Sam');
    expect(result[RecapDataKeys.hasLendingActivity], isTrue);
    expect(result[RecapDataKeys.hasGoalsActivity], isTrue);
    expect(result[RecapDataKeys.personaType], RecapPersonaTypes.settlementHero);
    expect(result[RecapDataKeys.settleUpHealthScore], 85);
    expect(result[RecapDataKeys.topCategoryRank], 1);
    expect((result[RecapDataKeys.spendingTrend] as List).length, 1);
    expect(result[RecapDataKeys.topCategory], isNot('Salary'));
  });

  test('expenseTotal mirrors expense-only totalSpent from base recap', () async {
    final month = DateTime(2026, 7, 1);
    final aggregator = MonthlyRecapAggregator(
      testHooks: MonthlyRecapAggregatorTestHooks(
        generateBaseRecap: (m) async => {
          RecapDataKeys.month: m,
          RecapDataKeys.totalSpent: 4200.0,
          RecapDataKeys.lastMonthTotal: 3900.0,
          RecapDataKeys.topCategory: 'Food',
          RecapDataKeys.topCategoryAmount: 2200.0,
          RecapDataKeys.categoryBreakdown: {'Food': 2200.0, 'Travel': 2000.0},
        },
        fetchSpendingTrend: (_) async => [],
        fetchWeekdayHabit: (_) async => {
          RecapDataKeys.habitType: RecapHabitTypes.quietMonth,
          RecapDataKeys.habitTransactionCount: 0,
        },
        fetchSocialTrust: () async => {
          RecapDataKeys.groupCount: 0,
          RecapDataKeys.openExposure: 0.0,
        },
        fetchLendingSnapshot: (_) async =>
            {RecapDataKeys.hasLendingActivity: false},
        fetchGoalsSnapshot: (_) async =>
            {RecapDataKeys.hasGoalsActivity: false},
        fetchGroupActivity: (_) async =>
            {RecapDataKeys.hasGroupActivity: false},
        fetchPersonaSlice: (_, __) async => PersonaEngine.fallbackPayload(),
        fetchSettleUpHealthScore: () async => InsightsLimits.settleHealthDefault,
        fetchSettlementsClosed: (_) async => 0,
      ),
    );

    final result = await aggregator.load(month);

    expect(result[RecapDataKeys.expenseTotal], 4200.0);
    expect(result[RecapDataKeys.totalSpent], 4200.0);
    expect(result[RecapDataKeys.topCategory], 'Food');
  });

  test('loadPayload returns typed view over load()', () async {
    final month = DateTime(2026, 8, 1);
    final aggregator = MonthlyRecapAggregator(
      testHooks: MonthlyRecapAggregatorTestHooks(
        generateBaseRecap: (m) async => {
          RecapDataKeys.month: m,
          RecapDataKeys.totalSpent: 300.0,
          RecapDataKeys.topCategory: 'Food',
          RecapDataKeys.categoryBreakdown: {'Food': 300.0},
        },
        fetchSpendingTrend: (_) async => [],
        fetchWeekdayHabit: (_) async => {
          RecapDataKeys.habitType: RecapHabitTypes.quietMonth,
          RecapDataKeys.habitTransactionCount: 2,
        },
        fetchSocialTrust: () async => {
          RecapDataKeys.groupCount: 0,
          RecapDataKeys.openExposure: 0.0,
        },
        fetchLendingSnapshot: (_) async =>
            {RecapDataKeys.hasLendingActivity: false},
        fetchGoalsSnapshot: (_) async =>
            {RecapDataKeys.hasGoalsActivity: false},
        fetchGroupActivity: (_) async =>
            {RecapDataKeys.hasGroupActivity: false},
        fetchPersonaSlice: (_, __) async => PersonaEngine.fallbackPayload(),
        fetchSettleUpHealthScore: () async => InsightsLimits.settleHealthDefault,
      ),
    );

    final payload = await aggregator.loadPayload(month);

    expect(payload.totalSpent, 300.0);
    expect(payload.hasLendingActivity, isFalse);
    expect(payload.habitType, RecapHabitTypes.quietMonth);
  });
}
