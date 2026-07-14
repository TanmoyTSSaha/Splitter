import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Utils/currency_utils.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:splitr/Model/activity_model.dart';
import 'package:splitr/Model/group_model.dart';
import 'package:splitr/Services/supabase_service.dart';

class ActivityService {
  final supabase = Supabase.instance.client;

  /// Fetches activities for a given group with pagination.
  Future<List<ActivityItem>> getGroupActivities(String groupId,
      {int limit = 20, int offset = 0}) async {
    try {
      // Fetch transactions
      final transactions = await SupabaseDatabase().getGroupTransactionsData(
          userID: SupabaseAuth().supabaseGetUserID(), groupID: groupId);

      // Group transactions by transactionGroupID
      final Map<String, List<GroupTransactionModel>> groupedTransactions = {};
      for (var t in transactions) {
        if (t.transactionGroupID != null) {
          if (!groupedTransactions.containsKey(t.transactionGroupID)) {
            groupedTransactions[t.transactionGroupID!] = [];
          }
          groupedTransactions[t.transactionGroupID!]!.add(t);
        }
      }

      final String currentUserId = SupabaseAuth().supabaseGetUserID();
      final List<ActivityItem> transactionActivities = [];

      // Collect all activity IDs to fetch reactions in one go
      List<String> activityIds = [];

      groupedTransactions.forEach((key, groupTrns) {
        if (groupTrns.isEmpty) return;
        final first = groupTrns.first;
        if (first.transactionID != null) {
          activityIds.add(first.transactionID!);
        }
      });

      // Fetch reactions for these activities
      Map<String, List<Reaction>> reactionsMap = {};
      if (activityIds.isNotEmpty) {
        final reactionsData = await supabase
            .from(SupabaseTables.activityReactions)
            .select()
            .inFilter('activity_id', activityIds);

        for (var r in reactionsData) {
          final reaction = Reaction.fromJSON(r);
          final activityId = r['activity_id'] as String;
          if (!reactionsMap.containsKey(activityId)) {
            reactionsMap[activityId] = [];
          }
          reactionsMap[activityId]!.add(reaction);
        }
      }

      Map<String, int> commentCounts = {};
      if (activityIds.isNotEmpty) {
        try {
          final commentRows = await supabase
              .from(SupabaseTables.activityComments)
              .select('activity_id')
              .inFilter('activity_id', activityIds);
          for (final row in commentRows) {
            final aid = row['activity_id'] as String;
            commentCounts[aid] = (commentCounts[aid] ?? 0) + 1;
          }
        } catch (e, stack) {
          AppErrorReporter.report(
            'ActivityService comment count fetch failed',
            error: e,
            stack: stack,
            context: {'feature': 'activity', 'operation': 'commentCountFetch'},
          );
        }
      }

      groupedTransactions.forEach((key, groupTrns) {
        if (groupTrns.isEmpty) return;

        // Use the first transaction for common details (payer, date, description)
        final first = groupTrns.first;
        final payerId = first.paidByUUID ?? "";
        final isPayer = payerId == currentUserId;
        final isSettlement = first.sharingType == SharingTypeValues.settlement;

        String splitSummary = "";

        if (isSettlement) {
          splitSummary = isPayer
              ? "You paid ${first.sharedWithName} ${userCurrencySymbol()}${first.sharedTransactionAmount?.toStringAsFixed(2)}"
              : "${first.paidByName} paid you ${userCurrencySymbol()}${first.sharedTransactionAmount?.toStringAsFixed(2)}";
        } else {
          // Expense
          if (isPayer) {
            List<String> debtors = [];
            double totalOwedToMe = 0;

            for (var t in groupTrns) {
              if (t.sharedWithUUID != currentUserId) {
                debtors.add(
                    "${t.sharedWithName?.split(' ')[0]} owes ${userCurrencySymbol()}${t.sharedTransactionAmount?.toStringAsFixed(0)}");
                totalOwedToMe += t.sharedTransactionAmount ?? 0;
              }
            }

            if (debtors.isEmpty) {
              splitSummary = "You paid for yourself";
            } else if (debtors.length <= 2) {
              splitSummary = debtors.join(", ");
            } else {
              splitSummary =
                  "You get ${userCurrencySymbol()}${totalOwedToMe.toStringAsFixed(0)} from ${debtors.length} people";
            }
          } else {
            // Someone else paid.
            GroupTransactionModel? myShareRow;
            try {
              myShareRow = groupTrns
                  .firstWhere((t) => t.sharedWithUUID == currentUserId);
            } catch (e) {
              myShareRow = null;
            }

            if (myShareRow != null) {
              splitSummary =
                  "You owe ${userCurrencySymbol()}${myShareRow.sharedTransactionAmount?.toStringAsFixed(0)}";
            } else {
              splitSummary = "You are not involved";
            }
          }
        }

        final activityId = first.transactionID ?? "";

        transactionActivities.add(ActivityItem(
          id: activityId,
          groupId: groupId,
          type:
              isSettlement ? ActivityType.settledUp : ActivityType.expenseAdded,
          actorId: payerId,
          actorName: first.paidByName ?? DisplayFallbacks.user,
          description:
              isSettlement ? "settled up" : "added '${first.description}'",
          amount: null,
          timestamp: first.transactionDate ?? DateTime.now(),
          metadata: {MetadataKeys.splitSummary: splitSummary},
          reactions: reactionsMap[activityId] ?? [],
          commentCount: commentCounts[activityId] ?? 0,
        ));
      });

      // Sort by timestamp desc
      transactionActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return transactionActivities;
    } catch (e) {
      // Fallback to empty list or rethrow
      return [];
    }
  }

