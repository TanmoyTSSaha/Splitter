import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Screen/AuthScreens/biometric_lock_screen.dart';
import 'package:splitr/Screen/AuthScreens/login_screen.dart';
import 'package:splitr/Screen/BottomNavigationController/bottom_navigation_controller.dart';
import 'package:splitr/Screen/OnboardingScreen/onboarding_screen.dart';
import 'package:splitr/Services/supabase_service.dart';

/// Branded splash — white surface, centered Splitr. wordmark.
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _goNext());
  }

  Future<void> _goNext() async {
    await Future<void>.delayed(AppMotion.splash);
    if (!mounted) return;

    final next = _resolveInitialScreen();
    Get.off(() => next, transition: Transition.fade);
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
      body: const Center(
        child: Text(
          AppBranding.brandLogo,
          style: TextStyle(
            fontFamily: kFontAlbra,
            fontSize: splitrFontRecapXl,
            fontWeight: FontWeight.w600,
            color: groupOnSurface,
            height: 1,
          ),
        ),
      ),
    );
  }
}
