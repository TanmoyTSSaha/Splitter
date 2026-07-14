import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Services/razorpay_payment_service.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum PremiumSubscriptionStatus { none, pending, active, cancelled }

/// Manages Splitr Pro via Razorpay Subscriptions + server-authoritative Supabase state.
class PremiumSubscriptionController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  RazorpayPaymentService? get _razorpay =>
      Get.isRegistered<RazorpayPaymentService>()
          ? Get.find<RazorpayPaymentService>()
          : null;

  static const _prefActive = PrefKeys.premiumActive;
  static const _prefExpires = PrefKeys.premiumExpiresAt;

  final RxBool isPremium = false.obs;
  final RxBool isLoading = false.obs;
  final Rx<PremiumSubscriptionStatus> subscriptionStatus =
      PremiumSubscriptionStatus.none.obs;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    await refreshStatus();
  }

  Future<void> refreshStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool serverPremium = false;
    DateTime? expires;
    PremiumSubscriptionStatus status = PremiumSubscriptionStatus.none;

    try {
      final userId = SupabaseAuth().supabaseGetUserID();
      if (userId.isNotEmpty) {
        final userRow = await _supabase
            .from(SupabaseTables.users)
            .select(
                '${SupabaseColumns.isPremium}, ${SupabaseColumns.premiumExpiresAt}')
            .eq(SupabaseColumns.userId, userId)
            .maybeSingle();

        if (userRow != null) {
          serverPremium = userRow[SupabaseColumns.isPremium] as bool? ?? false;
          final serverExpires = userRow[SupabaseColumns.premiumExpiresAt];
          if (serverExpires != null) {
            expires = DateTime.tryParse(serverExpires.toString());
            if (expires != null && DateTime.now().isAfter(expires)) {
              serverPremium = false;
            }
          }
        }

        final subRow = await _supabase
            .from(SupabaseTables.premiumSubscriptions)
            .select('status')
            .eq(SupabaseColumns.userId, userId)
            .maybeSingle();

        if (subRow != null) {
          status = _mapSubscriptionStatus(subRow['status'] as String?);
        }
      }
    } catch (e, stack) {
      AppErrorReporter.report(
        'PremiumSubscriptionController.refreshStatus failed',
        error: e,
        stack: stack,
        context: {'feature': 'premium', 'operation': 'refreshStatus'},
        showToastOnUserFacing: false,
      );
      if (kDebugMode) {
        final localActive = prefs.getBool(_prefActive) ?? false;
        final expiresStr = prefs.getString(_prefExpires);
        final localExpires =
            expiresStr != null ? DateTime.tryParse(expiresStr) : null;
        if (localExpires != null && DateTime.now().isAfter(localExpires)) {
          await _setLocalPremium(active: false);
          isPremium.value = false;
          subscriptionStatus.value = PremiumSubscriptionStatus.none;
          return;
        }
        isPremium.value = localActive;
        subscriptionStatus.value = localActive
            ? PremiumSubscriptionStatus.active
            : PremiumSubscriptionStatus.none;
        return;
      }
    }

    subscriptionStatus.value = status;
    isPremium.value = serverPremium;

    await _setLocalPremium(
      active: serverPremium,
      expiresAt: expires,
    );
  }

  Future<void> purchaseMonthly() => _purchaseSubscription('monthly');

  Future<void> purchaseYearly() => _purchaseSubscription('yearly');

  Future<void> cancelSubscription() async {
    isLoading.value = true;
    try {
      await _supabase.functions.invoke('cancel-subscription');
      await refreshStatus();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _purchaseSubscription(String plan) async {
    if (!RazorpayPaymentService.isConfigured) {
      throw AppStrings.premium.razorpayNotConfigured;
    }

    final razorpay = _razorpay;
    if (razorpay == null) {
      throw AppStrings.premium.razorpayNotConfigured;
    }

    isLoading.value = true;
    subscriptionStatus.value = PremiumSubscriptionStatus.pending;

    try {
      final createResponse = await _supabase.functions.invoke(
        'create-subscription',
        body: {'plan': plan},
      );

      if (createResponse.status != 200) {
        final serverError = _extractFunctionError(createResponse.data);
        AppErrorReporter.unexpected(
          'PremiumSubscriptionController.createSubscription failed',
          error: serverError ?? createResponse.data,
          context: {'feature': 'premium', 'operation': 'createSubscription'},
        );
        throw AppStrings.premium.subscriptionCreateFailed;
      }

      final data = createResponse.data as Map<String, dynamic>;
      final subscriptionId = data['subscription_id'] as String?;
      final keyId = data['key_id'] as String?;

      if (subscriptionId == null || subscriptionId.isEmpty) {
        throw AppStrings.premium.subscriptionCreateFailed;
      }

      final profile = await _loadProfileContact();
      final completer = Completer<void>();

      await razorpay.openSubscriptionCheckout(
        subscriptionId: subscriptionId,
        keyId: keyId,
        payerContact: profile.contact,
        payerEmail: profile.email,
        onSuccess: (PaymentSuccessResponse response) async {
          try {
            final paymentId = response.paymentId;
            final signature = response.signature;
            if (paymentId != null &&
                paymentId.isNotEmpty &&
                signature != null &&
                signature.isNotEmpty) {
              await _supabase.functions.invoke(
                'verify-subscription-auth',
                body: {
                  'subscription_id': subscriptionId,
                  'payment_id': paymentId,
                  'signature': signature,
                },
              );
            }
            await _pollPremiumActivation();
            if (!completer.isCompleted) completer.complete();
          } catch (e, stack) {
            AppErrorReporter.report(
              'PremiumSubscriptionController.purchaseSubscription verify failed',
              error: e,
              stack: stack,
              context: {'feature': 'premium', 'operation': 'purchaseSubscription.verify'},
            );
            if (!completer.isCompleted) {
              completer.completeError(e);
            }
          }
        },
        onError: (message) {
          AppErrorReporter.unexpected(
            'PremiumSubscriptionController Razorpay checkout failed',
            error: message,
            context: {'feature': 'premium', 'operation': 'razorpayCheckout'},
          );
          if (!completer.isCompleted) {
            completer.completeError(AppStrings.errors.paymentHumorous);
          }
        },
      );

      await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () => throw AppStrings.premium.subscriptionCheckoutTimeout,
      );
    } finally {
      isLoading.value = false;
      await refreshStatus();
    }
  }

  Future<void> _pollPremiumActivation() async {
    const attempts = 10;
    for (var i = 0; i < attempts; i++) {
      await refreshStatus();
      if (isPremium.value) return;
      await Future<void>.delayed(const Duration(seconds: 3));
    }
  }

  Future<({String email, String contact})> _loadProfileContact() async {
    try {
      final userId = SupabaseAuth().supabaseGetUserID();
      if (userId.isEmpty) {
        return (email: '', contact: '');
      }
      final row = await _supabase
          .from(SupabaseTables.users)
          .select('user_email, phone')
          .eq(SupabaseColumns.userId, userId)
          .maybeSingle();
      return (
        email: row?[SupabaseColumns.userEmail] as String? ?? '',
        contact: row?['phone'] as String? ?? '',
      );
    } catch (e, stack) {
      AppErrorReporter.report(
        'PremiumSubscriptionController._loadProfileContact failed',
        error: e,
        stack: stack,
        context: {'feature': 'premium', 'operation': 'loadProfileContact'},
        showToastOnUserFacing: false,
      );
      return (email: '', contact: '');
    }
  }

  String? _extractFunctionError(dynamic data) {
    if (data is Map && data['error'] != null) {
      return data['error'].toString();
    }
    return null;
  }

  PremiumSubscriptionStatus _mapSubscriptionStatus(String? status) {
    switch (status) {
      case 'active':
      case 'authenticated':
        return PremiumSubscriptionStatus.active;
      case 'cancelled':
        return PremiumSubscriptionStatus.cancelled;
      case 'created':
      case 'pending':
        return PremiumSubscriptionStatus.pending;
      default:
        return PremiumSubscriptionStatus.none;
    }
  }

  /// Debug-only toggle for QA without Razorpay setup.
  Future<void> enableDevPremium(
      {int days = PremiumDurations.yearlyDays}) async {
    if (!kDebugMode) return;
    final expires = DateTime.now().add(Duration(days: days));
    await _setLocalPremium(active: true, expiresAt: expires);
    isPremium.value = true;
    subscriptionStatus.value = PremiumSubscriptionStatus.active;
  }

  Future<void> _setLocalPremium({
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
  }

  String priceLabelFor(bool yearly) => yearly
      ? AppStrings.premium.yearlyPriceFallback
      : AppStrings.premium.monthlyPriceFallback;

  String billingLabelFor(bool yearly) => yearly
      ? AppStrings.premium.billedAnnuallyFallback
      : AppStrings.premium.billedMonthlyFallback;
}
