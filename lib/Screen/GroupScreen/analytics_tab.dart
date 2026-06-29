import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/shared.dart';
import 'package:splitter/Controller/group_screen_controller.dart';
import 'package:splitter/Controller/analytics_controller.dart';
import 'package:splitter/Screen/GroupScreen/GraphAnalysisWidgets/contribution_analysis_chart.dart';
import 'package:splitter/Screen/GroupScreen/GraphAnalysisWidgets/expense_comparison_chart.dart';
import 'package:splitter/Screen/GroupScreen/GraphAnalysisWidgets/group_expense_analysis.dart';
import 'package:splitter/Screen/GroupScreen/GraphAnalysisWidgets/spending_trends_chart.dart';
import 'package:splitter/Screen/GroupScreen/GraphAnalysisWidgets/split_balance_and_dept_analysis.dart';
import 'package:splitter/Screen/GroupScreen/GraphAnalysisWidgets/top_categories_chart.dart';

class AnalyticsTab extends StatefulWidget {
  final String groupID;
  final String userID;

  const AnalyticsTab({
    required this.groupID,
    required this.userID,
    super.key,
  });

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  late final AnalyticsController _analyticsController;
  Worker? _refreshWorker;

  @override
  void initState() {
    super.initState();
    _analyticsController = Get.put(
      AnalyticsController(
        groupID: widget.groupID,
        userID: widget.userID,
      ),
      tag: widget.groupID,
    );
    if (Get.isRegistered<GroupScreenController>()) {
      final groupController = Get.find<GroupScreenController>();
      _refreshWorker = ever(groupController.refreshTrigger, (_) {
        _analyticsController.fetchAnalyticsData(showLoading: false);
      });
    }
  }

  @override
  void dispose() {
    _refreshWorker?.dispose();
    Get.delete<AnalyticsController>(tag: widget.groupID);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        if (_analyticsController.isLoading.value) {
          return const Center(child: LoadingWidget());
        }

        if (_analyticsController.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bar_chart_rounded,
                  color: neopopGrey,
                  size: height_10 * 4.8,
                ),
                SizedBox(height: height_16),
                Text(
                  _analyticsController.errorMessage.value,
                  style: body1_text.copyWith(color: neopopGrey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height_16),
                ElevatedButton(
                  onPressed: () => _analyticsController.fetchAnalyticsData(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neopopAccent,
                  ),
                  child: Text(
                    "Retry",
                    style: button_text.copyWith(color: neopopOnAccent),
                  ),
                ),
              ],
            ),
          );
        }

        return DefaultTabController(
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
                  overlayColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      return neopopAccent.withOpacity(0.15);
                    },
                  ),
                  isScrollable: true,
                  indicatorPadding: const EdgeInsets.all(0),
                  physics: const BouncingScrollPhysics(),
                  tabs: const [
                    Tab(text: "Group Expense"),
                    Tab(text: "Split Balances & Debt"),
                    Tab(text: "Contribution Analysis"),
                    Tab(text: "Spending Trends"),
                    Tab(text: "Expense Comparison"),
                    Tab(text: "Top Categories"),
                  ],
                ),
                SizedBox(height: height_16),
                Expanded(
                  child: TabBarView(
                    children: [
                      GroupExpenseAnalysis(
                        categoryBreakdown: Map<String, double>.from(
                            _analyticsController.categoryBreakdown),
                        selectedDuration:
                            _analyticsController.selectedDuration.value,
                        onDurationChanged: _analyticsController.setDuration,
                      ),
                      SplitBalanceAndDeptAnalysis(
                        memberBalances: List<Map<String, dynamic>>.from(
                            _analyticsController.memberBalances),
                      ),
                      ContributionAnalysisChart(
                        memberContributions:
                            Map<String, Map<String, double>>.from(
                                _analyticsController.memberContributions),
                      ),
                      SpendingTrendsChart(
                        monthlyTrends: Map<String, double>.from(
                            _analyticsController.monthlyTrends),
                      ),
                      ExpenseComparisonChart(
                        categoryComparison:
                            Map<String, Map<String, double>>.from(
                                _analyticsController.categoryComparison),
                      ),
                      TopCategoriesChart(
                        topCategories: List<MapEntry<String, double>>.from(
                            _analyticsController.topCategories),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
