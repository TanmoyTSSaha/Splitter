import 'package:splitr/config/app_secrets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Cold-start performance transaction (PERF-01 / D-05).
class SentryColdStart {
  SentryColdStart._();

  static ISentrySpan? _transaction;
  static ISentrySpan? _firstFrameSpan;
  static ISentrySpan? _deferredSpan;

  static const transactionName = 'app.cold_start';

  static void start() {
    if (!AppSecrets.sentryEnabled || !Sentry.isEnabled) return;
    _transaction = Sentry.startTransaction(
      transactionName,
      'app.start',
      bindToScope: true,
    );
    _firstFrameSpan = _transaction?.startChild('time_to_first_frame');
  }

  static void finishTimeToFirstFrame() {
    _firstFrameSpan?.finish();
    _firstFrameSpan = null;
  }

  static ISentrySpan? startDeferredSpan() {
    if (!AppSecrets.sentryEnabled || !Sentry.isEnabled) return null;
    _deferredSpan = _transaction?.startChild('bootstrap.deferred');
    return _deferredSpan;
  }

  static void finishTimeToHome() {
    _deferredSpan?.finish();
    _deferredSpan = null;
    final homeSpan = _transaction?.startChild('time_to_home');
    homeSpan?.finish();
    _transaction?.finish();
    _transaction = null;
  }

  static void syncUser(User? user) {
    if (!AppSecrets.sentryEnabled || !Sentry.isEnabled) return;
    Sentry.configureScope((scope) {
      scope.setUser(user == null ? null : SentryUser(id: user.id));
    });
  }
}
