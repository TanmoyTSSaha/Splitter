import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:splitter/Controller/add_transaction_controller.dart';
import 'package:splitter/Model/group_model.dart';
import 'package:splitter/Screen/GroupScreen/SharingTypeTabs/by_item_tab.dart';
import 'package:splitter/Screen/GroupScreen/SharingTypeTabs/even_share_tab.dart';
import 'package:splitter/Screen/GroupScreen/SharingTypeTabs/percentage_share_tab.dart';
import 'package:splitter/Screen/GroupScreen/SharingTypeTabs/shares_tab.dart';
import 'package:splitter/Screen/GroupScreen/SharingTypeTabs/uneven_share_tab.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';

import '../../Constants/constants.dart';

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

class _ShareDistributionScreenState extends State<ShareDistributionScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          setState(() {
            FocusManager.instance.primaryFocus!.unfocus();
          });
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            primary: true,
            backgroundColor: Colors.white,
            scrolledUnderElevation: 0,
            centerTitle: false,
            title: Text(
              "Adjust share",
              style: sub_headline4_text.copyWith(color: groupOnSurface),
            ),
            elevation: 0,
            iconTheme: const IconThemeData(color: groupOnSurface),
            actions: [
              IconButton(
                onPressed: () {
                  Get.back();
                  Fluttertoast.showToast(
                    msg: "Split shared preciously!",
                    textColor: groupOnSurface,
                    backgroundColor: neopopYellow,
                  );
                },
                icon: const Icon(
                  Icons.check_rounded,
                  color: groupOnSurface,
                ),
              ),
            ],
          ),
          body: DefaultTabController(
            length: 5,
            initialIndex: 0,
            child: Container(
              width: devSysWidth,
              padding: EdgeInsets.all(height_16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TabBar(
                    tabAlignment: TabAlignment.start,
                    indicatorColor: neopopAccent,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorPadding: const EdgeInsets.all(0),
                    labelStyle: body2_text,
                    labelColor: neopopAccent,
                    dividerColor: groupOnSurfaceMuted.withOpacity(0.3),
                    unselectedLabelColor: groupOnSurfaceMuted,
                    isScrollable: true,
                    physics: const BouncingScrollPhysics(),
                    overlayColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        return neopopAccent.withOpacity(0.15);
                      },
                    ),
                    onTap: (index) {
                      final controller =
                          Get.find<AddTransactionScreenController>();
                      controller.updateCurrentTabIndex(index);
                    },
                    tabs: const [
                      Tab(
                        text: "Evenly",
                      ),
                      Tab(
                        text: "Unevenly",
                      ),
                      Tab(
                        text: "By Percentage",
                      ),
                      Tab(
                        text: "By Shares",
                      ),
                      Tab(
                        text: "By Item",
                      ),
                    ],
                  ),
                  SizedBox(height: height_16),
                  Expanded(
                    child: TabBarView(
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
        ),
      ),
    );
  }
}
