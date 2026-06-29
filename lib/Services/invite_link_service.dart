import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Creates and resolves shareable friend / group invite links.
class InviteLinkService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const _uuid = Uuid();

  static const String webBaseUrl = 'https://splito.app';
  static const String appScheme = 'splito';

  String buildFriendInviteUri(String inviterUserId) =>
      '$appScheme://invite/friend/$inviterUserId';

  String buildFriendInviteWebUrl(String inviterUserId) =>
      '$webBaseUrl/invite/friend/$inviterUserId';

  String buildGroupJoinUri(String token) => '$appScheme://join/$token';

  String buildGroupJoinWebUrl(String token) => '$webBaseUrl/join/$token';

  /// Share a friend invite link via the system share sheet.
  Future<void> shareFriendInvite({
    required String inviterUserId,
    required String inviterName,
  }) async {
    final link = buildFriendInviteWebUrl(inviterUserId);
    await Share.share(
      '$inviterName invited you to SplitO! Add them as a friend: $link',
      subject: 'Join me on SplitO',
    );
  }

  /// Create a shareable group join token and return the web URL.
  Future<String> createGroupInviteLink({
    required String groupId,
    required String groupName,
  }) async {
    final token = _uuid.v4();
    final userId = _supabase.auth.currentUser!.id;

    await _supabase.from('shareable_invites').insert({
      'token': token,
      'invite_type': 'group',
      'creator_id': userId,
      'group_id': groupId,
      'status': 'active',
    });

    final url = buildGroupJoinWebUrl(token);
    await Share.share(
      'Join "$groupName" on SplitO: $url',
      subject: 'Group invite — $groupName',
    );
    return url;
  }

  /// Send a friend request to the user encoded in a friend invite link.
  Future<void> acceptFriendInvite(String inviterUserId) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) throw 'Not signed in';
    if (currentUserId == inviterUserId) throw 'Cannot add yourself';

    final existing = await _supabase
        .from('friends')
        .select()
        .or('and(user_id.eq.$currentUserId,friend_id.eq.$inviterUserId),'
            'and(user_id.eq.$inviterUserId,friend_id.eq.$currentUserId)');

    if (existing.isNotEmpty) {
      final row = existing.first;
      if (row['status'] == 'pending' && row['friend_id'] == currentUserId) {
        await _supabase
            .from('friends')
            .update({'status': 'accepted'}).eq('id', row['id']);
        return;
      }
      if (row['status'] == 'accepted') return;
    }

    await _supabase.from('friends').insert({
      'user_id': currentUserId,
      'friend_id': inviterUserId,
      'status': 'pending',
    });
  }

  /// Join a group using a shareable invite token.
  Future<String> acceptGroupInvite(String token) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) throw 'Not signed in';

    final rows = await _supabase
        .from('shareable_invites')
        .select()
        .eq('token', token)
        .eq('status', 'active')
        .limit(1);

    if (rows.isEmpty) throw 'Invite link is invalid or expired';

    final invite = rows.first;
    final groupId = invite['group_id'] as String?;

    if (groupId == null) throw 'Invalid group invite';

    final memberCheck = await _supabase
        .from('group_members')
        .select()
        .eq('group_id', groupId)
        .eq('user_id', currentUserId);

    if (memberCheck.isEmpty) {
      await _supabase.rpc('join_group_as_member', params: {
        'p_group_id': groupId,
      });
    }

    await _supabase
        .from('shareable_invites')
        .update({'status': 'used'}).eq('token', token);

    return groupId;
  }

  /// Parse invite payloads from deep link URIs.
  static InviteLinkPayload? parseUri(Uri uri) {
    try {
      final isAppScheme = uri.scheme == appScheme;
      final isWebHost =
          uri.host == 'splito.app' || uri.host.endsWith('.splito.app');

      if (!isAppScheme && !isWebHost) return null;

      List<String> segments = List.from(uri.pathSegments);

      // splito://invite/friend/{id} → host=invite, path=/friend/{id}
      if (isAppScheme && uri.host == 'invite') {
        if (segments.length >= 2 && segments[0] == 'friend') {
          return InviteLinkPayload.friend(segments[1]);
        }
      }

      // splito://join/{token} → host=join, path=/{token}
      if (isAppScheme && uri.host == 'join' && segments.isNotEmpty) {
        return InviteLinkPayload.group(segments.first);
      }

      // https://splito.app/invite/friend/{id}
      if (segments.length >= 3 &&
          segments[0] == 'invite' &&
          segments[1] == 'friend') {
        return InviteLinkPayload.friend(segments[2]);
      }

      // https://splito.app/join/{token}
      if (segments.length >= 2 && segments[0] == 'join') {
        return InviteLinkPayload.group(segments[1]);
      }
    } catch (e) {
      debugPrint('InviteLinkService.parseUri: $e');
    }
    return null;
  }
}

class InviteLinkPayload {
  final InviteLinkType type;
  final String id;

  const InviteLinkPayload._(this.type, this.id);

  factory InviteLinkPayload.friend(String userId) =>
      InviteLinkPayload._(InviteLinkType.friend, userId);

  factory InviteLinkPayload.group(String token) =>
      InviteLinkPayload._(InviteLinkType.group, token);
}

enum InviteLinkType { friend, group }
