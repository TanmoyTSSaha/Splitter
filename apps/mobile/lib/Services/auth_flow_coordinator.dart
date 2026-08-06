import 'package:get/get.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Controllers/premium_subscription_controller.dart';
import 'package:splitr/Screen/BottomNavigationController/bottom_navigation_controller.dart';
import 'package:splitr/Services/deep_link_service.dart';
import 'package:splitr/Services/local/database.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Shared post-auth navigation used by login, register, and OAuth deep links.
abstract final class AuthFlowCoordinator {
  /// Returns false when no valid session exists (caller should stay on auth UI).
  static Future<bool> completeSignIn({
    String loginMethod = LoginMethods.google,
    bool clearLocalCache = true,
  }) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null || session.isExpired) {
      return false;
    }

    if (clearLocalCache && Get.isRegistered<AppDatabase>()) {
      await Get.find<AppDatabase>().clearAllUserData();
    }

    await SupabaseAuth().recordLastUsedLoginMethod(loginMethod);

    if (Get.isRegistered<PremiumSubscriptionController>()) {
      await Get.find<PremiumSubscriptionController>().refreshStatus();
    }

    if (Get.isRegistered<DeepLinkService>()) {
      await Get.find<DeepLinkService>().processPendingInvite();
    }

    Get.offAll(() => const BottomNavigationController());
    return true;
  }
}
