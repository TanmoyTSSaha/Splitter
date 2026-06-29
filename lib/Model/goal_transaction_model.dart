class GoalTransactionModel {
  String? id;
  String? goalId;
  double? amount;
  String? type; // 'deposit', 'withdraw'
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
    this.exchangeRateToInr = 1.0,
    this.transactionDate,
    this.createdAt,
  });

  GoalTransactionModel.fromJSON(Map<String, dynamic> json)
      : exchangeRateToInr = double.tryParse(
                json["exchange_rate_to_inr"]?.toString() ?? "1.0") ??
            1.0 {
    id = json["id"];
    goalId = json["goal_id"];
    amount = double.tryParse(json["amount"]?.toString() ?? "0") ?? 0.0;
    type = json["type"];
    note = json["note"];
    currency = json["currency"] ?? 'INR';
    transactionDate = json["transaction_date"] != null
        ? DateTime.tryParse(json["transaction_date"])
        : null;
    createdAt = json["created_at"] != null
        ? DateTime.tryParse(json["created_at"])
        : null;
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["goal_id"] = goalId;
    data["amount"] = amount;
    data["type"] = type;
    data["note"] = note;
    data["currency"] = currency ?? 'INR';
    data["exchange_rate_to_inr"] = exchangeRateToInr;
    data["transaction_date"] = transactionDate?.toIso8601String();
    return data;
  }
}
