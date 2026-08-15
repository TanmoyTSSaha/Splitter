import 'package:flutter/material.dart';
import 'package:splitr/Widgets/splitr_toast.dart';

import 'package:get/get.dart';
import 'package:splitr/Bindings/app_bindings.dart';
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/sync_indicator_widget.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/glass_card.dart';
import 'package:splitr/Constants/gradient_mesh_background.dart';
import 'package:splitr/Constants/shared.dart';
import 'package:splitr/Controller/group_screen_controller.dart';
import 'package:splitr/Controller/profile_controller.dart';
import 'package:splitr/Controllers/premium_subscription_controller.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Model/group_model.dart';
import 'package:splitr/Model/trip_model.dart';
import 'package:splitr/Model/user_details_model.dart';
import 'package:splitr/Screen/GroupScreen/add_carousel_card.dart';
import 'package:splitr/Screen/GroupScreen/create_group_screen.dart';
import 'package:splitr/Screen/GroupScreen/group_empty_state_widget.dart';
import 'package:splitr/Screen/GroupScreen/group_detailed_screen.dart';
import 'package:splitr/Screen/ProfileScreen/premium_plan_screen.dart';
import 'package:splitr/Screen/TripScreen/create_trip_screen.dart';
import 'package:splitr/Repository/group_repository.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Services/trip_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/Services/SupabaseServices/transaction_service.dart';
import 'package:splitr/Controller/notification_badge_controller.dart';
import 'package:splitr/Widgets/notification_bell_button.dart';
import 'package:splitr/Widgets/user_avatar.dart';
import 'package:splitr/Widgets/summary_stat_card.dart';
import 'package:splitr/Widgets/active_group_card.dart';
import 'package:splitr/Widgets/trip_gradient_card.dart';
import 'package:splitr/Widgets/transaction_tile.dart';
import 'package:splitr/Screen/HomeScreen/all_transactions_screen.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Widgets/tab_empty_state.dart';
import 'package:splitr/Widgets/pill_tab_bar.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/app_dimensions.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen>
    with SingleTickerProviderStateMixin {
  final String userID = SupabaseAuth().supabaseGetUserID();
  final TripService _tripService = TripService();
  late final GroupScreenController _groupController;

  late TabController _tabController;
  int _selectedTabIndex = 0;
  String _selectedCurrency = CurrencyDefaults.code;
  Worker? _currencyWorker;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<GroupScreenController>()) {
      AppBindings().dependencies();
    }
    _groupController = Get.find<GroupScreenController>();
    _groupController.initialize(userID);
    if (Get.isRegistered<NotificationBadgeController>()) {
      Get.find<NotificationBadgeController>().updateBadge();
    }
    final cc = Get.find<CurrencyController>();
    _selectedCurrency = cc.code;
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    // Rebuild FutureBuilders when currency changes
    _currencyWorker = ever(cc.rxCode, (newCode) {
      setState(() => _selectedCurrency = newCode);
    });
  }

  @override
  void dispose() {
    _currencyWorker?.dispose();
    _tabController.dispose();
    _groupController.unsubscribeFromGroupRealtime();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = Get.find<ProfileController>();
    return Obx(() {
      if (profile.errorMessage.value != null && profile.user.value == null) {
        return _buildErrorState();
      }
      final userDetails = profile.user.value;
      if (userDetails == null) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Center(child: LoadingWidget()),
        );
      }

      return Obx(() {
        if (_groupController.isLoadingGroups.value &&
            _groupController.groups.isEmpty) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: Center(child: LoadingWidget()),
          );
        }

        if (_groupController.groups.isEmpty) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: _buildAppBar(userDetails),
            body: Column(
              children: [
                SyncStatusBanner(
                  status: _groupController.syncStatus.value,
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _groupController.refreshGroups,
                    child: GroupEmptyState(
                      onActionComplete: _groupController.refreshGroups,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final groups = _groupController.groups.toList();
        // Filter groups based on selected tab for stats
        final filterIsTrip = _selectedTabIndex == 1;
        final filteredGroups =
            groups.where((g) => g.isTrip == filterIsTrip).toList();
        final stats = _calculateOverallStats(filteredGroups);

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: _buildAppBar(userDetails),
          body: Column(
            children: [
              SyncStatusBanner(status: _groupController.syncStatus.value),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _groupController.refreshGroups,
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      SliverToBoxAdapter(
                        child: GradientMeshBackground(
                          child: GlassCard(
                            margin: const EdgeInsets.symmetric(
                                horizontal: groupGutter, vertical: groupGapSm),
                            opacity: AppDimensions.glassCardOpacityHome,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.home.tagline,
                                  style: TextStyle(
                                    fontFamily: kFontAlbra,
                                    fontSize: splitrFontHeadline1,
                                    height: 1.2,
                                    color: neopopBackground,
                                  ),
                                ),
                                const SizedBox(height: groupGapLg),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SummaryStatCard(
                                        title: AppStrings.groups.youAreOwed,
                                        amount: stats['toReceive']!
                                            .toStringAsFixed(0),
                                        subtitle:
                                            AppStringFormat.fromGroupsCount(
                                                groups
                                                    .where((g) => (g
                                                            .groupBalance
                                                            ?.any((b) =>
                                                                b.donorID ==
                                                                userID) ??
                                                        false))
                                                    .length),
                                        isPositive: true,
                                      ),
                                    ),
                                    const SizedBox(width: groupCarouselGap),
                                    Expanded(
                                      child: SummaryStatCard(
                                        title: AppStrings.groups.youOwe,
                                        amount:
                                            stats['toPay']!.toStringAsFixed(0),
                                        subtitle: AppStringFormat.toGroupsCount(
                                            groups
                                                .where((g) => (g.groupBalance
                                                        ?.any((b) =>
                                                            b.receiverID ==
                                                            userID) ??
                                                    false))
                                                .length),
                                        isPositive: false,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: groupGapSm),
                              ],
                            ),
                          ),
                        ),
                      ),
                      sliverPillTabBar(
                        controller: _tabController,
                        tabs: [
                          AppStrings.groups.groupExpenseTab,
                          AppStrings.groups.tripExpenseTab,
                        ],
                      ),
                    ],
                    body: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildGroupsTabContent(groups),
                        _buildTripsTabContent(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(
                bottom: groupFabClearance + AppDimensions.groupFabExtraPadding),
            child: _buildExpandableFab(),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      });
    });
  }

  Map<String, double> _calculateOverallStats(List<GroupModel> groups) {
    double toReceive = 0;
    double toPay = 0;

    for (var group in groups) {
      if (group.groupBalance == null) continue;

      for (var balance in group.groupBalance!) {
        // If I am the receiver, I am the DEBTOR (I borrowed), so I must PAY
        if (balance.receiverID == userID) {
          toPay += balance.amount ?? 0;
        }
        // If I am the donor, I am the CREDITOR (I lent), so I will RECEIVE
        else if (balance.donorID == userID) {
          toReceive += balance.amount ?? 0;
        }
      }
    }

    return {'toReceive': toReceive, 'toPay': toPay};
  }

  PreferredSizeWidget _buildAppBar(UserDetails user) {
    return AppBar(
      backgroundColor: groupTransparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: Text(
        AppBranding.brandLogo,
        style: TextStyle(
          fontFamily: kFontAlbra,
          fontSize: splitrFontHeadline2,
          fontWeight: FontWeight.w700,
          color: neopopBackground,
        ),
      ),
      actions: [
        const NotificationBellButton(),
        const SizedBox(width: groupGap10),
        UserAvatar(
          userID: user.userID ?? SupabaseAuth().supabaseGetUserID(),
          userName: "${user.firstName} ${user.lastName}",
          imageUrl: user.profilePictureURL,
          radius: 20,
        ),
        const SizedBox(width: groupGutter),
      ],
    );
  }

  Widget _buildGroupsTabContent(List<GroupModel> groups) {
    final onlyGroups = groups
        .where((g) =>
            !g.isTrip && (_groupController.showArchived.value || !g.isArchived))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
          horizontal: groupGutter, vertical: groupGapLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSectionHeader(
                    AppStrings.groups.activeGroups, onlyGroups.length),
              ),
              Obx(() => TextButton(
                    onPressed: () => _groupController.showArchived.value =
                        !_groupController.showArchived.value,
                    child: Text(
                      _groupController.showArchived.value
                          ? AppStrings.groups.hideArchived
                          : AppStrings.groups.showArchived,
                      style: caption_text.copyWith(color: neopopAccent),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: groupGapMd),
          SizedBox(
            height: groupCarouselCardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: onlyGroups.length + 1,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: groupCarouselGap),
              itemBuilder: (context, index) {
                if (index == onlyGroups.length) {
                  return AddCarouselCard(
                    label: AppStrings.groups.newGroup,
                    icon: Icons.groups_2_rounded,
                    onTap: _openCreateGroup,
                  );
                }
                return ActiveGroupCard(
                  groupModel: onlyGroups[index],
                  onTap: () => Get.to(() => GroupDetailedScreen(
                        groupModel: onlyGroups[index],
                        userID: userID,
                      )),
                );
              },
            ),
          ),
          const SizedBox(height: groupGapXl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.groups.recentActivity,
                style: caption_text.copyWith(
                  color: neopopGrey,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                  letterSpacing: AppDimensions.letterSpacingSection,
                ),
              ),
              TextButton(
                onPressed: () => Get.to(() => AllTransactionsScreen(
                      isGroupFilter: true,
                      groups: onlyGroups,
                    )),
                child: Text(AppStrings.actions.viewAll,
                    style: body2_text.copyWith(
                        color: neopopBackground, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: groupGapMd),
          _buildRecentActivityFeed(isTrip: false, groups: onlyGroups),
          const SizedBox(height: groupGapXl),
          _buildProBanner(),
          const SizedBox(height: groupFabClearance),
        ],
      ),
    );
  }

  Widget _buildTripsTabContent() {
    return FutureBuilder<List<TripModel>>(
      future: _tripService.getTrips(userID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LoadingWidget());
        }
        final trips = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: groupGutter, vertical: groupGapLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(AppStrings.groups.myTrips, trips.length),
              const SizedBox(height: groupGapMd),
              SizedBox(
                height: groupCarouselCardHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: trips.length + 1,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: groupCarouselGap),
                  itemBuilder: (context, index) {
                    if (index == trips.length) {
                      return AddCarouselCard(
                        label: AppStrings.groups.newTrip,
                        icon: Icons.flight_takeoff_rounded,
                        onTap: _openCreateTrip,
                      );
                    }
                    return TripGradientCard(
                      trip: trips[index],
                      onTap: () => _navigateToTrip(trips[index]),
                    );
                  },
                ),
              ),
              const SizedBox(height: groupGapXl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.groups.recentTripActivity,
                    style: caption_text.copyWith(
                      color: neopopGrey,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      letterSpacing: AppDimensions.letterSpacingSection,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.to(() => AllTransactionsScreen(
                          isTripFilter: true,
                          tripGroupIds: trips
                              .map((t) => t.groupId)
                              .whereType<String>()
                              .toSet(),
                        )),
                    child: Text(AppStrings.actions.viewAll,
                        style: body2_text.copyWith(
                            color: neopopBackground,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: groupGapMd),
              _buildRecentActivityFeed(
                  isTrip: true,
                  groups: trips.map((t) => t).toList(),
                  tripGroupIds:
                      trips.map((t) => t.groupId).whereType<String>().toSet()),
              const SizedBox(height: groupGapXl),
              _buildProBanner(),
              const SizedBox(height: groupFabClearance),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, int? count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: caption_text.copyWith(
            color: neopopGrey,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.bold,
            letterSpacing: AppDimensions.letterSpacingSection,
          ),
        ),
        if (count != null)
          Container(
            padding: const EdgeInsets.all(groupGapXs),
            decoration: BoxDecoration(
              color: groupMutedFillWhisper,
              shape: BoxShape.circle,
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                  fontSize: splitrFontMicro, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentActivityFeed(
      {required bool isTrip,
      List<dynamic>? groups,
      Set<String>? tripGroupIds}) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: TransactionService().getUnifiedTransactions(
        userID: userID,
        limit: 10,
        selectedCurrency: _selectedCurrency,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LoadingWidget());
        }
        final allTxns = snapshot.data ?? [];
        // Filter group transactions only
        final groupTxns = allTxns
            .where((t) => t[UnifiedTxnKeys.type] == TransactionTypes.group)
            .toList();

        // Filter by trip vs non-trip group IDs
        List<Map<String, dynamic>> filteredTxns;
        if (isTrip && tripGroupIds != null) {
          filteredTxns = groupTxns
              .where((t) => tripGroupIds.contains(t[UnifiedTxnKeys.groupId]))
              .toList();
        } else if (!isTrip && groups != null) {
          final nonTripGroupIds = groups
              .whereType<GroupModel>()
              .map((g) => g.groupID)
              .whereType<String>()
              .toSet();
          filteredTxns = groupTxns
              .where((t) => nonTripGroupIds.contains(t[UnifiedTxnKeys.groupId]))
              .toList();
        } else {
          filteredTxns = groupTxns;
        }

        if (filteredTxns.isEmpty) {
          return TabEmptyState(
            title: AppStrings.groups.noRecentActivity,
            variant: TabEmptyVariant.activity,
            compact: true,
          );
        }

        return Column(
          children: filteredTxns
              .map(
                (txn) => TransactionTile(
                  txn: txn,
                  currencySymbol: Get.find<CurrencyController>().symbol,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildProBanner() {
    return Obx(() {
      if (Get.find<PremiumSubscriptionController>().isPremium.value) {
        return const SizedBox.shrink();
      }
      return GestureDetector(
        onTap: () => Get.to(() => const PremiumPlanScreen()),
        child: SizedBox(
          width: double.infinity,
          height: 150,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(groupCardRadius),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: groupMutedBorder,
                ),
                borderRadius: BorderRadius.circular(groupCardRadius),
              ),
              child: Stack(
                children: [
                  Container(
                    color: groupCardFill,
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _DiagonalLinePainter(
                        lineColor: groupMutedFillLight,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppStrings.premium.membership,
                          style: TextStyle(
                            fontFamily: kFontPoppins,
                            fontSize: splitrFontMicro,
                            fontWeight: FontWeight.w500,
                            color: groupOnSurfaceMuted,
                            letterSpacing: AppDimensions.letterSpacingProWide,
                          ),
                        ),
                        const SizedBox(height: groupGap10),
                        Text(
                          AppStringFormat.upgradeToBrandPro(
                              AppBranding.brandPro),
                          style: TextStyle(
                            fontFamily: kFontAlbra,
                            fontSize: splitrFontHeadline2,
                            fontWeight: FontWeight.w300,
                            fontStyle: FontStyle.normal,
                            color: groupOnSurface,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: groupGap10),
                        Text(
                          AppStrings.groups.unlockReceiptExports,
                          style: TextStyle(
                            fontFamily: kFontPoppins,
                            fontSize: splitrFontCaption,
                            color: groupOnSurfaceMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void _navigateToTrip(TripModel trip) async {
    // Show loading while fetching details
    Get.dialog(const Center(child: LoadingWidget()), barrierDismissible: false);

    try {
      // Fetch GroupModel for the trip to use in GroupDetailedScreen
      final groupModel =
          await Get.find<GroupRepository>().getGroupModel(trip.groupId);

      Get.back(); // Close loading

      if (groupModel != null) {
        Get.to(() => GroupDetailedScreen(
              groupModel: groupModel,
              userID: userID,
              tripModel: trip, // Pass TripModel for timeline data
            ));
      } else {
        SplitrToast.show(SplitrToast.join(AppStrings.errors.errorTitle, AppStrings.errors.couldNotLoadTripDetails));
      }
    } catch (e, stack) {
      Get.back();
      AppErrorReporter.report(
        AppStrings.errors.couldNotLoadTripDetails,
        error: e,
        stack: stack,
      );
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppStrings.errors.generic,
            style: sub_headline5_text.copyWith(color: neopopAccent),
          ),
          const SizedBox(height: groupGapMd),
          TextButton(
            onPressed: _groupController.refreshGroups,
            child: Text(
              AppStrings.actions.tryAgain,
              style: body2_text.copyWith(color: neopopAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableFab() {
    return FloatingActionButton.extended(
      heroTag: HeroTags.groupsFab,
      onPressed: _showCreateOptions,
      backgroundColor: neopopAccent,
      icon: const Icon(Icons.add, color: neopopBackground),
      label: Text(
        _selectedTabIndex == 0
            ? AppStrings.groups.newGroup
            : AppStrings.groups.newTrip,
        style: body1_text.copyWith(
            color: neopopBackground, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showCreateOptions() {
    if (_selectedTabIndex == 1) {
      _openCreateTrip();
    } else {
      _openCreateGroup();
    }
  }

  Future<void> _openCreateGroup() async {
    final created = await Get.to(() => const CreateGroupScreen());
    if (created == true) await _groupController.refreshGroups();
  }

  Future<void> _openCreateTrip() async {
    final created = await Get.to(() => const CreateTripScreen());
    if (created == true) setState(() {});
  }
}

/// Custom painter that draws 45° diagonal lines over the pro banner.
class _DiagonalLinePainter extends CustomPainter {
  const _DiagonalLinePainter({required this.lineColor});

  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Draw lines at exactly 45° across the full bounding box
    // Spacing between lines (perpendicular distance)
    const double spacing = 16.0;
    final double diagonal = size.width + size.height;
    final int count = (diagonal / spacing).ceil() + 2;

    for (int i = -count; i <= count; i++) {
      final double x0 = i * spacing;
      // Line goes from (x0, 0) to (x0 + size.height, size.height) at 45°
      canvas.drawLine(
        Offset(x0, 0),
        Offset(x0 + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DiagonalLinePainter oldDelegate) =>
      oldDelegate.lineColor != lineColor;
}
