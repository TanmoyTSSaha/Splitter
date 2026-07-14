import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/theme_accent_colors.dart';
import 'package:splitr/Screen/BottomNavigationController/bottom_navigation_controller.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Services/biometric_auth_service.dart';

/// Full-screen biometric lock shown on cold start when biometric lock is enabled.
class BiometricLockScreen extends StatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen> {
  final BiometricAuthService _bioService = BiometricAuthService();
  bool _isAuthenticating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(AppMotion.biometricDelay);
      if (mounted) _authenticate();
    });
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    final result = await _bioService.authenticate();

    if (!mounted) return;

    if (result.isSuccess) {
      Get.offAll(() => const BottomNavigationController());
      return;
    }

    setState(() {
      _isAuthenticating = false;
      if (result.status == BiometricAuthStatus.cancelled) {
        _errorMessage = null;
      } else {
        _errorMessage = AppStrings.errors.biometricFailed;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: surface,
      body: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.paddingOf(context).top,
          bottom: MediaQuery.paddingOf(context).bottom,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // ── App Icon ──
              Container(
                width: AppDimensions.biometricIconContainer,
                height: AppDimensions.biometricIconContainer,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      neopopAccent,
                      neopopAccentIconDim,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: neopopAccentBorderSoft,
                      blurRadius: AppDimensions.biometricIconBlur,
                      spreadRadius: AppDimensions.biometricIconSpread,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    AppStrings.biometric.brandMonogram,
                    style: TextStyle(
                      color: neopopOnPrimary,
                      fontSize: splitrFontHero,
                      fontWeight: FontWeight.w800,
                      letterSpacing: AppDimensions.letterSpacingTight,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: groupGapLg),

              // ── Title ──
              Text(
                AppBranding.brandLogo,
                style: headline1_text.copyWith(
                  color: groupOnSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: groupGapSm),

              Text(
                AppStrings.biometric.locked,
                style: body1_text.copyWith(
                  color: groupOnSurfaceMuted,
                ),
              ),

              const Spacer(flex: 2),

              // ── Fingerprint Button ──
              GestureDetector(
                onTap: _isAuthenticating ? null : _authenticate,
                child: AnimatedContainer(
                  duration: AppMotion.nav,
                  width: AppDimensions.biometricButtonSize,
                  height: AppDimensions.biometricButtonSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isAuthenticating
                        ? neopopAccentFillSoft
                        : neopopAccentFillMedium,
                    border: Border.all(
                      color: neopopAccentBorderSoft,
                      width: 2,
                    ),
                  ),
                  child: _isAuthenticating
                      ? const Center(
                          child: SizedBox(
                            width: AppDimensions.groupIconLg,
                            height: AppDimensions.groupIconLg,
                            child: CircularProgressIndicator(
                              strokeWidth: groupProgressStrokeWidthMedium,
                              color: neopopAccent,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.fingerprint_rounded,
                          color: neopopAccent,
                          size: AppDimensions.biometricIconSize,
                        ),
                ),
              ),

              const SizedBox(height: groupGutter),

              Text(
                _isAuthenticating
                    ? AppStrings.biometric.authenticating
                    : AppStrings.biometric.tapToUnlock,
                style: caption_text.copyWith(
                  color: groupOnSurfaceMuted,
                ),
              ),

              // ── Error Message ──
              if (_errorMessage != null) ...[
                const SizedBox(height: groupCarouselGap),
                GestureDetector(
                  onTap: _authenticate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: groupGutter, vertical: groupGapSm),
                    decoration: BoxDecoration(
                      color: neopopYellow.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(groupControlRadius),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: caption_text.copyWith(
                        color: ThemeAccentColors.oweWarning(context),
                      ),
                    ),
                  ),
                ),
              ],

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
