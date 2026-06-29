import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:splitter/Model/group_model.dart';
import 'package:splitter/Model/group_invite_model.dart';
import 'package:splitter/Services/currency_service.dart';

class GroupService {
  final supabase = Supabase.instance.client;

  Future<void> addMembersToGroup({
    required String groupID,
    required List<String> memberIDs,
  }) async {
    try {
      await supabase.rpc(
        'add_group_members',
        params: {
          'p_group_id': groupID,
          'p_user_ids': memberIDs,
        },
      );
    } catch (e) {
      debugPrint("ADD MEMBER EXCEPTION: $e");
      rethrow;
    }
  }

  Future<List<GroupMembers>> getGroupMembersData(
      {required String userID}) async {
    try {
      final groupMemberData =
          await supabase.from("group_members").select().eq("user_id", userID);

      List<GroupMembers> groupMembersDetails = [];

      for (var element in groupMemberData) {
        groupMembersDetails.add(GroupMembers.fromJSON(element));
      }

      return groupMembersDetails;
    } catch (e) {
      debugPrint("GROUP MEMBER EXCEPTION: $e");
      if (e is PostgrestException) {
        debugPrint("Postgrest Details: ${e.details} Code: ${e.code}");
      }
      List<GroupMembers> groupMembersDetails = [];
      return groupMembersDetails;
    }
  }

  Future<List<GroupModel>> getGroupData({required String userID}) async {
    try {
      List<GroupMembers> groupMembers =
          await getGroupMembersData(userID: userID);

      List<String> groupIDs = [];

      for (var element in groupMembers) {
        groupIDs.add(element.groupID!.toString());
      }

      if (groupIDs.isEmpty) return [];

      // 1. Fetch Groups
      final groupData = await supabase
          .from("groups")
          .select()
          .inFilter('group_id', groupIDs)
          .order('updated_on', ascending: false)
          .order('group_name', ascending: true);

      // 2. Fetch Trip Metadata to identify which groups are actually trips
      final tripData = await supabase
          .from("trip_metadata")
          .select("group_id")
          .inFilter('group_id', groupIDs);

      final Set<String> tripGroupIDs =
          tripData.map<String>((e) => e['group_id'] as String).toSet();

      List<GroupModel> groupModelData = [];

      for (var element in groupData) {
        List<Map<String, dynamic>> groupBalanceList = [];
        if (element["group_balance"] != null) {
          for (var elm in (element["group_balance"] as List<dynamic>)) {
            Map<String, dynamic> groupBalance = {};
            groupBalance["donor"] = elm["donor"];
            groupBalance["donor_id"] = elm["donor_id"];
            groupBalance["receiver"] = elm["receiver"];
            groupBalance["receiver_id"] = elm["receiver_id"];
            groupBalance["amount"] = double.parse(elm["amount"].toString());

            groupBalanceList.add(groupBalance);
          }
        }

        element["group_balance"] = groupBalanceList;
        // Mark as trip if ID exists in trip metadata
        element["is_trip"] = tripGroupIDs.contains(element["group_id"]);

        GroupModel groupModel = GroupModel.fromJSON(element);
        groupModelData.add(groupModel);
      }

      return groupModelData;
    } catch (e) {
      debugPrint("GROUPS EXCEPTION: $e");
      if (e is PostgrestException) {
        debugPrint("Postgrest Details: ${e.details} Code: ${e.code}");
      }
      List<GroupModel> groupModelData = [];
      return groupModelData;
    }
  }

  Future<List<GroupMembersWithNameModel>> getGroupMembers(
      {required String groupID, required String currentUserID}) async {
    // Single query: join group_members with users via foreign key
    final groupMembersRawData =
        await supabase.from("group_members").select().eq("group_id", groupID);

    if (groupMembersRawData.isEmpty) return [];

    // Batch-fetch all user details in one query
    final List<String> userIDs =
        groupMembersRawData.map<String>((e) => e["user_id"] as String).toList();

    final groupMembersNameData = await supabase
        .from("users")
        .select("user_id, firstname, lastname, profile_picture_url")
        .inFilter("user_id", userIDs);

    // Build lookup map for O(1) access instead of O(n²) nested loop
    final Map<String, Map<String, dynamic>> userLookup = {};
    for (var user in groupMembersNameData) {
      userLookup[user["user_id"]] = user;
    }

    List<GroupMembersWithNameModel> grpMbrNmList = [];

    for (var grpElem in groupMembersRawData) {
      final userElem = userLookup[grpElem["user_id"]];
      if (userElem == null) continue;

      GroupMembers groupMembersModel = GroupMembers.fromJSON({
        "group_id": grpElem["group_id"],
        "user_id": grpElem["user_id"],
      });

      final fullName = "${userElem["firstname"]} ${userElem["lastname"]}";
      grpMbrNmList.add(
        GroupMembersWithNameModel.fromVariables(
          groupMembersModel,
          currentUserID == userElem["user_id"] ? "$fullName(you)" : fullName,
          userElem["profile_picture_url"] ?? "",
        ),
      );
    }

    return grpMbrNmList;
  }

