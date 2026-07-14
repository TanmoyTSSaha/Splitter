import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/domain_values.dart';

class PersonalBudget {
  final String id;
  final String userId;
  final String? category;
  final String period;
  final double limitAmount;
  final double alertThreshold;
  final bool includeGroupExpenses;

  const PersonalBudget({
    required this.id,
    required this.userId,
    this.category,
    this.period = BudgetDefaults.defaultPeriod,
    required this.limitAmount,
    required this.alertThreshold,
    this.includeGroupExpenses = true,
  });

  /// ponytail: alias for one release while callers migrate off monthlyLimit.
  double get monthlyLimit => limitAmount;

  bool get isOverall => category == null || category!.isEmpty;

  String get displayLabel =>
      isOverall ? BudgetDefaults.overallLabel : category!;

  factory PersonalBudget.fromJson(Map<String, dynamic> json) {
    final limitRaw = json[SupabaseColumns.limitAmount] ??
        json[SupabaseColumns.monthlyLimit];
    return PersonalBudget(
      id: json[SupabaseColumns.id] as String,
      userId: json[SupabaseColumns.userId] as String,
      category: json[SupabaseColumns.category] as String?,
      period: json[SupabaseColumns.period] as String? ??
          BudgetDefaults.defaultPeriod,
      limitAmount: double.tryParse(
              limitRaw?.toString() ?? AppAmountHints.zero) ??
          0,
      alertThreshold: double.tryParse(
              json[SupabaseColumns.alertThreshold]?.toString() ??
                  BudgetRules.alertThreshold.toString()) ??
          BudgetRules.alertThreshold,
      includeGroupExpenses:
          json[SupabaseColumns.includeGroupExpenses] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id.isNotEmpty) SupabaseColumns.id: id,
        SupabaseColumns.userId: userId,
        SupabaseColumns.category: category,
        SupabaseColumns.period: period,
        SupabaseColumns.limitAmount: limitAmount,
        SupabaseColumns.alertThreshold: alertThreshold,
        SupabaseColumns.includeGroupExpenses: includeGroupExpenses,
      };
}
