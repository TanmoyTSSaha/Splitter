import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/shared.dart';
import 'package:splitr/Controller/group_screen_controller.dart';
import 'package:splitr/Controller/analytics_controller.dart';
import 'package:splitr/Screen/GroupScreen/GraphAnalysisWidgets/contribution_analysis_chart.dart';
import 'package:splitr/Screen/GroupScreen/GraphAnalysisWidgets/expense_comparison_chart.dart';
import 'package:splitr/Screen/GroupScreen/GraphAnalysisWidgets/group_expense_analysis.dart';
import 'package:splitr/Screen/GroupScreen/GraphAnalysisWidgets/spending_trends_chart.dart';
import 'package:splitr/Screen/GroupScreen/GraphAnalysisWidgets/split_balance_and_dept_analysis.dart';
import 'package:splitr/Screen/GroupScreen/GraphAnalysisWidgets/top_categories_chart.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Widgets/insights_pro_gate.dart';
import 'package:splitr/Constants/app_strings.dart';

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
    return Obx(() {
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
                  size: groupCtaHeightCompact,
                ),
                SizedBox(height: groupGutter),
                Text(
                  _analyticsController.errorMessage.value,
                  style: body1_text.copyWith(color: neopopGrey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: groupGutter),
                ElevatedButton(
                  onPressed: () => _analyticsController.fetchAnalyticsData(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neopopAccent,
                  ),
                  child: Text(
                    AppStrings.groups.retry,
                    style: button_text.copyWith(color: neopopOnAccent),
                  ),
                ),
              ],
            ),
          );
        }

        return InsightsProGate(
          featureLabel: AppStrings.groups.featureAdvancedAnalytics,
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
                    dividerColor: groupMutedBorderHairline,
                    labelColor: neopopAccent,
                    labelStyle: body2_text,
                    unselectedLabelColor: groupOnSurfaceMuted,
                    overlayColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        return neopopAccentFillMedium;
                      },
                    ),
                    isScrollable: true,
                    indicatorPadding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    tabs: [
                      Tab(text: AppStrings.groups.analyticsGroupExpense),
                      Tab(text: AppStrings.groups.analyticsSplitBalances),
                      Tab(text: AppStrings.groups.analyticsContribution),
                      Tab(text: AppStrings.groups.analyticsSpendingTrends),
                      Tab(text: AppStrings.groups.analyticsExpenseComparison),
                      Tab(text: AppStrings.groups.analyticsTopCategories),
                    ],
                  ),
                  SizedBox(height: groupGutter),
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
          ),
        );
      });
  }
}
