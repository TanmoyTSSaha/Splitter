import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Model/financial_goal_model.dart';
import 'package:splitter/Model/group_model.dart';
import 'package:splitter/Screen/GoalScreen/goal_details_screen.dart';
import 'package:splitter/Screen/GroupScreen/group_detailed_screen.dart';
import 'package:splitter/Screen/GroupScreen/group_screen.dart';
import 'package:splitter/Screen/HomeScreen/all_transactions_screen.dart';
import 'package:splitter/Services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Deep links from insight action cards.
class InsightsNavigation {
  static final _supabase = Supabase.instance.client;
  static final _userId = SupabaseAuth().supabaseGetUserID();

  static Future<void> handleAction(Map<String, dynamic> action) async {
    final type = action['action_type'] as String? ?? '';

    switch (type) {
      case 'settle_up':
        await _openSettleUp(
          groupId: action['group_id'] as String?,
          groupName: action['group_name'] as String?,
        );
        break;
      case 'review_category':
        Get.to(() => const AllTransactionsScreen());
        break;
      case 'view_goal':
        final goal = action['goal'];
        if (goal is FinancialGoalModel) {
          Get.to(() => const GoalDetailsScreen(), arguments: goal);
        }
        break;
      case 'view_expense':
        Get.to(() => const AllTransactionsScreen());
        break;
      default:
        Get.snackbar(
          'Insights',
          action['reason'] as String? ?? 'No action available',
          snackPosition: SnackPosition.BOTTOM,
        );
    }
  }

  static Future<void> _openSettleUp({
    String? groupId,
    String? groupName,
  }) async {
    if (groupId == null || groupId.isEmpty) {
      Get.to(() => const GroupScreen());
      return;
    }

    try {
      final row = await _supabase
          .from('groups')
          .select()
          .eq('group_id', groupId)
          .maybeSingle();

      if (row == null) {
        Get.to(() => const GroupScreen());
        return;
      }

      final tripRow = await _supabase
          .from('trip_metadata')
          .select('group_id')
          .eq('group_id', groupId)
          .maybeSingle();

      final balances = <Map<String, dynamic>>[];
      if (row['group_balance'] != null) {
        for (final elm in row['group_balance'] as List<dynamic>) {
          balances.add({
            'donor': elm['donor'],
            'donor_id': elm['donor_id'],
            'receiver': elm['receiver'],
            'receiver_id': elm['receiver_id'],
            'amount': double.tryParse(elm['amount'].toString()) ?? 0,
          });
        }
      }
      row['group_balance'] = balances;
      row['is_trip'] = tripRow != null;

      final group = GroupModel.fromJSON(row);
      Get.to(() => GroupDetailedScreen(
            groupModel: group,
            userID: _userId,
          ));
    } catch (e) {
      debugPrint('insights settle_up nav: $e');
      Get.to(() => const GroupScreen());
    }
  }
}
