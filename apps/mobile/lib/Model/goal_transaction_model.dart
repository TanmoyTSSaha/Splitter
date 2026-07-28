import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';

class GoalTransactionModel {
  String? id;
  String? goalId;
  double? amount;
  String? type;
  String? note;
  String? currency;
  double exchangeRateToInr;
  DateTime? transactionDate;
  DateTime? createdAt;

  GoalTransactionModel({
    this.id,
    this.goalId,
    this.amount,
    this.type,
    this.note,
    this.currency,
    this.exchangeRateToInr = CurrencyDefaults.exchangeRateToInr,
    this.transactionDate,
    this.createdAt,
  });

  GoalTransactionModel.fromJSON(Map<String, dynamic> json)
      : exchangeRateToInr = double.tryParse(
                json[SupabaseColumns.exchangeRateToInr]?.toString() ??
                    CurrencyDefaults.exchangeRateToInrString) ??
            CurrencyDefaults.exchangeRateToInr {
    id = json[SupabaseColumns.id];
    goalId = json[SupabaseColumns.goalId];
    amount = double.tryParse(
            json[SupabaseColumns.amount]?.toString() ?? AppAmountHints.zero) ??
        0.0;
    type = json[SupabaseColumns.type];
    note = json[SupabaseColumns.note];
    currency = json[SupabaseColumns.currency] ?? CurrencyDefaults.code;
    transactionDate = json[SupabaseColumns.transactionDate] != null
        ? DateTime.tryParse(json[SupabaseColumns.transactionDate])
        : null;
    createdAt = json[SupabaseColumns.createdAt] != null
        ? DateTime.tryParse(json[SupabaseColumns.createdAt])
        : null;
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[SupabaseColumns.goalId] = goalId;
    data[SupabaseColumns.amount] = amount;
    data[SupabaseColumns.type] = type;
    data[SupabaseColumns.note] = note;
    data[SupabaseColumns.currency] = currency ?? CurrencyDefaults.code;
    data[SupabaseColumns.exchangeRateToInr] = exchangeRateToInr;
    data[SupabaseColumns.transactionDate] = transactionDate?.toIso8601String();
    return data;
  }
}
