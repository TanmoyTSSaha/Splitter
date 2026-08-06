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
}
