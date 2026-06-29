import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Controller/group_screen_controller.dart';
import 'package:splitter/Screen/FriendScreen/friends_screen.dart';
import 'package:splitter/Screen/GroupScreen/group_detailed_screen.dart';
import 'package:splitter/Services/invite_link_service.dart';
import 'package:splitter/Services/supabase_service.dart';

/// Listens for app / universal links and routes invite flows.
class DeepLinkService {
  static const _pendingUriKey = 'pending_deep_link_uri';

  final AppLinks _appLinks = AppLinks();
  final InviteLinkService _inviteLinks = InviteLinkService();
  StreamSubscription<Uri>? _sub;
  bool _handling = false;

  Future<void> initialize() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        await _handleUri(initial);
      }
    } catch (e) {
      debugPrint('DeepLinkService initial link: $e');
    }

    _sub = _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri);
    });

    if (SupabaseAuth().supabaseRetrieveSession()) {
      await processPendingInvite();
    }
  }

  Future<void> _savePendingUri(Uri uri) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingUriKey, uri.toString());
  }

  Future<Uri?> _loadPendingUri() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingUriKey);
    if (raw == null) return null;
    return Uri.tryParse(raw);
  }

  Future<void> _clearPendingUri() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingUriKey);
  }

  /// Call after login / register so queued invites are applied.
  Future<void> processPendingInvite() async {
    final pending = await _loadPendingUri();
    if (pending == null) return;
    await _clearPendingUri();
    await _handleUri(pending, fromQueue: true);
  }

  Future<void> _handleUri(Uri uri, {bool fromQueue = false}) async {
    if (_handling) return;
    final payload = InviteLinkService.parseUri(uri);
    if (payload == null) return;

    if (!SupabaseAuth().supabaseRetrieveSession()) {
      await _savePendingUri(uri);
      Fluttertoast.showToast(
        msg: fromQueue
            ? 'Sign in to accept this invite'
            : 'Sign in to accept this invite — we\'ll open it after login',
        backgroundColor: neopopYellow,
        textColor: neopopBackground,
      );
      return;
    }

    _handling = true;
    try {
      switch (payload.type) {
        case InviteLinkType.friend:
          await _inviteLinks.acceptFriendInvite(payload.id);
          Fluttertoast.showToast(
            msg: 'Friend request sent!',
            backgroundColor: neopopAccent,
            textColor: neopopBackground,
          );
          Get.to(() => const FriendsScreen());
          break;
        case InviteLinkType.group:
          final groupId = await _inviteLinks.acceptGroupInvite(payload.id);
          GroupScreenController.refreshFromAnywhere();
          final groups = await SupabaseDatabase().getGroupData(
            userID: SupabaseAuth().supabaseGetUserID(),
          );
          final group = groups.firstWhere((g) => g.groupID == groupId);
          Get.to(() => GroupDetailedScreen(
                groupModel: group,
                userID: SupabaseAuth().supabaseGetUserID(),
              ));
          Fluttertoast.showToast(
            msg: 'Joined group!',
            backgroundColor: neopopAccent,
            textColor: neopopBackground,
          );
          break;
      }
    } catch (e) {
      debugPrint('DeepLinkService handle error: $e');
      Fluttertoast.showToast(
        msg: 'Could not process invite: $e',
        backgroundColor: neopopYellow,
        textColor: neopopBackground,
      );
    } finally {
      _handling = false;
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}

