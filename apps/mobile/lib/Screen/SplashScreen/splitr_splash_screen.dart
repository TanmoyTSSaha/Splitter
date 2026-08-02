import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitr/Screen/AuthScreens/biometric_lock_screen.dart';
import 'package:splitr/Screen/AuthScreens/login_screen.dart';
import 'package:splitr/Screen/BottomNavigationController/bottom_navigation_controller.dart';
import 'package:splitr/Screen/OnboardingScreen/onboarding_screen.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Widgets/splitr_stroke_wordmark.dart';

/// Branded splash — white surface, centered animated Splitr. wordmark.
class SplitrSplashScreen extends StatefulWidget {
  final bool hasSeenOnboarding;
  final bool biometricEnabled;

  const SplitrSplashScreen({
    super.key,
    required this.hasSeenOnboarding,
    this.biometricEnabled = false,
  });

  @override
  State<SplitrSplashScreen> createState() => _SplitrSplashScreenState();
}

class _SplitrSplashScreenState extends State<SplitrSplashScreen> {
  bool _navigated = false;

  void _onAnimationComplete() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Get.off(() => _resolveInitialScreen(), transition: Transition.fade);
  }

  Widget _resolveInitialScreen() {
    if (!widget.hasSeenOnboarding) {
      return const OnboardingScreen();
    }
    final hasSession = SupabaseAuth().supabaseRetrieveSession();
    if (hasSession && widget.biometricEnabled) {
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
        child: SplitrStrokeWordmark(onDrawComplete: _onAnimationComplete),
      ),
    );
  }
}
