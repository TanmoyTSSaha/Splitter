import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:splitr/Bindings/app_bindings.dart';
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_themes.dart';
import 'package:splitr/Constants/system_ui.dart';
import 'package:splitr/Controllers/theme_controller.dart';
import 'package:splitr/Screen/SplashScreen/splitr_splash_screen.dart';
import 'package:splitr/Services/app_bootstrap.dart';
import 'package:splitr/Services/app_services.dart';
import 'package:splitr/Services/deep_link_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/Widgets/achievement_celebration_overlay.dart';
import 'package:splitr/Widgets/splitr_error_scope.dart';
import 'package:splitr/config/app_secrets.dart';
import 'package:splitr/config/sentry_cold_start.dart';
import 'package:splitr/config/sentry_options.dart';

export 'package:splitr/Services/app_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: EnvFiles.dotenv, isOptional: true);

  if (AppSecrets.sentryEnabled) {
    await SentryFlutter.init(configureSentryOptions);
  }
  _installGlobalErrorHandlers();

  SentryColdStart.start();
  await bootstrapCritical();

  final app = const MyApp();
  runApp(AppSecrets.sentryEnabled ? SentryWidget(child: app) : app);
}

void _installGlobalErrorHandlers() {
  final previousFlutterOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    AppErrorReporter.unexpected(
      'Flutter framework error',
      error: details.exception,
      stack: details.stack,
      context: {
        'library': details.library ?? '',
        'context': details.context?.toString() ?? '',
      },
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SentryColdStart.finishTimeToFirstFrame();
      if (Get.isRegistered<DeepLinkService>()) {
        deepLinkService.markNavigationReady();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final materialApp = _buildMaterialApp();
    if (Get.isRegistered<ThemeController>()) {
      return Obx(() {
        final themeController = Get.find<ThemeController>();
        return _buildMaterialApp(themeMode: themeController.themeMode.value);
      });
    }
    return materialApp;
  }

  Widget _buildMaterialApp({ThemeMode themeMode = ThemeMode.light}) {
    return GetMaterialApp(
      title: AppBranding.brandName,
      debugShowCheckedModeBanner: false,
      initialBinding: AppBindings(),
      navigatorObservers: AppSecrets.sentryEnabled
          ? [SentryNavigatorObserver()]
          : const [],
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      themeMode: themeMode,
      builder: (context, child) => AchievementCelebrationHost(
        child: SplitrErrorScope(
          screenTag: Get.currentRoute,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: kSplitrSystemUiOverlay,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
      home: const SplitrSplashScreen(),
    );
  }
}
