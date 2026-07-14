import 'package:flutter/material.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:get/get.dart';
import 'package:splitr/Controller/add_transaction_controller.dart';
import 'package:splitr/Model/group_model.dart';
import 'package:splitr/Screen/GroupScreen/SharingTypeTabs/by_item_tab.dart';
import 'package:splitr/Screen/GroupScreen/SharingTypeTabs/even_share_tab.dart';
import 'package:splitr/Screen/GroupScreen/SharingTypeTabs/percentage_share_tab.dart';
import 'package:splitr/Screen/GroupScreen/SharingTypeTabs/shares_tab.dart';
import 'package:splitr/Screen/GroupScreen/SharingTypeTabs/uneven_share_tab.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

import '../../Constants/constants.dart';
import '../../Widgets/splitr_detail_app_bar.dart';
import 'package:splitr/Constants/app_strings.dart';

class ShareDistributionScreen extends StatefulWidget {
  final double totalAmount;
  final List<GroupMembersWithNameModel> groupMembersWithNameModel;
  const ShareDistributionScreen({
    super.key,
    required this.groupMembersWithNameModel,
    required this.totalAmount,
  });

  @override
  State<ShareDistributionScreen> createState() =>
      _ShareDistributionScreenState();
}

class _ShareDistributionScreenState extends State<ShareDistributionScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final AddTransactionScreenController _splitController;

  @override
  void initState() {
    super.initState();
    _splitController = Get.find<AddTransactionScreenController>();
    final initialIndex =
        _splitController.currentTabIndex.value.clamp(0, 4).toInt();
    _tabController = TabController(
      length: 5,
      initialIndex: initialIndex,
      vsync: this,
    );
    _tabController.addListener(_syncTabIndex);
  }

  void _syncTabIndex() {
    if (_tabController.indexIsChanging) return;
    _splitController.updateCurrentTabIndex(_tabController.index);
  }

  @override
  void dispose() {
    _tabController.removeListener(_syncTabIndex);
    _tabController.dispose();
    super.dispose();
  }

  void _confirmDistribution() {
    _splitController.updateCurrentTabIndex(_tabController.index);
    _splitController.updateStateRefresh();
    Get.back();
    SplitrToast.show(AppStrings.groups.shareDistributionToast);
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return GestureDetector(
      onTap: () {
        setState(() {
          FocusManager.instance.primaryFocus?.unfocus();
        });
      },
      child: Scaffold(
        backgroundColor: surface,
        appBar: SplitrDetailAppBar(
          title: AppStrings.groups.shareDistributionTitle,
          actions: [
            IconButton(
              onPressed: _confirmDistribution,
              icon: const Icon(
                Icons.check_rounded,
                color: groupOnSurface,
              ),
            ),
          ],
        ),
        body: Container(
          width: devSysWidth,
          padding: EdgeInsets.all(groupGutter),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TabBar(
                controller: _tabController,
                tabAlignment: TabAlignment.start,
                indicatorColor: neopopAccent,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorPadding: EdgeInsets.zero,
                labelStyle: body2_text,
                labelColor: neopopAccent,
                dividerColor: groupMutedBorderSoft,
                unselectedLabelColor: groupOnSurfaceMuted,
                isScrollable: true,
                physics: const BouncingScrollPhysics(),
                overlayColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    return neopopAccentFillMedium;
                  },
                ),
                onTap: _splitController.updateCurrentTabIndex,
                tabs: [
                  Tab(text: SharingMode.byEvenly.label),
                  Tab(text: SharingMode.byUnevenly.label),
                  Tab(text: SharingMode.byPercentage.label),
                  Tab(text: SharingMode.byShares.label),
                  Tab(text: SharingMode.byItem.label),
                ],
              ),
              SizedBox(height: groupGutter),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    EvenShareTab(
                      groupMembersWithNameModel:
                          widget.groupMembersWithNameModel,
                      totalAmount: widget.totalAmount,
                    ),
                    UnevenShareTab(
                      groupMembersWithNameModel:
                          widget.groupMembersWithNameModel,
                      totalAmount: widget.totalAmount,
                    ),
                    PercentageShareTab(
                      groupMembersWithNameModel:
                          widget.groupMembersWithNameModel,
                      totalAmount: widget.totalAmount,
                    ),
                    SharesTab(
                      groupMembersWithNameModel:
                          widget.groupMembersWithNameModel,
                      totalAmount: widget.totalAmount,
                    ),
                    ByItemTab(
                      groupMembersWithNameModel:
                          widget.groupMembersWithNameModel,
                      totalAmount: widget.totalAmount,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
