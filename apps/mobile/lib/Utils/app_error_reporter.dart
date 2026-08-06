import 'package:flutter/services.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Services/app_logger.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Central error reporting — unexpected failures go to Sentry; user-facing stay local.
abstract final class AppErrorReporter {
  static String? _activeScreenTag;

  static const _technicalTokens = [
    'postgrest',
    'postgres',
    'jwt',
    'row-level security',
    'violates',
    'policy',
    'socketexception',
    'httpexception',
    'httpstatus',
    'functionexception',
    'clientexception',
    'failed host lookup',
    'connection refused',
    'connection reset',
    'timeout',
    '42883',
    'pgrst',
    'rpc',
    'sql',
    'supabase',
    'razorpay',
    'exception:',
    'error:',
    'stacktrace',
    'permission denied',
    'forbidden',
    'unauthorized',
    'not found',
    'migration',
    'create_notification_for_user',
  ];

  static void setActiveScreenTag(String? tag) => _activeScreenTag = tag;

  static Map<String, dynamic> _withScreen(Map<String, dynamic>? context) {
    final merged = <String, dynamic>{...?context};
    if (_activeScreenTag != null && _activeScreenTag!.isNotEmpty) {
      merged.putIfAbsent('screen', () => _activeScreenTag);
    }
    return merged;
  }

  static bool isMissingSchemaError(Object error) {
    if (error is PostgrestException) {
      final code = error.code ?? '';
      return code == 'PGRST205' || code == 'PGRST202';
    }
    return false;
  }

  static bool isFirebaseConfigError(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('valid api key') ||
        text.contains("no firebase app '[default]'");
  }

  static bool isOfflineFontError(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('fonts.gstatic.com');
  }

  static bool isOtpExpiredAuthError(Object error) {
    if (error is! AuthException) return false;
    final code = error.code ?? '';
    final status = error.statusCode ?? '';
    if (code == 'otp_expired' || status == 'otp_expired') return true;
    return error.message.toLowerCase().contains('invalid or has expired');
  }

  /// Skip Sentry for known dev/config gaps — still log locally.
  static bool shouldSkipSentry(Object? error) {
    if (error == null) return false;
    return isMissingSchemaError(error) ||
        isFirebaseConfigError(error) ||
        isOfflineFontError(error) ||
        isOtpExpiredAuthError(error);
  }

  static void unexpected(
    String message, {
    Object? error,
    StackTrace? stack,
    Map<String, dynamic>? context,
  }) {
    AppLogger.error(
      message,
      error: error,
      stack: stack,
      data: _withScreen(context),
    );
  }

  static void userFacing(
    String message, {
    Object? error,
    Map<String, dynamic>? context,
    bool showToast = true,
  }) {
    final safe = userSafeMessage(
      error,
      fallback: message,
      context: context,
    );
    if (showToast) SplitrToast.show(safe);
    AppLogger.warning(safe, data: _withScreen(context));
  }

  /// User-safe text for inline widgets (`Text`, banners, error states).
  static String inlineMessage(
    Object? error, {
    required String fallback,
    Map<String, dynamic>? context,
  }) =>
      userSafeMessage(error, fallback: fallback, context: context);

  /// Logs full detail to Sentry and shows a sanitized toast for user actions.
  static void reportActionFailure(
    String message, {
    Object? error,
    StackTrace? stack,
    Map<String, dynamic>? context,
    bool showToast = true,
  }) {
    unexpected(message, error: error, stack: stack, context: context);
    if (!showToast) return;
    final safe = userSafeMessage(
      error,
      fallback: message,
      context: context,
    );
    SplitrToast.show(safe);
  }

  /// Routes to [unexpected] or [userFacing] based on error type.
  static void report(
    String message, {
    Object? error,
    StackTrace? stack,
    Map<String, dynamic>? context,
    bool showToastOnUserFacing = true,
  }) {
    if (error != null && isExpectedUserError(error)) {
      final userMessage = userSafeMessage(
        error,
        fallback: message,
        context: context,
      );
      userFacing(
        userMessage,
        error: error,
        context: context,
        showToast: showToastOnUserFacing,
      );
      return;
    }
    unexpected(message, error: error, stack: stack, context: context);
  }

