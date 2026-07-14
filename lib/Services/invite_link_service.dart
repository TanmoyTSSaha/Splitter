import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:share_plus/share_plus.dart';
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Creates and resolves shareable friend / group invite links.
class InviteLinkService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const _uuid = Uuid();

  static String get webBaseUrl => AppBranding.webBaseUrl;
  static String get appScheme => AppBranding.appScheme;

  String buildFriendInviteUri(String inviterUserId) =>
      '$appScheme://${DeepLinkPaths.invite}/${InviteTypes.friend}/$inviterUserId';

  String buildFriendInviteWebUrl(String inviterUserId) =>
      '$webBaseUrl/${DeepLinkPaths.invite}/${InviteTypes.friend}/$inviterUserId';

  String buildGroupJoinUri(String token) =>
      '$appScheme://${DeepLinkPaths.join}/$token';

  String buildGroupJoinWebUrl(String token) =>
      '$webBaseUrl/${DeepLinkPaths.join}/$token';

  /// Share a friend invite link via the system share sheet.
  Future<void> shareFriendInvite({
    required String inviterUserId,
    required String inviterName,
  }) async {
    final link = buildFriendInviteWebUrl(inviterUserId);
    await Share.share(
      '$inviterName${GroupInviteCopy.invitedYouTo}${AppBranding.brandName}${GroupInviteCopy.addThemAsFriend}$link',
      subject: '${GroupInviteCopy.joinMeOn}${AppBranding.brandName}',
    );
  }

  /// Create a shareable group join token and return the web URL.
  Future<String> createGroupInviteLink({
    required String groupId,
    required String groupName,
  }) async {
    final token = _uuid.v4();
    final userId = _supabase.auth.currentUser!.id;

    await _supabase.from(SupabaseTables.shareableInvites).insert({
      SupabaseColumns.token: token,
      SupabaseColumns.inviteType: InviteTypes.group,
      SupabaseColumns.creatorId: userId,
      SupabaseColumns.groupId: groupId,
      SupabaseColumns.status: InviteStatusValues.active,
    });

    final url = buildGroupJoinWebUrl(token);
    await Share.share(
      '${GroupInviteCopy.joinGroupOn}$groupName${GroupInviteCopy.onBrandSuffix}${AppBranding.brandName}: $url',
      subject: '${GroupInviteCopy.groupInviteSubject}$groupName',
    );
    return url;
  }

  /// Send a friend request to the user encoded in a friend invite link.
  Future<void> acceptFriendInvite(String inviterUserId) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) throw ServiceErrors.notSignedIn;
    if (currentUserId == inviterUserId) throw ServiceErrors.cannotAddYourself;

    final existing = await _supabase.from(SupabaseTables.friends).select().or(
        'and(${SupabaseColumns.userId}.eq.$currentUserId,${SupabaseColumns.friendId}.eq.$inviterUserId),'
        'and(${SupabaseColumns.userId}.eq.$inviterUserId,${SupabaseColumns.friendId}.eq.$currentUserId)');

    if (existing.isNotEmpty) {
      final row = existing.first;
      if (row[SupabaseColumns.status] == FriendStatusValues.pending &&
          row[SupabaseColumns.friendId] == currentUserId) {
        await _supabase.from(SupabaseTables.friends).update({
          SupabaseColumns.status: FriendStatusValues.accepted,
        }).eq(SupabaseColumns.id, row[SupabaseColumns.id]);
        return;
      }
      if (row[SupabaseColumns.status] == FriendStatusValues.accepted) return;
    }

    await _supabase.from(SupabaseTables.friends).insert({
      SupabaseColumns.userId: currentUserId,
      SupabaseColumns.friendId: inviterUserId,
      SupabaseColumns.status: FriendStatusValues.pending,
    });
  }

  /// Join a group using a shareable invite token.
  Future<String> acceptGroupInvite(String token) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) throw ServiceErrors.notSignedIn;

    final rows = await _supabase
        .from(SupabaseTables.shareableInvites)
        .select()
        .eq(SupabaseColumns.token, token)
        .eq(SupabaseColumns.status, InviteStatusValues.active)
        .limit(1);

    if (rows.isEmpty) throw ServiceErrors.inviteInvalidOrExpired;

    final invite = rows.first;
    final groupId = invite[SupabaseColumns.groupId] as String?;

    if (groupId == null) throw ServiceErrors.invalidGroupInvite;

    final memberCheck = await _supabase
        .from(SupabaseTables.groupMembers)
        .select()
        .eq(SupabaseColumns.groupId, groupId)
        .eq(SupabaseColumns.userId, currentUserId);

    if (memberCheck.isEmpty) {
      await _supabase.rpc(SupabaseRpc.joinGroupAsMember, params: {
        SupabaseColumns.pGroupId: groupId,
      });
    }

    await _supabase.from(SupabaseTables.shareableInvites).update({
      SupabaseColumns.status: InviteStatusValues.used,
    }).eq(SupabaseColumns.token, token);

    return groupId;
  }

  static bool _isKnownWebHost(String host) {
    return host == AppBranding.legacyWebHost ||
        host.endsWith('.${AppBranding.legacyWebHost}') ||
        host == Uri.parse(AppBranding.webBaseUrl).host ||
        host.endsWith('.${Uri.parse(AppBranding.webBaseUrl).host}');
  }

  static bool _isKnownAppScheme(String scheme) {
    return scheme == AppBranding.appScheme ||
        scheme == AppBranding.legacyAppScheme;
  }

  /// Parse invite payloads from deep link URIs (supports splitr and legacy splito).
  static InviteLinkPayload? parseUri(Uri uri) {
    try {
      final isAppScheme = _isKnownAppScheme(uri.scheme);
      final isWebHost = _isKnownWebHost(uri.host);

      if (!isAppScheme && !isWebHost) return null;

      final segments = List<String>.from(uri.pathSegments);

      if (isAppScheme && uri.host == DeepLinkPaths.invite) {
        if (segments.length >= 2 && segments[0] == InviteTypes.friend) {
          return InviteLinkPayload.friend(segments[1]);
        }
      }

      if (isAppScheme &&
          uri.host == DeepLinkPaths.join &&
          segments.isNotEmpty) {
        return InviteLinkPayload.group(segments.first);
      }

      if (segments.length >= 3 &&
          segments[0] == DeepLinkPaths.invite &&
          segments[1] == InviteTypes.friend) {
        return InviteLinkPayload.friend(segments[2]);
      }

      if (segments.length >= 2 && segments[0] == DeepLinkPaths.join) {
        return InviteLinkPayload.group(segments[1]);
      }
    } catch (e, stack) {
      AppErrorReporter.report(
        'InviteLinkService.parseUri failed',
        error: e,
        stack: stack,
        context: {'feature': 'invites', 'operation': 'parseUri'},
      );
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
