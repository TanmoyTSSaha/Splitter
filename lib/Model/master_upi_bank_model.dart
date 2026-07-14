import 'package:splitr/Constants/app_keys.dart';

class MasterUpiBank {
  final String bankSlug;
  final String bankName;
  final int sortOrder;
  final bool isActive;

  const MasterUpiBank({
    required this.bankSlug,
    required this.bankName,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory MasterUpiBank.fromJson(Map<String, dynamic> json) {
    return MasterUpiBank(
      bankSlug: json[SupabaseColumns.bankSlug] as String,
      bankName: json[SupabaseColumns.bankName] as String,
      sortOrder: json[SupabaseColumns.sortOrder] as int? ?? 0,
      isActive: json[SupabaseColumns.isActive] as bool? ?? true,
    );
  }
}
