import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/shared.dart';
import 'package:splitter/Model/friend_model.dart';
import 'package:splitter/Services/supabase_service.dart';

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
        final isAccepted = f.status == 'accepted';
        final friendID = f.friendUserID;
        final isNotMember = !_existingMemberIDs.contains(friendID);
        return isAccepted && isNotMember && friendID != null;
      }).toList();
    } catch (e) {
      debugPrint("FETCH DATA ERROR: $e");
      Fluttertoast.showToast(msg: "Failed to load data.");
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
          final uid = user['user_id']?.toString();
          if (uid != widget.userID && !_existingMemberIDs.contains(uid)) {
            _searchResults.add(user);
          }
        }
      });
    } catch (e) {
      debugPrint("SEARCH ERROR: $e");
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _addSelectedMembers() async {
    if (_selectedUserIDs.isEmpty) {
      Fluttertoast.showToast(msg: "Select at least one member.");
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

      Fluttertoast.showToast(msg: "Invites sent successfully!");
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint("ADD API ERROR: $e");
      Fluttertoast.showToast(msg: "Failed to send invites: ${e.toString()}");
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
            padding: EdgeInsets.only(top: height_16 * 4),
            child: Text(
              'No users found for "${_searchController.text.trim()}".',
              textAlign: TextAlign.center,
              style: body2_text.copyWith(color: neopopGrey),
            ),
          ),
        );
      }
      return ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Text(
            'Search Results',
            style: sub_headline5_text.copyWith(color: neopopBackground),
          ),
          SizedBox(height: height_10),
          ..._searchResults.map((user) {
            final uid = user['user_id'].toString();
            return _buildUserTile(
              uid: uid,
              name: user['user_name'] ?? 'Unknown',
              email: user['user_email'] ?? '',
              isSelected: _selectedUserIDs.contains(uid),
            );
          }),
        ],
      );
    }

    if (_friends.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: height_16 * 4),
          child: Text(
            'No friends available to add.\nTry searching by email.',
            textAlign: TextAlign.center,
            style: body2_text.copyWith(color: neopopGrey),
          ),
        ),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          'Your Friends',
          style: sub_headline5_text.copyWith(color: neopopBackground),
        ),
        SizedBox(height: height_10),
        ..._friends.map((friend) {
          return _buildUserTile(
            uid: friend.friendUserID!,
            name: friend.friendName ?? 'Unknown',
            email: friend.friendEmail ?? '',
            isSelected: _selectedUserIDs.contains(friend.friendUserID),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Invite Members',
          style: sub_headline4_text.copyWith(color: neopopBackground),
        ),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: neopopBackground),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: neopopBackground),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_selectedUserIDs.isNotEmpty)
            TextButton(
              onPressed: _isLoading ? null : _addSelectedMembers,
              child: Text(
                'Invite (${_selectedUserIDs.length})',
                style: body2_text.copyWith(
                  color: neopopAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(width_16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                style: body1_text.copyWith(color: neopopBackground),
                onChanged: _searchUsers,
                decoration: InputDecoration(
                  hintText: 'Search friends or by email...',
                  hintStyle: body2_text.copyWith(color: neopopGrey),
                  prefixIcon: const Icon(Icons.search, color: neopopGrey),
                  filled: true,
                  fillColor: neopopBackground.withValues(alpha: 0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: neopopGrey.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: neopopGrey.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: neopopAccent),
                  ),
                ),
              ),
              SizedBox(height: height_16),
              Expanded(child: _buildListContent()),
            ],
          ),
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
      margin: EdgeInsets.only(bottom: height_10),
      padding: EdgeInsets.symmetric(horizontal: width_16, vertical: height_10),
      decoration: BoxDecoration(
        color: isSelected
            ? neopopAccent.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? neopopAccent
              : neopopGrey.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: neopopBackground.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _toggleSelection(uid),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: height_10 * 4,
              height: height_10 * 4,
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
            SizedBox(width: width_16),
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
