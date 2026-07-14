import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Model/group_invite_model.dart';
import 'package:splitr/Model/loan_model.dart';
import 'package:splitr/Services/SupabaseServices/group_service.dart';
import 'package:splitr/Services/SupabaseServices/notification_service.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

/// Tracks whether the bell icon should show an unseen-notification dot.
class NotificationBadgeController extends GetxController {
  final bool _forTest;

  NotificationBadgeController({@visibleForTesting bool forTest = false})
      : _forTest = forTest;

  final hasUnseen = false.obs;

  DateTime? _lastViewedAt;
  GroupService? _groupService;

  @override
  void onInit() {
    super.onInit();
    if (_forTest) return;
    updateBadge();
  }

  @visibleForTesting
  void seedUnseenForTest(bool value) {
    hasUnseen.value = value;
  }

  Future<void> _loadLastViewed() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(PrefKeys.notificationsLastViewedAt);
    _lastViewedAt = stored != null ? DateTime.tryParse(stored) : null;
  }

  /// Call when the user opens the notification screen.
  Future<void> markViewed() async {
    _lastViewedAt = DateTime.now();
    hasUnseen.value = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      PrefKeys.notificationsLastViewedAt,
      _lastViewedAt!.toIso8601String(),
    );
  }

  /// Re-check pending invites and loan requests against last viewed time.
  Future<void> updateBadge() async {
    final userId = SupabaseAuth().supabaseGetUserID();
    if (userId.isEmpty) {
      hasUnseen.value = false;
      return;
    }

    await _loadLastViewed();

    try {
      final unread =
          await NotificationService().getUnreadCount(userID: userId);
      if (unread > 0) {
        hasUnseen.value = true;
        return;
      }

      final groupService = _groupService ??= GroupService();
      final results = await Future.wait([
        groupService.getPendingInvites(userID: userId),
        SupabaseDatabase().getPendingLoansAwaitingAction(userID: userId),
      ]);

      final invites = results[0] as List<GroupInviteModel>;
      final loans = results[1] as List<LoanModel>;

      if (invites.isEmpty && loans.isEmpty) {
        hasUnseen.value = false;
        return;
      }

      if (_lastViewedAt == null) {
        hasUnseen.value = true;
        return;
      }

      for (final invite in invites) {
        if (invite.createdAt.isAfter(_lastViewedAt!)) {
          hasUnseen.value = true;
          return;
        }
      }

      for (final loan in loans) {
        final createdAt = loan.createdAt ?? loan.startDate;
        if (createdAt.isAfter(_lastViewedAt!)) {
          hasUnseen.value = true;
          return;
        }
      }

      hasUnseen.value = false;
    } catch (e, stack) {
      AppErrorReporter.report(
        'NotificationBadgeController.updateBadge failed',
        error: e,
        stack: stack,
        context: {'feature': 'notifications', 'operation': 'updateBadge'},
        showToastOnUserFacing: false,
      );
    }
  }
}