  Future<List<Map<String, dynamic>>> getDistinctGroups(
      {required String userID}) async {
    // Fetch group IDs for user
    final memberRows = await supabase
        .from("group_members")
        .select("group_id")
        .eq("user_id", userID);

    if (memberRows.isEmpty) return [];

    // De-duplicate group IDs using Set
    final distinctGroupIDs =
        memberRows.map<String>((e) => e["group_id"] as String).toSet().toList();

    // Single query for group details
    final groupData = await supabase
        .from("groups")
        .select("group_id, group_name")
        .inFilter("group_id", distinctGroupIDs);

    return List<Map<String, dynamic>>.from(groupData);
  }

  /// Fetches the group balance data for settle-up.
  Future<List<GroupBalanceModel>> getGroupBalancesForSettleUp(
      {required String groupID}) async {
    try {
      final groupData = await supabase
          .from("groups")
          .select("group_balance")
          .eq("group_id", groupID)
          .single();

      List<GroupBalanceModel> balances = [];

      if (groupData["group_balance"] != null) {
        for (var elm in (groupData["group_balance"] as List<dynamic>)) {
          Map<String, dynamic> balanceMap = {};
          balanceMap["donor"] = elm["donor"];
          balanceMap["donor_id"] = elm["donor_id"];
          balanceMap["receiver"] = elm["receiver"];
          balanceMap["receiver_id"] = elm["receiver_id"];
          balanceMap["amount"] = double.parse(elm["amount"].toString());

          balances.add(GroupBalanceModel.fromJSON(balanceMap));
        }
      }

      return balances;
    } catch (e) {
      debugPrint("GET GROUP BALANCES EXCEPTION: $e");
      return [];
    }
  }

  /// Records a settlement between two users in a group.
  Future<void> recordSettlement({
    required String groupID,
    required String fromUserID,
    required String toUserID,
    required double amount,
    required String currency,
  }) async {
    try {
      // Step 1: Insert settlement transaction
      final transactionGroupID =
          "${groupID}_${DateTime.now().millisecondsSinceEpoch}";

      final double exchangeRate =
          await CurrencyService().getExchangeRateToInr(currency);

      await supabase.from("group_transaction").insert({
        "transaction_group_id": transactionGroupID,
        "group_id": groupID,
        "paid_by": fromUserID,
        "shared_with": toUserID,
        "total_transaction_amount": amount,
        "shared_transaction_amount": amount,
        "shared_percentage": 100.0,
        "self_share_amount": 0.0,
        "self_share_percentage": 0.0,
        "sharing_type": "settlement",
        "category": "Settlement",
        "description": "Settlement payment",
        "currency": currency,
        "exchange_rate_to_inr": exchangeRate,
        "is_settled_up": true,
        "transaction_date": DateTime.now().toIso8601String(),
      });

      // Step 2: Update group_balance JSONB
      // Fetch current balances
      final groupData = await supabase
          .from("groups")
          .select("group_balance")
          .eq("group_id", groupID)
          .single();

      List<Map<String, dynamic>> updatedBalances = [];

      if (groupData["group_balance"] != null) {
        for (var elm in (groupData["group_balance"] as List<dynamic>)) {
          String donorID = elm["donor_id"].toString();
          String receiverID = elm["receiver_id"].toString();
          double existingAmount = double.parse(elm["amount"].toString());

          // Check if this is the balance entry being settled
          // When settling, the PAYER (fromUserID) is paying off their debt.
          // So PAYER is the RECEIVER (Debtor) in the balance entry.
          // And PAYEE (toUserID) is the DONOR (Creditor).
          if (donorID == toUserID && receiverID == fromUserID) {
            double remaining = existingAmount - amount;
            if (remaining > 0.01) {
              // Reduce the amount
              updatedBalances.add({
                "donor": elm["donor"],
                "donor_id": donorID,
                "receiver": elm["receiver"],
                "receiver_id": receiverID,
                "amount": double.parse(remaining.toStringAsFixed(2)),
              });
            }
            // If remaining <= 0.01, skip this entry (debt fully settled)
          } else {
            // Keep other balance entries unchanged
            updatedBalances.add({
              "donor": elm["donor"],
              "donor_id": donorID,
              "receiver": elm["receiver"],
              "receiver_id": receiverID,
              "amount": existingAmount,
            });
          }
        }
      }

      // Write updated balances back
      await supabase.from("groups").update({
        "group_balance": updatedBalances,
        "updated_on": DateTime.now().toIso8601String(),
      }).eq("group_id", groupID);
    } catch (e) {
      debugPrint("RECORD SETTLEMENT EXCEPTION: $e");
      rethrow;
    }
  }
  // ---------------------------------------------------------------------------
  // INVITE FLOW
  // ---------------------------------------------------------------------------

