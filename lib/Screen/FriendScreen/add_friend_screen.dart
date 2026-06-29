import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/shared.dart';
import 'package:splitter/Controller/friends_controller.dart';
import 'package:splitter/Widgets/dark_surface_theme.dart';
import 'package:splitter/Services/supabase_service.dart';

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
    _friendsController.loadContactMatches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _shareInviteLink() async {
    final profile = await SupabaseDatabase()
        .getCurrentUserProfile(userID: widget.userID);
    final name = '${profile.firstName} ${profile.lastName}'.trim();
    await _friendsController.shareFriendInviteLink(
      name.isEmpty ? 'A friend' : name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DarkSurfaceTheme(
      child: DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: neopopBackground,
        appBar: AppBar(
          backgroundColor: neopopBackground,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon:
                const Icon(Icons.arrow_back_rounded, color: neopopOnBackground),
          ),
          title: Text("Add Friend", style: sub_headline4_text),
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
            unselectedLabelColor: neopopGrey,
            tabs: const [
              Tab(text: 'Search'),
              Tab(text: 'Contacts'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              _buildSearchTab(),
              _buildContactsTab(),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildSearchTab() {
    return Padding(
      padding: EdgeInsets.all(width_16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            style: body1_text,
            onChanged: _friendsController.searchUsers,
            decoration: InputDecoration(
              hintText: "Search by email...",
              hintStyle: body2_text.copyWith(color: neopopGrey),
              prefixIcon:
                  const Icon(Icons.search_rounded, color: neopopGrey),
              filled: true,
              fillColor: neopopOnPrimary.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: neopopGrey.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: neopopAccent),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: neopopGrey.withOpacity(0.2)),
              ),
            ),
          ),
          SizedBox(height: height_8),
          Text(
            'We only use contacts on your device to find friends already on SplitO.',
            style: caption_text.copyWith(color: neopopGrey),
          ),
          SizedBox(height: height_16),
          Expanded(
            child: Obx(() {
              if (_friendsController.isSearching.value) {
                return const Center(child: LoadingWidget());
              }
              if (_friendsController.searchResults.isEmpty &&
                  _searchController.text.isNotEmpty) {
                return Center(
                  child: Text("No users found.",
                      style: body2_text.copyWith(color: neopopGrey)),
                );
              }
              if (_friendsController.searchResults.isEmpty) {
                return Center(
                  child: Text(
                    "Search for friends by their email address",
                    style: body2_text.copyWith(color: neopopGrey),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return ListView.separated(
                itemCount: _friendsController.searchResults.length,
                separatorBuilder: (_, __) => SizedBox(height: height_10),
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
      padding: EdgeInsets.all(width_16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Friends from your contact book who use SplitO',
            style: body2_text.copyWith(color: neopopGrey),
          ),
          SizedBox(height: height_16),
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
                          color: neopopGrey.withOpacity(0.4), size: 48),
                      SizedBox(height: height_10),
                      Text(
                        'No matching contacts found.\nGrant contact access or share your invite link.',
                        style: body2_text.copyWith(color: neopopGrey),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: height_16),
                      TextButton(
                        onPressed: () =>
                            _friendsController.loadContactMatches(),
                        child: Text('Retry',
                            style: body2_text.copyWith(color: neopopAccent)),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                itemCount: _friendsController.contactMatches.length,
                separatorBuilder: (_, __) => SizedBox(height: height_10),
                itemBuilder: (context, index) {
                  final match = _friendsController.contactMatches[index];
                  return _buildUserTile({
                    'user_id': match.userId,
                    'user_name': match.userName ?? match.contactName,
                    'user_email': match.email,
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
    return Container(
      padding: EdgeInsets.all(height_16),
      decoration: BoxDecoration(
        color: neopopOnPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: neopopGrey.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: height_10 * 4.4,
            height: height_10 * 4.4,
            decoration: BoxDecoration(
              color: getRandomBrightColor(),
              borderRadius: BorderRadius.circular(height_10 * 2.2),
            ),
            alignment: Alignment.center,
            child: Text(
              getInitials(user['user_name']?.toString() ?? '?'),
              style: body1_text.copyWith(
                  color: neopopBackground, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(width: width_10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['user_name']?.toString() ?? 'Unknown',
                  style: body1_text.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle ?? user['user_email']?.toString() ?? '',
                  style: caption_text.copyWith(color: neopopGrey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final uid = user['user_id']?.toString();
              if (uid != null) {
                final success =
                    await _friendsController.sendFriendRequest(uid);
                Fluttertoast.showToast(
                  msg: success
                      ? "Friend request sent!"
                      : "Failed to send request.",
                  backgroundColor: success ? neopopAccent : neopopYellow,
                  textColor: neopopBackground,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: neopopAccent,
              padding: EdgeInsets.symmetric(
                  horizontal: width_10, vertical: height_10 * 0.6),
            ),
            child: Text("Add",
                style: caption_text.copyWith(color: neopopOnBackground)),
          ),
        ],
      ),
    );
  }
}
