import 'package:get/get.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Services/currency_service.dart';

/// ISO currency code for the signed-in user's preference (falls back to INR).
String userCurrencyCode() {
  if (Get.isRegistered<CurrencyController>()) {
    return Get.find<CurrencyController>().code;
  }
  return CurrencyDefaults.code;
}

/// Display symbol for the user's selected currency.
String userCurrencySymbol() {
  return CurrencyService.symbolFor(userCurrencyCode());
}

/// Display symbol for a specific currency [code] (e.g. trip or loan currency).
String currencySymbolFor(String? code) {
  return CurrencyService.symbolFor(code ?? userCurrencyCode());
}

/// Formats [amount] with the user's currency symbol.
String formatUserCurrency(double amount, {int decimals = 0}) {
  return '${userCurrencySymbol()}${amount.toStringAsFixed(decimals)}';
}

/// Formats [amount] with the symbol for [code].
String formatCurrency(
  double amount, {
  String? code,
  int decimals = 0,
}) {
  return '${currencySymbolFor(code)}${amount.toStringAsFixed(decimals)}';
}

/// Prefix for amount text fields, e.g. `₹ ` or `$ `.
String currencyPrefixText() => '${userCurrencySymbol()} ';
