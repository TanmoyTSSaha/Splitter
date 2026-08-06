import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Services/deep_link_service.dart';
import 'package:splitr/Services/google_auth_errors.dart';

void main() {
  group('DeepLinkService auth callback parsing', () {
    test('detects otp_expired failure from query and fragment', () {
      final uri = Uri.parse(
        'splitr://login-callback/?error=access_denied&error_code=otp_expired'
        '#error=access_denied&error_code=otp_expired',
      );

      final params = DeepLinkService.authCallbackParams(uri);

      expect(DeepLinkService.isAuthCallbackFailure(params), isTrue);
      expect(DeepLinkService.hasAuthSessionPayload(params), isFalse);
      expect(DeepLinkService.isAuthCallbackUri(uri), isTrue);
    });

    test('detects success payload with access token', () {
      final uri = Uri.parse(
        'splitr://login-callback/?access_token=abc&refresh_token=def',
      );

      final params = DeepLinkService.authCallbackParams(uri);

      expect(DeepLinkService.isAuthCallbackFailure(params), isFalse);
      expect(DeepLinkService.hasAuthSessionPayload(params), isTrue);
    });

    test('detects Google OAuth callback params', () {
      final params = DeepLinkService.authCallbackParams(
        Uri.parse('splitr://login-callback/?provider=google&code=abc'),
      );
      expect(GoogleAuthErrors.isGoogleOAuthCallback(params), isTrue);
    });
  });
}
