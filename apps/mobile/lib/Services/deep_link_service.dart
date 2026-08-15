import 'dart:async';
import 'package:splitr/Widgets/splitr_toast.dart';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Controller/group_screen_controller.dart';
import 'package:splitr/Screen/AuthScreens/login_screen.dart';
import 'package:splitr/Screen/FriendScreen/friends_screen.dart';
import 'package:splitr/Screen/GroupScreen/group_detailed_screen.dart';
import 'package:splitr/Services/auth_recovery_coordinator.dart';
import 'package:splitr/Services/auth_flow_coordinator.dart';
import 'package:splitr/Services/google_auth_errors.dart';
import 'package:splitr/Services/invite_link_service.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Listens for app / universal links and routes invite flows.
class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  final InviteLinkService _inviteLinks = InviteLinkService();
  StreamSubscription<Uri>? _sub;
  bool _handling = false;
  bool _initialized = false;
  bool _navigationReady = false;
  final List<Uri> _pendingUris = [];
  final List<VoidCallback> _pendingNavigation = [];

  /// Call after [GetMaterialApp] mounts so [Get.offAll]/[Get.to] are safe.
  void markNavigationReady() {
    if (_navigationReady) return;
    _navigationReady = true;
    final pending = List<VoidCallback>.from(_pendingNavigation);
    _pendingNavigation.clear();
    for (final action in pending) {
      action();
    }
  }

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

    _initialized = true;
    await _drainPendingUris();
  }

  Future<void> _drainPendingUris() async {
    if (_pendingUris.isEmpty) return;
    final queued = List<Uri>.from(_pendingUris);
    _pendingUris.clear();
    for (final uri in queued) {
      await _handleUri(uri, fromQueue: true);
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

  static bool isAuthCallbackUri(Uri uri) {
    final normalized = _normalizeAuthUri(uri);
    if (normalized.scheme == AppBranding.appScheme &&
        normalized.host == DeepLinkPaths.loginCallback) {
      return true;
    }
    if (normalized.scheme == 'https' && _isSplitrWebHost(normalized.host)) {
      final path = normalized.path;
      return path == DeepLinkPaths.authCallback ||
          path == '${DeepLinkPaths.authCallback}/';
    }
    return false;
  }

  static bool isRecoveryUri(Uri uri) {
    final normalized = _normalizeAuthUri(uri);
    if (normalized.queryParameters[SupabaseAuthQuery.type] ==
        SupabaseAuthQuery.recovery) {
      return true;
    }
    final fragment = normalized.fragment;
    return fragment.contains('${SupabaseAuthQuery.type}=${SupabaseAuthQuery.recovery}');
  }

  @visibleForTesting
  static Map<String, String> authCallbackParams(Uri uri) {
    final normalized = _normalizeAuthUri(uri);
    final params = Map<String, String>.from(normalized.queryParameters);
    if (normalized.fragment.isNotEmpty) {
      params.addAll(Uri.splitQueryString(normalized.fragment));
    }
    return params;
  }

  @visibleForTesting
  static bool isAuthCallbackFailure(Map<String, String> params) {
    final errorCode = params['error_code'] ?? '';
    final error = params['error'] ?? '';
    return errorCode == 'otp_expired' || error == 'access_denied';
  }

  @visibleForTesting
  static bool hasAuthSessionPayload(Map<String, String> params) {
    return params.containsKey('access_token') ||
        params.containsKey('refresh_token') ||
        params.containsKey('code');
  }

  static Uri _normalizeAuthUri(Uri uri) {
    if (uri.scheme != AppBranding.appScheme) return uri;
    if (uri.host.isNotEmpty) return uri;
    final segments = uri.pathSegments;
    if (segments.isNotEmpty && segments.first == DeepLinkPaths.loginCallback) {
      return uri.replace(host: DeepLinkPaths.loginCallback, path: '');
    }
    return uri;
  }

  static bool _isSplitrWebHost(String host) {
    return host == AppBranding.webHost || host == 'www.${AppBranding.webHost}';
  }

  void _runWhenNavigationReady(VoidCallback action) {
    if (_navigationReady && Get.key.currentContext != null) {
      action();
      return;
    }
    _pendingNavigation.add(action);
  }

  void _routeToLogin({required String message}) {
    _runWhenNavigationReady(() {
      SplitrToast.show(message);
      Get.offAll(() => const LoginScreen());
    });
  }

  void _routeToHome({String loginMethod = LoginMethods.email}) {
    _runWhenNavigationReady(() {
      unawaited(AuthFlowCoordinator.completeSignIn(loginMethod: loginMethod));
    });
  }

  Future<void> _handleUri(Uri uri, {bool fromQueue = false}) async {
    if (!_initialized) {
      _pendingUris.add(uri);
      return;
    }
    if (_handling) return;

    if (isAuthCallbackUri(uri)) {
      final normalized = _normalizeAuthUri(uri);
      final params = authCallbackParams(normalized);

      if (isAuthCallbackFailure(params) && !hasAuthSessionPayload(params)) {
        _routeToLogin(
          message: AppStrings.services.deepLink.emailLinkExpired,
        );
        return;
      }

      try {
        await Supabase.instance.client.auth.getSessionFromUrl(normalized);
        if (isRecoveryUri(normalized)) {
          _runWhenNavigationReady(AuthRecoveryCoordinator.routeToResetPassword);
          return;
        }
        final user = Supabase.instance.client.auth.currentUser;
        final loginMethod = GoogleAuthErrors.isGoogleOAuthCallback(params) ||
                GoogleAuthErrors.userSignedInWithGoogle(user)
            ? LoginMethods.google
            : LoginMethods.email;
        _routeToHome(loginMethod: loginMethod);
        await processPendingInvite();
      } on AuthException catch (e) {
        if (AppErrorReporter.isOtpExpiredAuthError(e)) {
          _routeToLogin(
            message: AppStrings.services.deepLink.emailLinkExpired,
          );
          return;
        }
        _routeToLogin(
          message: AppStrings.services.deepLink.googleSignInIncomplete,
        );
      } catch (e) {
        _routeToLogin(
          message: AppStrings.services.deepLink.googleSignInIncomplete,
        );
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
          _runWhenNavigationReady(() => Get.to(() => const FriendsScreen()));
          break;
        case InviteLinkType.group:
          final groupId = await _inviteLinks.acceptGroupInvite(payload.id);
          final userId = SupabaseAuth().supabaseGetUserIDOrNull();
          if (userId == null) {
            await _savePendingUri(uri);
            SplitrToast.show(AppStrings.services.deepLink.signInToAccept);
            return;
          }
          GroupScreenController.refreshFromAnywhere();
          final groups = await SupabaseDatabase().getGroupData(userID: userId);
          final group = groups.firstWhere((g) => g.groupID == groupId);
          _runWhenNavigationReady(
            () => Get.to(
              () => GroupDetailedScreen(
                groupModel: group,
                userID: userId,
              ),
            ),
          );
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

  @visibleForTesting
  int get pendingUriCountForTest => _pendingUris.length;

  @visibleForTesting
  void enqueueUriForTest(Uri uri) {
    if (!_initialized) {
      _pendingUris.add(uri);
    }
  }
}
