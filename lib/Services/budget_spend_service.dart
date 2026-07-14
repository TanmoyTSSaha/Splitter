import 'package:get/get.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Model/personal_budget_model.dart';
import 'package:splitr/Services/SupabaseServices/transaction_service.dart';
import 'package:splitr/Services/personal_budget_alert_service.dart';
import 'package:splitr/Utils/budget_period_resolver.dart';

class BudgetSpendService {
  final TransactionService _txService;

  BudgetSpendService({TransactionService? txService})
      : _txService = txService ?? TransactionService();

  String get _currency => Get.isRegistered<CurrencyController>()
      ? Get.find<CurrencyController>().code
      : CurrencyDefaults.code;

  Future<double> getSpendForBudget({
    required PersonalBudget budget,
    required String userId,
    DateTime? now,
  }) async {
    final map = await getSpendForBudgets(
      budgets: [budget],
      userId: userId,
      now: now,
    );
    return map[budget.id] ?? 0;
  }

  Future<Map<String, double>> getSpendForBudgets({
    required List<PersonalBudget> budgets,
    required String userId,
    DateTime? now,
  }) async {
    if (budgets.isEmpty) return {};
    final target = now ?? DateTime.now();
    final results = <String, double>{};
    final cache = <String, Future<Map<String, double>>>{};

    for (final budget in budgets) {
      final window = BudgetPeriodResolver.resolve(budget.period, target);
      final cacheKey = '${window.periodKey}_${budget.includeGroupExpenses}';
      final analyticsFuture = cache.putIfAbsent(
        cacheKey,
        () => _txService.getSpendAnalytics(
          userID: userId,
          rangeStart: window.start,
          rangeEnd: window.end,
          selectedCurrency: _currency,
          includeGroupExpenses: budget.includeGroupExpenses,
          personalDebitsOnly: true,
        ),
      );
      final analytics = await analyticsFuture;

      if (budget.isOverall) {
        results[budget.id] = analytics['total'] ?? 0;
      } else {
        results[budget.id] = analytics[budget.category] ?? 0;
      }
    }
    return results;
  }
}

/// ponytail: one-liner for alert re-evaluation from screens.
Future<void> reevaluateBudgetAlerts(String userId) async {
  if (!Get.isRegistered<PersonalBudgetAlertService>()) return;
  await Get.find<PersonalBudgetAlertService>().evaluateAndNotify(userId);
}
