import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const String _enabledKey = 'biometric_lock_enabled';

  /// Whether the device supports biometric authentication.
  Future<bool> isDeviceSupported() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      if (!isSupported) return false;

      final availableBiometrics = await _auth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      debugPrint('BiometricAuthService: isDeviceSupported error — $e');
      return false;
    }
  }

  /// Whether the user has enabled biometric lock for the app.
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  /// Toggles biometric lock on or off.
  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
  }

  /// Authenticates the user using biometrics.
  Future<BiometricAuthResult> authenticate({
    String reason = 'Authenticate to unlock SplitO',
  }) async {
    try {
      final canAuthenticate = await _auth.canCheckBiometrics;
      if (!canAuthenticate) {
        return const BiometricAuthResult(
          BiometricAuthStatus.unavailable,
          message: 'Biometrics are not available on this device.',
        );
      }

      final didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
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
      debugPrint('BiometricAuthService: auth error — ${e.code}: ${e.message}');
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
          message: e.message ?? 'Set up fingerprint unlock in device settings.',
        );
      case 'LockedOut':
      case 'lockedOut':
      case 'PermanentlyLockedOut':
      case 'permanentlyLockedOut':
        return const BiometricAuthResult(
          BiometricAuthStatus.failed,
          message: 'Too many attempts. Try again later.',
        );
      default:
        return BiometricAuthResult(
          BiometricAuthStatus.failed,
          message: e.message ?? 'Authentication failed. Tap to retry.',
        );
    }
  }
}
