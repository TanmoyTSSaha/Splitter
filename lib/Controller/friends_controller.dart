import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Model/friend_model.dart';

import 'package:splitter/Services/contact_invite_service.dart';
import 'package:splitter/Services/invite_link_service.dart';
import 'package:splitter/Services/SupabaseServices/notification_service.dart';

import 'package:splitter/Services/supabase_service.dart';

enum FriendRelationshipState {
  none,
  friends,
  pendingOutgoing,
  pendingIncoming,
}

class FriendsController extends GetxController {
  final String userID;

  FriendsController({required this.userID});

  RxBool isLoading = true.obs;
  RxBool isSearching = false.obs;
  RxString errorMessage = ''.obs;

  RxList<FriendBalanceModel> friendBalances = <FriendBalanceModel>[].obs;
  RxList<FriendModel> incomingPendingRequests = <FriendModel>[].obs;
  RxList<FriendModel> outgoingPendingRequests = <FriendModel>[].obs;
  RxList<FriendModel> allRelationships = <FriendModel>[].obs;
  RxList<Map<String, dynamic>> searchResults = <Map<String, dynamic>>[].obs;
  RxList<ContactMatch> contactMatches = <ContactMatch>[].obs;
  RxBool isLoadingContacts = false.obs;

  final ContactInviteService _contactService = ContactInviteService();
  final InviteLinkService _inviteLinkService = InviteLinkService();
  final NotificationService _notificationService = NotificationService();

  String? _cachedSenderName;

  @override
  void onInit() {
    super.onInit();
    fetchFriendsData();
  }

  FriendModel? relationshipRecordWith(String otherUserId) {
    for (final f in allRelationships) {
      if (f.friendUserID == otherUserId) return f;
    }
    return null;
  }

  FriendRelationshipState relationshipWith(String otherUserId) {
    final record = relationshipRecordWith(otherUserId);
    if (record == null) return FriendRelationshipState.none;
    if (record.status == 'accepted') return FriendRelationshipState.friends;
    if (record.status == 'pending') {
      if (record.userID == userID) {
        return FriendRelationshipState.pendingOutgoing;
      }
      return FriendRelationshipState.pendingIncoming;
    }
    return FriendRelationshipState.none;
  }

  /// Fetches friends list, pending requests, and computes balances.
  Future<void> fetchFriendsData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final friends = await SupabaseDatabase().getFriends(userID: userID);
      allRelationships.value = friends;

      incomingPendingRequests.value = friends
          .where((f) => f.status == 'pending' && f.userID != userID)
          .toList();

      outgoingPendingRequests.value = friends
          .where((f) => f.status == 'pending' && f.userID == userID)
          .toList();

      final acceptedFriends =
          friends.where((f) => f.status == 'accepted').toList();

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

  /// Resets add-friend search UI state.
  void clearSearch() {
    searchResults.clear();
    isSearching.value = false;
  }

  /// Search users by email.
  Future<void> searchUsers(String email) async {
    if (email.trim().isEmpty) {
      clearSearch();
      return;
    }

    try {
      isSearching.value = true;
      final results =
          await SupabaseDatabase().searchUsersByEmail(email: email.trim());
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
      await _notifyFriendRequest(toUserID);
      await fetchFriendsData();
      return true;
    } catch (e) {
      debugPrint("SEND FRIEND REQUEST EXCEPTION: $e");
      await fetchFriendsData();
      final state = relationshipWith(toUserID);
      if (state == FriendRelationshipState.pendingOutgoing ||
          state == FriendRelationshipState.friends) {
        return true;
      }
      return false;
    }
  }

  /// Accept a friend request.
  Future<bool> acceptFriendRequest(String requestID) async {
    try {
      await SupabaseDatabase().acceptFriendRequest(requestID: requestID);
      await fetchFriendsData();
      return true;
    } catch (e) {
      debugPrint("ACCEPT FRIEND REQUEST EXCEPTION: $e");
      return false;
    }
  }

  /// Cancel an outgoing pending friend request.
  Future<bool> cancelFriendRequest(String requestID) async {
    try {
      await SupabaseDatabase().cancelFriendRequest(
        requestID: requestID,
        fromUserID: userID,
      );
      await fetchFriendsData();
      return true;
    } catch (e) {
      debugPrint("CANCEL FRIEND REQUEST EXCEPTION: $e");
      return false;
    }
  }

  /// Send an in-app reminder notification for an outgoing friend request.
  Future<bool> remindFriendRequest(FriendModel req) async {
    final recipientId = req.friendUserID;
    if (recipientId == null) return false;

    try {
      final senderName = await _resolveSenderName();
      await _notificationService.createNotification(
        userId: recipientId,
        type: 'friend_request',
        title: '$senderName sent you a friend request',
        body: 'Open SplitO to accept.',
        metadata: {'from_user_id': userID, 'request_id': req.id},
      );
      return true;
    } catch (e) {
      debugPrint('REMIND FRIEND REQUEST EXCEPTION: $e');
      return false;
    }
  }

  Future<String> _resolveSenderName() async {
    if (_cachedSenderName != null) return _cachedSenderName!;
    try {
      final profile =
          await SupabaseDatabase().getCurrentUserProfile(userID: userID);
      final name = '${profile.firstName} ${profile.lastName}'.trim();
      _cachedSenderName = name.isEmpty ? 'Someone' : name;
    } catch (e) {
      _cachedSenderName = 'Someone';
    }
    return _cachedSenderName!;
  }

  Future<void> _notifyFriendRequest(String toUserID) async {
    try {
      final senderName = await _resolveSenderName();
      await _notificationService.createNotification(
        userId: toUserID,
        type: 'friend_request',
        title: '$senderName sent you a friend request',
        body: 'Open SplitO to accept.',
        metadata: {'from_user_id': userID},
      );
    } catch (e) {
      debugPrint('FRIEND REQUEST NOTIFICATION EXCEPTION: $e');
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
