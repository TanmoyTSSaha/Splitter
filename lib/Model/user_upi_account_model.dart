import 'package:splitr/Constants/app_keys.dart';

class UserUpiAccount {
  final String id;
  final String userId;
  final String vpa;
  final String bankAlias;
  final bool isPrimary;
  final DateTime? createdAt;

  const UserUpiAccount({
    required this.id,
    required this.userId,
    required this.vpa,
    required this.bankAlias,
    this.isPrimary = false,
    this.createdAt,
  });

  factory UserUpiAccount.fromJson(Map<String, dynamic> json) {
    return UserUpiAccount(
      id: json[SupabaseColumns.id] as String,
      userId: json[SupabaseColumns.userId] as String,
      vpa: json[SupabaseColumns.vpa] as String,
      bankAlias: json[SupabaseColumns.bankAlias] as String,
      isPrimary: json[SupabaseColumns.isPrimary] as bool? ?? false,
      createdAt: json[SupabaseColumns.createdAt] != null
          ? DateTime.tryParse(json[SupabaseColumns.createdAt] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        SupabaseColumns.id: id,
        SupabaseColumns.userId: userId,
        SupabaseColumns.vpa: vpa,
        SupabaseColumns.bankAlias: bankAlias,
        SupabaseColumns.isPrimary: isPrimary,
        if (createdAt != null)
          SupabaseColumns.createdAt: createdAt!.toIso8601String(),
      };

  UserUpiAccount copyWith({
    String? id,
    String? userId,
    String? vpa,
    String? bankAlias,
    bool? isPrimary,
    DateTime? createdAt,
  }) {
    return UserUpiAccount(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vpa: vpa ?? this.vpa,
      bankAlias: bankAlias ?? this.bankAlias,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
