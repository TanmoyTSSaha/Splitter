import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:splitter/Model/friend_model.dart';
import 'package:splitter/Services/SupabaseServices/group_service.dart';

class FriendService {
  final supabase = Supabase.instance.client;
  final GroupService _groupService = GroupService();

  /// Fetches all friend relationships for a user (both as sender and receiver).
  /// Returns both pending and accepted friends.
  Future<List<FriendModel>> getFriends({required String userID}) async {
    try {
      // Fetch where user is the sender
      final sentResponse =
          await supabase.from('friends').select().eq('user_id', userID);

      // Fetch where user is the receiver
      final receivedResponse =
          await supabase.from('friends').select().eq('friend_id', userID);

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
            .from('users')
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
    } catch (e) {
      debugPrint('GET FRIENDS EXCEPTION: $e');
      return [];
    }
  }

  /// Sends a friend request.
  Future<void> sendFriendRequest({
    required String fromUserID,
    required String toUserID,
  }) async {
    try {
      await supabase.from('friends').insert({
        'user_id': fromUserID,
        'friend_id': toUserID,
        'status': 'pending',
      });
    } catch (e) {
      debugPrint('SEND FRIEND REQUEST EXCEPTION: $e');
      rethrow;
    }
  }

  /// Accepts a friend request by its row ID.
  Future<void> acceptFriendRequest({required String requestID}) async {
    try {
      await supabase
          .from('friends')
          .update({'status': 'accepted'}).eq('id', requestID);
    } catch (e) {
      debugPrint('ACCEPT FRIEND REQUEST EXCEPTION: $e');
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
          .from('friends')
          .delete()
          .eq('id', requestID)
          .eq('user_id', fromUserID)
          .eq('status', 'pending');
    } catch (e) {
      debugPrint('CANCEL FRIEND REQUEST EXCEPTION: $e');
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
                groupName: group.groupName ?? 'Unknown',
                groupID: group.groupID ?? '',
                amount: balance.amount ?? 0.0, // Positive: they owe me
              ));
            }
            // Case 2: I am donor (I owe friend)
            if (balance.donorID == userID &&
                balance.receiverID == friend.friendUserID) {
              totalOwing += balance.amount ?? 0.0;
              groupBreakdowns.add(GroupBalanceBreakdown(
                groupName: group.groupName ?? 'Unknown',
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
    } catch (e) {
      debugPrint('GET FRIEND BALANCES EXCEPTION: $e');
      return [];
    }
  }
}
