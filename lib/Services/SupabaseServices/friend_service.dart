import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/Model/friend_model.dart';
import 'package:splitr/Services/SupabaseServices/group_service.dart';

class FriendService {
  final supabase = Supabase.instance.client;
  final GroupService _groupService = GroupService();

  /// Fetches all friend relationships for a user (both as sender and receiver).
  /// Returns both pending and accepted friends.
  Future<List<FriendModel>> getFriends({required String userID}) async {
    try {
      // Fetch where user is the sender
      final sentResponse = await supabase
          .from(SupabaseTables.friends)
          .select()
          .eq('user_id', userID);

      // Fetch where user is the receiver
      final receivedResponse = await supabase
          .from(SupabaseTables.friends)
          .select()
          .eq('friend_id', userID);

      List<FriendModel> friends = [];

      // Process sent requests — friend details are in friend_id
      Set<String> friendUserIDs = {};
      for (var row in sentResponse) {
        friendUserIDs.add(row['friend_id'].toString());
      }
      for (var row in receivedResponse) {
        friendUserIDs.add(row['user_id'].toString());
      }

      // Batch fetch user details
      Map<String, Map<String, dynamic>> userDetailsMap = {};
      if (friendUserIDs.isNotEmpty) {
        final usersData = await supabase
            .from(SupabaseTables.users)
            .select('user_id, user_name, user_email, profile_picture_url')
            .inFilter('user_id', friendUserIDs.toList());
        for (var u in usersData) {
          userDetailsMap[u['user_id'].toString()] = u;
        }
      }

      // Build models for sent requests
      for (var row in sentResponse) {
        String fid = row['friend_id'].toString();
        var details = userDetailsMap[fid];
        friends.add(FriendModel(
          id: row['id']?.toString(),
          userID: row['user_id']?.toString(),
          friendUserID: fid,
          tableFriendId: row['friend_id']?.toString(),
          friendName: details?['user_name']?.toString(),
          friendEmail: details?['user_email']?.toString(),
          friendPic: details?['profile_picture_url']?.toString(),
          status: row['status']?.toString(),
          createdAt: row['created_at'] != null
              ? DateTime.tryParse(row['created_at'].toString())
              : null,
        ));
      }

      // Build models for received requests
      for (var row in receivedResponse) {
        String uid = row['user_id'].toString();
        var details = userDetailsMap[uid];
        friends.add(FriendModel(
          id: row['id']?.toString(),
          userID: row['user_id']?.toString(),
          friendUserID: uid,
          tableFriendId: row['friend_id']?.toString(),
          friendName: details?['user_name']?.toString(),
          friendEmail: details?['user_email']?.toString(),
          friendPic: details?['profile_picture_url']?.toString(),
          status: row['status']?.toString(),
          createdAt: row['created_at'] != null
              ? DateTime.tryParse(row['created_at'].toString())
              : null,
        ));
      }

      return friends;
    } catch (e, stack) {
      AppErrorReporter.report(
        'FriendService.getFriends failed',
        error: e,
        stack: stack,
        context: {'feature': 'friends', 'operation': 'getFriends'},
      );
      return [];
    }
  }

  /// Sends a friend request. Returns true when a new pending request was created.
  Future<bool> sendFriendRequest({
    required String fromUserID,
    required String toUserID,
  }) async {
    try {
      final existing = await supabase.from(SupabaseTables.friends).select().or(
            'and(${SupabaseColumns.userId}.eq.$fromUserID,${SupabaseColumns.friendId}.eq.$toUserID),'
            'and(${SupabaseColumns.userId}.eq.$toUserID,${SupabaseColumns.friendId}.eq.$fromUserID)',
          );

      for (final row in existing) {
        final status = row[SupabaseColumns.status]?.toString();
        final rowUserId = row[SupabaseColumns.userId]?.toString();
        final rowFriendId = row[SupabaseColumns.friendId]?.toString();

        if (status == FriendStatusValues.accepted) {
          return false;
        }
        if (status == FriendStatusValues.pending) {
          if (rowUserId == fromUserID && rowFriendId == toUserID) {
            return false;
          }
          if (rowUserId == toUserID && rowFriendId == fromUserID) {
            await acceptFriendRequest(
              requestID: row[SupabaseColumns.id].toString(),
            );
            return false;
          }
        }
      }

      await supabase.from(SupabaseTables.friends).insert({
        'user_id': fromUserID,
        'friend_id': toUserID,
        'status': FriendStatusValues.pending,
      });
      return true;
    } catch (e, stack) {
      AppErrorReporter.report(
        'FriendService.sendFriendRequest failed',
        error: e,
        stack: stack,
        context: {'feature': 'friends', 'operation': 'sendFriendRequest'},
      );
      rethrow;
    }
  }

