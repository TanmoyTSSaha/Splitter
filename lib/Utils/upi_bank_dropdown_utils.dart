import 'package:splitr/Constants/upi_banks.dart';
import 'package:splitr/Model/master_upi_bank_model.dart';

/// Client-only dropdown sentinel for custom bank name entry.
abstract final class UpiBankDropdownSentinel {
  static const other = '__other__';
  static const legacy = '__legacy__';
}

/// Resolves initial dropdown slug from saved [bankAlias] and master list.
String resolveUpiBankDropdownSlug({
  required String? bankAlias,
  required List<MasterUpiBank> banks,
}) {
  if (bankAlias == null || bankAlias.trim().isEmpty) {
    return banks.isNotEmpty ? banks.first.bankSlug : UpiBankDropdownSentinel.other;
  }

  for (final bank in banks) {
    if (bank.bankName == bankAlias) return bank.bankSlug;
  }

  return UpiBankDropdownSentinel.other;
}

/// Dedupes master banks by slug (first wins).
List<MasterUpiBank> dedupeMasterUpiBanks(List<MasterUpiBank> banks) {
  final seen = <String>{};
  final result = <MasterUpiBank>[];
  for (final bank in banks) {
    if (seen.add(bank.bankSlug)) {
      result.add(bank);
    }
  }
  return result;
}

/// Maps selected slug to persisted bank_alias text.
String bankAliasForSlug({
  required String selectedSlug,
  required List<MasterUpiBank> banks,
  required String customBankName,
}) {
  if (selectedSlug == UpiBankDropdownSentinel.other ||
      selectedSlug == UpiBankDropdownSentinel.legacy) {
    return customBankName.trim();
  }

  for (final bank in banks) {
    if (bank.bankSlug == selectedSlug) return bank.bankName;
  }

  return customBankName.trim();
}

bool isOtherBankSlug(String slug) =>
    slug == UpiBankDropdownSentinel.other ||
    slug == UpiBankDropdownSentinel.legacy;

/// Whether [bankAlias] is a known master bank name.
bool isKnownMasterBankAlias(String bankAlias, List<MasterUpiBank> banks) {
  return banks.any((b) => b.bankName == bankAlias);
}

/// Label for Other menu item (uses existing copy constant).
String get upiBankOtherLabel => UpiBanks.other;
