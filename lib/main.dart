import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitter/Constants/app_themes.dart';
import 'package:splitter/Bindings/app_bindings.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Screen/AuthScreens/biometric_lock_screen.dart';
import 'package:splitter/Screen/AuthScreens/login_screen.dart';
import 'package:splitter/Screen/BottomNavigationController/bottom_navigation_controller.dart';
import 'package:splitter/Screen/OnboardingScreen/onboarding_screen.dart';
import 'package:splitter/Controllers/currency_controller.dart';
import 'package:splitter/Services/biometric_auth_service.dart';
import 'package:splitter/Services/local/database.dart';
import 'package:splitter/Services/realtime_service.dart';
import 'package:splitter/Services/reminder_service.dart';
import 'package:splitter/Services/reminder_settings_service.dart';
import 'package:splitter/Controllers/premium_subscription_controller.dart';
import 'package:splitter/Services/deep_link_service.dart';
import 'package:splitter/Services/supabase_service.dart';
import 'package:splitter/Services/sync_service.dart';
import 'package:splitter/git_ignore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Global service instances — registered via GetX for DI.
late final AppDatabase appDatabase;
late final SyncService syncService;
late final RealtimeService realtimeService;
late final ReminderService reminderService;
late final DeepLinkService deepLinkService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Supabase
  await Supabase.initialize(
    url: supabaseURL,
    anonKey: supabaseAnonPublicKey,
  );

  // 2. Local database (Drift)
  appDatabase = AppDatabase();

  // 3. Sync service (queue + connectivity listener)
  syncService = SyncService(appDatabase);
  syncService.startListening();

  // 4. Realtime service (Supabase channels)
  realtimeService = RealtimeService();

  // 5. Reminder service (local notifications)
  reminderService = ReminderService();
  await reminderService.initialize();

  // Register as GetX singletons for easy access
  Get.put(appDatabase, permanent: true);
  Get.put(syncService, permanent: true);
  Get.put(realtimeService, permanent: true);
  Get.put(reminderService, permanent: true);
  Get.put(ReminderSettingsService(), permanent: true);
  Get.put(CurrencyController(), permanent: true);
  Get.put(PremiumSubscriptionController(), permanent: true);

  deepLinkService = DeepLinkService();
  Get.put(deepLinkService, permanent: true);
  await deepLinkService.initialize();

  // 6. Check onboarding status
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  // 7. Check biometric lock status
  final biometricEnabled = await BiometricAuthService().isEnabled();

  runApp(MyApp(
    hasSeenOnboarding: hasSeenOnboarding,
    biometricEnabled: biometricEnabled,
  ));
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
    return GetMaterialApp(
      title: 'SplitO',
      debugShowCheckedModeBanner: false,
      initialBinding: AppBindings(),
      theme: AppThemes.light,
      home: _getInitialScreen(),
    );
  }

  Widget _getInitialScreen() {
    if (!hasSeenOnboarding) {
      return const OnboardingScreen();
    }
    final hasSession = SupabaseAuth().supabaseRetrieveSession();
    if (hasSession && biometricEnabled) {
      return const BiometricLockScreen();
    }
    return hasSession
        ? const BottomNavigationController()
        : const LoginScreen();
  }
}