  /// Sends a group invite to a specific user.
  Future<void> sendGroupInvite({
    required String groupID,
    required String invitedUserID,
  }) async {
    try {
      final currentUserID = supabase.auth.currentUser!.id;

      // Check if already member
      final memberCheck = await supabase
          .from('group_members')
          .select()
          .eq('group_id', groupID)
          .eq('user_id', invitedUserID);

      if (memberCheck.isNotEmpty) {
        throw "User is already a member of this group.";
      }

      // Check if invite already exists (pending)
      final existingInvite = await supabase
          .from('group_invites')
          .select()
          .eq('group_id', groupID)
          .eq('invited_user_id', invitedUserID)
          .eq('status', 'pending');

      if (existingInvite.isNotEmpty) {
        throw "Invite already sent.";
      }

      await supabase.from('group_invites').insert({
        'group_id': groupID,
        'invited_by': currentUserID,
        'invited_user_id': invitedUserID,
        'status': 'pending',
      });
    } catch (e) {
      debugPrint("SEND INVITE EXCEPTION: $e");
      rethrow;
    }
  }

  /// Fetches pending invites for the current user.
  Future<List<GroupInviteModel>> getPendingInvites(
      {required String userID}) async {
    try {
      final response = await supabase
          .from('group_invites')
          .select()
          .eq('invited_user_id', userID)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      if (response.isEmpty) return [];

      final groupIds = response
          .map<String>((row) => row['group_id'] as String)
          .toSet()
          .toList();
      final inviterIds = response
          .map<String>((row) => row['invited_by'] as String)
          .toSet()
          .toList();

      final lookups = await Future.wait([
        supabase
            .from('groups')
            .select('group_id, group_name')
            .inFilter('group_id', groupIds),
        supabase
            .from('users')
            .select('user_id, user_name')
            .inFilter('user_id', inviterIds),
      ]);

      final groupNameById = <String, String>{};
      for (final group in lookups[0] as List) {
        groupNameById[group['group_id'] as String] =
            group['group_name'] as String;
      }

      final inviterNameById = <String, String>{};
      for (final user in lookups[1] as List) {
        inviterNameById[user['user_id'] as String] =
            user['user_name'] as String? ?? 'Someone';
      }

      return response.map((item) {
        final groupId = item['group_id'] as String;
        final invitedBy = item['invited_by'] as String;
        return GroupInviteModel(
          id: item['id'] as String,
          groupId: groupId,
          invitedBy: invitedBy,
          invitedUserId: item['invited_user_id'] as String,
          status: item['status'] as String,
          createdAt: DateTime.parse(item['created_at'] as String),
          groupName: groupNameById[groupId],
          inviterName: inviterNameById[invitedBy],
        );
      }).toList();
    } catch (e) {
      debugPrint("GET INVITES EXCEPTION: $e");
      if (e is PostgrestException) {
        debugPrint("Postgrest Details: ${e.details} Code: ${e.code}");
      }
      return [];
    }
  }

  /// Responds to a group invite (Accept/Decline).
  Future<void> respondToInvite({
    required String inviteID,
    required bool accept,
  }) async {
    try {
      await supabase.rpc('respond_to_group_invite', params: {
        'p_invite_id': inviteID,
        'p_accept': accept,
      });
    } catch (e) {
      debugPrint("RESPOND INVITE EXCEPTION: $e");
      rethrow;
    }
  }

