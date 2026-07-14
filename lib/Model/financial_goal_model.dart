import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';

class FinancialGoalModel {
  String? id;
  String? userId;
  String? title;
  double? targetAmount;
  double? currentAmount;
  DateTime? deadline;
  String? status;
  String? icon;
  DateTime? createdAt;
  String? colorHex;
  String? iconKey;
  String? smartRecommendationId;
  DateTime? estimatedCompletionDate;
  String? description;
  String? goalType;
  String? currency;
  double exchangeRateToInr;

  FinancialGoalModel({
    this.id,
    this.userId,
    this.title,
    this.targetAmount,
    this.currentAmount,
    this.deadline,
    this.status,
    this.icon,
    this.createdAt,
    this.colorHex,
    this.iconKey,
    this.smartRecommendationId,
    this.estimatedCompletionDate,
    this.description,
    this.goalType,
    this.currency,
    this.exchangeRateToInr = CurrencyDefaults.exchangeRateToInr,
  });

  FinancialGoalModel.fromJSON(Map<String, dynamic> json)
      : exchangeRateToInr = double.tryParse(
                json[SupabaseColumns.exchangeRateToInr]?.toString() ??
                    CurrencyDefaults.exchangeRateToInrString) ??
            CurrencyDefaults.exchangeRateToInr {
    id = json[SupabaseColumns.id];
    userId = json[SupabaseColumns.userId];
    title = json[SupabaseColumns.title];
    targetAmount = double.tryParse(
            json[SupabaseColumns.targetAmount]?.toString() ??
                AppAmountHints.zero) ??
        0.0;
    currentAmount = double.tryParse(
            json[SupabaseColumns.currentAmount]?.toString() ??
                AppAmountHints.zero) ??
        0.0;
    deadline = json[SupabaseColumns.deadline] != null
        ? DateTime.tryParse(json[SupabaseColumns.deadline])
        : null;
    status = json[SupabaseColumns.status];
    icon = json[SupabaseColumns.icon];
    createdAt = json[SupabaseColumns.createdAt] != null
        ? DateTime.tryParse(json[SupabaseColumns.createdAt])
        : null;
    colorHex = json[SupabaseColumns.colorHex];
    iconKey = json[SupabaseColumns.iconKey];
    smartRecommendationId = json[SupabaseColumns.smartRecommendationId];
    estimatedCompletionDate =
        json[SupabaseColumns.estimatedCompletionDate] != null
            ? DateTime.tryParse(json[SupabaseColumns.estimatedCompletionDate])
            : null;
    description = json[SupabaseColumns.description];
    goalType = json[SupabaseColumns.goalType];
    currency = json[SupabaseColumns.currency] ?? CurrencyDefaults.code;
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[SupabaseColumns.userId] = userId;
    data[SupabaseColumns.title] = title;
    data[SupabaseColumns.targetAmount] = targetAmount;
    data[SupabaseColumns.currentAmount] = currentAmount;
    data[SupabaseColumns.deadline] = deadline?.toIso8601String();
    data[SupabaseColumns.status] = status;
    data[SupabaseColumns.icon] = icon;
    data[SupabaseColumns.colorHex] = colorHex;
    data[SupabaseColumns.iconKey] = iconKey;
    data[SupabaseColumns.smartRecommendationId] = smartRecommendationId;
    data[SupabaseColumns.estimatedCompletionDate] =
        estimatedCompletionDate?.toIso8601String();
    data[SupabaseColumns.description] = description;
    data[SupabaseColumns.goalType] = goalType;
    data[SupabaseColumns.currency] = currency ?? CurrencyDefaults.code;
    data[SupabaseColumns.exchangeRateToInr] = exchangeRateToInr;
    return data;
  }
}
