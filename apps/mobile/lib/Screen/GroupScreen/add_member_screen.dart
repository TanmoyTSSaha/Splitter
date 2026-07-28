import 'package:flutter/material.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/shared.dart';
import 'package:splitr/Model/friend_model.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/Widgets/bordered_input_field.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/app_dimensions.dart';

class AddMemberScreen extends StatefulWidget {
  final String userID;
  final String groupID;

  const AddMemberScreen({
    required this.userID,
    required this.groupID,
    super.key,
  });

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SupabaseDatabase _supabaseDatabase = SupabaseDatabase();

  bool _isLoading = true;
  bool _isSearching = false;
  List<FriendModel> _friends = [];
  List<String> _existingMemberIDs = [];
  final List<Map<String, dynamic>> _searchResults = [];
  final Set<String> _selectedUserIDs = {};

  bool get _hasSearchQuery => _searchController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    try {
      final members = await _supabaseDatabase.getGroupMembers(
        groupID: widget.groupID,
        currentUserID: widget.userID,
      );
      _existingMemberIDs = members.map((m) => m.userID!).toList();

      final allFriends =
          await _supabaseDatabase.getFriends(userID: widget.userID);

      _friends = allFriends.where((f) {
        final isAccepted = f.status == GroupInviteStatusValues.accepted;
        final friendID = f.friendUserID;
        final isNotMember = !_existingMemberIDs.contains(friendID);
        return isAccepted && isNotMember && friendID != null;
      }).toList();
    } catch (e, stack) {
      AppErrorReporter.report(
        AppStrings.errors.failedToLoadData,
        error: e,
        stack: stack,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _searchUsers(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    try {
      final results =
          await _supabaseDatabase.searchUsersByEmail(email: trimmed);
      if (!mounted) return;
      setState(() {
        _searchResults.clear();
        for (var user in results) {
          final uid = user[UserSearchResultKeys.userId]?.toString();
          if (uid != widget.userID && !_existingMemberIDs.contains(uid)) {
            _searchResults.add(user);
          }
        }
      });
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        'User search failed',
        error: e,
        stack: stack,
      );
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _addSelectedMembers() async {
    if (_selectedUserIDs.isEmpty) {
      SplitrToast.show(AppStrings.groups.selectAtLeastOneMember);
      return;
    }

    setState(() => _isLoading = true);
    try {
      for (var uid in _selectedUserIDs) {
        await _supabaseDatabase.sendGroupInvite(
          groupID: widget.groupID,
          invitedUserID: uid,
        );
      }

      SplitrToast.show(AppStrings.groups.invitesSent);
      if (mounted) Navigator.pop(context, true);
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        AppStrings.groups.failedToSendInvitesPrefix,
        error: e,
        stack: stack,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleSelection(String uid) {
    setState(() {
      if (_selectedUserIDs.contains(uid)) {
        _selectedUserIDs.remove(uid);
      } else {
        _selectedUserIDs.add(uid);
      }
    });
  }

  Widget _buildListContent() {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }

    if (_hasSearchQuery) {
      if (_isSearching) {
        return const Center(child: LoadingWidget());
      }
      if (_searchResults.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.only(top: groupGapXl * 2),
            child: Text(
              AppStringFormat.noUsersFoundFor(_searchController.text.trim()),
              textAlign: TextAlign.center,
              style: body2_text.copyWith(color: groupOnSurfaceMuted),
            ),
          ),
        );
      }
      return ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Text(
            AppStrings.friends.searchResults,
            style: sub_headline5_text.copyWith(color: groupOnSurface),
          ),
          const SizedBox(height: groupGapSm),
          ..._searchResults.map((user) {
            final uid = user[UserSearchResultKeys.userId].toString();
            return _buildUserTile(
              uid: uid,
              name: user[UserSearchResultKeys.userName] ??
                  DisplayFallbacks.unknownUser,
              email: user[UserSearchResultKeys.userEmail] ?? '',
              isSelected: _selectedUserIDs.contains(uid),
            );
          }),
        ],
      );
    }

    if (_friends.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: groupGapXl * 2),
          child: Text(
            AppStrings.groups.noFriendsAvailableToAdd,
            textAlign: TextAlign.center,
            style: body2_text.copyWith(color: groupOnSurfaceMuted),
          ),
        ),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          AppStrings.friends.yourFriends,
          style: sub_headline5_text.copyWith(color: neopopBackground),
        ),
        SizedBox(height: groupGap10),
        ..._friends.map((friend) {
          return _buildUserTile(
            uid: friend.friendUserID!,
            name: friend.friendName ?? DisplayFallbacks.unknownUser,
            email: friend.friendEmail ?? '',
            isSelected: _selectedUserIDs.contains(friend.friendUserID),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: surface,
      appBar: SplitrDetailAppBar(
        title: AppStrings.friends.inviteMembers,
        leading: SplitrDetailAppBar.iosBackLeading(
          context,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_selectedUserIDs.isNotEmpty)
            TextButton(
              onPressed: _isLoading ? null : _addSelectedMembers,
              child: Text(
                AppStringFormat.inviteCount(_selectedUserIDs.length),
                style: body2_text.copyWith(
                  color: neopopAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          groupGutter,
          groupGutter,
          groupGutter,
          groupGutter + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
            children: [
              BorderedInputField(
                controller: _searchController,
                hintText: AppStrings.groups.searchFriendsOrEmail,
                onChanged: _searchUsers,
                prefixIcon: const Icon(
                  Icons.search,
                  color: groupOnSurfaceMuted,
                ),
              ),
              const SizedBox(height: groupGapMd),
              Expanded(child: _buildListContent()),
            ],
          ),
        ),
    );
  }

  Widget _buildUserTile({
    required String uid,
    required String name,
    required String email,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: groupGapSm),
      padding: const EdgeInsets.symmetric(
        horizontal: groupGutter,
        vertical: groupGapSm,
      ),
      decoration: BoxDecoration(
        color: isSelected ? neopopAccentFillSoft : groupCardFill,
        borderRadius: BorderRadius.circular(groupControlRadius),
        border: Border.all(
          color: isSelected ? neopopAccent : groupMutedBorderSoft,
        ),
        boxShadow: [
          BoxShadow(
            color: groupSurfaceFillWhisper,
            blurRadius: AppDimensions.groupCardShadowBlur,
            offset: const Offset(0, AppDimensions.groupCardShadowOffsetSmY),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _toggleSelection(uid),
        borderRadius: BorderRadius.circular(groupControlRadius),
        child: Row(
          children: [
            Container(
              width: groupGap10 * 4,
              height: groupGap10 * 4,
              decoration: BoxDecoration(
                color: getRandomBrightColor(),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                getInitials(name),
                style: body1_text.copyWith(
                  color: neopopBackground,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: groupGutter),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: body1_text.copyWith(color: neopopBackground),
                  ),
                  if (email.isNotEmpty)
                    Text(
                      email,
                      style: caption_text.copyWith(
                        color: neopopGrey,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? neopopAccent : neopopGrey,
            ),
          ],
        ),
      ),
    );
  }
}