  /// Adds a new group expense (transaction).
  Future<void> addGroupExpense({
    required String groupID,
    required String paidByUserID,
    required double totalAmount,
    required String description,
    required String category,
    required Map<String, double> splits, // Map of UserID -> Amount Owed
    required String currency,
    String? note, // New optional parameter
    String sharingType = 'evenly',
  }) async {
    try {
      final transactionGroupID =
          "${groupID}_${DateTime.now().millisecondsSinceEpoch}";
      final transactionDate = DateTime.now().toIso8601String();

      // Fetch exchange rate once for all rows in this transaction
      final double exchangeRate =
          await CurrencyService().getExchangeRateToInr(currency);

      // 1. Calculate Self Share
      // Total - Sum(Others' Share) = Self Share
      double sharedSum =
          splits.values.fold(0.0, (previous, current) => previous + current);
      double selfShare = totalAmount - sharedSum;

      // 2. Prepare Transaction Rows (Batch Insert?)
      // Supabase insert accepts a list of maps.
      List<Map<String, dynamic>> transactionRows = [];

      splits.forEach((sharedWithUserID, amount) {
        if (amount > 0) {
          transactionRows.add({
            "transaction_group_id": transactionGroupID,
            "group_id": groupID,
            "paid_by": paidByUserID,
            "shared_with": sharedWithUserID,
            "total_transaction_amount": totalAmount,
            "shared_transaction_amount": amount,
            "shared_percentage": (amount / totalAmount) * 100,
            "self_share_amount": selfShare,
            "self_share_percentage": (selfShare / totalAmount) * 100,
            "sharing_type": sharingType,
            "category": category,
            "description": description,
            "transaction_note": note, // Insert note
            "currency": currency,
            "exchange_rate_to_inr": exchangeRate,
            "is_settled_up": false,
            "transaction_date": transactionDate,
          });
        }
      });

      if (transactionRows.isEmpty) {
        // If paid only for self (no splits or all self), maybe just log 1 row?
        // But system is for "Splitting". If no split, maybe no Debt.
        // We insert a self-reference row to track the expense history?
        transactionRows.add({
          "transaction_group_id": transactionGroupID,
          "group_id": groupID,
          "paid_by": paidByUserID,
          "shared_with": paidByUserID, // Shared with self
          "total_transaction_amount": totalAmount,
          "shared_transaction_amount": 0.0,
          "shared_percentage": 0.0,
          "self_share_amount": totalAmount,
          "self_share_percentage": 100.0,
          "sharing_type": sharingType,
          "category": category,
          "description": description,
          "currency": currency,
          "exchange_rate_to_inr": exchangeRate,
          "is_settled_up": true, // Self expense is settled?
          "transaction_date": transactionDate,
        });
      }

      await supabase.from("group_transaction").insert(transactionRows);

      // 3. Update Group Balances
      // Fetch current balances
      final groupData = await supabase
          .from("groups")
          .select("group_balance")
          .eq("group_id", groupID)
          .single();

      List<Map<String, dynamic>> currentBalances = [];
      if (groupData["group_balance"] != null) {
        currentBalances =
            List<Map<String, dynamic>>.from(groupData["group_balance"]);
      }

      // Helper to update/add balance
      void updateBalance(
          String donorId, String receiverId, double amountToAdd) {
        // Check for existing (Donor -> Receiver)
        int index = currentBalances.indexWhere((element) =>
            element["donor_id"] == donorId &&
            element["receiver_id"] == receiverId);

        if (index != -1) {
          double newAmount =
              double.parse(currentBalances[index]["amount"].toString()) +
                  amountToAdd;
          currentBalances[index]["amount"] =
              double.parse(newAmount.toStringAsFixed(2));
        } else {
          // Check for reverse (Receiver -> Donor) and net out
          int reverseIndex = currentBalances.indexWhere((element) =>
              element["donor_id"] == receiverId &&
              element["receiver_id"] == donorId);

          if (reverseIndex != -1) {
            double reverseAmount = double.parse(
                currentBalances[reverseIndex]["amount"].toString());

            if (amountToAdd > reverseAmount) {
              // Flip the debt
              double diff = amountToAdd - reverseAmount;
              currentBalances.removeAt(reverseIndex);
              currentBalances.add({
                "donor":
                    "ID:$donorId", // Names handled by frontend usually? Or need to fetch names?
                // The DB stores names in JSON? "donor": "Name".
                // Ideally we should just rely on IDs, but existing model uses names.
                // We'll keep IDs consistent. Names might be outdated.
                "donor_id": donorId,
                "receiver": "ID:$receiverId",
                "receiver_id": receiverId,
                "amount": double.parse(diff.toStringAsFixed(2)),
              });
            } else if (amountToAdd < reverseAmount) {
              // Reduce reverse debt
              double remaining = reverseAmount - amountToAdd;
              currentBalances[reverseIndex]["amount"] =
                  double.parse(remaining.toStringAsFixed(2));
            } else {
              // Exact match, remove entry
              currentBalances.removeAt(reverseIndex);
            }
          } else {
            // New Entry
            if (donorId != receiverId) {
              currentBalances.add({
                "donor":
                    "ID:$donorId", // Placeholder, system should fetch names if needed for display
                "donor_id": donorId,
                "receiver": "ID:$receiverId",
                "receiver_id": receiverId,
                "amount": double.parse(amountToAdd.toStringAsFixed(2)),
              });
            }
          }
        }
      }

      // Apply each split to balance
      splits.forEach((userId, amount) {
        if (userId != paidByUserID && amount > 0) {
          // Payer is Donor (Creditor), Ower is Receiver (Debtor)
          updateBalance(paidByUserID, userId, amount);
        }
      });

      // Write updated balances
      await supabase.from("groups").update({
        "group_balance": currentBalances,
        "updated_on": DateTime.now().toIso8601String(),
      }).eq("group_id", groupID);
    } catch (e) {
      debugPrint("ADD EXPENSE EXCEPTION: $e");
      rethrow;
    }
  }

