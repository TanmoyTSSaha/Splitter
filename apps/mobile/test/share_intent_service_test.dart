import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Services/share_intent_service.dart';

void main() {
  group('ShareIntentService.isShareableMediaPath', () {
    test('rejects auth callback deep link paths', () {
      expect(
        ShareIntentService.isShareableMediaPath(
          '/splitr:/login-callback/?error=access_denied&error_code=otp_expired',
        ),
        isFalse,
      );
      expect(
        ShareIntentService.isShareableMediaPath(
          'splitr://login-callback/?code=abc',
        ),
        isFalse,
      );
    });

    test('rejects remote urls', () {
      expect(
        ShareIntentService.isShareableMediaPath('https://example.com/receipt.jpg'),
        isFalse,
      );
    });

    test('rejects missing files', () {
      expect(
        ShareIntentService.isShareableMediaPath('C:/missing/receipt.jpg'),
        isFalse,
      );
    });
  });
}
