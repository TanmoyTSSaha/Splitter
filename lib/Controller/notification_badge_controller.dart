import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitter/Model/group_invite_model.dart';
import 'package:splitter/Model/loan_model.dart';
import 'package:splitter/Services/SupabaseServices/group_service.dart';
import 'package:splitter/Services/supabase_service.dart';

/// Tracks whether the bell icon should show an unseen-notification dot.
class NotificationBadgeController extends GetxController {
  static const _prefsKey = 'notifications_last_viewed_at';

  final hasUnseen = false.obs;

  DateTime? _lastViewedAt;
  final GroupService _groupService = GroupService();

  @override
  void onInit() {
    super.onInit();
    updateBadge();
  }

  Future<void> _loadLastViewed() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    _lastViewedAt = stored != null ? DateTime.tryParse(stored) : null;
  }

  /// Call when the user opens the notification screen.
  Future<void> markViewed() async {
    _lastViewedAt = DateTime.now();
    hasUnseen.value = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _lastViewedAt!.toIso8601String());
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
      final results = await Future.wait([
        _groupService.getPendingInvites(userID: userId),
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
    } catch (_) {
      // Keep previous badge state on transient errors.
    }
  }
}