  /// Fetches a single group model by ID.
  Future<GroupModel?> getGroupModel(String groupID) async {
    try {
      final groupData = await supabase
          .from("groups")
          .select()
          .eq("group_id", groupID)
          .single();

      // Check if it's a trip
      final tripCheck = await supabase
          .from("trip_metadata")
          .select("group_id")
          .eq("group_id", groupID)
          .maybeSingle();

      List<GroupBalanceModel> groupBalanceList = [];
      if (groupData["group_balance"] != null) {
        for (var elm in (groupData["group_balance"] as List<dynamic>)) {
          groupBalanceList.add(GroupBalanceModel.fromJSON(elm));
        }
      }

      // We need to inject the balance list back into the map if we want to use fromJSON
      // OR we can manually construct it.
      // The map already has "group_balance" as List<dynamic>.
      // Let's just update the list if needed or rely on fromJSON parsing it again?
      // GroupModel.fromJSON expects the raw map.

      // Let's just update the is_trip in the map before creating the model
      groupData["is_trip"] = tripCheck != null;

      return GroupModel.fromJSON(groupData);
    } catch (e) {
      debugPrint("GET GROUP MODEL EXCEPTION: $e");
      return null;
    }
  }

  /// Finds an existing 2-member non-trip group shared with [friendUserId].
  Future<String?> findDirectSplitGroupId({
    required String userID,
    required String friendUserId,
  }) async {
    try {
      final groups = await getGroupData(userID: userID);
      for (final group in groups) {
        if (group.isTrip || group.groupID == null) continue;
        final members = await getGroupMembers(
          groupID: group.groupID!,
          currentUserID: userID,
        );
        if (members.length != 2) continue;
        final ids = members.map((m) => m.userID).toSet();
        if (ids.contains(userID) && ids.contains(friendUserId)) {
          return group.groupID;
        }
      }
      return null;
    } catch (e) {
      debugPrint('FIND DIRECT SPLIT GROUP EXCEPTION: $e');
      return null;
    }
  }

  /// Creates (or reuses) a 2-member group for a 1:1 split with a friend.
  Future<GroupModel> getOrCreateDirectSplitGroup({
    required String userID,
    required String friendUserId,
    required String friendName,
  }) async {
    final existing = await findDirectSplitGroupId(
      userID: userID,
      friendUserId: friendUserId,
    );
    if (existing != null) {
      final model = await getGroupModel(existing);
      if (model != null) return model;
    }

    final result = await supabase.rpc('create_group_with_member', params: {
      'p_group_name': 'Split with $friendName',
    });

    final groupId = result['group_id'] as String;

    await supabase.rpc('add_group_members', params: {
      'p_group_id': groupId,
      'p_user_ids': [friendUserId],
    });

    final model = await getGroupModel(groupId);
    if (model == null) {
      throw 'Could not load new split group';
    }
    return model;
  }
}
