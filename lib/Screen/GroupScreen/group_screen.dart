import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:splitter/Bindings/app_bindings.dart';
import 'package:splitter/Constants/sync_indicator_widget.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/glass_card.dart';
import 'package:splitter/Constants/gradient_mesh_background.dart';
import 'package:splitter/Constants/shared.dart';
import 'package:splitter/Controller/group_screen_controller.dart';
import 'package:splitter/Controllers/premium_subscription_controller.dart';
import 'package:splitter/Controllers/currency_controller.dart';
import 'package:splitter/Model/group_model.dart';
import 'package:splitter/Model/trip_model.dart';
import 'package:splitter/Model/user_details_model.dart';
import 'package:splitter/Screen/GroupScreen/add_carousel_card.dart';
import 'package:splitter/Screen/GroupScreen/create_group_screen.dart';
import 'package:splitter/Screen/GroupScreen/group_empty_state_widget.dart';
import 'package:splitter/Screen/GroupScreen/group_detailed_screen.dart';
import 'package:splitter/Screen/ProfileScreen/premium_plan_screen.dart';
import 'package:splitter/Screen/TripScreen/create_trip_screen.dart';
import 'package:splitter/Services/supabase_service.dart';
import 'package:splitter/Services/trip_service.dart';
import 'package:splitter/Services/SupabaseServices/transaction_service.dart';
import 'package:splitter/Controller/notification_badge_controller.dart';
import 'package:splitter/Widgets/notification_bell_button.dart';
import 'package:splitter/Widgets/user_avatar.dart';
import 'package:splitter/Widgets/summary_stat_card.dart';
import 'package:splitter/Widgets/active_group_card.dart';
import 'package:splitter/Widgets/trip_gradient_card.dart';
import 'package:splitter/Widgets/transaction_tile.dart';
import 'package:splitter/Screen/HomeScreen/all_transactions_screen.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitter/Widgets/tab_empty_state.dart';
import 'package:splitter/Widgets/pill_tab_bar.dart';

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
  String _selectedCurrency = 'INR';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserDetails>(
      future: SupabaseDatabase().getCurrentUserProfile(userID: userID),
      builder: (context, userDetailsSnapshot) {
        if (userDetailsSnapshot.hasData) {
          return Obx(() {
            if (_groupController.isLoadingGroups.value &&
                _groupController.groups.isEmpty) {
              return const Scaffold(
                backgroundColor: Colors.white,
                body: Center(child: LoadingWidget()),
              );
            }

            if (_groupController.groups.isEmpty) {
              return Scaffold(
                backgroundColor: Colors.white,
                appBar: _buildAppBar(userDetailsSnapshot.data!),
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
              backgroundColor: Colors.white,
              appBar: _buildAppBar(userDetailsSnapshot.data!),
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
                          opacity: 0.1,
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "money matters,\nsimplified.",
                              style: TextStyle(
                                fontFamily: 'Albra',
                                fontSize: 32,
                                height: 1.2,
                                color: neopopBackground,
                              ),
                            ),
                            const SizedBox(height: groupGapLg),
                            Row(
                              children: [
                                Expanded(
                                  child: SummaryStatCard(
                                    title: "YOU ARE OWED",
                                    amount:
                                        stats['toReceive']!.toStringAsFixed(0),
                                    subtitle:
                                        "from ${groups.where((g) => (g.groupBalance?.any((b) => b.donorID == userID) ?? false)).length} groups",
                                    isPositive: true,
                                  ),
                                ),
                                const SizedBox(width: groupCarouselGap),
                                Expanded(
                                  child: SummaryStatCard(
                                    title: "YOU OWE",
                                    amount: stats['toPay']!.toStringAsFixed(0),
                                    subtitle:
                                        "to ${groups.where((g) => (g.groupBalance?.any((b) => b.receiverID == userID) ?? false)).length} groups",
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
                      tabs: const ['Group Expense', 'Trip Expense'],
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
                padding: const EdgeInsets.only(bottom: groupFabClearance + 10),
                child: _buildExpandableFab(),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
            );
          });
        } else if (userDetailsSnapshot.hasError) {
          return _buildErrorState();
        }
        return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: LoadingWidget()),
        );
      },
    );
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
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: false,
      title: const Text(
        "Splitr.",
        style: TextStyle(
          fontFamily: 'Albra',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: neopopBackground,
        ),
      ),
      actions: [
        const NotificationBellButton(),
        SizedBox(width: width_10),
        UserAvatar(
          userID: user.userID ?? SupabaseAuth().supabaseGetUserID(),
          userName: "${user.firstName} ${user.lastName}",
          imageUrl: user.profilePictureURL,
          radius: 20,
        ),
        SizedBox(width: width_16),
      ],
    );
  }

  Widget _buildGroupsTabContent(List<GroupModel> groups) {
    final onlyGroups = groups.where((g) => !g.isTrip).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
          horizontal: groupGutter, vertical: groupGapLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("active groups", onlyGroups.length),
          const SizedBox(height: groupGapMd),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: onlyGroups.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: groupCarouselGap),
              itemBuilder: (context, index) {
                if (index == onlyGroups.length) {
                  return AddCarouselCard(
                    label: 'New Group',
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
                "RECENT ACTIVITY",
                style: caption_text.copyWith(
                  color: neopopGrey,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              TextButton(
                onPressed: () => Get.to(() => AllTransactionsScreen(
                      isGroupFilter: true,
                      groups: onlyGroups,
                    )),
                child: Text("VIEW ALL",
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
              _buildSectionHeader("my trips", trips.length),
              const SizedBox(height: groupGapMd),
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: trips.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: groupCarouselGap),
                  itemBuilder: (context, index) {
                    if (index == trips.length) {
                      return AddCarouselCard(
                        label: 'New Trip',
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
                    "RECENT TRIP ACTIVITY",
                    style: caption_text.copyWith(
                      color: neopopGrey,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
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
                    child: Text("VIEW ALL",
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
            letterSpacing: 1.2,
          ),
        ),
        if (count != null)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: neopopSecondaryGrey.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
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
        final groupTxns = allTxns.where((t) => t['type'] == 'group').toList();

        // Filter by trip vs non-trip group IDs
        List<Map<String, dynamic>> filteredTxns;
        if (isTrip && tripGroupIds != null) {
          filteredTxns = groupTxns
              .where((t) => tripGroupIds.contains(t['group_id']))
              .toList();
        } else if (!isTrip && groups != null) {
          final nonTripGroupIds = groups
              .whereType<GroupModel>()
              .map((g) => g.groupID)
              .whereType<String>()
              .toSet();
          filteredTxns = groupTxns
              .where((t) => nonTripGroupIds.contains(t['group_id']))
              .toList();
        } else {
          filteredTxns = groupTxns;
        }

        if (filteredTxns.isEmpty) {
          return const TabEmptyState(
            title: 'No recent activity',
            variant: TabEmptyVariant.activity,
            compact: true,
          );
        }

        return Column(
          children:
              filteredTxns.map((txn) => TransactionTile(txn: txn)).toList(),
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
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Container(
                  color: const Color(0xFF111827),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DiagonalLinePainter(),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "PRO MEMBERSHIP",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white54,
                          letterSpacing: 2.5,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "upgrade to splitr pro.",
                        style: TextStyle(
                          fontFamily: 'Albra',
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.normal,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Unlock receipt scanning & exports \u2192",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
      final groupModel = await SupabaseDatabase().getGroupModel(trip.groupId);

      Get.back(); // Close loading

      if (groupModel != null) {
        Get.to(() => GroupDetailedScreen(
              groupModel: groupModel,
              userID: userID,
              tripModel: trip, // Pass TripModel for timeline data
            ));
      } else {
        Get.snackbar("Error", "Could not load trip details");
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "Could not load trip details");
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Text(
        "Something went wrong!",
        style: sub_headline5_text.copyWith(color: neopopAccent),
      ),
    );
  }

  Widget _buildExpandableFab() {
    return FloatingActionButton.extended(
      heroTag: 'groups_fab',
      onPressed: _showCreateOptions,
      backgroundColor: neopopAccent,
      icon: const Icon(Icons.add, color: neopopBackground),
      label: Text(
        _selectedTabIndex == 0 ? "New Group" : "New Trip",
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
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.07)
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
  bool shouldRepaint(covariant _DiagonalLinePainter oldDelegate) => false;
}
