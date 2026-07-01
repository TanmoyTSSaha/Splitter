import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:splitter/Constants/category_style.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/glass_card.dart';
import 'package:splitter/Constants/gradient_mesh_background.dart';
import 'package:splitter/Constants/sync_indicator_widget.dart';
import 'package:splitter/Controllers/currency_controller.dart';
import 'package:splitter/Model/financial_goal_model.dart';
import 'package:splitter/Model/user_details_model.dart';
import 'package:splitter/Screen/GoalScreen/create_goal_screen.dart';
import 'package:splitter/Screen/GoalScreen/goal_details_screen.dart';
import 'package:splitter/Screen/HomeScreen/add_personal_transaction_screen.dart';
import 'package:splitter/Screen/HomeScreen/daily_spend_bar_chart.dart';
import 'package:splitter/Controller/notification_badge_controller.dart';
import 'package:splitter/Services/supabase_service.dart';
import 'package:splitter/Widgets/animated_glass_bottom_nav_bar.dart';
import 'package:splitter/Widgets/notification_bell_button.dart';
import 'package:splitter/Widgets/user_avatar.dart';
import 'package:splitter/Widgets/insights_promo_card.dart';
import 'package:splitter/Widgets/transaction_tile.dart';
import 'package:splitter/Screen/HomeScreen/all_transactions_screen.dart';
import 'package:splitter/Screen/HomeScreen/empty_state_widget.dart';
import 'package:splitter/Services/sync_service.dart';

