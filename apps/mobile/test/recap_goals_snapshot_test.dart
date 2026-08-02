import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Model/financial_goal_model.dart';
import 'package:splitr/Services/monthly_recap_aggregator.dart';

void main() {
  test('computeGoalsSnapshot returns inactive when no goals or deposits', () {
    final snapshot = MonthlyRecapAggregator.computeGoalsSnapshot(
      [],
      0,
      DateTime(2026, 7, 1),
    );

    expect(snapshot[RecapDataKeys.hasGoalsActivity], isFalse);
  });

  test('computeGoalsSnapshot surfaces hero goal and contribution', () {
    final goal = FinancialGoalModel(
      id: 'goal-1',
      title: 'Emergency Fund',
      targetAmount: 1000,
      currentAmount: 600,
      status: GoalStatusValues.active,
    );

    final snapshot = MonthlyRecapAggregator.computeGoalsSnapshot(
      [goal],
      150,
      DateTime(2026, 7, 1),
    );

    expect(snapshot[RecapDataKeys.hasGoalsActivity], isTrue);
    expect(snapshot[RecapDataKeys.activeGoalsCount], 1);
    expect(snapshot[RecapDataKeys.bestGoalTitle], 'Emergency Fund');
    expect(snapshot[RecapDataKeys.bestGoalProgress], closeTo(0.6, 0.001));
    expect(snapshot[RecapDataKeys.goalsContributedThisMonth], 150);
    expect(snapshot[RecapDataKeys.goalsMotivationLine],
        RecapGoalMotivation.onTrack);
  });

  test('computeGoalsSnapshot flags goal completed in month', () {
    final goal = FinancialGoalModel(
      id: 'goal-1',
      title: 'Vacation',
      targetAmount: 1000,
      currentAmount: 1050,
      status: GoalStatusValues.active,
    );

    final snapshot = MonthlyRecapAggregator.computeGoalsSnapshot(
      [goal],
      200,
      DateTime(2026, 7, 1),
    );

    expect(snapshot[RecapDataKeys.goalsAtTargetCount], 1);
    expect(snapshot[RecapDataKeys.goalCompletedInMonth], isTrue);
    expect(snapshot[RecapDataKeys.bestGoalProgress], greaterThanOrEqualTo(1.0));
  });
}
