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

  PersonalTransactionModel({
    this.transactionID,
    this.userID,
    this.amount,
    this.category,
    this.transactionDescription,
    this.currency,
    this.paymentMethod,
    this.transactionDate,
  });

  PersonalTransactionModel.fromJSON(Map<String, dynamic> json) {
    transactionID = json["transaction_id"];
    userID = json["user_id"];
    amount = double.parse(json["amount"].toString());
    category = json["category"];
    transactionDescription = json["transaction_description"];
    currency = json["currency"];
    paymentMethod = json["payment_method"];
    transactionDate = DateTime.parse(json["transaction_date"]).toLocal();
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data["user_id"] = this.userID;
    data["amount"] = this.amount;
    data["category"] = this.category;
    data["transaction_description"] = this.transactionDescription;
    data["currency"] = this.currency;
    data["payment_method"] = this.paymentMethod;

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
  });

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
  }

  PersonalTransactionWithProductCategoryModel.fromJSON(
      Map<String, dynamic> json) {
    transactionID = json["transaction_id"];
    userID = json["user_id"];
    amount = double.parse(json["amount"].toString());
    category = json["category"];
    transactionDescription = json["transaction_description"];
    currency = json["currency"];
    paymentMethod = json["payment_method"];
    transactionDate = DateTime.parse(json["transaction_date"]).toLocal();
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