import '../../Constants/shared.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseDatabase _supabase = SupabaseDatabase();
  final String _userID = SupabaseAuth().supabaseGetUserID();

  // State Variables
  List<Map<String, dynamic>> _unifiedTransactions = [];
  Map<String, double> _monthlyAnalytics = {};
  List<FinancialGoalModel> _goals = [];
  bool _isLoading = true;

  // Analytics State
  bool _showTrueSpend = true; // Toggle state
  double _monthlyCashFlow = 0.0;
  List<Map<String, dynamic>> _dailySpendData = [];

  Worker? _currencyWorker;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<NotificationBadgeController>()) {
      Get.find<NotificationBadgeController>().updateBadge();
    }
    _fetchHomeData();
    // Re-fetch whenever the user changes the display currency
    final cc = Get.find<CurrencyController>();
    _currencyWorker = ever(cc.rxCode, (_) => _fetchHomeData());
  }

  @override
  void dispose() {
    _currencyWorker?.dispose();
    super.dispose();
  }

  Future<void> _fetchHomeData() async {
    setState(() => _isLoading = true);
    try {
      final String selectedCurrency = Get.find<CurrencyController>().code;
      final results = await Future.wait([
        _supabase.getUnifiedTransactions(
            userID: _userID, selectedCurrency: selectedCurrency),
        _supabase.getMonthlySpendAnalytics(
            userID: _userID, selectedCurrency: selectedCurrency),
        _supabase.getGoals(userID: _userID),
        _supabase.getMonthlyCashFlow(
            userID: _userID, selectedCurrency: selectedCurrency),
        _supabase.getMonthlyPulseData(
            userID: _userID, selectedCurrency: selectedCurrency),
      ]);

      setState(() {
        _unifiedTransactions = results[0] as List<Map<String, dynamic>>;
        _monthlyAnalytics = results[1] as Map<String, double>;
        _goals = results[2] as List<FinancialGoalModel>;
        _monthlyCashFlow = results[3] as double;
        _dailySpendData = results[4] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("HOME DATA FETCH ERROR: $e");
      setState(() => _isLoading = false);
    }
  }

  bool get _hasHomeData =>
      _unifiedTransactions.isNotEmpty ||
      _goals.isNotEmpty ||
      _monthlyAnalytics.entries.any((e) => e.key != 'total' && e.value > 0);

  EdgeInsets get _homePadding => EdgeInsets.fromLTRB(
        width_16,
        height_16,
        width_16,
        height_16 + bottomNavClearance,
      );

  ButtonStyle get _sectionActionStyle => TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserDetails>(
        future: _supabase.getCurrentUserProfile(userID: _userID),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoadingWidget();

          final user = snapshot.data!;

          return Scaffold(
            backgroundColor: const Color(0xFFFAFAFA), // Light Background
            appBar: _buildAppBar(user),
            body: Column(
              children: [
                StreamBuilder<SyncStatus>(
                  stream: Get.find<SyncService>().syncStatus,
                  initialData: SyncStatus.synced,
                  builder: (context, syncSnapshot) {
                    return SyncStatusBanner(
                      status: syncSnapshot.data ?? SyncStatus.synced,
                    );
                  },
                ),
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: LoadingAnimationWidget.discreteCircle(
                              color: neopopAccent, size: 40))
                      : !_hasHomeData
                          ? HomeEmptyState(
                              userName: user.firstName,
                              onActionComplete: _fetchHomeData,
                            )
                          : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: _homePadding,
                          child: Column(
                            children: [
                              const InsightsPromoCard(),
                              GradientMeshBackground(
                                child: GlassCard(
                                  margin: EdgeInsets.zero,
                                  padding:
                                      EdgeInsets.symmetric(vertical: height_16),
                                  opacity: 0.12,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildTagline(),
                                      SizedBox(height: height_16 * 2),
                                      _buildMonthlySpendSection(),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: height_16 * 2),
                              _buildTransactionsList(),
                              SizedBox(height: height_16 * 2),
                              _buildAnalyticsHeader(),
                              SizedBox(height: height_16),
                              if (_showTrueSpend)
                                _buildPulseGraph()
                              else
                                _buildCashFlowSection(),
                              SizedBox(height: height_16 * 2),
                              _buildGoalsSection(),
                              SizedBox(height: height_10 * 8), // Bottom Padding
                            ],
                          ),
                        ),
                ),
              ],
            ),

            floatingActionButton: _hasHomeData
                ? Padding(
              padding: const EdgeInsets.only(bottom: bottomNavClearance + 16),
              child: FloatingActionButton(
                heroTag: "home_make_transaction_fab",
                onPressed: () async {
                  bool? result =
                      await Get.to(() => const AddPersonalTransactionScreen());
                  if (result == true) {
                    _fetchHomeData(); // Refresh if transaction added
                  }
                },
                backgroundColor: neopopBackground,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            )
                : null,
          );
        });
  }

  AppBar _buildAppBar(UserDetails user) {
    return AppBar(
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0, // Fix: Prevent color change on scroll
      elevation: 0,
      centerTitle: false,
      titleSpacing: width_16,
      automaticallyImplyLeading: false,
      title: const Text(
        "Splitr.",
        style: TextStyle(
          fontFamily: 'Albra', // Ensure correct font name
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: neopopBackground,
        ),
      ),
      actions: [
        const NotificationBellButton(),
        SizedBox(width: width_10),
        UserAvatar(
          userID: user.userID ?? _userID,
          userName: "${user.firstName} ${user.lastName}",
          imageUrl: user.profilePictureURL,
          radius: 20,
        ),
        SizedBox(width: width_16),
      ],
    );
  }

  Widget _buildTagline() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "money matters,\nsimplified.",
        style: TextStyle(
          fontFamily: 'Albra',
          fontSize: 32,
          height: 1.2,
          color: neopopBackground,
        ),
      ),
    );
  }

  Widget _buildAnalyticsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _showTrueSpend ? "True Spend" : "Cash Flow",
              style: headline3_text.copyWith(
                fontFamily: 'Albra',
                fontWeight: FontWeight.w600,
                color: neopopBackground,
              ),
            ),
            Text(
              _showTrueSpend ? "Actual cost incurred" : "Total money out",
              style: caption_text.copyWith(color: Colors.grey),
            ),
          ],
        ),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              _buildToggleOption("Spend", _showTrueSpend),
              _buildToggleOption("Flow", !_showTrueSpend),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleOption(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (!isSelected) setState(() => _showTrueSpend = !_showTrueSpend);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: width_16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? neopopBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: body2_text.copyWith(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildPulseGraph() {
    return DailySpendBarChart(
      dailySpendData: _dailySpendData,
      monthlyTotal: (_monthlyAnalytics['total'] as num?)?.toDouble() ?? 0,
    );
  }

  Widget _buildCashFlowSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(height_16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.arrow_upward_rounded,
                    color: Colors.redAccent, size: 24),
              ),
              SizedBox(width: width_16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Outflow",
                      style: caption_text.copyWith(color: Colors.grey)),
                  Obx(() {
                    final sym = Get.find<CurrencyController>().symbol;
                    return Text(
                      "$sym${_monthlyCashFlow.toStringAsFixed(0)}",
                      style: headline3_text.copyWith(
                          color: neopopBackground, fontWeight: FontWeight.bold),
                    );
                  }),
                ],
              ),
            ],
          ),
          SizedBox(height: height_16),
          Text(
            "This assumes full amount paid by you, including what others owe you.",
            style: caption_text.copyWith(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySpendSection() {
    // 1. Filter out zero/negative values and 'total' key
    final validEntries = _monthlyAnalytics.entries
        .where((e) => e.key != 'total' && e.value > 0)
        .toList();

    // 2. Sort by amount descending
    validEntries.sort((a, b) => b.value.compareTo(a.value));

    // 3. Take top 5 (or all if less than 5)
    final topEntries = validEntries.take(5).toList();

    if (topEntries.isEmpty) {
      return SizedBox.shrink(); // Hide section if no spend
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Monthly Spend",
            style: headline3_text.copyWith(
                fontFamily: 'Albra',
                fontWeight: FontWeight.w600,
                color: neopopBackground)),
        SizedBox(height: height_16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: topEntries.map((entry) {
              return _buildSpendCard(
                entry.key,
                entry.value,
                _getCategoryIcon(entry.key),
                categoryColor(entry.key),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSpendCard(
      String category, double amount, IconData icon, Color color) {
    return Container(
      width: 140,
      height: 160,
      margin: EdgeInsets.only(right: width_16),
      padding: EdgeInsets.all(height_16),
      decoration: BoxDecoration(
        color: neopopBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category,
                  style: caption_text.copyWith(color: Colors.white54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              SizedBox(height: 4),
              Obx(() {
                final sym = Get.find<CurrencyController>().symbol;
                return Text(
                  "$sym${amount.toStringAsFixed(0)}",
                  style: headline3_text.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                );
              }),
            ],
          ),
          // Mini Graph Visual (Static for now)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildMiniBar(10, color.withOpacity(0.3)),
              const SizedBox(width: 4),
              _buildMiniBar(20, color.withOpacity(0.5)),
              const SizedBox(width: 4),
              _buildMiniBar(15, color.withOpacity(0.4)),
              const SizedBox(width: 4),
              _buildMiniBar(30, color),
            ],
          )
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) => categoryIcon(category);

  Widget _buildMiniBar(double height, Color color) {
    return Container(
      width: 12,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Transactions",
                style: headline3_text.copyWith(
                    fontFamily: 'Albra',
                    fontWeight: FontWeight.w600,
                    color: neopopBackground)),
            if (_unifiedTransactions.isNotEmpty)
              TextButton(
                style: _sectionActionStyle,
                onPressed: () => Get.to(() => const AllTransactionsScreen()),
                child: Text("VIEW ALL",
                    style: body2_text.copyWith(
                        color: neopopBackground, fontWeight: FontWeight.bold)),
              )
          ],
        ),
        SizedBox(height: height_16),
        ..._unifiedTransactions
            .map((txn) => TransactionTile(txn: txn))
            .toList(),
      ],
    );
  }

  // Removed duplicate _buildTransactionsList and _buildSpendCard
  // Analytics Check (Pulse Graph)

  Widget _buildGoalsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Financial Goals",
                style: headline3_text.copyWith(
                    fontFamily: 'Albra',
                    fontWeight: FontWeight.w600,
                    color: neopopBackground)),
            TextButton(
              style: _sectionActionStyle,
              onPressed: () async {
                bool? result = await Get.to(() => const CreateGoalScreen());
                if (result == true) {
                  _fetchHomeData();
                }
              }, // Add Goal
              child: Text("SET A GOAL",
                  style: body2_text.copyWith(
                      color: neopopBackground, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        SizedBox(height: height_10),
        if (_goals.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: height_16),
            child: const Text(
              "Goals are essential,\nto have better lifestyle.",
              style: TextStyle(
                fontFamily: 'Albra',
                fontSize: 32,
                height: 1.2,
                color: neopopBackground,
              ),
            ),
          )
        else
          Column(
            children: _goals.map((g) => _buildGoalCard(g)).toList(),
          )
      ],
    );
  }

  Widget _buildGoalCard(FinancialGoalModel goal) {
    double progress = (goal.currentAmount ?? 0) / (goal.targetAmount ?? 1);
    Color goalColor =
        goal.colorHex != null ? Color(int.parse(goal.colorHex!)) : neopopAccent;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: height_16),
      padding: EdgeInsets.all(height_16),
      decoration: BoxDecoration(
        color: neopopBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: goalColor.withOpacity(0.2), shape: BoxShape.circle),
                child: Text(goal.icon ?? "🎯", style: TextStyle(fontSize: 20)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: goalColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("${(progress * 100).toInt()}%",
                    style: caption_text.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          SizedBox(height: height_16),
          Text(goal.title ?? "Goal",
              style: headline4_text.copyWith(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Obx(() {
            final sym = Get.find<CurrencyController>().symbol;
            return Text(
              "$sym${goal.currentAmount?.toStringAsFixed(0)} / $sym${goal.targetAmount?.toStringAsFixed(0)}",
              style: caption_text.copyWith(color: Colors.white54),
            );
          }),
          SizedBox(height: height_16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(goalColor),
              minHeight: 6,
            ),
          ),
          SizedBox(height: height_16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await Get.to(() => const GoalDetailsScreen(),
                    arguments: goal);
                _fetchHomeData();
              }, // Navigate to Goal Details
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0),
              child: Text("VIEW DETAILS",
                  style: caption_text.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}
