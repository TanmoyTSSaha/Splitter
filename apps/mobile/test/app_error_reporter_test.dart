import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('AppErrorReporter.isExpectedUserError', () {
    test('AuthException is expected', () {
      expect(
        AppErrorReporter.isExpectedUserError(
          const AuthException('Invalid login credentials'),
        ),
        isTrue,
      );
    });

    test('biometric user cancel PlatformException is expected', () {
      expect(
        AppErrorReporter.isExpectedUserError(
          PlatformException(code: 'UserCancel'),
        ),
        isTrue,
      );
    });

    test('generic Exception is unexpected', () {
      expect(
        AppErrorReporter.isExpectedUserError(Exception('db down')),
        isFalse,
      );
    });

    test('PostgrestException RLS violation is unexpected', () {
      expect(
        AppErrorReporter.isExpectedUserError(
          const PostgrestException(
            message:
                'new row violates row-level security policy for table "notifications"',
          ),
        ),
        isFalse,
      );
    });
  });

  group('AppErrorReporter.userSafeMessage', () {
    test('AuthException with feature auth returns original message', () {
      expect(
        AppErrorReporter.userSafeMessage(
          const AuthException('Invalid login credentials'),
          fallback: AppStrings.errors.genericHumorous,
          context: {'feature': 'auth'},
        ),
        'Invalid login credentials',
      );
    });

    test('AuthException outside auth returns generic humorous', () {
      expect(
        AppErrorReporter.userSafeMessage(
          const AuthException('Invalid login credentials'),
          fallback: AppStrings.errors.genericHumorous,
          context: {'feature': 'friends'},
        ),
        AppStrings.errors.genericHumorous,
      );
    });

    test('Postgrest JWT message is scrubbed', () {
      expect(
        AppErrorReporter.userSafeMessage(
          const PostgrestException(message: 'JWT expired'),
          fallback: AppStrings.errors.loadHumorous,
        ),
        AppStrings.errors.loadHumorous,
      );
    });

    test('Postgrest RLS message is scrubbed', () {
      expect(
        AppErrorReporter.userSafeMessage(
          const PostgrestException(
            message:
                'new row violates row-level security policy for table "users"',
          ),
          fallback: AppStrings.errors.genericHumorous,
        ),
        AppStrings.errors.genericHumorous,
      );
    });

    test('migration RPC missing hint uses access humorous', () {
      expect(
        AppErrorReporter.userSafeMessage(
          const PostgrestException(
            message: 'function create_notification_for_user() does not exist',
            code: '42883',
          ),
          fallback: 'Failed',
          context: {'hint': 'missing_rpc_migration'},
        ),
        AppStrings.errors.accessHumorous,
      );
    });

    test('Exception toString is scrubbed', () {
      expect(
        AppErrorReporter.userSafeMessage(
          Exception('PostgrestException: connection refused'),
          fallback: AppStrings.errors.networkHumorous,
        ),
        AppStrings.errors.networkHumorous,
      );
    });

    test('user-safe fallback passes through', () {
      expect(
        AppErrorReporter.userSafeMessage(
          null,
          fallback: AppStrings.errors.loadFriends,
        ),
        AppStrings.errors.loadFriends,
      );
    });

    test('technical fallback is scrubbed to humorous generic', () {
      expect(
        AppErrorReporter.userSafeMessage(
          null,
          fallback: 'Failed to load: PostgrestException socket error',
        ),
        AppStrings.errors.loadHumorous,
      );
    });

    test('payment feature uses payment humorous for technical errors', () {
      expect(
        AppErrorReporter.userSafeMessage(
          'Razorpay error code 500',
          fallback: 'Subscription failed: internal',
          context: {'feature': 'premium'},
        ),
        AppStrings.errors.paymentHumorous,
      );
    });
  });

  group('AppErrorReporter.inlineMessage', () {
    test('delegates to userSafeMessage', () {
      expect(
        AppErrorReporter.inlineMessage(
          const PostgrestException(message: 'JWT malformed'),
          fallback: AppStrings.errors.loadHumorous,
        ),
        AppStrings.errors.loadHumorous,
      );
    });
  });
}
