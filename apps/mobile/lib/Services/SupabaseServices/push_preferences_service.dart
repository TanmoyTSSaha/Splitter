import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushPreferences {
  const PushPreferences({
    required this.friendRequest,
    required this.groupInvite,
    required this.expenseAdded,
    required this.settlement,
    required this.settlementReminder,
    required this.loanRequest,
    required this.budgetAlert,
    required this.marketing,
  });

  final bool friendRequest;
  final bool groupInvite;
  final bool expenseAdded;
  final bool settlement;
  final bool settlementReminder;
  final bool loanRequest;
  final bool budgetAlert;
  final bool marketing;

  factory PushPreferences.defaults() => const PushPreferences(
        friendRequest: true,
        groupInvite: true,
        expenseAdded: true,
        settlement: true,
        settlementReminder: true,
        loanRequest: true,
        budgetAlert: true,
        marketing: false,
      );

  factory PushPreferences.fromMap(Map<String, dynamic> map) {
    bool read(String key, bool fallback) => map[key] as bool? ?? fallback;
    return PushPreferences(
      friendRequest: read('friend_request', true),
      groupInvite: read('group_invite', true),
      expenseAdded: read('expense_added', true),
      settlement: read('settlement', true),
      settlementReminder: read('settlement_reminder', true),
      loanRequest: read('loan_request', true),
      budgetAlert: read('budget_alert', true),
      marketing: read('marketing', false),
    );
  }

  Map<String, dynamic> toMap() => {
        'friend_request': friendRequest,
        'group_invite': groupInvite,
        'expense_added': expenseAdded,
        'settlement': settlement,
        'settlement_reminder': settlementReminder,
        'loan_request': loanRequest,
        'budget_alert': budgetAlert,
        'marketing': marketing,
        SupabaseColumns.updatedAt: DateTime.now().toIso8601String(),
      };

  PushPreferences copyWith({
    bool? friendRequest,
    bool? groupInvite,
    bool? expenseAdded,
    bool? settlement,
    bool? settlementReminder,
    bool? loanRequest,
    bool? budgetAlert,
    bool? marketing,
  }) {
    return PushPreferences(
      friendRequest: friendRequest ?? this.friendRequest,
      groupInvite: groupInvite ?? this.groupInvite,
      expenseAdded: expenseAdded ?? this.expenseAdded,
      settlement: settlement ?? this.settlement,
      settlementReminder: settlementReminder ?? this.settlementReminder,
      loanRequest: loanRequest ?? this.loanRequest,
      budgetAlert: budgetAlert ?? this.budgetAlert,
      marketing: marketing ?? this.marketing,
    );
  }

  bool isEnabledForType(String type) {
    switch (type) {
      case NotificationTypes.friendRequest:
        return friendRequest;
      case NotificationTypes.groupInvite:
        return groupInvite;
      case NotificationTypes.expenseAdded:
        return expenseAdded;
      case NotificationTypes.settlement:
      case NotificationTypes.settlementRequest:
        return settlement;
      case NotificationTypes.settlementReminder:
        return settlementReminder;
      case NotificationTypes.loanRequest:
        return loanRequest;
      case NotificationTypes.budgetAlert:
        return budgetAlert;
      case NotificationTypes.general:
        return marketing;
      default:
        return true;
    }
  }
}

class PushPreferencesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<PushPreferences> getPreferences(String userId) async {
    try {
      await _supabase.rpc('ensure_push_preferences', params: {
        'p_user_id': userId,
      });
      final row = await _supabase
          .from(SupabaseTables.pushPreferences)
          .select()
          .eq(SupabaseColumns.userId, userId)
          .maybeSingle();
      if (row == null) return PushPreferences.defaults();
      return PushPreferences.fromMap(row);
    } catch (e, stack) {
      if (!AppErrorReporter.shouldSkipSentry(e)) {
        AppErrorReporter.report(
          'PushPreferencesService.getPreferences failed',
          error: e,
          stack: stack,
          context: {'feature': 'push', 'operation': 'getPreferences'},
          showToastOnUserFacing: false,
        );
      }
      return PushPreferences.defaults();
    }
  }

  Future<void> savePreferences({
    required String userId,
    required PushPreferences prefs,
  }) async {
    try {
      await _supabase.from(SupabaseTables.pushPreferences).upsert({
        SupabaseColumns.userId: userId,
        ...prefs.toMap(),
      });
    } catch (e, stack) {
      AppErrorReporter.report(
        'PushPreferencesService.savePreferences failed',
        error: e,
        stack: stack,
        context: {'feature': 'push', 'operation': 'savePreferences'},
      );
      rethrow;
    }
  }
}
