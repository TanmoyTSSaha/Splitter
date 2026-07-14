import 'dart:async';
import 'package:splitr/Widgets/splitr_toast.dart';

import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Screen/AuthScreens/reset_password_screen.dart';
import 'package:splitr/Controller/group_screen_controller.dart';
import 'package:splitr/Screen/BottomNavigationController/bottom_navigation_controller.dart';
import 'package:splitr/Screen/FriendScreen/friends_screen.dart';
import 'package:splitr/Screen/GroupScreen/group_detailed_screen.dart';
import 'package:splitr/Services/invite_link_service.dart';
import 'package:splitr/Services/local/database.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Listens for app / universal links and routes invite flows.
class DeepLinkService {
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
    } catch (e, stack) {
      AppErrorReporter.report(
        'DeepLinkService.initialize initial link failed',
        error: e,
        stack: stack,
        context: {'feature': 'deep_links', 'operation': 'getInitialLink'},
      );
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
    await prefs.setString(PrefKeys.pendingDeepLinkUri, uri.toString());
  }

  Future<Uri?> _loadPendingUri() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(PrefKeys.pendingDeepLinkUri);
    if (raw == null) return null;
    return Uri.tryParse(raw);
  }

  Future<void> _clearPendingUri() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PrefKeys.pendingDeepLinkUri);
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

    final isAuthCallback = (uri.scheme == AppBranding.appScheme ||
            uri.scheme == SupabaseAuthSchemes.flutterQuickstart) &&
        uri.host == DeepLinkPaths.loginCallback;

    if (isAuthCallback) {
      try {
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
        final type = uri.queryParameters[SupabaseAuthQuery.type];
        if (type == SupabaseAuthQuery.recovery) {
          Get.offAll(() => const ResetPasswordScreen());
          return;
        }
        if (Get.isRegistered<AppDatabase>()) {
          await Get.find<AppDatabase>().clearAllUserData();
        }
        Get.offAll(() => const BottomNavigationController());
        await processPendingInvite();
      } catch (e) {
        SplitrToast.show(AppStrings.services.deepLink.googleSignInIncomplete);
      }
      return;
    }

    final payload = InviteLinkService.parseUri(uri);
    if (payload == null) return;

    if (!SupabaseAuth().supabaseRetrieveSession()) {
      await _savePendingUri(uri);
      SplitrToast.show(fromQueue
            ? AppStrings.services.deepLink.signInToAccept
            : AppStrings.services.deepLink.signInQueued);
      return;
    }

    _handling = true;
    try {
      switch (payload.type) {
        case InviteLinkType.friend:
          await _inviteLinks.acceptFriendInvite(payload.id);
          SplitrToast.show(AppStrings.services.deepLink.friendRequestSent);
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
          SplitrToast.show(AppStrings.services.deepLink.joinedGroup);
          break;
      }
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        'DeepLinkService.handleUri failed',
        error: e,
        stack: stack,
        context: {'feature': 'deep_links', 'operation': 'handleUri'},
      );
    } finally {
      _handling = false;
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}
