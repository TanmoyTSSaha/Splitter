class UserDetails {
  String? userID;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? defaultCurrency;
  double? totalSpent;
  double? totalReceived;
  DateTime? createdAt;
  String? profilePictureURL;

  UserDetails({
    this.userID,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.defaultCurrency,
    this.totalSpent,
    this.totalReceived,
    this.createdAt,
    this.profilePictureURL,
  });

  UserDetails.fromJSON(Map<String, dynamic> json) {
    userID = json["user_id"];
    firstName = json["firstname"] ??
        json["user_name"] ??
        "User"; // Fallback to user_name or "User"
    lastName = json["lastname"] ?? "";
    email = json["user_email"] ?? "";
    phone = json["phone"]?.toString() ?? "";
    defaultCurrency = json["currency"] ?? "INR";
    totalSpent = double.tryParse(json["total_spent"]?.toString() ?? "0") ?? 0.0;
    totalReceived =
        double.tryParse(json["total_received"]?.toString() ?? "0") ?? 0.0;
    createdAt = json["created_at"] != null
        ? DateTime.tryParse(json["created_at"])
        : DateTime.now();
    profilePictureURL = json["profile_picture_url"] ?? "";
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data["user_id"] = userID;
    data["firstname"] = firstName;
    data["lastname"] = lastName;
    data["email"] = email;
    data["phone"] = phone;
    data["currency"] = defaultCurrency;
    data["total_spent"] = totalSpent;
    data["total_received"] = totalReceived;
    data["created_at"] = createdAt;
    data["profile_picture_url"] = profilePictureURL;

    return data;
  }
}