  /// Accepts a friend request by its row ID.
  Future<void> acceptFriendRequest({required String requestID}) async {
    try {
      final rows = await supabase
          .from(SupabaseTables.friends)
          .select()
          .eq(SupabaseColumns.id, requestID)
          .limit(1);
      if (rows.isEmpty) return;

      final row = rows.first;
      final senderId = row[SupabaseColumns.userId]?.toString();
      final receiverId = row[SupabaseColumns.friendId]?.toString();
      if (senderId == null || receiverId == null) return;

      final oppositeRows = await supabase
          .from(SupabaseTables.friends)
          .select()
          .eq(SupabaseColumns.userId, receiverId)
          .eq(SupabaseColumns.friendId, senderId)
          .limit(1);

      if (oppositeRows.isNotEmpty &&
          oppositeRows.first[SupabaseColumns.status] ==
              FriendStatusValues.accepted) {
        await supabase
            .from(SupabaseTables.friends)
            .delete()
            .eq(SupabaseColumns.id, requestID)
            .eq(SupabaseColumns.status, FriendStatusValues.pending);
        return;
      }

      await supabase
          .from(SupabaseTables.friends)
          .update({SupabaseColumns.status: FriendStatusValues.accepted})
          .eq(SupabaseColumns.id, requestID);

      await supabase
          .from(SupabaseTables.friends)
          .delete()
          .eq(SupabaseColumns.userId, receiverId)
          .eq(SupabaseColumns.friendId, senderId)
          .eq(SupabaseColumns.status, FriendStatusValues.pending)
          .neq(SupabaseColumns.id, requestID);
    } catch (e, stack) {
      AppErrorReporter.report(
        'FriendService.acceptFriendRequest failed',
        error: e,
        stack: stack,
        context: {'feature': 'friends', 'operation': 'acceptFriendRequest'},
      );
      rethrow;
    }
  }

  /// Cancels a pending friend request sent by [fromUserID].
  Future<void> cancelFriendRequest({
    required String requestID,
    required String fromUserID,
  }) async {
    try {
      await supabase
          .from(SupabaseTables.friends)
          .delete()
          .eq('id', requestID)
          .eq('user_id', fromUserID)
          .eq(SupabaseColumns.status, FriendStatusValues.pending);
    } catch (e, stack) {
      AppErrorReporter.report(
        'FriendService.cancelFriendRequest failed',
        error: e,
        stack: stack,
        context: {'feature': 'friends', 'operation': 'cancelFriendRequest'},
      );
      rethrow;
    }
  }

  /// Computes per-friend balances across all shared groups.
  Future<List<FriendBalanceModel>> getFriendBalances({
    required String userID,
    required List<FriendModel> friends,
  }) async {
    try {
      if (friends.isEmpty) return [];

      // Fetch all groups for the current user
      final groups = await _groupService.getGroupData(userID: userID);

      List<FriendBalanceModel> balances = [];

      for (var friend in friends) {
        if (friend.friendUserID == null) continue;

        double totalOwed = 0.0; // They owe me
        double totalOwing = 0.0; // I owe them
        List<GroupBalanceBreakdown> groupBreakdowns = [];

        for (var group in groups) {
          if (group.groupBalance == null) continue;

          for (var balance in group.groupBalance!) {
            // Case 1: friend is donor (owes receiver)
            // If friend is donor and I am receiver → they owe me
            if (balance.donorID == friend.friendUserID &&
                balance.receiverID == userID) {
              totalOwed += balance.amount ?? 0.0;
              groupBreakdowns.add(GroupBalanceBreakdown(
                groupName: group.groupName ?? DisplayFallbacks.unknown,
                groupID: group.groupID ?? '',
                amount: balance.amount ?? 0.0, // Positive: they owe me
              ));
            }
            // Case 2: I am donor (I owe friend)
            if (balance.donorID == userID &&
                balance.receiverID == friend.friendUserID) {
              totalOwing += balance.amount ?? 0.0;
              groupBreakdowns.add(GroupBalanceBreakdown(
                groupName: group.groupName ?? DisplayFallbacks.unknown,
                groupID: group.groupID ?? '',
                amount: -(balance.amount ?? 0.0), // Negative: I owe them
              ));
            }
          }
        }

        double netBalance = totalOwed - totalOwing;

        balances.add(FriendBalanceModel(
          friendUserID: friend.friendUserID,
          friendName: friend.friendName,
          friendEmail: friend.friendEmail,
          friendPic: friend.friendPic,
          totalOwed: totalOwed,
          totalOwing: totalOwing,
          netBalance: double.parse(netBalance.toStringAsFixed(2)),
          groupBreakdown: groupBreakdowns,
        ));
      }

      return balances;
    } catch (e, stack) {
      AppErrorReporter.report(
        'FriendService.getFriendBalances failed',
        error: e,
        stack: stack,
        context: {'feature': 'friends', 'operation': 'getFriendBalances'},
      );
      return [];
    }
  }
}
