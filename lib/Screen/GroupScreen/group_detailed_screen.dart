import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:splitter/Bindings/app_bindings.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/sync_indicator_widget.dart';
import 'package:splitter/Controller/group_screen_controller.dart';
import 'package:splitter/Model/group_model.dart';
import 'package:splitter/Model/trip_model.dart';
import 'package:splitter/Screen/GroupScreen/add_transaction_screen.dart';
import 'package:splitter/Screen/GroupScreen/analytics_tab.dart';
import 'package:splitter/Screen/GroupScreen/members_tab.dart';
import 'package:splitter/Screen/GroupScreen/settle_up_tab.dart';
import 'package:splitter/Screen/GroupScreen/transaction_tab.dart';
import 'package:splitter/Screen/GroupScreen/wishlist_tab.dart';
import 'package:splitter/Screen/TripScreen/trip_timeline_screen.dart';

import 'package:neopop/neopop.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import '../../Constants/shared.dart';
import 'package:splitter/Services/export_service.dart';
import 'package:splitter/Services/invite_link_service.dart';
import 'package:splitter/Services/supabase_service.dart';
import 'package:splitter/Widgets/group_reminder_settings_sheet.dart';
import 'package:splitter/Widgets/premium_gate.dart';
import 'activity_feed_tab.dart';
import 'add_member_screen.dart';
import 'manual_settle_up_screen.dart';

class GroupDetailedScreen extends StatefulWidget {
  final GroupModel groupModel;
  final String userID;
  final TripModel? tripModel;

  const GroupDetailedScreen({
    required this.groupModel,
    required this.userID,
    this.tripModel,
    super.key,
  });

  @override
  State<GroupDetailedScreen> createState() => _GroupDetailedScreenState();
}

