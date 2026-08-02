import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/category_style.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/glass_card.dart';
import 'package:splitr/Constants/gradient_mesh_background.dart';
import 'package:splitr/Constants/sync_indicator_widget.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Model/financial_goal_model.dart';
import 'package:splitr/Model/user_details_model.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Screen/GoalScreen/create_goal_screen.dart';
import 'package:splitr/Screen/GoalScreen/goal_details_screen.dart';
import 'package:splitr/Screen/HomeScreen/add_personal_transaction_screen.dart';
import 'package:splitr/Screen/HomeScreen/daily_spend_bar_chart.dart';
import 'package:splitr/Controller/home_controller.dart';
import 'package:splitr/Controller/notification_badge_controller.dart';
import 'package:splitr/Controller/profile_controller.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Widgets/animated_glass_bottom_nav_bar.dart';
import 'package:splitr/Widgets/notification_bell_button.dart';
import 'package:splitr/Widgets/user_avatar.dart';
import 'package:splitr/Widgets/monthly_recap_drop_card.dart';
import 'package:splitr/Widgets/insights_promo_card.dart';
import 'package:splitr/Widgets/transaction_tile.dart';
import 'package:splitr/Screen/HomeScreen/widgets/personal_transaction_sheet.dart';
import 'package:splitr/Screen/HomeScreen/all_transactions_screen.dart';
import 'package:splitr/Screen/HomeScreen/empty_state_widget.dart';
import 'package:splitr/Services/sync_service.dart';

