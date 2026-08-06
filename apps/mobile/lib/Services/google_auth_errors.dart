import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Maps Google / Supabase auth failures to user-safe copy.
abstract final class GoogleAuthErrors {
  static String? mapAuthException(AuthException e) {
    final msg = e.message.toLowerCase();
    final code = (e.code ?? '').toLowerCase();

    if (msg.contains('email not confirmed') ||
        msg.contains('email_not_confirmed')) {
      return AppStrings.services.auth.verifyEmailBeforeGoogle;
    }
    if (_isIdentityConflict(msg, code)) {
      return AppStrings.services.auth.googleEmailRegisteredWithPassword;
    }
    if (_isNetworkError(msg)) {
      return AppStrings.services.auth.googleSignInNetworkError;
    }
    return null;
  }

  static String mapThrowable(Object error) {
    if (error is AuthException) {
      return mapAuthException(error) ??
          AppStrings.services.auth.googleSignInFailed;
    }
    if (error is GoogleSignInException) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return '';
      }
      if (_isConfigError(error.toString())) {
        return AppStrings.services.auth.googleSignInConfigError;
      }
    }
    if (error is PlatformException) {
      if (_isConfigError('${error.code} ${error.message}')) {
        return AppStrings.services.auth.googleSignInConfigError;
      }
      if (_isNetworkError('${error.code} ${error.message}')) {
        return AppStrings.services.auth.googleSignInNetworkError;
      }
    }
    final text = error.toString();
    if (_isConfigError(text)) {
      return AppStrings.services.auth.googleSignInConfigError;
    }
    if (_isNetworkError(text)) {
      return AppStrings.services.auth.googleSignInNetworkError;
    }
    return AppStrings.services.auth.googleSignInFailed;
  }

  static bool isGoogleOAuthCallback(Map<String, String> params) {
    final provider = (params['provider'] ?? '').toLowerCase();
    if (provider == 'google') return true;
    return params.containsKey('provider_token');
  }

  static bool userSignedInWithGoogle(User? user) {
    final identities = user?.identities;
    if (identities == null) return false;
    return identities.any((id) => id.provider == 'google');
  }

  static bool _isIdentityConflict(String msg, String code) {
    return msg.contains('user already registered') ||
        msg.contains('already been registered') ||
        msg.contains('identity already exists') ||
        msg.contains('email address is already') ||
        code.contains('user_already_exists');
  }

  static bool _isConfigError(String text) {
    final lower = text.toLowerCase();
    return lower.contains('developer_error') ||
        lower.contains('code: 10') ||
        lower.contains('error 10') ||
        lower.contains('12500') ||
        lower.contains('invalid_client') ||
        lower.contains('apiexception: 10') ||
        lower.contains('12500');
  }

  static bool _isNetworkError(String text) {
    final lower = text.toLowerCase();
    return lower.contains('network') ||
        lower.contains('socket') ||
        lower.contains('timeout') ||
        lower.contains('connection') ||
        lower.contains('offline');
  }
}
