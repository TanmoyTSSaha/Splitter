import 'package:flutter/material.dart';
import 'package:splitter/Model/group_model.dart';
import 'package:splitter/Screen/GroupScreen/SharingTypeTabs/even_share_tab.dart';
import 'package:splitter/Screen/GroupScreen/SharingTypeTabs/percentage_share_tab.dart';
import 'package:splitter/Screen/GroupScreen/SharingTypeTabs/shares_tab.dart';
import 'package:splitter/Screen/GroupScreen/SharingTypeTabs/uneven_share_tab.dart';

import '../../Constants/constants.dart';

class ShareDistributionScreen extends StatefulWidget {
  final List<GroupMembersWithNameModel> groupMembersWithNameModel;
  const ShareDistributionScreen({
    super.key,
    required this.groupMembersWithNameModel,
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
          backgroundColor: neopopBackground,
          appBar: AppBar(
            primary: true,
            backgroundColor: neopopBackground,
            centerTitle: false,
            title: Text(
              "Adjust share",
              style: sub_headline4_text,
            ),
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () {
                  // HERE WRITE THE LOGIC FOR ADD THE EXPENSE INSIDE THE SPECIFIC GROUP. AND ALSO UPDATE THE CHANGE TRACKER TABLE ONCE UPDATED.
                },
                icon: const Icon(
                  Icons.check_rounded,
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
                  TabBar(
                    tabAlignment: TabAlignment.start,
                    indicatorColor: neopopAccent,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorPadding: const EdgeInsets.all(0),
                    labelStyle: body2_text,
                    labelColor: neopopAccent,
                    dividerColor: neopopSecondaryGrey,
                    unselectedLabelColor: neopopGrey,
                    isScrollable: true,
                    physics: const BouncingScrollPhysics(),
                    overlayColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        return neopopAccent.withOpacity(0.15);
                      },
                    ),
                    onTap: (index) {
                      // _groupScreenController.updateTabIndex(index);
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
                    ],
                  ),
                  SizedBox(height: height_16),
                  Expanded(
                    child: TabBarView(
                      children: [
                        EvenShareTab(
                            groupMembersWithNameModel:
                                widget.groupMembersWithNameModel),
                        UnevenShareTab(
                            groupMembersWithNameModel:
                                widget.groupMembersWithNameModel),
                        PercentageShareTab(
                            groupMembersWithNameModel:
                                widget.groupMembersWithNameModel),
                        SharesTab(
                            groupMembersWithNameModel:
                                widget.groupMembersWithNameModel),
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