  /// Adds or removes a reaction to an activity item.
  Future<void> addReaction(
      String activityId, String emoji, String userId) async {
    try {
      // Check if reaction exists
      final existing = await supabase
          .from(SupabaseTables.activityReactions)
          .select()
          .eq('activity_id', activityId)
          .eq('user_id', userId)
          .eq('emoji', emoji)
          .maybeSingle();

      if (existing != null) {
        // Remove it
        await supabase
            .from(SupabaseTables.activityReactions)
            .delete()
            .eq('id', existing['id']);
      } else {
        // Add it
        // Fetch user name for display snapshot
        // We can get it from SupabaseAuth or DB.
        // For now, let's try to get it from current session or DB
        String userName = DisplayFallbacks.user;
        try {
          final userDetails = await supabase
              .from(SupabaseTables.users)
              .select('firstname, lastname')
              .eq('user_id', userId)
              .single();
          userName = "${userDetails['firstname']} ${userDetails['lastname']}";
        } catch (e) {
          // Ignore
        }

        await supabase.from(SupabaseTables.activityReactions).insert({
          'activity_id': activityId,
          'user_id': userId,
          'emoji': emoji,
          'user_name': userName,
        });
      }
    } catch (e, stack) {
      AppErrorReporter.report(
        'ActivityService.addReaction failed',
        error: e,
        stack: stack,
        context: {'feature': 'activity', 'operation': 'addReaction'},
      );
      rethrow;
    }
  }

  Future<List<ActivityComment>> getComments(String activityId) async {
    try {
      final rows = await supabase
          .from(SupabaseTables.activityComments)
          .select()
          .eq('activity_id', activityId)
          .order('created_at', ascending: true);
      return rows
          .map<ActivityComment>(
              (r) => ActivityComment.fromJSON(Map<String, dynamic>.from(r)))
          .toList();
    } catch (e, stack) {
      AppErrorReporter.report(
        'ActivityService.getComments failed',
        error: e,
        stack: stack,
        context: {'feature': 'activity', 'operation': 'getComments'},
      );
      return [];
    }
  }

  Future<void> addComment({
    required String activityId,
    required String groupId,
    required String userId,
    required String body,
  }) async {
    String userName = DisplayFallbacks.user;
    try {
      final userDetails = await supabase
          .from(SupabaseTables.users)
          .select('firstname, lastname, user_name')
          .eq('user_id', userId)
          .single();
      final first = userDetails['firstname'] ?? '';
      final last = userDetails['lastname'] ?? '';
      userName = '$first $last'.trim();
      if (userName.isEmpty) {
        userName = userDetails[SupabaseColumns.userName] as String? ??
            DisplayFallbacks.user;
      }
    } catch (_) {}

    await supabase.from(SupabaseTables.activityComments).insert({
      'activity_id': activityId,
      'group_id': groupId,
      'user_id': userId,
      'user_name': userName,
      'body': body,
    });
  }
}
