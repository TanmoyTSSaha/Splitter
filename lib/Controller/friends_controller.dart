import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Model/friend_model.dart';

import 'package:splitter/Services/contact_invite_service.dart';
import 'package:splitter/Services/invite_link_service.dart';

import 'package:splitter/Services/supabase_service.dart';

class FriendsController extends GetxController {
  final String userID;

  FriendsController({required this.userID});

  RxBool isLoading = true.obs;
  RxBool isSearching = false.obs;
  RxString errorMessage = ''.obs;

  RxList<FriendBalanceModel> friendBalances = <FriendBalanceModel>[].obs;
  RxList<FriendModel> pendingRequests = <FriendModel>[].obs;
  RxList<Map<String, dynamic>> searchResults = <Map<String, dynamic>>[].obs;
  RxList<ContactMatch> contactMatches = <ContactMatch>[].obs;
  RxBool isLoadingContacts = false.obs;

  final ContactInviteService _contactService = ContactInviteService();
  final InviteLinkService _inviteLinkService = InviteLinkService();

  @override
  void onInit() {
    super.onInit();
    fetchFriendsData();
  }

  /// Fetches friends list, pending requests, and computes balances.
  Future<void> fetchFriendsData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Fetch accepted friends
      final friends = await SupabaseDatabase().getFriends(userID: userID);

      // Separate pending incoming requests
      pendingRequests.value = friends
          .where((f) => f.status == 'pending' && f.friendUserID != userID)
          .toList();

      final acceptedFriends =
          friends.where((f) => f.status == 'accepted').toList();

      // Compute per-friend balances
      final balances = await SupabaseDatabase().getFriendBalances(
        userID: userID,
        friends: acceptedFriends,
      );

      friendBalances.value = balances;
      isLoading.value = false;
    } catch (e) {
      debugPrint("FRIENDS EXCEPTION: $e");
      errorMessage.value = "Failed to load friends.";
      isLoading.value = false;
    }
  }

  /// Search users by email.
  Future<void> searchUsers(String email) async {
    if (email.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isSearching.value = true;
      final results =
          await SupabaseDatabase().searchUsersByEmail(email: email.trim());
      // Filter out self
      searchResults.value =
          results.where((r) => r['user_id'] != userID).toList();
      isSearching.value = false;
    } catch (e) {
      debugPrint("SEARCH EXCEPTION: $e");
      isSearching.value = false;
    }
  }

  /// Send a friend request.
  Future<bool> sendFriendRequest(String toUserID) async {
    try {
      await SupabaseDatabase().sendFriendRequest(
        fromUserID: userID,
        toUserID: toUserID,
      );
      return true;
    } catch (e) {
      debugPrint("SEND FRIEND REQUEST EXCEPTION: $e");
      return false;
    }
  }

  /// Accept a friend request.
  Future<bool> acceptFriendRequest(String requestID) async {
    try {
      await SupabaseDatabase().acceptFriendRequest(requestID: requestID);
      await fetchFriendsData(); // Refresh
      return true;
    } catch (e) {
      debugPrint("ACCEPT FRIEND REQUEST EXCEPTION: $e");
      return false;
    }
  }

  /// Load device contacts that already have SplitO accounts.
  Future<void> loadContactMatches() async {
    try {
      isLoadingContacts.value = true;
      contactMatches.value = await _contactService.findRegisteredContacts();
      contactMatches.removeWhere((c) => c.userId == userID);
    } catch (e) {
      debugPrint('LOAD CONTACTS EXCEPTION: $e');
    } finally {
      isLoadingContacts.value = false;
    }
  }

  /// Share an invite link so friends can add you on SplitO.
  Future<void> shareFriendInviteLink(String inviterName) async {
    await _inviteLinkService.shareFriendInvite(
      inviterUserId: userID,
      inviterName: inviterName,
    );
  }
}
