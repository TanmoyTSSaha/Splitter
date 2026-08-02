import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Utils/budget_period_resolver.dart';

void main() {
  group('BudgetPeriodResolver', () {
    test('daily window is local calendar day', () {
      final now = DateTime(2026, 3, 11, 15, 30);
      final w = BudgetPeriodResolver.resolve(BudgetPeriodValues.daily, now);
      expect(w.start, DateTime(2026, 3, 11));
      expect(w.end, DateTime(2026, 3, 11, 23, 59, 59, 999));
      expect(w.periodKey, '2026-03-11');
    });

    test('weekly window is Monday-start for Wednesday', () {
      final now = DateTime(2026, 3, 11); // Wednesday
      final w = BudgetPeriodResolver.resolve(BudgetPeriodValues.weekly, now);
      expect(w.start, DateTime(2026, 3, 9)); // Monday
      expect(w.end, DateTime(2026, 3, 15, 23, 59, 59, 999)); // Sunday
      expect(w.periodKey, startsWith('2026-W'));
    });

    test('monthly window covers full calendar month', () {
      final now = DateTime(2026, 3, 20);
      final w = BudgetPeriodResolver.resolve(BudgetPeriodValues.monthly, now);
      expect(w.start, DateTime(2026, 3, 1));
      expect(w.end, DateTime(2026, 3, 31, 23, 59, 59, 999));
      expect(w.periodKey, '2026-03');
    });

    test('quarterly window Q2', () {
      final now = DateTime(2026, 5, 10);
      final w = BudgetPeriodResolver.resolve(BudgetPeriodValues.quarterly, now);
      expect(w.start, DateTime(2026, 4, 1));
      expect(w.end, DateTime(2026, 6, 30, 23, 59, 59, 999));
      expect(w.periodKey, '2026-Q2');
    });

    test('half-yearly H1', () {
      final now = DateTime(2026, 3, 31);
      final w =
          BudgetPeriodResolver.resolve(BudgetPeriodValues.halfYearly, now);
      expect(w.start, DateTime(2026, 1, 1));
      expect(w.end, DateTime(2026, 6, 30, 23, 59, 59, 999));
      expect(w.periodKey, '2026-H1');
    });

    test('yearly window', () {
      final now = DateTime(2026, 7, 4);
      final w = BudgetPeriodResolver.resolve(BudgetPeriodValues.yearly, now);
      expect(w.start, DateTime(2026, 1, 1));
      expect(w.end, DateTime(2026, 12, 31, 23, 59, 59, 999));
      expect(w.periodKey, '2026');
    });
  });
}
