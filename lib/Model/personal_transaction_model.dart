import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Model/product_category_model.dart';

class PersonalTransactionModel {
  String? transactionID;
  String? userID;
  double? amount;
  String? category;
  String? transactionDescription;
  String? currency;
  String? paymentMethod;
  DateTime? transactionDate;
  late double exchangeRateToInr;

  PersonalTransactionModel({
    this.transactionID,
    this.userID,
    this.amount,
    this.category,
    this.transactionDescription,
    this.currency,
    this.paymentMethod,
    this.transactionDate,
    double exchangeRateToInr = CurrencyDefaults.exchangeRateToInr,
  }) : exchangeRateToInr = exchangeRateToInr;

  PersonalTransactionModel.fromJSON(Map<String, dynamic> json) {
    transactionID = (json[SupabaseColumns.transactionId] ??
        json[SupabaseColumns.id]) as String?;
    userID = json[SupabaseColumns.userId];
    amount = double.tryParse(
            json[SupabaseColumns.amount]?.toString() ?? AppAmountHints.zero) ??
        0.0;
    category = json[SupabaseColumns.category];
    transactionDescription = json[SupabaseColumns.transactionDescription];
    currency = json[SupabaseColumns.currency];
    paymentMethod = json[SupabaseColumns.paymentMethod];
    transactionDate = json[SupabaseColumns.transactionDate] != null
        ? DateTime.tryParse(json[SupabaseColumns.transactionDate])?.toLocal()
        : null;
    exchangeRateToInr = double.tryParse(
            json[SupabaseColumns.exchangeRateToInr]?.toString() ??
                CurrencyDefaults.exchangeRateToInrString) ??
        CurrencyDefaults.exchangeRateToInr;
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data[SupabaseColumns.userId] = userID;
    data[SupabaseColumns.amount] = amount;
    data[SupabaseColumns.category] = category;
    data[SupabaseColumns.transactionDescription] = transactionDescription;
    data[SupabaseColumns.currency] = currency;
    data[SupabaseColumns.paymentMethod] = paymentMethod;
    data[SupabaseColumns.exchangeRateToInr] = exchangeRateToInr;

    return data;
  }
}

class PersonalTransactionWithProductCategoryModel {
  String? transactionID;
  String? userID;
  double? amount;
  String? category;
  String? transactionDescription;
  String? currency;
  String? paymentMethod;
  DateTime? transactionDate;
  CategoryOnlyModel? masterCategoryModel;
  late double exchangeRateToInr;

  PersonalTransactionWithProductCategoryModel({
    this.transactionID,
    this.userID,
    this.amount,
    this.category,
    this.transactionDescription,
    this.currency,
    this.paymentMethod,
    this.transactionDate,
    this.masterCategoryModel,
    double exchangeRateToInr = CurrencyDefaults.exchangeRateToInr,
  }) : exchangeRateToInr = exchangeRateToInr;

  PersonalTransactionWithProductCategoryModel.fromModel(
      PersonalTransactionModel personalTransaction,
      CategoryOnlyModel categoryModel) {
    transactionID = personalTransaction.transactionID;
    userID = personalTransaction.userID;
    amount = personalTransaction.amount;
    category = personalTransaction.category;
    transactionDescription = personalTransaction.transactionDescription;
    currency = personalTransaction.currency;
    paymentMethod = personalTransaction.paymentMethod;
    transactionDate = personalTransaction.transactionDate;
    masterCategoryModel = categoryModel;
    exchangeRateToInr = personalTransaction.exchangeRateToInr;
  }

  PersonalTransactionWithProductCategoryModel.fromJSON(
      Map<String, dynamic> json) {
    transactionID = (json[SupabaseColumns.transactionId] ??
        json[SupabaseColumns.id]) as String?;
    userID = json[SupabaseColumns.userId];
    amount = double.tryParse(
            json[SupabaseColumns.amount]?.toString() ?? AppAmountHints.zero) ??
        0.0;
    category = json[SupabaseColumns.category];
    transactionDescription = json[SupabaseColumns.transactionDescription];
    currency = json[SupabaseColumns.currency];
    paymentMethod = json[SupabaseColumns.paymentMethod];
    transactionDate = json[SupabaseColumns.transactionDate] != null
        ? DateTime.tryParse(json[SupabaseColumns.transactionDate])?.toLocal()
        : null;
    masterCategoryModel = json[SupabaseColumns.masterCategory];
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data[SupabaseColumns.transactionId] = transactionID;
    data[SupabaseColumns.userId] = userID;
    data[SupabaseColumns.amount] = amount;
    data[SupabaseColumns.category] = category;
    data[SupabaseColumns.transactionDescription] = transactionDescription;
    data[SupabaseColumns.currency] = currency;
    data[SupabaseColumns.paymentMethod] = paymentMethod;
    data[SupabaseColumns.transactionDate] = transactionDate;
    data[SupabaseColumns.masterProductCategory] = masterCategoryModel;

    return data;
  }
}
