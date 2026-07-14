import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitr/Bindings/app_bindings.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/sync_indicator_widget.dart';
import 'package:splitr/Controller/group_screen_controller.dart';
import 'package:splitr/Model/group_model.dart';
import 'package:splitr/Model/trip_model.dart';
import 'package:splitr/Screen/GroupScreen/add_transaction_screen.dart';
import 'package:splitr/Screen/GroupScreen/analytics_tab.dart';
import 'package:splitr/Screen/GroupScreen/members_tab.dart';
import 'package:splitr/Screen/GroupScreen/settle_up_tab.dart';
import 'package:splitr/Screen/GroupScreen/transaction_tab.dart';
import 'package:splitr/Screen/GroupScreen/wishlist_tab.dart';
import 'package:splitr/Screen/TripScreen/trip_timeline_screen.dart';

import 'package:neopop/neopop.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import '../../Constants/shared.dart';
import 'package:splitr/Services/export_service.dart';
import 'package:splitr/Services/invite_link_service.dart';
import 'package:splitr/Repository/group_repository.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Widgets/group_reminder_settings_sheet.dart';
import 'package:splitr/Widgets/premium_gate.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';
import 'activity_feed_tab.dart';
import 'add_member_screen.dart';
import 'manual_settle_up_screen.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

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
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: groupSheetTopBorderRadius,
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined,
                  color: neopopAccent),
              title: Text(AppStrings.groups.reminderSettings,
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
                } catch (e, stack) {
                  AppErrorReporter.reportActionFailure(
                    AppStrings.errors.couldNotOpenReminderPrefix,
                    error: e,
                    stack: stack,
                  );
                }
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.file_download_outlined, color: neopopAccent),
              title: Text(AppStrings.groups.exportTransactions,
                  style: body1_text.copyWith(color: neopopBackground)),
              subtitle: Text(AppStrings.groups.csvOrPdfPro,
                  style: caption_text.copyWith(color: neopopGrey)),
              onTap: () async {
                Navigator.pop(ctx);
                final ok = await requirePremium(
                  featureLabel: AppStrings.groups.featureCsvPdfExport,
                );
                if (!ok || !context.mounted) return;
                _showExportOptions(context);
              },
            ),
            ListTile(
              leading: Icon(
                widget.groupModel.isArchived
                    ? Icons.unarchive_outlined
                    : Icons.archive_outlined,
                color: neopopAccent,
              ),
              title: Text(
                widget.groupModel.isArchived
                    ? AppStrings.groups.unarchiveGroup
                    : AppStrings.groups.archiveGroup,
                style: body1_text.copyWith(color: neopopBackground),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final repo = Get.find<GroupRepository>();
                final archive = !widget.groupModel.isArchived;
                try {
                  await repo.setGroupArchived(
                      widget.groupModel.groupID!, archive);
                  GroupScreenController.refreshFromAnywhere();
                  if (context.mounted) Get.back();
                } catch (e, stack) {
                  AppErrorReporter.reportActionFailure(
                    AppStrings.errors.couldNotUpdateGroupPrefix,
                    error: e,
                    stack: stack,
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.link_rounded, color: neopopAccent),
              title: Text(AppStrings.groups.shareInviteLink,
                  style: body1_text.copyWith(color: neopopBackground)),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  await InviteLinkService().createGroupInviteLink(
                    groupId: widget.groupModel.groupID!,
                    groupName:
                        widget.groupModel.groupName ?? DisplayFallbacks.group,
                  );
                } catch (e, stack) {
                  AppErrorReporter.reportActionFailure(
                    AppStrings.errors.couldNotCreateInvitePrefix,
                    error: e,
                    stack: stack,
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
    final groupName = widget.groupModel.groupName ?? DisplayFallbacks.group;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: groupSheetTopBorderRadius,
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.table_chart_outlined, color: neopopAccent),
              title: Text(AppStrings.groups.exportCsv,
                  style: body1_text.copyWith(color: neopopBackground)),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  await export.exportGroupCsv(
                    groupId: groupId,
                    groupName: groupName,
                    userId: widget.userID,
                  );
                } catch (e, stack) {
                  AppErrorReporter.reportActionFailure(
                    'Group CSV export failed',
                    error: e,
                    stack: stack,
                    context: {'feature': 'export'},
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined,
                  color: neopopAccent),
              title: Text(AppStrings.groups.exportPdf,
                  style: body1_text.copyWith(color: neopopBackground)),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  await export.exportGroupPdf(
                    groupId: groupId,
                    groupName: groupName,
                    userId: widget.userID,
                  );
                } catch (e, stack) {
                  AppErrorReporter.reportActionFailure(
                    'Group CSV export failed',
                    error: e,
                    stack: stack,
                    context: {'feature': 'export'},
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
        Tab(
          text: AppStrings.groups.tabTimeline,
        ),
      Tab(
        text: AppStrings.groups.tabActivity,
      ),
      Tab(
        text: AppStrings.trips.transactions,
      ),
      Tab(
        text: AppStrings.groups.tabAnalytics,
      ),
      Tab(
        text: AppStrings.groups.tabSettleUp,
      ),
      Tab(
        text: AppStrings.groups.tabMembers,
      ),
      Tab(
        text: AppStrings.groups.tabWishlist,
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
        createdBy: widget.groupModel.createdBy,
      ),
      WishlistTab(
        key: _wishlistTabKey,
        groupId: widget.groupModel.groupID!,
        groupName: widget.groupModel.groupName ?? DisplayFallbacks.group,
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

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: SplitrDetailAppBar(
          titleWidget: Text(
            widget.groupModel.groupName ?? DisplayFallbacks.group,
            style: TextStyle(
              fontFamily: kFontAlbra,
              fontSize: splitrFontSubheadLg,
              fontWeight: FontWeight.w700,
              color: groupOnSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            if (isTrip)
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share_rounded, color: groupOnSurface),
              ),
            IconButton(
              onPressed: _groupScreenController.triggerRefresh,
              icon: const Icon(Icons.replay_rounded, color: groupOnSurface),
            ),
            IconButton(
              onPressed: () => _showGroupActions(context),
              icon: const Icon(Icons.settings_outlined, color: groupOnSurface),
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
                            width: groupCtaHeight,
                            height: groupCtaHeight,
                            decoration: BoxDecoration(
                              color: groupMutedFillFaint,
                              borderRadius:
                                  BorderRadius.circular(groupRadiusLgSm),
                              border: Border.all(
                                color: groupMutedBorderStrong,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              getInitials(widget.groupModel.groupName!),
                              style: headline2_text.copyWith(
                                color: neopopBackground,
                                fontFamily: kFontAlbra,
                              ),
                            ),
                          ),
                          const SizedBox(width: groupGapMd),
                          Expanded(
                            child: Text(
                              widget.groupModel.groupName!,
                              style: headline2_text.copyWith(
                                color: neopopBackground,
                                fontFamily: kFontAlbra,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: groupGapMd),
                      Container(
                        decoration: BoxDecoration(
                          color: groupMutedFillFaint,
                          borderRadius: BorderRadius.circular(groupPillRadius),
                        ),
                        child: TabBar(
                          tabAlignment: TabAlignment.start,
                          dividerColor: groupTransparent,
                          indicatorColor: groupTransparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: neopopBackground,
                            borderRadius:
                                BorderRadius.circular(groupPillRadius),
                          ),
                          labelColor: groupChipSelectedFg,
                          unselectedLabelColor: groupOnSurfaceMuted,
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
                ? AppStrings.groups.addTransaction
                : idx == settleUpIndex
                    ? AppStrings.settle.title
                    : idx == membersIndex
                        ? AppStrings.groups.addMember
                        : AppStrings.groups.addWishlist;

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
                          UnifiedTxnKeys.groupId: widget.groupModel.groupID,
                          SupabaseColumns.groupName:
                              widget.groupModel.groupName,
                        },
                        groupMembersDetails: value,
                      ),
                    );
                    _groupScreenController.triggerRefresh();
                  } catch (e, stack) {
                    AppErrorReporter.reportActionFailure(
                      'Open add transaction failed',
                      error: e,
                      stack: stack,
                    );
                  }
                } else if (idx == settleUpIndex) {
                  final settled = await Get.to<bool>(
                    () => ManualSettleUpScreen(
                      groupID: widget.groupModel.groupID!,
                      currentUserID: widget.userID,
                      groupName: widget.groupModel.groupName ??
                          DisplayFallbacks.group,
                    ),
                  );
                  if (settled == true) {
                    _groupScreenController.triggerRefresh();
                  }
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
                      size: AppDimensions.groupIconMd,
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
    );
  }
}
