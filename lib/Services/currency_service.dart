import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fetches and caches exchange rates from the Frankfurter API (free, no key).
/// Rates are cached for 24 hours to minimise API calls.
class CurrencyService {
  static const _cacheKey = 'fx_rates_cache';
  static const _cacheTsKey = 'fx_rates_timestamp';
  static const _baseUrl = 'api.frankfurter.app';

  // All supported Frankfurter currencies with display names
  static const Map<String, String> supportedCurrencies = {
    'INR': 'Indian Rupee',
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'JPY': 'Japanese Yen',
    'AUD': 'Australian Dollar',
    'CAD': 'Canadian Dollar',
    'SGD': 'Singapore Dollar',
    'AED': 'UAE Dirham',
    'CHF': 'Swiss Franc',
    'CNY': 'Chinese Yuan',
    'HKD': 'Hong Kong Dollar',
    'SEK': 'Swedish Krona',
    'NOK': 'Norwegian Krone',
    'NZD': 'New Zealand Dollar',
    'MXN': 'Mexican Peso',
    'BRL': 'Brazilian Real',
    'ZAR': 'South African Rand',
    'KRW': 'South Korean Won',
    'THB': 'Thai Baht',
    'MYR': 'Malaysian Ringgit',
    'IDR': 'Indonesian Rupiah',
    'PLN': 'Polish Złoty',
    'TRY': 'Turkish Lira',
    'SAR': 'Saudi Riyal',
  };

  static const Map<String, String> currencySymbols = {
    'INR': '₹',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'AUD': 'A\$',
    'CAD': 'C\$',
    'SGD': 'S\$',
    'AED': 'د.إ',
    'CHF': 'Fr',
    'CNY': '¥',
    'HKD': 'HK\$',
    'SEK': 'kr',
    'NOK': 'kr',
    'NZD': 'NZ\$',
    'MXN': 'Mex\$',
    'BRL': 'R\$',
    'ZAR': 'R',
    'KRW': '₩',
    'THB': '฿',
    'MYR': 'RM',
    'IDR': 'Rp',
    'PLN': 'zł',
    'TRY': '₺',
    'SAR': '﷼',
  };

  static String symbolFor(String code) => currencySymbols[code] ?? code;

  /// Returns cached rates or fetches fresh ones from Frankfurter.
  /// Rates are Map<String, double> where key is currency code, value is rate
  /// relative to the [base] currency.
  Future<Map<String, double>> getRates({String base = 'INR'}) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('${_cacheKey}_$base');
    final ts = prefs.getInt('${_cacheTsKey}_$base') ?? 0;
    final age = DateTime.now().millisecondsSinceEpoch - ts;

    // Return cache if <24h
    if (cached != null && age < 86400000) {
      final map = jsonDecode(cached) as Map<String, dynamic>;
      return map.cast<String, double>();
    }

    try {
      final uri = Uri.https(_baseUrl, '/latest', {'from': base});
      final client = HttpClient();
      final req = await client.getUrl(uri).timeout(const Duration(seconds: 8));
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      client.close();

      final json = jsonDecode(body) as Map<String, dynamic>;
      final rates =
          (json['rates'] as Map<String, dynamic>).cast<String, double>();
      rates[base] = 1.0; // Include base itself

      // Cache
      await prefs.setString('${_cacheKey}_$base', jsonEncode(rates));
      await prefs.setInt(
          '${_cacheTsKey}_$base', DateTime.now().millisecondsSinceEpoch);
      return rates;
    } catch (e) {
      debugPrint('CurrencyService.getRates error: $e');
      // Return a minimal fallback (base = 1.0)
      return {base: 1.0};
    }
  }

  /// Converts [amount] from [from] currency to [to] currency using [rates]
  /// where [rates] is fetched relative to [from].
  double convert({
    required double amount,
    required String from,
    required String to,
    required Map<String, double> rates,
  }) {
    if (from == to) return amount;
    final rate = rates[to] ?? 1.0;
    return amount * rate;
  }

  /// Returns the exchange rate from [fromCurrency] to INR at the current
  /// moment. Uses the 24-hour cached Frankfurter data — no extra network
  /// round-trip when the cache is warm.
  ///
  /// This is called **at save time** so the rate is frozen into the DB row
  /// and historical amounts are never affected by future rate changes.
  Future<double> getExchangeRateToInr(String fromCurrency) async {
    if (fromCurrency == 'INR') return 1.0;
    final rates = await getRates(base: fromCurrency);
    return rates['INR'] ?? 1.0;
  }
}