class _GroupDetailedScreenState extends State<GroupDetailedScreen> {
  late final GroupScreenController _groupScreenController;
  final GlobalKey<WishlistTabState> _wishlistTabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<GroupScreenController>()) {
      AppBindings().dependencies();
    }
    _groupScreenController = Get.find<GroupScreenController>();
    _groupScreenController.wishlistHasItems.value = false;
    _groupScreenController.initialize(widget.userID);
    _groupScreenController.subscribeToGroupRealtime(widget.groupModel.groupID!);
  }

  @override
  void dispose() {
    _groupScreenController.wishlistHasItems.value = false;
    _groupScreenController.unsubscribeFromGroupRealtime();
    super.dispose();
  }

  void _showGroupActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined,
                  color: neopopAccent),
              title: Text('Reminder settings',
                  style: body1_text.copyWith(color: neopopBackground)),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  final members = await SupabaseDatabase().getGroupMembers(
                    groupID: widget.groupModel.groupID!,
                    currentUserID: widget.userID,
                  );
                  if (context.mounted) {
                    await GroupReminderSettingsSheet.show(
                      context,
                      groupId: widget.groupModel.groupID!,
                      members: members,
                    );
                  }
                } catch (e) {
                  Fluttertoast.showToast(
                    msg: 'Could not open reminder settings: $e',
                    backgroundColor: neopopYellow,
                    textColor: neopopBackground,
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_download_outlined,
                  color: neopopAccent),
              title: Text('Export transactions',
                  style: body1_text.copyWith(color: neopopBackground)),
              subtitle: Text('CSV or PDF (Pro)',
                  style: caption_text.copyWith(color: neopopGrey)),
              onTap: () async {
                Navigator.pop(ctx);
                final ok = await requirePremium(
                  featureLabel: 'CSV & PDF Export',
                );
                if (!ok || !context.mounted) return;
                _showExportOptions(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link_rounded, color: neopopAccent),
              title: Text('Share group invite link',
                  style: body1_text.copyWith(color: neopopBackground)),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  await InviteLinkService().createGroupInviteLink(
                    groupId: widget.groupModel.groupID!,
                    groupName: widget.groupModel.groupName ?? 'Group',
                  );
                } catch (e) {
                  Fluttertoast.showToast(
                    msg: 'Could not create invite: $e',
                    backgroundColor: neopopYellow,
                    textColor: neopopBackground,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showExportOptions(BuildContext context) {
    final export = ExportService();
    final groupId = widget.groupModel.groupID!;
    final groupName = widget.groupModel.groupName ?? 'Group';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart_outlined,
                  color: neopopAccent),
              title: Text('Export as CSV',
                  style: body1_text.copyWith(color: neopopBackground)),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  await export.exportGroupCsv(
                    groupId: groupId,
                    groupName: groupName,
                    userId: widget.userID,
                  );
                } catch (e) {
                  Fluttertoast.showToast(
                    msg: 'Export failed: $e',
                    backgroundColor: neopopYellow,
                    textColor: neopopBackground,
                  );
                }
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.picture_as_pdf_outlined, color: neopopAccent),
              title: Text('Export as PDF',
                  style: body1_text.copyWith(color: neopopBackground)),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  await export.exportGroupPdf(
                    groupId: groupId,
                    groupName: groupName,
                    userId: widget.userID,
                  );
                } catch (e) {
                  Fluttertoast.showToast(
                    msg: 'Export failed: $e',
                    backgroundColor: neopopYellow,
                    textColor: neopopBackground,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isTrip = widget.tripModel != null;

    // Define tabs dynamically
    final List<Widget> tabs = [
      if (isTrip)
        const Tab(
          text: "Timeline",
        ),
      const Tab(
        text: "Activity",
      ),
      const Tab(
        text: "Transactions",
      ),
      const Tab(
        text: "Analytics",
      ),
      const Tab(
        text: "Settle up",
      ),
      const Tab(
        text: "Members",
      ),
      const Tab(
        text: "Wishlist",
      ),
    ];

    final List<Widget> tabViews = [
      if (isTrip)
        TripTimelineTab(
          trip: widget.tripModel!,
        ),
      ActivityFeedTab(
        groupId: widget.groupModel.groupID!,
      ),
      TransactionTab(
        userID: widget.userID,
        groupID: widget.groupModel.groupID!,
      ),
      AnalyticsTab(
        groupID: widget.groupModel.groupID!,
        userID: widget.userID,
      ),
      SettleUpTab(
        groupID: widget.groupModel.groupID!,
        userID: widget.userID,
        groupName: widget.groupModel.groupName!,
      ),
      MembersTab(
        userID: widget.userID,
        groupID: widget.groupModel.groupID!,
      ),
      WishlistTab(
        key: _wishlistTabKey,
        groupId: widget.groupModel.groupID!,
        groupName: widget.groupModel.groupName ?? 'Group',
        userId: widget.userID,
      ),
    ];

    // Calculate FAB indices based on isTrip
    // If trip, timeline is at 0, so other indices shift by +1
    // Activity is 1 (was 0)
    // Transactions is 2 (was 1)
    // Analytics is 3 (was 2)
    // Settle Up is 4 (was 3)
    // Members is 5 (was 4)
    // Wishlist is 6 (was 5)

    final transactionIndex = isTrip ? 2 : 1;
    final settleUpIndex = isTrip ? 4 : 3;
    final membersIndex = isTrip ? 5 : 4;
    final wishlistIndex = isTrip ? 6 : 5;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(color: neopopBackground),
          primary: true,
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          centerTitle: false,
          elevation: 0,
          title: Text(
            widget.groupModel.groupName ?? 'Group',
            style: const TextStyle(
              fontFamily: 'Albra',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: neopopBackground,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            if (isTrip)
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share_rounded, color: neopopBackground),
              ),
            IconButton(
              onPressed: _groupScreenController.triggerRefresh,
              icon: const Icon(Icons.replay_rounded, color: neopopBackground),
            ),
            IconButton(
              onPressed: () => _showGroupActions(context),
              icon: const Icon(Icons.settings_outlined, color: neopopBackground),
            ),
            const SizedBox(width: groupGapSm),
          ],
        ),
        body: Column(
          children: [
            Obx(() => SyncStatusBanner(
                  status: _groupScreenController.syncStatus.value,
                )),
            Expanded(
              child: DefaultTabController(
                length: tabs.length,
                initialIndex: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: groupGutter),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: groupGapMd),
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: neopopSecondaryGrey.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: neopopGrey.withValues(alpha: 0.35),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              getInitials(widget.groupModel.groupName!),
                              style: headline2_text.copyWith(
                                color: neopopBackground,
                                fontFamily: 'Albra',
                              ),
                            ),
                          ),
                          const SizedBox(width: groupGapMd),
                          Expanded(
                            child: Text(
                              widget.groupModel.groupName!,
                              style: headline2_text.copyWith(
                                color: neopopBackground,
                                fontFamily: 'Albra',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: groupGapMd),
                      Container(
                        decoration: BoxDecoration(
                          color: neopopSecondaryGrey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: TabBar(
                          tabAlignment: TabAlignment.start,
                          dividerColor: Colors.transparent,
                          indicatorColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: neopopBackground,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: neopopGrey,
                          labelStyle:
                              body2_text.copyWith(fontWeight: FontWeight.bold),
                          onTap: _groupScreenController.updateTabIndex,
                          isScrollable: true,
                          physics: const BouncingScrollPhysics(),
                          tabs: tabs,
                        ),
                      ),
                      const SizedBox(height: groupGapMd),
                      Expanded(child: TabBarView(children: tabViews)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: groupGapMd),
          child: Obx(() {
            final idx = _groupScreenController.tabIndex.value;
            final showFab = idx == transactionIndex ||
                idx == settleUpIndex ||
                idx == membersIndex ||
                (idx == wishlistIndex &&
                    _groupScreenController.wishlistHasItems.value);
            if (!showFab) return const SizedBox.shrink();

            final label = idx == transactionIndex
                ? 'Add Transaction'
                : idx == settleUpIndex
                    ? 'Settle Up'
                    : idx == membersIndex
                        ? 'Add Member'
                        : 'Add Wishlist';

            return NeoPopButton(
              color: neopopAccent,
              buttonPosition: Position.fullBottom,
              onTapUp: () async {
                if (idx == transactionIndex) {
                  try {
                    final value = await SupabaseDatabase().getGroupMembers(
                      groupID: widget.groupModel.groupID!,
                      currentUserID: widget.userID,
                    );
                    await Get.to(
                      () => AddTransactionScreen(
                        userID: widget.userID,
                        groupDetails: <String, dynamic>{
                          'group_id': widget.groupModel.groupID,
                          'group_name': widget.groupModel.groupName,
                        },
                        groupMembersDetails: value,
                      ),
                    );
                    _groupScreenController.triggerRefresh();
                  } catch (e) {
                    Fluttertoast.showToast(
                      msg: 'Something went wrong! \n$e',
                      textColor: neopopBackground,
                      backgroundColor: neopopYellow,
                    );
                  }
                } else if (idx == settleUpIndex) {
                  Get.to(() => ManualSettleUpScreen(
                        groupID: widget.groupModel.groupID!,
                        currentUserID: widget.userID,
                      ));
                } else if (idx == membersIndex) {
                  final result = await Get.to(
                    () => AddMemberScreen(
                      userID: widget.userID,
                      groupID: widget.groupModel.groupID!,
                    ),
                  );
                  if (result == true) setState(() {});
                } else if (idx == wishlistIndex) {
                  _wishlistTabKey.currentState?.showAddItemSheet();
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: groupGapLg,
                  vertical: groupGapMd,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      idx == membersIndex
                          ? Icons.person_add_rounded
                          : Icons.add_rounded,
                      color: neopopBackground,
                      size: 20,
                    ),
                    const SizedBox(width: groupGapSm),
                    Text(
                      label,
                      style: button_text.copyWith(
                        color: neopopBackground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
