import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Services/google_auth_errors.dart';
import 'package:splitr/Services/google_auth_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('GoogleAuthResult', () {
    test('completed outcome is successful', () {
      const result = GoogleAuthResult.completed();
      expect(result.isCompleted, isTrue);
      expect(result.isPendingBrowser, isFalse);
      expect(result.outcome, GoogleAuthOutcome.completed);
    });

    test('cancelled is distinct from failed', () {
      const cancelled = GoogleAuthResult.cancelled();
      final failed = GoogleAuthResult.failed('oops');

      expect(cancelled.outcome, GoogleAuthOutcome.cancelled);
      expect(cancelled.isCompleted, isFalse);
      expect(cancelled.userMessage, isNull);

      expect(failed.outcome, GoogleAuthOutcome.failed);
      expect(failed.userMessage, 'oops');
      expect(cancelled.outcome, isNot(failed.outcome));
    });

    test('pendingBrowser does not report completed', () {
      const result = GoogleAuthResult.pendingBrowser();
      expect(result.isCompleted, isFalse);
      expect(result.isPendingBrowser, isTrue);
    });

    test('failed carries user message', () {
      final result = GoogleAuthResult.failed('oops');
      expect(result.outcome, GoogleAuthOutcome.failed);
      expect(result.userMessage, 'oops');
    });
  });

  group('GoogleAuthErrors', () {
    test('maps identity conflict from AuthException', () {
      final message = GoogleAuthErrors.mapAuthException(
        const AuthException('User already registered'),
      );
      expect(
        message,
        AppStrings.services.auth.googleEmailRegisteredWithPassword,
      );
    });

    test('maps config errors from Platform-style text', () {
      final message = GoogleAuthErrors.mapThrowable(
        Exception('ApiException: 10: '),
      );
      expect(message, AppStrings.services.auth.googleSignInConfigError);
    });

    test('maps network errors', () {
      final message = GoogleAuthErrors.mapThrowable(
        Exception('SocketException: Failed host lookup'),
      );
      expect(message, AppStrings.services.auth.googleSignInNetworkError);
    });

    test('detects verified-email identity conflict for D-10 linking', () {
      expect(
        GoogleAuthErrors.isVerifiedEmailIdentityConflict(
          const AuthException('Identity already exists'),
        ),
        isTrue,
      );
      expect(
        GoogleAuthErrors.isVerifiedEmailIdentityConflict(
          const AuthException('Email not confirmed'),
        ),
        isFalse,
      );
    });

    test('detects Google OAuth callback params', () {
      expect(
        GoogleAuthErrors.isGoogleOAuthCallback({'provider': 'google'}),
        isTrue,
      );
      expect(
        GoogleAuthErrors.isGoogleOAuthCallback({'provider_token': 'x'}),
        isTrue,
      );
      expect(
        GoogleAuthErrors.isGoogleOAuthCallback({'access_token': 'x'}),
        isFalse,
      );
    });

    test('detects Google identity on user', () {
      final user = User(
        id: 'user-id',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        identities: [
          UserIdentity(
            identityId: 'google-id',
            id: 'google-id',
            userId: 'user-id',
            identityData: {},
            provider: 'google',
            createdAt: DateTime.now().toIso8601String(),
            lastSignInAt: DateTime.now().toIso8601String(),
          ),
        ],
      );
      expect(GoogleAuthErrors.userSignedInWithGoogle(user), isTrue);
      expect(GoogleAuthErrors.userSignedInWithGoogle(null), isFalse);
    });
  });

  group('Google auth Sentry contract (D-04 vs D-08)', () {
    test('cancel path must not report to Sentry', () {
      expect(
        GoogleAuthErrors.shouldReportGoogleAuthFailure(
          outcome: GoogleAuthOutcome.cancelled,
        ),
        isFalse,
      );
    });

    test('missing GOOGLE_WEB_CLIENT_ID must report to Sentry', () {
      expect(
        GoogleAuthErrors.shouldReportGoogleAuthFailure(
          outcome: GoogleAuthOutcome.failed,
          missingClientIdReason: 'missing_google_web_client_id',
        ),
        isTrue,
      );
    });

    test('AuthException must report to Sentry with feature auth', () {
      expect(
        GoogleAuthErrors.shouldReportGoogleAuthFailure(
          outcome: GoogleAuthOutcome.failed,
          error: const AuthException('Invalid token'),
        ),
        isTrue,
      );
    });

    test('ApiException 10 config error must report to Sentry', () {
      expect(
        GoogleAuthErrors.shouldReportGoogleAuthFailure(
          outcome: GoogleAuthOutcome.failed,
          error: Exception('ApiException: 10: '),
        ),
        isTrue,
      );
    });
  });

  group('Native Google sign-in service contract (tracer)', () {
    test('documents config-missing user copy expectation (D-02)', () {
      // AuthService returns this when AppSecrets.googleWebClientId is empty
      // after D-01 removal — no browser OAuth launch.
      expect(
        AppStrings.services.auth.googleSignInUnavailableUseEmail,
        isNotEmpty,
      );
    });

    test('documents cancel toast copy (D-08)', () {
      expect(AppStrings.services.auth.googleSignInCancelled, isNotEmpty);
    });

    test('documents offline block copy (D-09)', () {
      expect(AppStrings.services.auth.googleSignInOffline, isNotEmpty);
    });
  });
}
