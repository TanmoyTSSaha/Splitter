import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Services/budget_spend_service.dart';
import 'package:splitr/Services/currency_service.dart';
import 'package:splitr/Services/personal_budget_service.dart';
import 'package:splitr/Services/reminder_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/Utils/budget_alert_evaluator.dart';
import 'package:splitr/Utils/budget_period_resolver.dart';
import 'package:get/get.dart';

/// Fires at-most-once-per-period local notifications for budget thresholds.
class PersonalBudgetAlertService {
  final ReminderService _reminders;
  final PersonalBudgetService _budgets;
  final BudgetSpendService _spend;

  PersonalBudgetAlertService({
    ReminderService? reminders,
    PersonalBudgetService? budgets,
    BudgetSpendService? spend,
  })  : _reminders = reminders ?? Get.find<ReminderService>(),
        _budgets = budgets ?? PersonalBudgetService(),
        _spend = spend ?? BudgetSpendService();

  Future<void> evaluateAndNotify(String userId) async {
    try {
      final budgets = await _budgets.listBudgets(userId);
      if (budgets.isEmpty) return;

      final now = DateTime.now();
      final spentById = await _spend.getSpendForBudgets(
        budgets: budgets,
        userId: userId,
        now: now,
      );

      final sym = Get.isRegistered<CurrencyController>()
          ? Get.find<CurrencyController>().symbol
          : CurrencyService.symbolFor(CurrencyDefaults.code);

      final prefs = await SharedPreferences.getInstance();
      final sentAll =
          _readSentMap(prefs.getString(PrefKeys.budgetAlertSentV1));

      for (final budget in budgets) {
        final spent = spentById[budget.id] ?? 0;
        final alertType = budgetAlertType(
          spent: spent,
          limitAmount: budget.limitAmount,
          alertThreshold: budget.alertThreshold,
        );
        if (alertType == null) continue;

        final window = BudgetPeriodResolver.resolve(budget.period, now);
        final dedupeKey = '${budget.id}_${window.periodKey}_$alertType';
        if (sentAll[dedupeKey] == true) continue;

        final label = budget.displayLabel;
        final limitStr = '$sym${budget.limitAmount.toStringAsFixed(0)}';
        final spentStr = '$sym${spent.toStringAsFixed(0)}';

        if (alertType == BudgetAlertTypes.over) {
          await _reminders.showBudgetAlert(
            id: dedupeKey.hashCode,
            title: '${AppStrings.services.budget.overBudgetPrefix}$label',
            body:
                '${AppStrings.services.budget.overBodyPrefix}$spentStr${AppStrings.services.budget.overBodyMid}$limitStr${AppStrings.services.budget.overBodySuffix}',
          );
        } else {
          await _reminders.showBudgetAlert(
            id: dedupeKey.hashCode,
            title: '${AppStrings.services.budget.nearBudgetPrefix}$label',
            body:
                '${AppStrings.services.budget.nearBodyPrefix}$spentStr${AppStrings.services.budget.nearBodyMid}$limitStr${AppStrings.services.budget.nearBodySuffix}',
          );
        }

        sentAll[dedupeKey] = true;
      }

      // ponytail: FCM v2 — move dedupe server-side; periodKey already stable.
      await prefs.setString(PrefKeys.budgetAlertSentV1, jsonEncode(sentAll));
    } catch (e, stack) {
      AppErrorReporter.report(
        'PersonalBudgetAlertService.evaluateAndNotify failed',
        error: e,
        stack: stack,
        context: {'feature': 'budget', 'operation': 'evaluateAndNotify'},
      );
    }
  }

  Map<String, dynamic> _readSentMap(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        // Migrate legacy month-nested maps to flat period keys.
        final flat = <String, dynamic>{};
        for (final entry in decoded.entries) {
          final value = entry.value;
          if (value is Map) {
            for (final inner in value.entries) {
              flat[inner.key.toString()] = inner.value;
            }
          } else {
            flat[entry.key.toString()] = value;
          }
        }
        return flat;
      }
      return {};
    } catch (_) {
      return {};
    }
  }
}
