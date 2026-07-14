import 'package:splitr/Constants/domain_values.dart';

/// Returns `near` at alert threshold, `over` when spend exceeds limit.
String? budgetAlertType({
  required double spent,
  double? limitAmount,
  double? monthlyLimit,
  required double alertThreshold,
}) {
  final limit = limitAmount ?? monthlyLimit ?? 0;
  if (limit <= 0) return null;
  if (spent > limit) return BudgetAlertTypes.over;
  if (spent >= limit * alertThreshold) return BudgetAlertTypes.near;
  return null;
}
