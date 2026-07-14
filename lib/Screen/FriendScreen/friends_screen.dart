import 'package:flutter/material.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:splitr/Utils/currency_utils.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/shared.dart';
import 'package:splitr/Controller/friends_controller.dart';
import 'package:splitr/Model/friend_model.dart';
import 'package:splitr/Screen/FriendScreen/add_friend_screen.dart';
import 'package:splitr/Screen/FriendScreen/friend_detail_screen.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Controller/notification_badge_controller.dart';
import 'package:splitr/Widgets/notification_bell_button.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';
import 'package:splitr/Widgets/pill_tab_bar.dart';
import 'package:splitr/Widgets/tab_empty_state.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Widgets/user_avatar.dart';

TextStyle _actionLabelStyle(Color color) => TextStyle(
      fontFamily: kFontPoppins,
      fontSize: splitrFontCaption,
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
    _tabController =
        TabController(length: FriendScreenLayout.tabCount, vsync: this);
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: Text(
            AppStrings.auth.pleaseLogIn,
            style: body1_text.copyWith(color: groupOnSurface),
          ),
        ),
      );
    }

    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: surface,
      appBar: SplitrDetailAppBar(
        title: AppStrings.friends.title,
        leading: SplitrDetailAppBar.iosBackLeading(
          context,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          const NotificationBellButton(),
          IconButton(
            onPressed: () async {
              final profile = await SupabaseDatabase()
                  .getCurrentUserProfile(userID: _userID!);
              final name = '${profile.firstName} ${profile.lastName}'.trim();
              await _controller.shareFriendInviteLink(
                name.isEmpty ? DisplayFallbacks.aFriend : name,
              );
            },
            icon: const Icon(Icons.link_rounded, color: neopopAccent),
            tooltip: AppStrings.a11y.shareInviteLink,
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
              tabs: [
                AppStrings.friends.tabFriends,
                AppStrings.friends.tabPending,
                AppStrings.friends.tabIncoming,
              ],
              badgeCounts: [null, pendingCount, incomingCount],
              backgroundColor: surface,
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
          const Icon(Icons.error_outline_rounded,
              color: groupOnSurfaceMuted, size: groupCtaHeightCompact),
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
              AppStrings.actions.retry,
              style: button_text.copyWith(color: neopopOnPrimary),
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
          children: [
            TabEmptyState(
              title: AppStrings.friends.addFriendsEmpty,
              subtitle: AppStrings.friends.addFriendsEmptySubtitle,
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
          children: [
            TabEmptyState(
              title: AppStrings.friends.noPendingRequests,
              subtitle: AppStrings.friends.noPendingSubtitle,
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
          children: [
            TabEmptyState(
              title: AppStrings.friends.noIncomingRequests,
              subtitle: AppStrings.friends.noIncomingSubtitle,
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
        color: tint ?? neopopOnPrimary,
        borderRadius: BorderRadius.circular(groupCardRadius),
        border: Border.all(color: groupMutedBorderHairline),
        boxShadow: [
          BoxShadow(
            color: groupSurfaceFillWhisper,
            blurRadius: AppDimensions.groupCardShadowBlur,
            offset: Offset(0, AppDimensions.groupCardShadowOffsetSmY),
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
          userID: req.friendUserID ?? DisplayFallbacks.unknown.toLowerCase(),
          userName: req.friendName ?? DisplayFallbacks.questionMark,
          imageUrl: req.friendPic,
          radius: 22,
          fontSize: splitrFontBodyLg,
        ),
        const SizedBox(width: groupGapSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                req.friendName ?? DisplayFallbacks.unknown,
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
            width: FriendScreenLayout.actionButtonMinWidth,
            child: ElevatedButton(
              onPressed: () async {
                if (req.id != null) {
                  final success =
                      await _controller.acceptFriendRequest(req.id!);
                  SplitrToast.show(success
                        ? AppStrings.friends.friendRequestAccepted
                        : AppStrings.friends.friendRequestFailed);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: neopopAccent,
                padding: const EdgeInsets.symmetric(
                    horizontal: groupGapSm, vertical: groupGapSm),
                minimumSize: const Size(
                  FriendScreenLayout.actionButtonMinWidth,
                  FriendScreenLayout.actionButtonMinHeight,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(groupControlRadiusSm),
                ),
              ),
              child: Text(AppStrings.actions.accept,
                  style: _actionLabelStyle(neopopOnBackground)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutgoingCard(FriendModel req) {
    final requestId = req.id;
    final isBusy = requestId != null && _actionsInFlight.contains(requestId);

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
                    side: BorderSide(color: groupMutedBorderHairline),
                    padding: const EdgeInsets.symmetric(vertical: groupGapSm),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(groupControlRadiusSm),
                    ),
                  ),
                  child: Text(AppStrings.actions.cancel,
                      style: _actionLabelStyle(groupOnSurfaceMuted)),
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
                    disabledBackgroundColor: neopopAccentIconMuted,
                    padding: const EdgeInsets.symmetric(vertical: groupGapSm),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(groupControlRadiusSm),
                    ),
                  ),
                  child: Text(AppStrings.friends.remind,
                      style: _actionLabelStyle(neopopOnBackground)),
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

    SplitrToast.show(success
          ? AppStrings.friends.requestCancelled
          : AppStrings.friends.requestCancelFailed);
  }

  Future<void> _onRemindRequest(FriendModel req) async {
    final requestId = req.id;
    if (requestId == null) return;

    setState(() => _actionsInFlight.add(requestId));
    final success = await _controller.remindFriendRequest(req);
    if (mounted) setState(() => _actionsInFlight.remove(requestId));

    SplitrToast.show(success
          ? AppStrings.friends.reminderSent
          : AppStrings.friends.reminderFailed);
  }

  Widget _buildFriendCard(FriendBalanceModel fb) {
    Color balanceColor;
    String balanceText;
    if (fb.netBalance > MoneyEpsilon.balanceSettled) {
      balanceColor = neopopAccent;
      balanceText =
          "${AppStrings.friends.owesYou} ${userCurrencySymbol()}${fb.netBalance.toStringAsFixed(DefaultDecimalPlaces.amount)}";
    } else if (fb.netBalance < -MoneyEpsilon.balanceSettled) {
      balanceColor = neopopOwe;
      balanceText =
          "${AppStrings.friends.youOwe} ${userCurrencySymbol()}${fb.netBalance.abs().toStringAsFixed(DefaultDecimalPlaces.amount)}";
    } else {
      balanceColor = groupOnSurfaceMuted;
      balanceText = AppStrings.friends.settledUp;
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
              userName: fb.friendName ?? DisplayFallbacks.questionMark,
              imageUrl: fb.friendPic,
              radius: 24,
              fontSize: splitrFontSubhead,
            ),
            const SizedBox(width: groupGapSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fb.friendName ?? DisplayFallbacks.unknown,
                    style: body1_text.copyWith(
                      color: groupOnSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: groupGap2),
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
                    '${fb.groupBreakdown.length}${AppStringFormat.groupCount(fb.groupBreakdown.length)}',
                    style: body2_text.copyWith(
                      color: groupOnSurfaceMuted,
                      fontSize: splitrFontMicro,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: groupGapXxs),
            const Icon(Icons.chevron_right_rounded,
                color: groupOnSurfaceMuted, size: AppDimensions.groupIconMd),
          ],
        ),
      ),
    );
  }
}
