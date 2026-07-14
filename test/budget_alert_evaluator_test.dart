import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Utils/budget_alert_evaluator.dart';

void main() {
  test('budgetAlertType returns null below threshold', () {
    expect(
      budgetAlertType(spent: 50, monthlyLimit: 100, alertThreshold: 0.9),
      isNull,
    );
  });

  test('budgetAlertType returns near at threshold', () {
    expect(
      budgetAlertType(spent: 90, monthlyLimit: 100, alertThreshold: 0.9),
      'near',
    );
  });

  test('budgetAlertType returns over when spent exceeds limit', () {
    expect(
      budgetAlertType(spent: 120, monthlyLimit: 100, alertThreshold: 0.9),
      'over',
    );
  });
}
