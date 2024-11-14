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
    firstName = json["firstname"];
    lastName = json["lastname"];
    email = json["email"];
    phone = json["phone"].toString();
    defaultCurrency = json["currency"] ?? "INR";
    totalSpent = double.parse(json["total_spent"].toString());
    totalReceived = double.parse(json["total_received"].toString());
    createdAt = DateTime.parse(json["created_at"]);
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
