import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

enum BiometricAuthStatus { success, cancelled, unavailable, failed }

class BiometricAuthResult {
  final BiometricAuthStatus status;
  final String? message;

  const BiometricAuthResult(this.status, {this.message});

  bool get isSuccess => status == BiometricAuthStatus.success;
}

/// Service that wraps `local_auth` for biometric authentication.
/// Manages enable/disable state via SharedPreferences.
class BiometricAuthService {
  static final BiometricAuthService _instance = BiometricAuthService._();
  factory BiometricAuthService() => _instance;
  BiometricAuthService._();

  final LocalAuthentication _auth = LocalAuthentication();

  /// Whether the device supports biometric authentication.
  Future<bool> isDeviceSupported() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      if (!isSupported) return false;

      final availableBiometrics = await _auth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e, stack) {
      AppErrorReporter.report(
        'BiometricAuthService.isDeviceSupported failed',
        error: e,
        stack: stack,
        context: {'feature': 'biometric'},
      );
      return false;
    }
  }

  /// Whether the user has enabled biometric lock for the app.
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PrefKeys.biometricLockEnabled) ?? false;
  }

  /// Toggles biometric lock on or off.
  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefKeys.biometricLockEnabled, value);
  }

  /// Authenticates the user using biometrics.
  Future<BiometricAuthResult> authenticate({
    String? reason,
  }) async {
    final localizedReason = reason ??
        '${AppStrings.services.biometric.authenticateReason}${AppBranding.brandName}';
    try {
      final canAuthenticate = await _auth.canCheckBiometrics;
      if (!canAuthenticate) {
        return BiometricAuthResult(
          BiometricAuthStatus.unavailable,
          message: AppStrings.services.biometric.notAvailable,
        );
      }

      final didAuthenticate = await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (didAuthenticate) {
        return const BiometricAuthResult(BiometricAuthStatus.success);
      }

      return const BiometricAuthResult(BiometricAuthStatus.cancelled);
    } on PlatformException catch (e) {
      final isUserCancel = e.code == 'UserCancel' ||
          e.code == 'userCancel' ||
          e.code == 'Canceled' ||
          e.code == 'canceled';
      AppErrorReporter.report(
        'BiometricAuthService.authenticate failed',
        error: e,
        context: {'feature': 'biometric', 'code': e.code},
        showToastOnUserFacing: !isUserCancel,
      );
      return _mapPlatformException(e);
    }
  }

  BiometricAuthResult _mapPlatformException(PlatformException e) {
    switch (e.code) {
      case 'NotAvailable':
      case 'notAvailable':
      case 'NotEnrolled':
      case 'notEnrolled':
      case 'PasscodeNotSet':
      case 'passcodeNotSet':
        return BiometricAuthResult(
          BiometricAuthStatus.unavailable,
          message: AppStrings.services.biometric.setupFingerprint,
        );
      case 'LockedOut':
      case 'lockedOut':
      case 'PermanentlyLockedOut':
      case 'permanentlyLockedOut':
        return BiometricAuthResult(
          BiometricAuthStatus.failed,
          message: AppStrings.services.biometric.tooManyAttempts,
        );
      default:
        return BiometricAuthResult(
          BiometricAuthStatus.failed,
          message: AppStrings.services.biometric.authFailed,
        );
    }
  }
}
