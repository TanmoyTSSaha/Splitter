import 'dart:convert';

import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Services/app_logger.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

import 'package:splitr/Constants/app_motion.dart';

import 'package:splitr/Constants/business_rules.dart';

import 'package:splitr/Constants/domain_values.dart';

/// Fetches and caches exchange rates from the Frankfurter API (free, no key).

/// Rates are cached for 24 hours to minimise API calls.

class CurrencyService {
  static const Map<String, String> supportedCurrencies = {
    CurrencyDefaults.code: CurrencyDisplayNames.inr,
    'USD': CurrencyDisplayNames.usd,
    'EUR': CurrencyDisplayNames.eur,
    'GBP': CurrencyDisplayNames.gbp,
    'JPY': CurrencyDisplayNames.jpy,
    'AUD': CurrencyDisplayNames.aud,
    'CAD': CurrencyDisplayNames.cad,
    'SGD': CurrencyDisplayNames.sgd,
    'AED': CurrencyDisplayNames.aed,
    'CHF': CurrencyDisplayNames.chf,
    'CNY': CurrencyDisplayNames.cny,
    'HKD': CurrencyDisplayNames.hkd,
    'SEK': CurrencyDisplayNames.sek,
    'NOK': CurrencyDisplayNames.nok,
    'NZD': CurrencyDisplayNames.nzd,
    'MXN': CurrencyDisplayNames.mxn,
    'BRL': CurrencyDisplayNames.brl,
    'ZAR': CurrencyDisplayNames.zar,
    'KRW': CurrencyDisplayNames.krw,
    'THB': CurrencyDisplayNames.thb,
    'MYR': CurrencyDisplayNames.myr,
    'IDR': CurrencyDisplayNames.idr,
    'PLN': CurrencyDisplayNames.pln,
    'TRY': CurrencyDisplayNames.try_,
    'SAR': CurrencyDisplayNames.sar,
  };

  static const Map<String, String> currencySymbols = {
    CurrencyDefaults.code: CurrencySymbols.inr,
    'USD': CurrencySymbols.usd,
    'EUR': CurrencySymbols.eur,
    'GBP': CurrencySymbols.gbp,
    'JPY': CurrencySymbols.jpy,
    'AUD': CurrencySymbols.aud,
    'CAD': CurrencySymbols.cad,
    'SGD': CurrencySymbols.sgd,
    'AED': CurrencySymbols.aed,
    'CHF': CurrencySymbols.chf,
    'CNY': CurrencySymbols.cny,
    'HKD': CurrencySymbols.hkd,
    'SEK': CurrencySymbols.sek,
    'NOK': CurrencySymbols.nok,
    'NZD': CurrencySymbols.nzd,
    'MXN': CurrencySymbols.mxn,
    'BRL': CurrencySymbols.brl,
    'ZAR': CurrencySymbols.zar,
    'KRW': CurrencySymbols.krw,
    'THB': CurrencySymbols.thb,
    'MYR': CurrencySymbols.myr,
    'IDR': CurrencySymbols.idr,
    'PLN': CurrencySymbols.pln,
    'TRY': CurrencySymbols.try_,
    'SAR': CurrencySymbols.sar,
  };

  static String symbolFor(String code) => currencySymbols[code] ?? code;

  /// Returns cached rates or fetches fresh ones from Frankfurter.

  /// Rates are Map<String, double> where key is currency code, value is rate

  /// relative to the [base] currency.

  Future<Map<String, double>> getRates(
      {String base = CurrencyDefaults.code}) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '${PrefKeys.fxRatesCache}_$base';
    final tsKey = '${PrefKeys.fxRatesTimestamp}_$base';
    final cached = prefs.getString(cacheKey);
    final ts = prefs.getInt(tsKey) ?? 0;
    final age = DateTime.now().millisecondsSinceEpoch - ts;
    final staleRates = _parseRatesCache(cached);

    if (staleRates != null && age < CacheTtls.fxRatesMs) {
      return staleRates;
    }

    try {
      final uri = Uri.https(
        FxApiConfig.host,
        FxApiPaths.latest,
        {FxApiPaths.fromParam: base},
      );

      final client = HttpClient();
      try {
        final req =
            await client.getUrl(uri).timeout(AppMotion.fxRequestTimeout);
        final res = await req.close();
        final body = await res.transform(utf8.decoder).join();

        if (res.statusCode != HttpStatus.ok) {
          throw HttpException(
            'FX API HTTP ${res.statusCode}',
            uri: uri,
          );
        }

        final json = jsonDecode(body) as Map<String, dynamic>;
        final rates = (json[FxApiPaths.ratesKey] as Map<String, dynamic>)
            .cast<String, double>();
        rates[base] = 1.0;

        await prefs.setString(cacheKey, jsonEncode(rates));
        await prefs.setInt(tsKey, DateTime.now().millisecondsSinceEpoch);

        return rates;
      } finally {
        client.close();
      }
    } catch (e, stack) {
      if (staleRates != null && staleRates.isNotEmpty) {
        AppLogger.warning(
          'CurrencyService.getRates: using stale cache after fetch failure',
          data: {
            'feature': 'currency',
            'operation': 'getRates',
            'base': base,
            'error': e.toString(),
          },
        );
        return staleRates;
      }

      AppErrorReporter.report(
        'CurrencyService.getRates failed',
        error: e,
        stack: stack,
        context: {'feature': 'currency', 'operation': 'getRates'},
      );

      return {base: 1.0};
    }
  }

  static Map<String, double>? _parseRatesCache(String? cached) {
    if (cached == null) return null;
    try {
      return (jsonDecode(cached) as Map<String, dynamic>).cast<String, double>();
    } catch (_) {
      return null;
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
    if (fromCurrency == CurrencyDefaults.code) {
      return CurrencyDefaults.exchangeRateToInr;
    }

    final rates = await getRates(base: fromCurrency);

    return rates[CurrencyDefaults.code] ?? CurrencyDefaults.exchangeRateToInr;
  }
}
