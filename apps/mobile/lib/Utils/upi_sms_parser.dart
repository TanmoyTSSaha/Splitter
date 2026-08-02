import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/business_rules.dart';

/// Parses common India UPI/bank debit SMS into expense draft fields.
class UpiSmsDraft {
  final double amount;
  final String? merchant;
  final DateTime? date;

  const UpiSmsDraft({
    required this.amount,
    this.merchant,
    this.date,
  });
}

class UpiSmsParser {
  UpiSmsParser._();

  static final _amountRe = RegExp(
    UpiSmsPatterns.amount,
    caseSensitive: false,
  );

  static final _merchantRe = RegExp(
    UpiSmsPatterns.merchant,
    caseSensitive: false,
  );

  static UpiSmsDraft? parse(String raw) {
    final text = raw.trim();
    if (text.length < UpiSmsRules.minTextLength) return null;

    final amountMatch = _amountRe.firstMatch(text);
    if (amountMatch == null) return null;

    final amount = double.tryParse(
      amountMatch.group(1)!.replaceAll(AppSeparators.thousandsComma, ''),
    );
    if (amount == null || amount <= 0) return null;

    String? merchant;
    final merchantMatch = _merchantRe.firstMatch(text);
    if (merchantMatch != null) {
      merchant = merchantMatch.group(1)?.trim();
      if (merchant != null && merchant.length < UpiSmsRules.minMerchantLength) {
        merchant = null;
      }
    }

    return UpiSmsDraft(
        amount: amount, merchant: merchant, date: DateTime.now());
  }
}
