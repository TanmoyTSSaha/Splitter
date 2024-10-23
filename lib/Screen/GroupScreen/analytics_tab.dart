import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Screen/GroupScreen/GraphAnalysisWidgets/group_expense_analysis.dart';
import 'package:splitter/Screen/GroupScreen/GraphAnalysisWidgets/split_balance_and_dept_analysis.dart';

class AnalyticsTab extends StatefulWidget {
  const AnalyticsTab({super.key});

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 6,
        initialIndex: 0,
        child: SizedBox(
          width: devSysWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TabBar(
                tabAlignment: TabAlignment.start,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorColor: neopopAccent,
                dividerColor: neopopSecondaryGrey,
                labelColor: neopopAccent,
                labelStyle: body2_text,
                unselectedLabelColor: neopopGrey,
                overlayColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    return neopopAccent.withOpacity(0.15);
                  },
                ),
                isScrollable: true,
                indicatorPadding: const EdgeInsets.all(0),
                physics: const BouncingScrollPhysics(),
                tabs: const [
                  Tab(
                    text: "Group Expense",
                  ),
                  Tab(
                    text: "Split Balances & Debt",
                  ),
                  Tab(
                    text: "Contribution Analysis",
                  ),
                  Tab(
                    text: "Group Spending Trends",
                  ),
                  Tab(
                    text: "Expense Comparison",
                  ),
                  Tab(
                    text: "Top Shared Expense Categories",
                  ),
                ],
              ),
              SizedBox(height: height_16),
              Expanded(
                child: TabBarView(
                  children: [
                    GroupExpenseAnalysis(),
                    SplitBalanceAndDeptAnalysis(),
                    GroupExpenseAnalysis(),
                    GroupExpenseAnalysis(),
                    GroupExpenseAnalysis(),
                    GroupExpenseAnalysis(),
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
