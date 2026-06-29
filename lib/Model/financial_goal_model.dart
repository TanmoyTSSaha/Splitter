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
    this.exchangeRateToInr = 1.0,
  });

  FinancialGoalModel.fromJSON(Map<String, dynamic> json)
      : exchangeRateToInr = double.tryParse(
                json["exchange_rate_to_inr"]?.toString() ?? "1.0") ??
            1.0 {
    id = json["id"];
    userId = json["user_id"];
    title = json["title"];
    targetAmount =
        double.tryParse(json["target_amount"]?.toString() ?? "0") ?? 0.0;
    currentAmount =
        double.tryParse(json["current_amount"]?.toString() ?? "0") ?? 0.0;
    deadline =
        json["deadline"] != null ? DateTime.tryParse(json["deadline"]) : null;
    status = json["status"];
    icon = json["icon"];
    createdAt = json["created_at"] != null
        ? DateTime.tryParse(json["created_at"])
        : null;
    colorHex = json["color_hex"];
    iconKey = json["icon_key"];
    smartRecommendationId = json["smart_recommendation_id"];
    estimatedCompletionDate = json["estimated_completion_date"] != null
        ? DateTime.tryParse(json["estimated_completion_date"])
        : null;
    description = json["description"];
    goalType = json["goal_type"];
    currency = json["currency"] ?? 'INR';
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["user_id"] = userId;
    data["title"] = title;
    data["target_amount"] = targetAmount;
    data["current_amount"] = currentAmount;
    data["deadline"] = deadline?.toIso8601String();
    data["status"] = status;
    data["icon"] = icon;
    data["color_hex"] = colorHex;
    data["icon_key"] = iconKey;
    data["smart_recommendation_id"] = smartRecommendationId;
    data["estimated_completion_date"] =
        estimatedCompletionDate?.toIso8601String();
    data["description"] = description;
    data["goal_type"] = goalType;
    data["currency"] = currency ?? 'INR';
    data["exchange_rate_to_inr"] = exchangeRateToInr;
    return data;
  }
}
