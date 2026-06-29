import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitter/Services/currency_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Global GetX controller that holds the user's selected currency.
/// Read this wherever you need to display monetary amounts.
///
/// Usage:
///   final cc = Get.find<CurrencyController>();
///   final symbol = cc.symbol;        // e.g. '₹'
///   final code   = cc.code;          // e.g. 'INR'
class CurrencyController extends GetxController {
  static const _prefKey = 'selected_currency';

  final supabase = Supabase.instance.client;

  final RxString _code = 'INR'.obs;

  String get code => _code.value;
  // Expose the raw Rx so callers can do: ever(cc.rxCode, (_) => ...)
  RxString get rxCode => _code;
  String get symbol => CurrencyService.symbolFor(_code.value);
  String get name =>
      CurrencyService.supportedCurrencies[_code.value] ?? _code.value;

  @override
  void onInit() {
    super.onInit();
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null &&
        CurrencyService.supportedCurrencies.containsKey(saved)) {
      _code.value = saved;
    } else {
      // Try to load from Supabase users table
      final uid = supabase.auth.currentUser?.id;
      if (uid != null) {
        try {
          final row = await supabase
              .from('users')
              .select('currency')
              .eq('user_id', uid)
              .single();
          final dbCurrency = row['currency'] as String? ?? 'INR';
          if (CurrencyService.supportedCurrencies.containsKey(dbCurrency)) {
            _code.value = dbCurrency;
            await prefs.setString(_prefKey, dbCurrency);
          }
        } catch (_) {}
      }
    }
  }

  /// Call this when user picks a new currency.
  Future<void> setCurrency(String newCode) async {
    if (!CurrencyService.supportedCurrencies.containsKey(newCode)) return;
    _code.value = newCode;

    // Persist locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, newCode);

    // Persist to Supabase
    final uid = supabase.auth.currentUser?.id;
    if (uid != null) {
      try {
        await supabase
            .from('users')
            .update({'currency': newCode}).eq('user_id', uid);
      } catch (_) {}
    }
  }
}
