import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/shared.dart';
import 'package:splitter/Controller/friends_controller.dart';
import 'package:splitter/Model/friend_model.dart';
import 'package:splitter/Widgets/dark_surface_theme.dart';
import 'package:splitter/Screen/FriendScreen/add_friend_screen.dart';
import 'package:splitter/Screen/FriendScreen/friend_detail_screen.dart';
import 'package:splitter/Controller/notification_badge_controller.dart';
import 'package:splitter/Widgets/notification_bell_button.dart';
import 'package:splitter/Services/supabase_service.dart';
import 'package:splitter/Widgets/user_avatar.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  late final FriendsController _controller;
  String? _userID;

  @override
  void initState() {
    super.initState();
    final uid = SupabaseAuth().supabaseGetUserID();
    _userID = uid.isNotEmpty ? uid : null;
    if (_userID != null) {
      _controller = Get.put(FriendsController(userID: _userID!));
      if (Get.isRegistered<NotificationBadgeController>()) {
        Get.find<NotificationBadgeController>().updateBadge();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userID == null) {
      return DarkSurfaceTheme(
        child: Scaffold(
        backgroundColor: neopopBackground,
        body: Center(
          child: Text("Please log in.", style: body1_text),
        ),
      ),
      );
    }

    return DarkSurfaceTheme(
      child: Scaffold(
      backgroundColor: neopopBackground,
      appBar: AppBar(
        backgroundColor: neopopBackground,
        title: Text("Friends", style: headline2_text),
        actions: [
          const NotificationBellButton(iconColor: neopopOnPrimary),
          IconButton(
            onPressed: () async {
              final profile = await SupabaseDatabase()
                  .getCurrentUserProfile(userID: _userID!);
              final name =
                  '${profile.firstName} ${profile.lastName}'.trim();
              await _controller.shareFriendInviteLink(
                name.isEmpty ? 'A friend' : name,
              );
            },
            icon: const Icon(Icons.link_rounded, color: neopopAccent),
            tooltip: 'Share invite link',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddFriendScreen(userID: _userID!),
                ),
              ).then((_) => _controller.fetchFriendsData());
            },
            icon: const Icon(Icons.person_add_rounded, color: neopopAccent),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width_16),
          child: Obx(() {
            if (_controller.isLoading.value) {
              return const Center(child: LoadingWidget());
            }

            if (_controller.errorMessage.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: neopopGrey, size: height_10 * 4.8),
                    SizedBox(height: height_16),
                    Text(
                      _controller.errorMessage.value,
                      style: body1_text.copyWith(color: neopopGrey),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: height_16),
                    ElevatedButton(
                      onPressed: () => _controller.fetchFriendsData(),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: neopopAccent),
                      child: Text("Retry",
                          style:
                              button_text.copyWith(color: neopopOnBackground)),
                    ),
                  ],
                ),
              );
            }

            final hasPending = _controller.pendingRequests.isNotEmpty;
            final hasFriends = _controller.friendBalances.isNotEmpty;

            if (!hasPending && !hasFriends) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline_rounded,
                        color: neopopAccent, size: height_10 * 6),
                    SizedBox(height: height_16),
                    Text("Add friends to start splitting!",
                        style: headline2_text.copyWith(color: neopopAccent)),
                    SizedBox(height: height_10),
                    Text("Tap the + icon to search by email.",
                        style: body2_text.copyWith(color: neopopGrey)),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => _controller.fetchFriendsData(),
              color: neopopAccent,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                children: [
                  // Pending requests section
                  if (hasPending) ...[
                    Text("Pending Requests",
                        style:
                            sub_headline4_text.copyWith(color: neopopYellow)),
                    SizedBox(height: height_10),
                    ..._controller.pendingRequests
                        .map((req) => _buildPendingCard(req)),
                    SizedBox(height: height_16 * 1.5),
                  ],

                  // Friends list
                  if (hasFriends) ...[
                    Text("Your Friends", style: sub_headline4_text),
                    SizedBox(height: height_10),
                    ..._controller.friendBalances
                        .map((fb) => _buildFriendCard(fb)),
                  ],
                ],
              ),
            );
          }),
        ),
      ),
    ),
    );
  }

  Widget _buildPendingCard(FriendModel req) {
    return Container(
      margin: EdgeInsets.only(bottom: height_10),
      padding: EdgeInsets.all(height_16),
      decoration: BoxDecoration(
        color: neopopYellow.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: neopopYellow.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          UserAvatar(
            userID: req.friendEmail ??
                req.friendName ??
                'unknown', // Best effort ID for pending
            userName: req.friendName ?? '?',
            radius: height_10 * 2.2,
            fontSize: 16,
          ),
          SizedBox(width: width_10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(req.friendName ?? 'Unknown', style: body1_text),
                Text(req.friendEmail ?? '',
                    style: caption_text.copyWith(color: neopopGrey)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (req.id != null) {
                final success = await _controller.acceptFriendRequest(req.id!);
                Fluttertoast.showToast(
                  msg: success
                      ? "Friend request accepted! ✅"
                      : "Failed to accept.",
                  backgroundColor: success ? neopopAccent : neopopYellow,
                  textColor: neopopBackground,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: neopopAccent,
              padding: EdgeInsets.symmetric(
                  horizontal: width_10, vertical: height_10 * 0.6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            child: Text("Accept",
                style: caption_text.copyWith(color: neopopOnBackground)),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendCard(FriendBalanceModel fb) {
    Color balanceColor;
    String balanceText;
    if (fb.netBalance > 0.01) {
      balanceColor = neopopAccent;
      balanceText = "owes you ₹${fb.netBalance.toStringAsFixed(2)}";
    } else if (fb.netBalance < -0.01) {
      balanceColor = neopopYellow;
      balanceText = "you owe ₹${fb.netBalance.abs().toStringAsFixed(2)}";
    } else {
      balanceColor = neopopGrey;
      balanceText = "settled up";
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FriendDetailScreen(
              friendBalance: fb,
              userID: _userID,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: height_10),
        padding: EdgeInsets.all(height_16),
        decoration: BoxDecoration(
          color: neopopOnPrimary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: neopopGrey.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            UserAvatar(
              userID: fb.friendUserID!,
              userName: fb.friendName ?? '?',
              radius: height_10 * 2.4,
              fontSize: 18,
            ),
            SizedBox(width: width_10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fb.friendName ?? 'Unknown',
                      style: body1_text.copyWith(fontWeight: FontWeight.w600)),
                  SizedBox(height: height_10 * 0.3),
                  Text(fb.friendEmail ?? '',
                      style: caption_text.copyWith(color: neopopGrey),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  balanceText,
                  style: caption_text.copyWith(
                      color: balanceColor, fontWeight: FontWeight.w600),
                ),
                if (fb.groupBreakdown.isNotEmpty)
                  Text(
                    "${fb.groupBreakdown.length} group${fb.groupBreakdown.length > 1 ? 's' : ''}",
                    style: caption_text.copyWith(
                      color: neopopGrey,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
            SizedBox(width: width_10 * 0.5),
            Icon(Icons.chevron_right_rounded,
                color: neopopGrey, size: height_10 * 2),
          ],
        ),
      ),
    );
  }
}
