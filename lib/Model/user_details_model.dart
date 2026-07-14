import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';

class UserDetails {
  String? userID;
  String? userName;
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
    this.userName,
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
    userID = json[SupabaseColumns.userId];
    userName = json[SupabaseColumns.userName];
    firstName = json[SupabaseColumns.firstname] ??
        json[SupabaseColumns.userName] ??
        DisplayFallbacks.user;
    lastName = json[SupabaseColumns.lastname] ?? StringDefaults.empty;
    email = json[SupabaseColumns.userEmail] ?? StringDefaults.empty;
    phone = json[SupabaseColumns.phone]?.toString() ?? StringDefaults.empty;
    defaultCurrency = json[SupabaseColumns.currency] ?? CurrencyDefaults.code;
    totalSpent = double.tryParse(json[SupabaseColumns.totalSpent]?.toString() ??
            AppAmountHints.zero) ??
        0.0;
    totalReceived = double.tryParse(
            json[SupabaseColumns.totalReceived]?.toString() ??
                AppAmountHints.zero) ??
        0.0;
    createdAt = json[SupabaseColumns.createdAt] != null
        ? DateTime.tryParse(json[SupabaseColumns.createdAt])
        : DateTime.now();
    profilePictureURL =
        json[SupabaseColumns.profilePictureUrl] ?? StringDefaults.empty;
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data[SupabaseColumns.userId] = userID;
    data[SupabaseColumns.userName] = userName;
    data[SupabaseColumns.firstname] = firstName;
    data[SupabaseColumns.lastname] = lastName;
    data[SupabaseColumns.email] = email;
    data[SupabaseColumns.phone] = phone;
    data[SupabaseColumns.currency] = defaultCurrency;
    data[SupabaseColumns.totalSpent] = totalSpent;
    data[SupabaseColumns.totalReceived] = totalReceived;
    data[SupabaseColumns.createdAt] = createdAt;
    data[SupabaseColumns.profilePictureUrl] = profilePictureURL;

    return data;
  }
}
