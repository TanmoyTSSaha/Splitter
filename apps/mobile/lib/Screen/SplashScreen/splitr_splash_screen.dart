import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitr/Screen/AuthScreens/biometric_lock_screen.dart';
import 'package:splitr/Screen/AuthScreens/login_screen.dart';
import 'package:splitr/Screen/BottomNavigationController/bottom_navigation_controller.dart';
import 'package:splitr/Screen/OnboardingScreen/onboarding_screen.dart';
import 'package:splitr/Services/app_bootstrap.dart';
import 'package:splitr/Services/app_services.dart';
import 'package:splitr/Services/deep_link_service.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Widgets/splitr_stroke_wordmark.dart';
import 'package:splitr/config/sentry_cold_start.dart';

/// Branded splash — white surface, centered animated Splitr. wordmark.
class SplitrSplashScreen extends StatefulWidget {
  const SplitrSplashScreen({super.key});

  @override
  State<SplitrSplashScreen> createState() => _SplitrSplashScreenState();
}

class _SplitrSplashScreenState extends State<SplitrSplashScreen> {
  bool _navigated = false;
  late final Future<BootstrapSessionResult> _deferredBootstrap;

  @override
  void initState() {
    super.initState();
    _deferredBootstrap = bootstrapDeferred();
  }

  Future<void> _onAnimationComplete() async {
    if (_navigated || !mounted) return;
    _navigated = true;

    final session = await _deferredBootstrap;
    SentryColdStart.finishTimeToHome();

    if (!mounted) return;
    if (Get.isRegistered<DeepLinkService>()) {
      deepLinkService.markNavigationReady();
    }

    Get.off(
      () => _resolveInitialScreen(session),
      transition: Transition.fade,
    );
  }

  Widget _resolveInitialScreen(BootstrapSessionResult session) {
    if (!session.hasSeenOnboarding) {
      return const OnboardingScreen();
    }
    final hasSession = SupabaseAuth().supabaseRetrieveSession();
    if (hasSession && session.biometricEnabled) {
      return const BiometricLockScreen();
    }
    return hasSession
        ? const BottomNavigationController()
        : const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: surface,
      body: Center(
        child: SplitrStrokeWordmark(
          onDrawComplete: () => _onAnimationComplete(),
        ),
      ),
    );
  }
}