  /// Whether the error is a known user-facing category (auth cancel, etc.).
  /// Does not mean raw [error.message] should be shown.
  static bool isExpectedUserError(Object error) {
    if (error is AuthException) {
      return !isOtpExpiredAuthError(error);
    }
    if (error is StorageException) {
      final message = error.message.toLowerCase();
      if (message.contains('bucket not found')) return true;
      if (message.contains('row-level security') ||
          message.contains('policy')) {
        return true;
      }
    }
    if (error is PlatformException) {
      final code = error.code.toLowerCase();
      if (code == 'usercancel' || code == 'canceled') return true;
    }
    if (error is PostgrestException) {
      final code = error.code ?? '';
      if (code == 'PGRST116') return true; // no rows
      if (error.message.contains('JWT')) return true;
    }
    return false;
  }

  /// Single source of truth for all user-visible error copy.
  static String userSafeMessage(
    Object? error, {
    required String fallback,
    Map<String, dynamic>? context,
  }) {
    final mergedContext = _withScreen(context);
    final feature = mergedContext['feature']?.toString();
    final contextual = _contextualFallback(fallback, mergedContext);

    if (error is AuthException) {
      if (isOtpExpiredAuthError(error)) {
        return AppStrings.services.deepLink.emailLinkExpired;
      }
      return feature == 'auth' ? error.message : AppStrings.errors.genericHumorous;
    }

    if (error is StorageException) {
      final message = error.message.toLowerCase();
      if (message.contains('bucket not found')) {
        return AppStrings.profile.photoStorageUnavailable;
      }
    }

    if (mergedContext['hint'] == 'rls_violation' ||
        mergedContext['hint'] == 'forbidden_target' ||
        mergedContext['hint'] == 'missing_rpc_migration') {
      return AppStrings.errors.accessHumorous;
    }

    if (error == null) {
      return _scrubIfTechnical(fallback, contextual);
    }

    if (error is String) {
      return _scrubIfTechnical(error, contextual);
    }

    return _scrubIfTechnical(error.toString(), contextual);
  }

  static String _contextualFallback(
    String fallback,
    Map<String, dynamic> context,
  ) {
    final feature = context['feature']?.toString() ?? '';
    if (feature == 'payment' || feature == 'premium' || feature == 'donate') {
      return AppStrings.errors.paymentHumorous;
    }
    if (feature == 'export') {
      return AppStrings.errors.exportHumorous;
    }
    if (context.containsKey('hint') &&
        (context['hint'] == 'rls_violation' ||
            context['hint'] == 'forbidden_target' ||
            context['hint'] == 'missing_rpc_migration')) {
      return AppStrings.errors.accessHumorous;
    }

    if (!_looksTechnical(fallback)) return fallback;

    final lower = fallback.toLowerCase();
    if (lower.contains('load') ||
        lower.contains('fetch') ||
        lower.contains('refresh')) {
      return AppStrings.errors.loadHumorous;
    }
    if (lower.contains('network') || lower.contains('connection')) {
      return AppStrings.errors.networkHumorous;
    }
    if (lower.contains('payment') ||
        lower.contains('subscription') ||
        lower.contains('razorpay')) {
      return AppStrings.errors.paymentHumorous;
    }
    if (lower.contains('access') ||
        lower.contains('permission') ||
        lower.contains('forbidden')) {
      return AppStrings.errors.accessHumorous;
    }
    if (lower.contains('export')) {
      return AppStrings.errors.exportHumorous;
    }

    return AppStrings.errors.genericHumorous;
  }

  static String _scrubIfTechnical(String candidate, String safeFallback) {
    if (!_looksTechnical(candidate)) return candidate;
    if (!_looksTechnical(safeFallback)) return safeFallback;
    return AppStrings.errors.genericHumorous;
  }

  static bool _looksTechnical(String text) {
    final lower = text.toLowerCase();
    for (final token in _technicalTokens) {
      if (lower.contains(token)) return true;
    }
    if (lower.startsWith('exception') || lower.contains('exception (')) {
      return true;
    }
    if (RegExp(r'\b\d{3}\b').hasMatch(lower) &&
        (lower.contains('http') || lower.contains('status'))) {
      return true;
    }
    return false;
  }
}
