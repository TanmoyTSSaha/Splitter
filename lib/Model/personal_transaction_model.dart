import 'package:splitter/Model/product_category_model.dart';

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
    double exchangeRateToInr = 1.0,
  }) : exchangeRateToInr = exchangeRateToInr;

  PersonalTransactionModel.fromJSON(Map<String, dynamic> json) {
    transactionID = json["transaction_id"];
    userID = json["user_id"];
    amount = double.tryParse(json["amount"]?.toString() ?? "0") ?? 0.0;
    category = json["category"];
    transactionDescription = json["transaction_description"];
    currency = json["currency"];
    paymentMethod = json["payment_method"];
    transactionDate = json["transaction_date"] != null
        ? DateTime.tryParse(json["transaction_date"])?.toLocal()
        : null;
    exchangeRateToInr =
        double.tryParse(json["exchange_rate_to_inr"]?.toString() ?? "1.0") ??
            1.0;
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["user_id"] = this.userID;
    data["amount"] = this.amount;
    data["category"] = this.category;
    data["transaction_description"] = this.transactionDescription;
    data["currency"] = this.currency;
    data["payment_method"] = this.paymentMethod;
    data["exchange_rate_to_inr"] = this.exchangeRateToInr;

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
    double exchangeRateToInr = 1.0,
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
    transactionID = json["transaction_id"];
    userID = json["user_id"];
    amount = double.tryParse(json["amount"]?.toString() ?? "0") ?? 0.0;
    category = json["category"];
    transactionDescription = json["transaction_description"];
    currency = json["currency"];
    paymentMethod = json["payment_method"];
    transactionDate = json["transaction_date"] != null
        ? DateTime.tryParse(json["transaction_date"])?.toLocal()
        : null;
    masterCategoryModel = json["master_category"];
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["transaction_id"] = transactionID;
    data["user_id"] = userID;
    data["amount"] = amount;
    data["category"] = category;
    data["transaction_description"] = transactionDescription;
    data["currency"] = currency;
    data["payment_method"] = paymentMethod;
    data["transaction_date"] = transactionDate;
    data["master_product_category"] = masterCategoryModel;

    return data;
  }
}
