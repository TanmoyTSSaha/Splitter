import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Services/app_bootstrap.dart';
import 'package:splitr/config/sentry_cold_start.dart';

void main() {
  group('AppBootstrap', () {
    test('bootstrapDeferred is exposed as a Future factory', () {
      expect(bootstrapDeferred, isA<Future<BootstrapSessionResult> Function()>());
    });

    test('bootstrapCritical is exposed as a Future factory', () {
      expect(bootstrapCritical, isA<Future<void> Function()>());
    });
  });

  group('SentryColdStart', () {
    test('transaction name is app.cold_start', () {
      expect(SentryColdStart.transactionName, 'app.cold_start');
    });
  });
}
