import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Model/friend_model.dart';

import 'package:splitr/Repository/friend_repository.dart';
import 'package:splitr/Services/contact_invite_service.dart';
import 'package:splitr/Services/invite_link_service.dart';
import 'package:splitr/Services/SupabaseServices/notification_service.dart';

import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

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
  final RxnString searchError = RxnString();

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
  FriendRepository get _friendRepo => Get.find<FriendRepository>();

  String? _cachedSenderName;

  @override
  void onInit() {
    super.onInit();
    fetchFriendsData();
  }

  FriendModel? relationshipRecordWith(String otherUserId) {
    FriendModel? accepted;
    FriendModel? pendingIncoming;
    FriendModel? pendingOutgoing;

    for (final f in allRelationships) {
      if (f.friendUserID != otherUserId) continue;

      if (f.status == FriendStatusValues.accepted) {
        accepted = f;
        break;
      }
      if (f.status == FriendStatusValues.pending) {
        if (f.userID == userID) {
          pendingOutgoing = f;
        } else {
          pendingIncoming = f;
        }
      }
    }

    return accepted ?? pendingIncoming ?? pendingOutgoing;
  }

  FriendRelationshipState relationshipWith(String otherUserId) {
    final record = relationshipRecordWith(otherUserId);
    if (record == null) return FriendRelationshipState.none;
    if (record.status == FriendStatusValues.accepted)
      return FriendRelationshipState.friends;
    if (record.status == FriendStatusValues.pending) {
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

      await _friendRepo.refreshFromServer(userID);
      final friends = await _friendRepo.getFriends(userID);
      allRelationships.value = friends;

      incomingPendingRequests.value = friends
          .where((f) =>
              f.status == FriendStatusValues.pending && f.userID != userID)
          .toList();

      outgoingPendingRequests.value = friends
          .where((f) =>
              f.status == FriendStatusValues.pending && f.userID == userID)
          .toList();

      final acceptedFriends = friends
          .where((f) => f.status == FriendStatusValues.accepted)
          .toList();

      final balances = await _friendRepo.getFriendBalances(
        userId: userID,
        friends: acceptedFriends,
      );

      friendBalances.value = balances;
      isLoading.value = false;
    } catch (e, stack) {
      AppErrorReporter.report(
        'FriendsController.fetchFriendsData failed',
        error: e,
        stack: stack,
        context: {'feature': 'friends', 'operation': 'fetchFriendsData'},
        showToastOnUserFacing: false,
      );
      errorMessage.value = AppStrings.errors.loadFriends;
      isLoading.value = false;
    }
  }

  /// Resets add-friend search UI state.
  void clearSearch() {
    searchResults.clear();
    isSearching.value = false;
    searchError.value = null;
  }

  /// Search users by email.
  Future<void> searchUsers(String email) async {
    if (email.trim().isEmpty) {
      clearSearch();
      return;
    }

    try {
      isSearching.value = true;
      searchError.value = null;
      final results =
          await SupabaseDatabase().searchUsersByEmail(email: email.trim());
      searchResults.value = results
          .where((r) => r[UserSearchResultKeys.userId] != userID)
          .toList();
      isSearching.value = false;
    } catch (e, stack) {
      AppErrorReporter.report(
        'FriendsController.searchUsers failed',
        error: e,
        stack: stack,
        context: {'feature': 'friends', 'operation': 'searchUsers'},
        showToastOnUserFacing: false,
      );
      searchResults.clear();
      searchError.value = AppStrings.errors.searchUsersFailed;
      isSearching.value = false;
    }
  }

  /// Send a friend request.
  Future<bool> sendFriendRequest(String toUserID) async {
    try {
      final created = await _friendRepo.sendFriendRequest(
        fromUserId: userID,
        toUserId: toUserID,
      );
      if (created) {
        await _notifyFriendRequest(toUserID);
      }
      await fetchFriendsData();
      return true;
    } catch (e, stack) {
      AppErrorReporter.report(
        'FriendsController.sendFriendRequest failed',
        error: e,
        stack: stack,
        context: {'feature': 'friends', 'operation': 'sendFriendRequest'},
        showToastOnUserFacing: false,
      );
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
      await _friendRepo.acceptFriendRequest(
        requestId: requestID,
        userId: userID,
      );
      await fetchFriendsData();
      return true;
    } catch (e, stack) {
      AppErrorReporter.report(
        'FriendsController.acceptFriendRequest failed',
        error: e,
        stack: stack,
        context: {'feature': 'friends', 'operation': 'acceptFriendRequest'},
        showToastOnUserFacing: false,
      );
      return false;
    }
  }

  /// Cancel an outgoing pending friend request.
  Future<bool> cancelFriendRequest(String requestID) async {
    try {
      await _friendRepo.cancelFriendRequest(
        requestId: requestID,
        fromUserId: userID,
      );
      await fetchFriendsData();
      return true;
    } catch (e, stack) {
      AppErrorReporter.report(
        'FriendsController.cancelFriendRequest failed',
        error: e,
        stack: stack,
        context: {'feature': 'friends', 'operation': 'cancelFriendRequest'},
        showToastOnUserFacing: false,
      );
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
        type: NotificationTypes.friendRequest,
        title: AppStringFormat.friendRequestTitle(senderName),
        body: AppStringFormat.friendRequestBody(AppBranding.brandName),
        metadata: {
          MetadataKeys.fromUserId: userID,
          SupabaseColumns.requestId: req.id,
        },
      );
      return true;
    } catch (e, stack) {
      AppErrorReporter.report(
        'FriendsController.remindFriendRequest failed',
        error: e,
        stack: stack,
        context: {'feature': 'friends', 'operation': 'remindFriendRequest'},
        showToastOnUserFacing: false,
      );
      return false;
    }
  }

  Future<String> _resolveSenderName() async {
    if (_cachedSenderName != null) return _cachedSenderName!;
    try {
      final profile =
          await SupabaseDatabase().getCurrentUserProfile(userID: userID);
      final name =
          AppStringFormat.fullName(profile.firstName, profile.lastName);
      _cachedSenderName = name.isEmpty ? DisplayFallbacks.someone : name;
    } catch (e, stack) {
      AppErrorReporter.report(
        'FriendsController._resolveSenderName failed',
        error: e,
        stack: stack,
        context: {'feature': 'friends', 'operation': 'resolveSenderName'},
        showToastOnUserFacing: false,
      );
      _cachedSenderName = DisplayFallbacks.someone;
    }
    return _cachedSenderName!;
  }

  Future<void> _notifyFriendRequest(String toUserID) async {
    try {
      final senderName = await _resolveSenderName();
      await _notificationService.createNotification(
        userId: toUserID,
        type: NotificationTypes.friendRequest,
        title: AppStringFormat.friendRequestTitle(senderName),
        body: AppStringFormat.friendRequestBody(AppBranding.brandName),
        metadata: {MetadataKeys.fromUserId: userID},
      );
    } catch (e, stack) {
      AppErrorReporter.report(
        'FriendsController._notifyFriendRequest failed',
        error: e,
        stack: stack,
        context: {'feature': 'friends', 'operation': 'notifyFriendRequest'},
        showToastOnUserFacing: false,
      );
    }
  }

  /// Load device contacts that already have Splitr accounts.
  Future<void> loadContactMatches() async {
    try {
      isLoadingContacts.value = true;
      contactMatches.value = await _contactService.findRegisteredContacts();
      contactMatches.removeWhere((c) => c.userId == userID);
    } catch (e, stack) {
      AppErrorReporter.report(
        'FriendsController.loadContactMatches failed',
        error: e,
        stack: stack,
        context: {'feature': 'friends', 'operation': 'loadContactMatches'},
        showToastOnUserFacing: false,
      );
    } finally {
      isLoadingContacts.value = false;
    }
  }

  /// Share an invite link so friends can add you on Splitr.
  Future<void> shareFriendInviteLink(String inviterName) async {
    await _inviteLinkService.shareFriendInvite(
      inviterUserId: userID,
      inviterName: inviterName,
    );
  }
}
