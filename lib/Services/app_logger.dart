import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:splitr/config/app_secrets.dart';

/// Structured logging — Sentry in release/staging, debugPrint locally in debug.
abstract final class AppLogger {
  static void info(String message, {Map<String, dynamic>? data}) {
    final scrubbed = _scrubData(data);
    if (kDebugMode) {
      debugPrint('[info] $message${data == null ? '' : ' $data'}');
    }
    if (AppSecrets.sentryEnabled && Sentry.isEnabled) {
      Sentry.logger.info(message, attributes: scrubbed);
    }
  }

  static void warning(String message, {Map<String, dynamic>? data}) {
    final scrubbed = _scrubData(data);
    if (kDebugMode) {
      debugPrint('[warn] $message${data == null ? '' : ' $data'}');
    }
    if (AppSecrets.sentryEnabled && Sentry.isEnabled) {
      Sentry.logger.warn(message, attributes: scrubbed);
    }
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stack,
    Map<String, dynamic>? data,
  }) {
    final scrubbed = _scrubData(data);
    if (kDebugMode) {
      debugPrint('[error] $message${data == null ? '' : ' $data'}');
      if (error != null) debugPrint('$error');
      if (stack != null) debugPrint('$stack');
    }
    if (AppSecrets.sentryEnabled && Sentry.isEnabled) {
      Sentry.logger.error(message, attributes: scrubbed);
      if (error != null) {
        Sentry.captureException(error, stackTrace: stack);
      }
    }
  }

  static Map<String, SentryAttribute>? _scrubData(
    Map<String, dynamic>? data,
  ) {
    if (data == null || data.isEmpty) return null;
    return data.map(
      (key, value) => MapEntry(key, SentryAttribute.string('$value')),
    );
  }
}
