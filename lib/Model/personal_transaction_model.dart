class PersonalTransaction {
  String? transactionID;
  String? userID;
  double? amount;
  String? category;
  String? transactionDescription;
  String? currency;
  String? paymentMethod;
  DateTime? transactionDate;

  PersonalTransaction({
    this.transactionID,
    this.userID,
    this.amount,
    this.category,
    this.transactionDescription,
    this.currency,
    this.paymentMethod,
    this.transactionDate,
  });

  PersonalTransaction.fromJson(Map<String, dynamic> json) {
    transactionID = json["transaction_id"];
    userID = json["user_id"];
    amount = double.parse(json["amount"].toString());
    category = json["category"];
    transactionDescription = json["transaction_description"];
    currency = json["currency"];
    paymentMethod = json["payment_method"];
    transactionDate = DateTime.parse(json["transaction_date"]).toLocal();
  }

  Map<String, dynamic> toJson() {
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