import '../../Constants/shared.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String _userID = SupabaseAuth().supabaseGetUserID();
  late final HomeController _homeController;
  ProfileController get _profile => Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    _homeController = Get.find<HomeController>();
    _homeController.initialize(_userID);
    if (Get.isRegistered<NotificationBadgeController>()) {
      Get.find<NotificationBadgeController>().updateBadge();
    }
  }

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
    return Obx(() {
      final user = _profile.user.value;
      if (user == null) return const LoadingWidget();

      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
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
            Obx(() {
              final error = _homeController.fetchError.value;
              if (error == null) return const SizedBox.shrink();
              return MaterialBanner(
                backgroundColor: neopopErrorFillMedium,
                content: Text(
                  error,
                  style: body2_text.copyWith(color: groupOnSurface),
                ),
                leading: const Icon(
                  Icons.cloud_off_rounded,
                  color: neopopError,
                ),
                actions: [
                  TextButton(
                    onPressed: () => _homeController.fetchError.value = null,
                    child: Text(
                      AppStrings.actions.dismiss,
                      style: body2_text.copyWith(color: groupOnSurfaceMuted),
                    ),
                  ),
                  TextButton(
                    onPressed: _homeController.fetchHomeData,
                    child: Text(
                      AppStrings.actions.retry,
                      style: body2_text.copyWith(
                        color: neopopAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            }),
            Expanded(
              child: Obx(() {
                if (_homeController.isLoading.value) {
                  return Center(
                    child: LoadingAnimationWidget.discreteCircle(
                      color: neopopAccent,
                      size: AppDimensions.loadingIndicatorLg,
                    ),
                  );
                }
                if (!_homeController.hasHomeData) {
                  return HomeEmptyState(
                    userName: user.firstName,
                    onActionComplete: _homeController.fetchHomeData,
                  );
                }
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: _homePadding,
                  child: Column(
                    children: [
                      const MonthlyRecapDropCard(),
                      const InsightsPromoCard(),
                      GradientMeshBackground(
                        child: GlassCard(
                          margin: EdgeInsets.zero,
                          padding: EdgeInsets.symmetric(vertical: height_16),
                          opacity: 0.12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                      Obx(() => _homeController.showTrueSpend.value
                          ? _buildPulseGraph()
                          : _buildCashFlowSection()),
                      SizedBox(height: height_16 * 2),
                      _buildGoalsSection(),
                      SizedBox(height: height_10 * 8),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
        floatingActionButton: Obx(() {
          if (!_homeController.hasHomeData) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: bottomNavClearance + 16),
            child: FloatingActionButton(
              heroTag: HeroTags.homeFab,
              onPressed: () async {
                bool? result =
                    await Get.to(() => const AddPersonalTransactionScreen());
                if (result == true) {
                  _homeController.fetchHomeData();
                }
              },
              backgroundColor: neopopBackground,
              child: const Icon(Icons.add, color: neopopOnPrimary),
            ),
          );
        }),
      );
    });
  }

  AppBar _buildAppBar(UserDetails user) {
    return AppBar(
      backgroundColor: groupTransparent,
      scrolledUnderElevation: 0, // Fix: Prevent color change on scroll
      elevation: 0,
      centerTitle: false,
      titleSpacing: width_16,
      automaticallyImplyLeading: false,
      title: const Text(
        AppBranding.brandLogo,
        style: TextStyle(
          fontFamily: kFontAlbra,
          fontSize: splitrFontHeadline2,
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
          radius: AppDimensions.homeAppBarAvatarRadius,
        ),
        SizedBox(width: width_16),
      ],
    );
  }

  Widget _buildTagline() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        AppStrings.home.tagline,
        style: TextStyle(
          fontFamily: kFontAlbra,
          fontSize: splitrFontHeadline1,
          height: 1.2,
          color: neopopBackground,
        ),
      ),
    );
  }

  Widget _buildAnalyticsHeader() {
    return Obx(() {
      final showSpend = _homeController.showTrueSpend.value;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                showSpend
                    ? AppStrings.home.trueSpend
                    : AppStrings.home.cashFlow,
                style: headline3_text.copyWith(
                  fontFamily: kFontAlbra,
                  fontWeight: FontWeight.w600,
                  color: neopopBackground,
                ),
              ),
              Text(
                showSpend
                    ? AppStrings.home.trueSpendSubtitle
                    : AppStrings.home.cashFlowSubtitle,
                style: caption_text.copyWith(color: groupOnSurfaceMuted),
              ),
            ],
          ),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: groupChipTrackBg,
              borderRadius: BorderRadius.circular(groupCardRadiusLg),
            ),
            child: Row(
              children: [
                _buildToggleOption(AppStrings.home.spend, showSpend),
                _buildToggleOption(AppStrings.home.flow, !showSpend),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildToggleOption(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (!isSelected) _homeController.toggleAnalyticsMode();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: groupGutter, vertical: groupGapSm),
        decoration: BoxDecoration(
          color: isSelected ? neopopBackground : groupTransparent,
          borderRadius: BorderRadius.circular(groupCardRadiusLg),
        ),
        child: Text(
          text,
          style: body2_text.copyWith(
            fontWeight: FontWeight.bold,
            color: isSelected ? groupChipSelectedFg : groupChipUnselectedFg,
          ),
        ),
      ),
    );
  }

  Widget _buildPulseGraph() {
    return DailySpendBarChart(
      dailySpendData: _homeController.dailySpendData,
      monthlyTotal:
          (_homeController.monthlyAnalytics['total'] as num?)?.toDouble() ?? 0,
    );
  }

  Widget _buildCashFlowSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(groupGutter),
      decoration: BoxDecoration(
        color: groupCardFill,
        borderRadius: BorderRadius.circular(groupCardRadiusLg),
        border: Border.all(color: groupSurfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(groupCarouselGap),
                decoration: BoxDecoration(
                    color: neopopErrorFillSoft, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_upward_rounded,
                    color: neopopError, size: groupCarouselIconLg),
              ),
              SizedBox(width: width_16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.home.totalOutflow,
                      style: caption_text.copyWith(color: groupOnSurfaceMuted)),
                  Obx(() {
                    final sym = Get.find<CurrencyController>().symbol;
                    return Text(
                      "$sym${_homeController.monthlyCashFlow.value.toStringAsFixed(0)}",
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
            AppStrings.home.cashFlowDisclaimer,
            style: caption_text.copyWith(
                color: groupOnSurfaceMuted, fontSize: splitrFontCaptionSm),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySpendSection() {
    // 1. Filter out zero/negative values and 'total' key
    final validEntries = _homeController.monthlyAnalytics.entries
        .where((e) => e.key != 'total' && e.value > 0)
        .toList();

    // 2. Sort by amount descending
    validEntries.sort((a, b) => b.value.compareTo(a.value));

    // 3. Take top 5 (or all if less than 5)
    final topEntries = validEntries.take(5).toList();

    if (topEntries.isEmpty) {
      return const SizedBox.shrink(); // Hide section if no spend
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.home.monthlySpend,
            style: headline3_text.copyWith(
                fontFamily: kFontAlbra,
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
      width: AppDimensions.homeSpendCardWidth,
      height: AppDimensions.homeSpendCardHeight,
      margin: EdgeInsets.only(right: width_16),
      padding: EdgeInsets.all(height_16),
      decoration: BoxDecoration(
        color: neopopBackground,
        borderRadius: BorderRadius.circular(groupCardRadiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: AppDimensions.groupIconLg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category,
                  style: caption_text.copyWith(color: shareCardTextMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: groupGapXxs),
              Obx(() {
                final sym = Get.find<CurrencyController>().symbol;
                return Text(
                  "$sym${amount.toStringAsFixed(0)}",
                  style: headline3_text.copyWith(
                      color: neopopOnPrimary, fontWeight: FontWeight.bold),
                );
              }),
            ],
          ),
          // Mini Graph Visual (Static for now)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildMiniBar(10, color.withOpacity(0.3)),
              const SizedBox(width: groupGapXxs),
              _buildMiniBar(20, color.withOpacity(0.5)),
              const SizedBox(width: groupGapXxs),
              _buildMiniBar(15, color.withOpacity(0.4)),
              const SizedBox(width: groupGapXxs),
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
      width: AppDimensions.homeMiniBarWidth,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(groupRadiusSm),
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
            Text(AppStrings.home.transactions,
                style: headline3_text.copyWith(
                    fontFamily: kFontAlbra,
                    fontWeight: FontWeight.w600,
                    color: neopopBackground)),
            if (_homeController.unifiedTransactions.isNotEmpty)
              TextButton(
                style: _sectionActionStyle,
                onPressed: () => Get.to(() => const AllTransactionsScreen()),
                child: Text(AppStrings.actions.viewAll,
                    style: body2_text.copyWith(
                        color: neopopBackground, fontWeight: FontWeight.bold)),
              )
          ],
        ),
        SizedBox(height: height_16),
        ..._homeController.unifiedTransactions.map(
          (txn) => TransactionTile(
            txn: txn,
            onLongPress: txn['type'] != TransactionTypes.group
                ? () => PersonalTransactionSheet.show(
                      context,
                      txn: txn,
                      onChanged: _homeController.fetchHomeData,
                    )
                : null,
          ),
        ),
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
            Text(AppStrings.home.financialGoals,
                style: headline3_text.copyWith(
                    fontFamily: kFontAlbra,
                    fontWeight: FontWeight.w600,
                    color: neopopBackground)),
            TextButton(
              style: _sectionActionStyle,
              onPressed: () async {
                bool? result = await Get.to(() => const CreateGoalScreen());
                if (result == true) {
                  _homeController.fetchHomeData();
                }
              }, // Add Goal
              child: Text(AppStrings.home.setAGoal,
                  style: body2_text.copyWith(
                      color: neopopBackground, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        SizedBox(height: height_10),
        if (_homeController.goals.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: height_16),
            child: Text(
              AppStrings.home.goalsEmptyQuote,
              style: TextStyle(
                fontFamily: kFontAlbra,
                fontSize: splitrFontHeadline1,
                height: 1.2,
                color: groupOnSurface,
              ),
            ),
          )
        else
          Column(
            children:
                _homeController.goals.map((g) => _buildGoalCard(g)).toList(),
          )
      ],
    );
  }

  Widget _buildGoalCard(FinancialGoalModel goal) {
    double progress = (goal.currentAmount ?? 0) / (goal.targetAmount ?? 1);
    Color goalColor =
        goal.colorHex != null ? Color(int.parse(goal.colorHex!)) : neopopAccent;
    final surface = Theme.of(context).colorScheme.surface;
    final border = groupMutedBorder;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: height_16),
      padding: EdgeInsets.all(height_16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(groupCardRadiusXl),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: groupMutedFillFaint,
            blurRadius: homeSpendChartShadowBlur,
            offset: homeSpendChartShadowOffset,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(groupGap10),
                decoration: BoxDecoration(
                    color: goalColor.withOpacity(0.2), shape: BoxShape.circle),
                child: Text(goal.icon ?? GoalDefaults.defaultEmoji,
                    style: const TextStyle(fontSize: splitrFontTitle)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: groupGap10, vertical: groupGapXs),
                decoration: BoxDecoration(
                  color: goalColor,
                  borderRadius: BorderRadius.circular(groupCardRadiusLg),
                ),
                child: Text(
                  AppStringFormat.progressPercent((progress * 100).toInt()),
                  style: caption_text.copyWith(
                    color: neopopOnPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: height_16),
          Text(goal.title ?? DisplayFallbacks.goal,
              style: headline4_text.copyWith(color: groupOnSurface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: groupGapXxs),
          Obx(() {
            final sym = Get.find<CurrencyController>().symbol;
            return Text(
              "$sym${goal.currentAmount?.toStringAsFixed(0)} / $sym${goal.targetAmount?.toStringAsFixed(0)}",
              style: caption_text.copyWith(color: groupOnSurfaceMuted),
            );
          }),
          SizedBox(height: height_16),
          ClipRRect(
            borderRadius: BorderRadius.circular(groupRadiusSm),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: groupMutedFillMedium,
              valueColor: AlwaysStoppedAnimation<Color>(goalColor),
              minHeight: 6,
            ),
          ),
          SizedBox(height: height_16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await Get.to(() => const GoalDetailsScreen(), arguments: goal);
                _homeController.fetchHomeData();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: neopopAccentFillLight,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(groupControlRadius)),
                  elevation: 0),
              child: Text(AppStrings.actions.viewDetails,
                  style: caption_text.copyWith(
                      color: neopopAccent, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}
