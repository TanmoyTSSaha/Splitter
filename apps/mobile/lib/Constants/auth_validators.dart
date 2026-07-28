import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/business_rules.dart';

/// Shared auth field validators and messages.
abstract final class AuthValidators {
  static const emailRequired = 'Email is required';
  static const emailInvalid = 'Enter a valid email';
  static const passwordRequired = 'Password is required';
  static const passwordMinLength =
      'Use at least ${AuthRules.minPasswordLength} characters';
  static const confirmPasswordRequired = 'Confirm your password';
  static const passwordsDoNotMatch = 'Passwords do not match';
  static const firstNameLabel = 'First name';
  static const lastNameLabel = 'Last name';

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return emailRequired;
    }
    if (!RegExp(InputPatterns.email).hasMatch(value.trim())) {
      return emailInvalid;
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return passwordRequired;
    }
    if (value.length < AuthRules.minPasswordLength) {
      return passwordMinLength;
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return confirmPasswordRequired;
    }
    if (value != password) {
      return passwordsDoNotMatch;
    }
    return null;
  }

  static String? requiredName(String? value, String label) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return '$label is required';
    return null;
  }
}
