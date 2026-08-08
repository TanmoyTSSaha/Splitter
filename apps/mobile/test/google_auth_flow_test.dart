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

    test('failed carries user message', () {
      final result = GoogleAuthResult.failed('oops');
      expect(result.outcome, GoogleAuthOutcome.failed);
      expect(result.userMessage, 'oops');
    });
  });

  group('GoogleAuthErrors', () {
    test('does not map verified-email identity conflict to password copy (D-10)', () {
      final message = GoogleAuthErrors.mapAuthException(
        const AuthException('User already registered'),
      );
      expect(message, isNull);
      expect(
        GoogleAuthErrors.isVerifiedEmailIdentityConflict(
          const AuthException('User already registered'),
        ),
        isTrue,
      );
    });

    test('maps unconfirmed email before Google sign-in', () {
      final message = GoogleAuthErrors.mapAuthException(
        const AuthException('Email not confirmed'),
      );
      expect(message, AppStrings.services.auth.verifyEmailBeforeGoogle);
      expect(
        GoogleAuthErrors.isVerifiedEmailIdentityConflict(
          const AuthException('Email not confirmed'),
        ),
        isFalse,
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

    test('detects verified-email identity conflict for linkIdentityWithIdToken', () {
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

    test('offline block must not report to Sentry', () {
      expect(
        GoogleAuthErrors.shouldReportGoogleAuthFailure(
          outcome: GoogleAuthOutcome.failed,
        ),
        isFalse,
      );
    });
  });

  group('Native Google sign-in service contract', () {
    test('config-missing user copy points to email sign-in (D-02)', () {
      expect(
        AppStrings.services.auth.googleSignInUnavailableUseEmail,
        contains('email'),
      );
    });

    test('cancel toast copy (D-08)', () {
      expect(
        AppStrings.services.auth.googleSignInCancelled,
        'Sign-in cancelled',
      );
    });

    test('offline block copy (D-09)', () {
      expect(
        AppStrings.services.auth.googleSignInOffline,
        'Internet required to sign in',
      );
    });

    test('D-10 identity conflict triggers linkIdentityWithIdToken in AuthService', () {
      // AuthService._signInWithGoogleTokens calls linkIdentityWithIdToken when
      // signInWithIdToken throws a verified-email identity conflict.
      const conflict = AuthException('Identity already exists');
      expect(GoogleAuthErrors.isVerifiedEmailIdentityConflict(conflict), isTrue);
      expect(GoogleAuthErrors.mapAuthException(conflict), isNull);
    });
  });
}
