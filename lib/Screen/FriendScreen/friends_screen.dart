import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/shared.dart';
import 'package:splitter/Controller/friends_controller.dart';
import 'package:splitter/Model/friend_model.dart';
import 'package:splitter/Screen/FriendScreen/add_friend_screen.dart';
import 'package:splitter/Screen/FriendScreen/friend_detail_screen.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitter/Controller/notification_badge_controller.dart';
import 'package:splitter/Widgets/notification_bell_button.dart';
import 'package:splitter/Widgets/pill_tab_bar.dart';
import 'package:splitter/Widgets/tab_empty_state.dart';
import 'package:splitter/Services/supabase_service.dart';
import 'package:splitter/Widgets/user_avatar.dart';

const Color _lightBg = Color(0xFFFAFAFA);
const Color _cardBorder = Color(0xFFEEEEEE);
const double _actionButtonMinWidth = 76;

TextStyle _actionLabelStyle(Color color) => TextStyle(
      fontFamily: 'Poppins',
      fontSize: 12,
      fontWeight: FontWeight.w600,
      fontStyle: FontStyle.normal,
      color: color,
    );

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late final FriendsController _controller;
  late final TabController _tabController;
  String? _userID;
  final Set<String> _actionsInFlight = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_userID == null) {
      return Scaffold(
        backgroundColor: _lightBg,
        body: Center(
          child: Text(
            "Please log in.",
            style: body1_text.copyWith(color: groupOnSurface),
          ),
        ),
      );
    }

    return Scaffold(
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
          'Friends',
          style: headline3_text.copyWith(
            fontFamily: 'Albra',
            fontWeight: FontWeight.w600,
            color: groupOnSurface,
          ),
        ),
        actions: [
          const NotificationBellButton(),
          IconButton(
            onPressed: () async {
              final profile = await SupabaseDatabase()
                  .getCurrentUserProfile(userID: _userID!);
              final name = '${profile.firstName} ${profile.lastName}'.trim();
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
            icon: const Icon(Icons.person_add_rounded, color: groupOnSurface),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: LoadingWidget());
        }

        if (_controller.errorMessage.value.isNotEmpty) {
          return _buildErrorState();
        }

        final pendingCount = _controller.outgoingPendingRequests.length;
        final incomingCount = _controller.incomingPendingRequests.length;

        return NestedScrollView(
          headerSliverBuilder: (_, __) => [
            sliverPillTabBar(
              controller: _tabController,
              tabs: const ['Friends', 'Pending', 'Incoming'],
              badgeCounts: [null, pendingCount, incomingCount],
              backgroundColor: _lightBg,
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildFriendsTab(),
              _buildPendingTab(),
              _buildIncomingTab(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded,
              color: groupOnSurfaceMuted, size: 48),
          const SizedBox(height: groupGapMd),
          Text(
            _controller.errorMessage.value,
            style: body1_text.copyWith(color: groupOnSurfaceMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: groupGapMd),
          ElevatedButton(
            onPressed: () => _controller.fetchFriendsData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: neopopBackground,
            ),
            child: Text(
              "Retry",
              style: button_text.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsTab() {
    final friends = _controller.friendBalances;

    if (friends.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _controller.fetchFriendsData(),
        color: neopopAccent,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: const [
            TabEmptyState(
              title: 'Add friends to start splitting!',
              subtitle: 'Tap the + icon to search by email.',
              compact: true,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _controller.fetchFriendsData(),
      color: neopopAccent,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(
          groupGutter,
          groupGapMd,
          groupGutter,
          groupGapXl,
        ),
        itemCount: friends.length,
        itemBuilder: (context, index) => _buildFriendCard(friends[index]),
      ),
    );
  }

  Widget _buildPendingTab() {
    final requests = _controller.outgoingPendingRequests;

    if (requests.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _controller.fetchFriendsData(),
        color: neopopAccent,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: const [
            TabEmptyState(
              title: 'No pending requests',
              subtitle: 'Friend requests you send appear here.',
              compact: true,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _controller.fetchFriendsData(),
      color: neopopAccent,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(
          groupGutter,
          groupGapMd,
          groupGutter,
          groupGapXl,
        ),
        itemCount: requests.length,
        itemBuilder: (context, index) => _buildOutgoingCard(requests[index]),
      ),
    );
  }

  Widget _buildIncomingTab() {
    final requests = _controller.incomingPendingRequests;

    if (requests.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _controller.fetchFriendsData(),
        color: neopopAccent,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: const [
            TabEmptyState(
              title: 'No incoming requests',
              subtitle: "When someone adds you, they'll show up here.",
              compact: true,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _controller.fetchFriendsData(),
      color: neopopAccent,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(
          groupGutter,
          groupGapMd,
          groupGutter,
          groupGapXl,
        ),
        itemCount: requests.length,
        itemBuilder: (context, index) => _buildIncomingCard(requests[index]),
      ),
    );
  }

  Widget _buildLightCard({required Widget child, Color? tint}) {
    return Container(
      margin: const EdgeInsets.only(bottom: groupGapSm),
      padding: const EdgeInsets.all(groupGapMd),
      decoration: BoxDecoration(
        color: tint ?? Colors.white,
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
      child: child,
    );
  }

  Widget _buildRequestIdentity(FriendModel req) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UserAvatar(
          userID: req.friendUserID ?? 'unknown',
          userName: req.friendName ?? '?',
          imageUrl: req.friendPic,
          radius: 22,
          fontSize: 16,
        ),
        const SizedBox(width: groupGapSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                req.friendName ?? 'Unknown',
                style: body1_text.copyWith(
                  color: groupOnSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                req.friendEmail ?? '',
                style: body2_text.copyWith(
                  color: groupOnSurfaceMuted,
                  fontStyle: FontStyle.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIncomingCard(FriendModel req) {
    return _buildLightCard(
      tint: neopopYellow.withValues(alpha: 0.12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _buildRequestIdentity(req)),
          const SizedBox(width: groupGapSm),
          SizedBox(
            width: _actionButtonMinWidth,
            child: ElevatedButton(
              onPressed: () async {
                if (req.id != null) {
                  final success =
                      await _controller.acceptFriendRequest(req.id!);
                  Fluttertoast.showToast(
                    msg: success
                        ? "Friend request accepted!"
                        : "Failed to accept.",
                    backgroundColor: success ? neopopAccent : neopopYellow,
                    textColor: neopopBackground,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: neopopAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                minimumSize: const Size(_actionButtonMinWidth, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  Text('Accept', style: _actionLabelStyle(neopopOnBackground)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutgoingCard(FriendModel req) {
    final requestId = req.id;
    final isBusy =
        requestId != null && _actionsInFlight.contains(requestId);

    return _buildLightCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRequestIdentity(req),
          const SizedBox(height: groupGapSm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isBusy || requestId == null
                      ? null
                      : () => _onCancelRequest(req),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: groupOnSurfaceMuted,
                    side: BorderSide(color: _cardBorder),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Cancel', style: _actionLabelStyle(groupOnSurfaceMuted)),
                ),
              ),
              const SizedBox(width: groupGapSm),
              Expanded(
                child: ElevatedButton(
                  onPressed: isBusy || requestId == null
                      ? null
                      : () => _onRemindRequest(req),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neopopAccent,
                    disabledBackgroundColor:
                        neopopAccent.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      Text('Remind', style: _actionLabelStyle(neopopOnBackground)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onCancelRequest(FriendModel req) async {
    final requestId = req.id;
    if (requestId == null) return;

    setState(() => _actionsInFlight.add(requestId));
    final success = await _controller.cancelFriendRequest(requestId);
    if (mounted) setState(() => _actionsInFlight.remove(requestId));

    Fluttertoast.showToast(
      msg: success ? 'Request cancelled.' : 'Failed to cancel.',
      backgroundColor: success ? neopopAccent : neopopYellow,
      textColor: neopopBackground,
    );
  }

  Future<void> _onRemindRequest(FriendModel req) async {
    final requestId = req.id;
    if (requestId == null) return;

    setState(() => _actionsInFlight.add(requestId));
    final success = await _controller.remindFriendRequest(req);
    if (mounted) setState(() => _actionsInFlight.remove(requestId));

    Fluttertoast.showToast(
      msg: success ? 'Reminder sent.' : 'Failed to send reminder.',
      backgroundColor: success ? neopopAccent : neopopYellow,
      textColor: neopopBackground,
    );
  }

  Widget _buildFriendCard(FriendBalanceModel fb) {
    Color balanceColor;
    String balanceText;
    if (fb.netBalance > 0.01) {
      balanceColor = neopopAccent;
      balanceText = "owes you ₹${fb.netBalance.toStringAsFixed(2)}";
    } else if (fb.netBalance < -0.01) {
      balanceColor = const Color(0xFFE6A800);
      balanceText = "you owe ₹${fb.netBalance.abs().toStringAsFixed(2)}";
    } else {
      balanceColor = groupOnSurfaceMuted;
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
      child: _buildLightCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UserAvatar(
              userID: fb.friendUserID!,
              userName: fb.friendName ?? '?',
              imageUrl: fb.friendPic,
              radius: 24,
              fontSize: 18,
            ),
            const SizedBox(width: groupGapSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fb.friendName ?? 'Unknown',
                    style: body1_text.copyWith(
                      color: groupOnSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fb.friendEmail ?? '',
                    style: body2_text.copyWith(
                      color: groupOnSurfaceMuted,
                      fontStyle: FontStyle.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  balanceText,
                  style: _actionLabelStyle(balanceColor),
                ),
                if (fb.groupBreakdown.isNotEmpty)
                  Text(
                    "${fb.groupBreakdown.length} group${fb.groupBreakdown.length > 1 ? 's' : ''}",
                    style: body2_text.copyWith(
                      color: groupOnSurfaceMuted,
                      fontSize: 10,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded,
                color: groupOnSurfaceMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
