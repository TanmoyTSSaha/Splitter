import 'dart:ui';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splitr/Constants/system_ui.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_themes.dart';
import 'package:splitr/Bindings/app_bindings.dart';
import 'package:splitr/Screen/AuthScreens/login_screen.dart';
import 'package:splitr/Screen/SplashScreen/splitr_splash_screen.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Services/biometric_auth_service.dart';
import 'package:splitr/Services/local/database.dart';
import 'package:splitr/Services/realtime_service.dart';
import 'package:splitr/Services/reminder_service.dart';
import 'package:splitr/Services/reminder_settings_service.dart';
import 'package:splitr/Controllers/premium_subscription_controller.dart';
import 'package:splitr/Services/deep_link_service.dart';
import 'package:splitr/Services/razorpay_payment_service.dart';
import 'package:splitr/Services/sync_service.dart';
import 'package:splitr/Controllers/theme_controller.dart';
import 'package:splitr/Services/share_intent_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/Widgets/achievement_celebration_overlay.dart';
import 'package:splitr/Widgets/splitr_error_scope.dart';
import 'package:splitr/config/app_secrets.dart';
import 'package:splitr/config/sentry_options.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Global service instances — registered via GetX for DI.
late final AppDatabase appDatabase;
late final SyncService syncService;
late final RealtimeService realtimeService;
late final ReminderService reminderService;
late final DeepLinkService deepLinkService;
late final ShareIntentService shareIntentService;

class _BootstrapResult {
  const _BootstrapResult({
    required this.hasSeenOnboarding,
    required this.biometricEnabled,
  });

  final bool hasSeenOnboarding;
  final bool biometricEnabled;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: EnvFiles.dotenv, isOptional: true);

  if (AppSecrets.sentryEnabled) {
    await SentryFlutter.init(configureSentryOptions);
  }
  _installGlobalErrorHandlers();

  final bootstrap = await _bootstrapServices();

  final app = MyApp(
    hasSeenOnboarding: bootstrap.hasSeenOnboarding,
    biometricEnabled: bootstrap.biometricEnabled,
  );
  runApp(AppSecrets.sentryEnabled ? SentryWidget(child: app) : app);
}

void _installGlobalErrorHandlers() {
  final previousFlutterOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    AppErrorReporter.unexpected(
      'Flutter framework error',
      error: details.exception,
      stack: details.stack,
      context: {'library': details.library ?? '', 'context': details.context?.toString() ?? ''},
    );
    previousFlutterOnError?.call(details);
  };

  final previousPlatformOnError = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (error, stack) {
    AppErrorReporter.unexpected(
      'Uncaught async error',
      error: error,
      stack: stack,
    );
    return previousPlatformOnError?.call(error, stack) ?? false;
  };
}

Future<_BootstrapResult> _bootstrapServices() async {
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

  syncService = SyncService(appDatabase);
  syncService.startListening();

  realtimeService = RealtimeService();

  reminderService = ReminderService();
  await reminderService.initialize();

  Get.put(appDatabase, permanent: true);
  Get.put(syncService, permanent: true);
  Get.put(realtimeService, permanent: true);
  Get.put(reminderService, permanent: true);
  Get.put(ReminderSettingsService(), permanent: true);
  Get.put(CurrencyController(), permanent: true);
  Get.put(RazorpayPaymentService(), permanent: true);
  Get.put(PremiumSubscriptionController(), permanent: true);
  Get.put(ThemeController(), permanent: true);

  deepLinkService = DeepLinkService();
  Get.put(deepLinkService, permanent: true);
  await deepLinkService.initialize();

  shareIntentService = ShareIntentService();
  await shareIntentService.initialize();

  _listenAuthStateChanges();
  _syncSentryUser(Supabase.instance.client.auth.currentUser);

  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool(PrefKeys.hasSeenOnboarding) ?? false;
  final biometricEnabled = await BiometricAuthService().isEnabled();

  return _BootstrapResult(
    hasSeenOnboarding: hasSeenOnboarding,
    biometricEnabled: biometricEnabled,
  );
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  final bool biometricEnabled;
  const MyApp({
    super.key,
    required this.hasSeenOnboarding,
    this.biometricEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return Obx(
      () => GetMaterialApp(
        title: AppBranding.brandName,
        debugShowCheckedModeBanner: false,
        initialBinding: AppBindings(),
        navigatorObservers: AppSecrets.sentryEnabled
            ? [SentryNavigatorObserver()]
            : const [],
        theme: AppThemes.light,
        darkTheme: AppThemes.dark,
        themeMode: themeController.themeMode.value,
        builder: (context, child) => AchievementCelebrationHost(
          child: SplitrErrorScope(
            screenTag: Get.currentRoute,
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: kSplitrSystemUiOverlay,
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ),
        home: SplitrSplashScreen(
          hasSeenOnboarding: hasSeenOnboarding,
          biometricEnabled: biometricEnabled,
        ),
      ),
    );
  }
}

void _listenAuthStateChanges() {
  Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
    switch (data.event) {
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.tokenRefreshed:
        _syncSentryUser(data.session?.user);
      case AuthChangeEvent.signedOut:
      case AuthChangeEvent.userDeleted:
        _syncSentryUser(null);
        await _onAuthSessionEnded();
      default:
        break;
    }
  });
}

void _syncSentryUser(User? user) {
  if (!AppSecrets.sentryEnabled || !Sentry.isEnabled) return;
  Sentry.configureScope((scope) {
    scope.setUser(user == null ? null : SentryUser(id: user.id));
  });
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
