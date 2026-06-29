import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitter/Services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Product IDs — must match Play Console / App Store Connect.
class PremiumProducts {
  static const monthly = 'splito_pro_monthly';
  static const yearly = 'splito_pro_yearly';
  static const all = [monthly, yearly];
}

/// Manages SplitO Pro subscription state (IAP + local cache + Supabase sync).
class PremiumSubscriptionController extends GetxController {
  final InAppPurchase _iap = InAppPurchase.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  static const _prefActive = 'premium_active';
  static const _prefExpires = 'premium_expires_at';

  final RxBool isPremium = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool storeAvailable = false.obs;
  final RxList<ProductDetails> products = <ProductDetails>[].obs;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  @override
  void onClose() {
    _purchaseSub?.cancel();
    super.onClose();
  }

  Future<void> _init() async {
    await refreshStatus();
    storeAvailable.value = await _iap.isAvailable();
    if (!storeAvailable.value) return;

    _purchaseSub = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (e) => debugPrint('IAP stream error: $e'),
    );

    final response = await _iap.queryProductDetails(PremiumProducts.all.toSet());
    if (response.error != null) {
      debugPrint('IAP query error: ${response.error}');
    }
    products.assignAll(response.productDetails);
  }

  Future<void> refreshStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final localActive = prefs.getBool(_prefActive) ?? false;
    final expiresStr = prefs.getString(_prefExpires);
    DateTime? expires =
        expiresStr != null ? DateTime.tryParse(expiresStr) : null;

    if (expires != null && DateTime.now().isAfter(expires)) {
      await _setPremium(active: false);
      isPremium.value = false;
      return;
    }

    bool serverPremium = localActive;
    try {
      final userId = SupabaseAuth().supabaseGetUserID();
      if (userId.isNotEmpty) {
        final row = await _supabase
            .from('users')
            .select('is_premium, premium_expires_at')
            .eq('user_id', userId)
            .maybeSingle();
        if (row != null) {
          serverPremium = row['is_premium'] as bool? ?? false;
          final serverExpires = row['premium_expires_at'];
          if (serverExpires != null) {
            expires = DateTime.tryParse(serverExpires.toString());
            if (expires != null && DateTime.now().isAfter(expires)) {
              serverPremium = false;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Premium refresh from server: $e');
    }

    isPremium.value = serverPremium || localActive;
    if (expires != null && isPremium.value) {
      await prefs.setString(_prefExpires, expires.toIso8601String());
    }
  }

  Future<void> purchaseMonthly() => _purchase(PremiumProducts.monthly);

  Future<void> purchaseYearly() => _purchase(PremiumProducts.yearly);

  Future<void> _purchase(String productId) async {
    if (!storeAvailable.value) {
      throw 'Store not available on this device';
    }

    ProductDetails details;
    try {
      details = products.firstWhere((p) => p.id == productId);
    } catch (_) {
      final response =
          await _iap.queryProductDetails({productId});
      if (response.productDetails.isEmpty) {
        throw 'Product not found in store';
      }
      details = response.productDetails.first;
    }

    isLoading.value = true;
    try {
      final param = PurchaseParam(productDetails: details);
      await _iap.buyNonConsumable(purchaseParam: param);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> restorePurchases() async {
    if (!storeAvailable.value) {
      throw 'Store not available on this device';
    }
    isLoading.value = true;
    try {
      await _iap.restorePurchases();
    } finally {
      isLoading.value = false;
    }
  }

  /// Debug-only toggle for QA without store setup.
  Future<void> enableDevPremium({int days = 365}) async {
    if (!kDebugMode) return;
    final expires = DateTime.now().add(Duration(days: days));
    await _setPremium(active: true, expiresAt: expires);
    isPremium.value = true;
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) continue;

      if (purchase.status == PurchaseStatus.error) {
        debugPrint('Purchase error: ${purchase.error}');
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        final expires = _expiryForProduct(purchase.productID);
        await _setPremium(active: true, expiresAt: expires);
        isPremium.value = true;
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  DateTime _expiryForProduct(String productId) {
    final now = DateTime.now();
    if (productId == PremiumProducts.yearly) {
      return now.add(const Duration(days: 365));
    }
    return now.add(const Duration(days: 30));
  }

  Future<void> _setPremium({
    required bool active,
    DateTime? expiresAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefActive, active);
    if (expiresAt != null) {
      await prefs.setString(_prefExpires, expiresAt.toIso8601String());
    } else if (!active) {
      await prefs.remove(_prefExpires);
    }

    try {
      final userId = SupabaseAuth().supabaseGetUserID();
      if (userId.isNotEmpty) {
        await _supabase.from('users').update({
          'is_premium': active,
          'premium_expires_at': expiresAt?.toIso8601String(),
        }).eq('user_id', userId);
      }
    } catch (e) {
      debugPrint('Premium sync to Supabase: $e');
    }
  }

  ProductDetails? productFor(bool yearly) {
    final id =
        yearly ? PremiumProducts.yearly : PremiumProducts.monthly;
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
