import 'package:flutter/material.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/shared.dart';
import 'package:splitr/Controller/friends_controller.dart';
import 'package:splitr/Model/friend_model.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Widgets/bordered_input_field.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';
import 'package:splitr/Widgets/user_avatar.dart';

TextStyle _actionLabelStyle(Color color) => TextStyle(
      fontFamily: kFontPoppins,
      fontSize: splitrFontCaption,
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
      name.isEmpty ? DisplayFallbacks.aFriend : name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: surface,
        appBar: SplitrDetailAppBar(
          title: AppStrings.friends.addFriend,
          leading: SplitrDetailAppBar.iosBackLeading(
            context,
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              onPressed: _shareInviteLink,
              icon: const Icon(Icons.link_rounded, color: neopopAccent),
              tooltip: AppStrings.a11y.shareInviteLink,
            ),
          ],
          bottom: TabBar(
            indicatorColor: neopopAccent,
            labelColor: neopopAccent,
            unselectedLabelColor: groupOnSurfaceMuted,
            labelStyle: const TextStyle(
              fontFamily: kFontPoppins,
              fontWeight: FontWeight.w600,
            ),
            tabs: [
              Tab(text: AppStrings.friends.tabSearch),
              Tab(text: AppStrings.friends.tabContacts),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSearchTab(context),
            _buildContactsTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(groupGutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BorderedInputField(
            controller: _searchController,
            hintText: AppStrings.friends.searchHint,
            onChanged: _friendsController.searchUsers,
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: groupOnSurfaceMuted,
            ),
          ),
          const SizedBox(height: groupGapSm),
          Text(
            '${AppStrings.friends.contactsPrivacyPrefix}${AppBranding.brandName}.',
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
              if (_friendsController.searchError.value != null &&
                  _searchController.text.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _friendsController.searchError.value!,
                        style: body2_text.copyWith(color: groupOnSurfaceMuted),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: groupGapSm),
                      TextButton(
                        onPressed: () => _friendsController
                            .searchUsers(_searchController.text),
                        child: Text(
                          AppStrings.actions.tryAgain,
                          style: body2_text.copyWith(color: neopopAccent),
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (_friendsController.searchResults.isEmpty &&
                  _searchController.text.isNotEmpty) {
                return Center(
                  child: Text(
                    AppStrings.friends.noUsersFound,
                    style: body2_text.copyWith(color: groupOnSurfaceMuted),
                  ),
                );
              }
              if (_friendsController.searchResults.isEmpty) {
                return Center(
                  child: Text(
                    AppStrings.friends.searchFriendsHint,
                    style: body2_text.copyWith(color: groupOnSurfaceMuted),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return ListView.separated(
                itemCount: _friendsController.searchResults.length,
                separatorBuilder: (_, __) => const SizedBox(height: groupGapSm),
                itemBuilder: (context, index) => _buildUserTile(
                    context, _friendsController.searchResults[index]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(groupGutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppStrings.friends.contactsFromBookPrefix}${AppBranding.brandName}',
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
                          color: groupMutedIconMuted,
                          size: groupCtaHeightCompact),
                      const SizedBox(height: groupGapSm),
                      Text(
                        AppStrings.friends.noMatchingContacts,
                        style: body2_text.copyWith(color: groupOnSurfaceMuted),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: groupGapMd),
                      TextButton(
                        onPressed: () =>
                            _friendsController.loadContactMatches(),
                        child: Text(
                          AppStrings.actions.retry,
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
                  return _buildUserTile(
                      context,
                      {
                        UserSearchResultKeys.userId: match.userId,
                        UserSearchResultKeys.userName:
                            match.userName ?? match.contactName,
                        UserSearchResultKeys.userEmail: match.email,
                        SupabaseColumns.profilePictureUrl: match.userPic,
                      },
                      subtitle: match.contactName);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(BuildContext context, Map<String, dynamic> user,
      {String? subtitle}) {
    final surface = Theme.of(context).colorScheme.surface;
    final borderColor = groupMutedBorderHairline;
    final uid = user[UserSearchResultKeys.userId]?.toString() ?? '';

    return Obx(() {
      final state = _friendsController.relationshipWith(uid);
      final record = _friendsController.relationshipRecordWith(uid);

      return Container(
        padding: const EdgeInsets.all(groupGapMd),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(groupCardRadius),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: groupSurfaceFillWhisper,
              blurRadius: AppDimensions.groupCardShadowBlur,
              offset: Offset(0, AppDimensions.groupCardShadowOffsetSmY),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UserAvatar(
              userID: uid,
              userName: user[UserSearchResultKeys.userName]?.toString() ??
                  DisplayFallbacks.questionMark,
              imageUrl: user[SupabaseColumns.profilePictureUrl]?.toString(),
              radius: 22,
            ),
            const SizedBox(width: groupGapSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user[UserSearchResultKeys.userName]?.toString() ??
                        DisplayFallbacks.unknown,
                    style: body1_text.copyWith(
                      color: groupOnSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle ??
                        user[UserSearchResultKeys.userEmail]?.toString() ??
                        '',
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
          width: FriendScreenLayout.actionButtonMinWidth,
          child: ElevatedButton(
            onPressed: () => _handleAdd(userId),
            style: ElevatedButton.styleFrom(
              backgroundColor: neopopAccent,
              padding: const EdgeInsets.symmetric(
                  horizontal: groupGapSm, vertical: groupGapSm),
              minimumSize: const Size(
                FriendScreenLayout.actionButtonMinWidth,
                FriendScreenLayout.actionButtonMinHeight,
              ),
            ),
            child: Text(AppStrings.friends.add,
                style: _actionLabelStyle(neopopOnBackground)),
          ),
        );
      case FriendRelationshipState.pendingOutgoing:
        return SizedBox(
          width: FriendScreenLayout.actionButtonMinWidth,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: neopopDisabledBg,
              disabledBackgroundColor: neopopDisabledBg,
              padding: const EdgeInsets.symmetric(
                  horizontal: groupGapSm, vertical: groupGapSm),
              minimumSize: const Size(
                FriendScreenLayout.actionButtonMinWidth,
                FriendScreenLayout.actionButtonMinHeight,
              ),
            ),
            child: Text(AppStrings.lending.pending,
                style: _actionLabelStyle(neopopDisabledFg)),
          ),
        );
      case FriendRelationshipState.friends:
        return SizedBox(
          width: FriendScreenLayout.actionButtonMinWidth,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: neopopDisabledBg,
              disabledBackgroundColor: neopopDisabledBg,
              padding: const EdgeInsets.symmetric(
                  horizontal: groupGapSm, vertical: groupGapSm),
              minimumSize: const Size(
                FriendScreenLayout.actionButtonMinWidth,
                FriendScreenLayout.actionButtonMinHeight,
              ),
            ),
            child: Text(AppStrings.friends.tabFriends,
                style: _actionLabelStyle(neopopDisabledFg)),
          ),
        );
      case FriendRelationshipState.pendingIncoming:
        return SizedBox(
          width: FriendScreenLayout.actionButtonMinWidth,
          child: ElevatedButton(
            onPressed:
                record?.id != null ? () => _handleAccept(record!.id!) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: neopopAccent,
              padding: const EdgeInsets.symmetric(
                  horizontal: groupGapSm, vertical: groupGapSm),
              minimumSize: const Size(
                FriendScreenLayout.actionButtonMinWidth,
                FriendScreenLayout.actionButtonMinHeight,
              ),
            ),
            child: Text(AppStrings.actions.accept,
                style: _actionLabelStyle(neopopOnBackground)),
          ),
        );
    }
  }

  Future<void> _handleAdd(String userId) async {
    final success = await _friendsController.sendFriendRequest(userId);
    SplitrToast.show(success
          ? AppStrings.friends.friendRequestSent
          : AppStrings.friends.friendRequestSendFailed);
  }

  Future<void> _handleAccept(String requestId) async {
    final success = await _friendsController.acceptFriendRequest(requestId);
    SplitrToast.show(success
          ? AppStrings.friends.friendRequestAccepted
          : AppStrings.friends.friendRequestFailed);
  }
}
