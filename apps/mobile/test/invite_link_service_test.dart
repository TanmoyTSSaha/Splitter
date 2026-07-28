import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Services/invite_link_service.dart';

void main() {
  group('InviteLinkService.parseUri', () {
    const userId = 'user-abc-123';
    const token = 'group-token-xyz';

    test('parses canonical friend invite on splitr.money', () {
      final payload = InviteLinkService.parseUri(
        Uri.parse('https://splitr.money/invite/friend/$userId'),
      );
      expect(payload, isNotNull);
      expect(payload!.type, InviteLinkType.friend);
      expect(payload.id, userId);
    });

    test('parses canonical group join on splitr.money', () {
      final payload = InviteLinkService.parseUri(
        Uri.parse('https://splitr.money/join/$token'),
      );
      expect(payload, isNotNull);
      expect(payload!.type, InviteLinkType.group);
      expect(payload.id, token);
    });

    test('parses splitr custom scheme group join', () {
      final payload = InviteLinkService.parseUri(
        Uri.parse('splitr://join/$token'),
      );
      expect(payload, isNotNull);
      expect(payload!.type, InviteLinkType.group);
      expect(payload.id, token);
    });

    test('returns null for unknown host', () {
      expect(
        InviteLinkService.parseUri(
          Uri.parse('https://example.com/join/$token'),
        ),
        isNull,
      );
    });

    test('returns null for removed legacy hosts', () {
      expect(
        InviteLinkService.parseUri(
          Uri.parse('https://splitr.app/join/$token'),
        ),
        isNull,
      );
      expect(
        InviteLinkService.parseUri(
          Uri.parse('https://splito.app/invite/friend/$userId'),
        ),
        isNull,
      );
      expect(
        InviteLinkService.parseUri(Uri.parse('splito://join/$token')),
        isNull,
      );
    });
  });
}
