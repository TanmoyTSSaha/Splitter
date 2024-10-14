import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Controller/group_screen_controller.dart';
import 'package:splitter/Screen/GroupScreen/analytics_tab.dart';
import 'package:splitter/Screen/GroupScreen/members_tab.dart';
import 'package:splitter/Screen/GroupScreen/settle_up_tab.dart';
import 'package:splitter/Screen/GroupScreen/transaction_tab.dart';

import '../../Constants/shared.dart';

class GroupDetailedScreen extends StatefulWidget {
  final String group_name;
  const GroupDetailedScreen({
    required this.group_name,
    super.key,
  });

  @override
  State<GroupDetailedScreen> createState() => _GroupDetailedScreenState();
}

class _GroupDetailedScreenState extends State<GroupDetailedScreen> {
  List<String> expenseHistoryStrings = [
    "Flight Confirmation",
    "Hotel Reservation",
    "Activity Planning",
    "Packing List",
    "Travel Insurance",
    "Resort Booking",
    "Packing List",
    "Hotel Reservation",
  ];

  final GroupScreenController _groupScreenController =
      Get.put(GroupScreenController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: neopopBackground,
        appBar: AppBar(
          primary: true,
          backgroundColor: neopopBackground,
          centerTitle: false,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.settings_outlined,
              ),
            ),
          ],
        ),
        body: DefaultTabController(
          length: 4,
          initialIndex: 0,
          child: Container(
            width: devSysWidth,
            padding: EdgeInsets.all(height_16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: height_10 * 12,
                      height: height_10 * 12,
                      decoration: BoxDecoration(
                        color: getRandomBrightColor(),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(width_16 / 2),
                      child: Text(
                        getInitials(widget.group_name),
                        style: headline2_text.copyWith(
                          color: neopopBackground,
                        ),
                      ),
                    ),
                    SizedBox(width: width_16),
                    Container(
                      height: height_10 * 12,
                      width: width_10 * 25,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.group_name,
                        style: headline1_text,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height_16),
                TabBar(
                  tabAlignment: TabAlignment.start,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorColor: neopopAccent,
                  dividerColor: neopopSecondaryGrey,
                  labelColor: neopopAccent,
                  labelStyle: body2_text,
                  unselectedLabelColor: neopopGrey,
                  overlayColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      return neopopAccent.withOpacity(0.15);
                    },
                  ),
                  onTap: (index) {
                    debugPrint("INDEX:: $index");
                    _groupScreenController.updateTabIndex(index);
                  },
                  isScrollable: true,
                  indicatorPadding: const EdgeInsets.all(0),
                  physics: const BouncingScrollPhysics(),
                  tabs: const [
                    Tab(
                      text: "Transactions",
                    ),
                    Tab(
                      text: "Analytics",
                    ),
                    Tab(
                      text: "Settle up",
                    ),
                    Tab(
                      text: "Members",
                    ),
                  ],
                ),
                SizedBox(height: height_16),
                Expanded(
                  child: TabBarView(
                    children: [
                      TransactionTab(
                          expenseHistoryStrings: expenseHistoryStrings),
                      const AnalyticsTab(),
                      const SettleUpTab(),
                      const MembersTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton:
            Obx(() => [0, 2].contains(_groupScreenController.tabIndex.value)
                ? ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: neopopAccent,
                      minimumSize: Size(devSysWidth * 0.35, height_16 * 3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(devSysWidth * 0.5),
                      ),
                    ),
                    child: Text(
                      _groupScreenController.tabIndex == 0
                          ? "Add Transaction"
                          : "Settle Up",
                      style: button_text.copyWith(
                        color: neopopOnBackground,
                      ),
                    ),
                  )
                : const SizedBox(
                    height: 0,
                    width: 0,
                  )),
      ),
    );
  }
}
