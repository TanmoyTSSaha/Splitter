import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/shared.dart';
import 'package:splitter/Controller/friends_controller.dart';
import 'package:splitter/Model/friend_model.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitter/Services/supabase_service.dart';
import 'package:splitter/Widgets/user_avatar.dart';

const Color _lightBg = Color(0xFFFAFAFA);
const Color _cardBorder = Color(0xFFEEEEEE);
const double _actionButtonMinWidth = 76;
const Color _disabledButtonBg = Color(0xFFDDDDDD);
const Color _disabledButtonLabel = Color(0xFF9E9E9E);

TextStyle _actionLabelStyle(Color color) => TextStyle(
      fontFamily: 'Poppins',
      fontSize: 12,
      fontWeight: FontWeight.w600,
      fontStyle: FontStyle.normal,
      color: color,
    );

class AddFriendScreen extends StatefulWidget {
  final String userID;

  const AddFriendScreen({required this.userID, super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final FriendsController _friendsController;

  @override
  void initState() {
    super.initState();
    _friendsController = Get.find<FriendsController>();
    _friendsController.clearSearch();
    _friendsController.loadContactMatches();
  }

  @override
  void dispose() {
    _friendsController.clearSearch();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _shareInviteLink() async {
    final profile =
        await SupabaseDatabase().getCurrentUserProfile(userID: widget.userID);
    final name = '${profile.firstName} ${profile.lastName}'.trim();
    await _friendsController.shareFriendInviteLink(
      name.isEmpty ? 'A friend' : name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _lightBg,
        appBar: AppBar(
          backgroundColor: _lightBg,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: groupOnSurface),
          ),
          title: Text(
            'Add Friend',
            style: headline3_text.copyWith(
              fontFamily: 'Albra',
              fontWeight: FontWeight.w600,
              color: groupOnSurface,
            ),
          ),
          actions: [
            IconButton(
              onPressed: _shareInviteLink,
              icon: const Icon(Icons.link_rounded, color: neopopAccent),
              tooltip: 'Share invite link',
            ),
          ],
          bottom: TabBar(
            indicatorColor: neopopAccent,
            labelColor: neopopAccent,
            unselectedLabelColor: groupOnSurfaceMuted,
            labelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'Search'),
              Tab(text: 'Contacts'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSearchTab(),
            _buildContactsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTab() {
    return Padding(
      padding: const EdgeInsets.all(groupGutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _cardBorder),
            ),
            child: TextField(
              controller: _searchController,
              style: body1_text.copyWith(color: groupOnSurface),
              onChanged: _friendsController.searchUsers,
              decoration: InputDecoration(
                hintText: "Search by email...",
                hintStyle: body2_text.copyWith(color: groupOnSurfaceMuted),
                prefixIcon:
                    Icon(Icons.search_rounded, color: groupOnSurfaceMuted),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: groupGapSm),
          Text(
            'We only use contacts on your device to find friends already on SplitO.',
            style: body2_text.copyWith(
              color: groupOnSurfaceMuted,
              fontStyle: FontStyle.normal,
            ),
          ),
          const SizedBox(height: groupGapMd),
          Expanded(
            child: Obx(() {
              if (_friendsController.isSearching.value) {
                return const Center(child: LoadingWidget());
              }
              if (_friendsController.searchResults.isEmpty &&
                  _searchController.text.isNotEmpty) {
                return Center(
                  child: Text(
                    "No users found.",
                    style: body2_text.copyWith(color: groupOnSurfaceMuted),
                  ),
                );
              }
              if (_friendsController.searchResults.isEmpty) {
                return Center(
                  child: Text(
                    "Search for friends by their email address",
                    style: body2_text.copyWith(color: groupOnSurfaceMuted),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return ListView.separated(
                itemCount: _friendsController.searchResults.length,
                separatorBuilder: (_, __) => const SizedBox(height: groupGapSm),
                itemBuilder: (context, index) =>
                    _buildUserTile(_friendsController.searchResults[index]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsTab() {
    return Padding(
      padding: const EdgeInsets.all(groupGutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Friends from your contact book who use SplitO',
            style: body2_text.copyWith(color: groupOnSurfaceMuted),
          ),
          const SizedBox(height: groupGapMd),
          Expanded(
            child: Obx(() {
              if (_friendsController.isLoadingContacts.value) {
                return const Center(child: LoadingWidget());
              }
              if (_friendsController.contactMatches.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.contacts_outlined,
                          color: groupOnSurfaceMuted.withValues(alpha: 0.5),
                          size: 48),
                      const SizedBox(height: groupGapSm),
                      Text(
                        'No matching contacts found.\nGrant contact access or share your invite link.',
                        style: body2_text.copyWith(color: groupOnSurfaceMuted),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: groupGapMd),
                      TextButton(
                        onPressed: () =>
                            _friendsController.loadContactMatches(),
                        child: Text(
                          'Retry',
                          style: body2_text.copyWith(color: neopopAccent),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                itemCount: _friendsController.contactMatches.length,
                separatorBuilder: (_, __) => const SizedBox(height: groupGapSm),
                itemBuilder: (context, index) {
                  final match = _friendsController.contactMatches[index];
                  return _buildUserTile({
                    'user_id': match.userId,
                    'user_name': match.userName ?? match.contactName,
                    'user_email': match.email,
                    'profile_picture_url': match.userPic,
                  }, subtitle: match.contactName);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user, {String? subtitle}) {
    final uid = user['user_id']?.toString() ?? '';

    return Obx(() {
      final state = _friendsController.relationshipWith(uid);
      final record = _friendsController.relationshipRecordWith(uid);

      return Container(
        padding: const EdgeInsets.all(groupGapMd),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UserAvatar(
              userID: uid,
              userName: user['user_name']?.toString() ?? '?',
              imageUrl: user['profile_picture_url']?.toString(),
              radius: 22,
            ),
            const SizedBox(width: groupGapSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['user_name']?.toString() ?? 'Unknown',
                    style: body1_text.copyWith(
                      color: groupOnSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle ?? user['user_email']?.toString() ?? '',
                    style: body2_text.copyWith(
                      color: groupOnSurfaceMuted,
                      fontStyle: FontStyle.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: groupGapSm),
            _buildActionButton(state: state, userId: uid, record: record),
          ],
        ),
      );
    });
  }

  Widget _buildActionButton({
    required FriendRelationshipState state,
    required String userId,
    required FriendModel? record,
  }) {
    switch (state) {
      case FriendRelationshipState.none:
        return SizedBox(
          width: _actionButtonMinWidth,
          child: ElevatedButton(
            onPressed: () => _handleAdd(userId),
            style: ElevatedButton.styleFrom(
              backgroundColor: neopopAccent,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              minimumSize: const Size(_actionButtonMinWidth, 36),
            ),
            child: Text('Add', style: _actionLabelStyle(neopopOnBackground)),
          ),
        );
      case FriendRelationshipState.pendingOutgoing:
        return SizedBox(
          width: _actionButtonMinWidth,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _disabledButtonBg,
              disabledBackgroundColor: _disabledButtonBg,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              minimumSize: const Size(_actionButtonMinWidth, 36),
            ),
            child: Text('Pending', style: _actionLabelStyle(_disabledButtonLabel)),
          ),
        );
      case FriendRelationshipState.friends:
        return SizedBox(
          width: _actionButtonMinWidth,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _disabledButtonBg,
              disabledBackgroundColor: _disabledButtonBg,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              minimumSize: const Size(_actionButtonMinWidth, 36),
            ),
            child: Text('Friends', style: _actionLabelStyle(_disabledButtonLabel)),
          ),
        );
      case FriendRelationshipState.pendingIncoming:
        return SizedBox(
          width: _actionButtonMinWidth,
          child: ElevatedButton(
            onPressed: record?.id != null
                ? () => _handleAccept(record!.id!)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: neopopAccent,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              minimumSize: const Size(_actionButtonMinWidth, 36),
            ),
            child: Text('Accept', style: _actionLabelStyle(neopopOnBackground)),
          ),
        );
    }
  }

  Future<void> _handleAdd(String userId) async {
    final success = await _friendsController.sendFriendRequest(userId);
    Fluttertoast.showToast(
      msg: success ? "Friend request sent!" : "Failed to send request.",
      backgroundColor: success ? neopopAccent : neopopYellow,
      textColor: neopopBackground,
    );
  }

  Future<void> _handleAccept(String requestId) async {
    final success = await _friendsController.acceptFriendRequest(requestId);
    Fluttertoast.showToast(
      msg: success ? "Friend request accepted!" : "Failed to accept.",
      backgroundColor: success ? neopopAccent : neopopYellow,
      textColor: neopopBackground,
    );
  }
}
