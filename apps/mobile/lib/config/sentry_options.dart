import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:splitr/config/app_secrets.dart';

const _sensitiveKeyFragments = [
  'password',
  'token',
  'anon_key',
  'vpa',
  'upi',
  'amount',
  'razorpay',
  'authorization',
  'secret',
  'api_key',
  'apikey',
];

void configureSentryOptions(SentryFlutterOptions options) {
  options.dsn = AppSecrets.sentryDsn;
  options.environment = _resolveEnvironment();
  options.debug = kDebugMode;
  options.tracesSampleRate = kReleaseMode ? 0.2 : 1.0;
  options.enableLogs = true;
  options.sendDefaultPii = false;
  if (kDebugMode) {
    // Replay encodes screen to MP4 on Android (MPEG4Writer/MediaCodec log spam).
    options.replay.sessionSampleRate = 0;
    options.replay.onErrorSampleRate = 0;
    options.attachScreenshot = false;
  } else {
    options.replay.sessionSampleRate = 0.1;
    options.replay.onErrorSampleRate = 1.0;
    options.attachScreenshot = true;
  }
  options.privacy.maskAllText = true;
  options.privacy.maskAllImages = true;
  options.attachViewHierarchy = true;
  options.anrEnabled = true;

  final supabaseUrl = AppSecrets.supabaseUrl;
  if (supabaseUrl.isNotEmpty &&
      !options.tracePropagationTargets.contains(supabaseUrl)) {
    options.tracePropagationTargets.add(supabaseUrl);
  }

  options.beforeSend = _scrubEvent;
  options.beforeBreadcrumb = _scrubBreadcrumb;
}

String _resolveEnvironment() {
  if (AppSecrets.sentryEnvironment.isNotEmpty) {
    return AppSecrets.sentryEnvironment;
  }
  return kReleaseMode ? 'production' : 'development';
}

FutureOr<SentryEvent?> _scrubEvent(SentryEvent event, Hint hint) {
  if (event.extra != null) {
    event.extra = _scrubMap(event.extra);
  }
  event.user = _scrubUser(event.user);
  return event;
}

Breadcrumb? _scrubBreadcrumb(Breadcrumb? breadcrumb, Hint hint) {
  if (breadcrumb == null) return null;
  return breadcrumb.copyWith(data: _scrubMap(breadcrumb.data));
}

SentryUser? _scrubUser(SentryUser? user) {
  if (user == null) return null;
  return SentryUser(id: user.id);
}

Map<String, dynamic>? _scrubMap(Map<String, dynamic>? input) {
  if (input == null || input.isEmpty) return input;
  return input.map((key, value) => MapEntry(key, _scrubValue(key, value)));
}

dynamic _scrubDynamic(dynamic value) {
  if (value is Map<String, dynamic>) return _scrubMap(value);
  if (value is Map) {
    return value.map(
      (key, nested) => MapEntry(key, _scrubValue(key.toString(), nested)),
    );
  }
  if (value is List) {
    return value.map(_scrubDynamic).toList();
  }
  return value;
}

dynamic _scrubValue(String key, dynamic value) {
  if (_isSensitiveKey(key)) return '[Filtered]';
  return _scrubDynamic(value);
}

bool _isSensitiveKey(String key) {
  final normalized = key.toLowerCase();
  return _sensitiveKeyFragments.any(normalized.contains);
}
