import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/system_ui.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Controllers/premium_subscription_controller.dart';
import 'package:splitr/Controllers/theme_controller.dart';
import 'package:splitr/Screen/AuthScreens/login_screen.dart';
import 'package:splitr/Services/auth_recovery_coordinator.dart';
import 'package:splitr/Services/biometric_auth_service.dart';
import 'package:splitr/Services/deep_link_service.dart';
import 'package:splitr/Services/local/database.dart';
import 'package:splitr/Services/push_notification_service.dart';
import 'package:splitr/Services/razorpay_payment_service.dart';
import 'package:splitr/Services/realtime_service.dart';
import 'package:splitr/Services/reminder_service.dart';
import 'package:splitr/Services/reminder_settings_service.dart';
import 'package:splitr/Services/share_intent_service.dart';
import 'package:splitr/Services/sync_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/config/app_secrets.dart';
import 'package:splitr/Services/app_services.dart';
import 'package:splitr/config/sentry_cold_start.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Session flags read after deferred bootstrap (onboarding + biometric).
class BootstrapSessionResult {
  const BootstrapSessionResult({
    required this.hasSeenOnboarding,
    required this.biometricEnabled,
  });

  final bool hasSeenOnboarding;
  final bool biometricEnabled;
}

/// Critical-path bootstrap: Supabase + Drift only (PERF-01 / D-01).
Future<void> bootstrapCritical() async {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(kSplitrSystemUiOverlay);

  if (!AppSecrets.isConfigured) {
    throw StateError(AppStrings.errors.missingSupabaseStartup);
  }
  await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );

  appDatabase = AppDatabase();
  Get.put(appDatabase, permanent: true);

  syncService = SyncService(appDatabase);
  Get.put(syncService, permanent: true);

  realtimeService = RealtimeService();
  Get.put(realtimeService, permanent: true);

  final prefs = await SharedPreferences.getInstance();
  final themeController = ThemeController();
  themeController.themeMode.value =
      ThemeController.modeFromStoredValue(prefs.getString(PrefKeys.themeMode));
  Get.put(themeController, permanent: true);
}

/// Deferred bootstrap during splash window (PERF-01 / D-02).
Future<BootstrapSessionResult> bootstrapDeferred() async {
  final deferredSpan = SentryColdStart.startDeferredSpan();

  syncService.startListening();

  reminderService = ReminderService();
  await reminderService.initialize();

  pushNotificationService =
      PushNotificationService(reminderService: reminderService);
  await pushNotificationService.initialize();

  Get.put(reminderService, permanent: true);
  Get.put(pushNotificationService, permanent: true);
  Get.put(ReminderSettingsService(), permanent: true);
  Get.put(CurrencyController(), permanent: true);
  Get.put(RazorpayPaymentService(), permanent: true);
  Get.put(PremiumSubscriptionController(), permanent: true);

  deepLinkService = DeepLinkService();
  Get.put(deepLinkService, permanent: true);
  await deepLinkService.initialize();

  shareIntentService = ShareIntentService();
  await shareIntentService.initialize();

  _listenAuthStateChanges();
  _syncSentryUser(Supabase.instance.client.auth.currentUser);

  final signedInUserId = Supabase.instance.client.auth.currentUser?.id;
  if (signedInUserId != null) {
    await pushNotificationService.registerForUser(signedInUserId);
  }

  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool(PrefKeys.hasSeenOnboarding) ?? false;
  final biometricEnabled = await BiometricAuthService().isEnabled();

  deferredSpan?.finish();

  return BootstrapSessionResult(
    hasSeenOnboarding: hasSeenOnboarding,
    biometricEnabled: biometricEnabled,
  );
}

void _listenAuthStateChanges() {
  Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
    switch (data.event) {
      case AuthChangeEvent.passwordRecovery:
        AuthRecoveryCoordinator.routeToResetPassword();
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.tokenRefreshed:
        _syncSentryUser(data.session?.user);
        if (data.event == AuthChangeEvent.signedIn) {
          final userId = data.session?.user.id;
          if (userId != null) {
            await pushNotificationService.registerForUser(userId);
          }
        }
      case AuthChangeEvent.signedOut:
      case AuthChangeEvent.userDeleted:
        AuthRecoveryCoordinator.reset();
        _syncSentryUser(null);
        await pushNotificationService.unregisterCurrentUser();
        await _onAuthSessionEnded();
      default:
        break;
    }
  });
}

void _syncSentryUser(User? user) {
  if (!AppSecrets.sentryEnabled) return;
  SentryColdStart.syncUser(user);
}

Future<void> _onAuthSessionEnded() async {
  try {
    realtimeService.unsubscribeAll();
    await appDatabase.clearAllUserData();
    if (Get.isDialogOpen == true) {
      Get.back();
    }
    Get.offAll(() => const LoginScreen());
  } catch (error, stack) {
    AppErrorReporter.unexpected(
      'Auth session cleanup failed',
      error: error,
      stack: stack,
    );
    rethrow;
  }
}
