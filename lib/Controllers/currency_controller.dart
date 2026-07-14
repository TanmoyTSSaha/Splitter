import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Services/currency_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Global GetX controller that holds the user's selected currency.
/// Read this wherever you need to display monetary amounts.
///
/// Usage:
///   final cc = Get.find<CurrencyController>();
///   final symbol = cc.symbol;        // e.g. '₹'
///   final code   = cc.code;          // e.g. 'INR'
class CurrencyController extends GetxController {
  final bool _forTest;

  CurrencyController({@visibleForTesting bool forTest = false})
      : _forTest = forTest;

  SupabaseClient get supabase => Supabase.instance.client;

  final RxString _code = CurrencyDefaults.code.obs;

  String get code => _code.value;
  // Expose the raw Rx so callers can do: ever(cc.rxCode, (_) => ...)
  RxString get rxCode => _code;
  String get symbol => CurrencyService.symbolFor(_code.value);
  String get name =>
      CurrencyService.supportedCurrencies[_code.value] ?? _code.value;

  @override
  void onInit() {
    super.onInit();
    if (_forTest) return;
    _loadFromPrefs();
  }

  @visibleForTesting
  void seedCodeForTest(String code) {
    if (CurrencyService.supportedCurrencies.containsKey(code)) {
      _code.value = code;
    }
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(PrefKeys.selectedCurrency);
    if (saved != null &&
        CurrencyService.supportedCurrencies.containsKey(saved)) {
      _code.value = saved;
    } else {
      // Try to load from Supabase users table
      final uid = supabase.auth.currentUser?.id;
      if (uid != null) {
        try {
          final row = await supabase
              .from(SupabaseTables.users)
              .select(SupabaseColumns.currency)
              .eq(SupabaseColumns.userId, uid)
              .single();
          final dbCurrency =
              row[SupabaseColumns.currency] as String? ?? CurrencyDefaults.code;
          if (CurrencyService.supportedCurrencies.containsKey(dbCurrency)) {
            _code.value = dbCurrency;
            await prefs.setString(PrefKeys.selectedCurrency, dbCurrency);
          }
        } catch (e, stack) {
          AppErrorReporter.report(
            'CurrencyController._loadFromPrefs failed',
            error: e,
            stack: stack,
            context: {'feature': 'currency', 'operation': 'loadFromPrefs'},
            showToastOnUserFacing: false,
          );
        }
      }
    }
  }

  /// Call this when user picks a new currency.
  Future<void> setCurrency(String newCode) async {
    if (!CurrencyService.supportedCurrencies.containsKey(newCode)) return;
    _code.value = newCode;

    // Persist locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefKeys.selectedCurrency, newCode);

    // Persist to Supabase
    final uid = supabase.auth.currentUser?.id;
    if (uid != null) {
      try {
        await supabase
            .from(SupabaseTables.users)
            .update({SupabaseColumns.currency: newCode}).eq(
                SupabaseColumns.userId, uid);
      } catch (e, stack) {
        AppErrorReporter.report(
          'CurrencyController.setCurrency failed',
          error: e,
          stack: stack,
          context: {'feature': 'currency', 'operation': 'setCurrency'},
          showToastOnUserFacing: false,
        );
      }
    }
  }
}
