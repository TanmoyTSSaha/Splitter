import 'package:fl_chart/fl_chart.dart';
import 'package:splitr/Services/currency_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/theme_accent_colors.dart';
import 'package:splitr/Constants/glass_card.dart';
import 'package:splitr/Constants/shared.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Controllers/premium_subscription_controller.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Screen/Insights/widgets/insights_action_card.dart';
import 'package:splitr/Screen/Insights/widgets/insights_coach_card.dart';
import 'package:splitr/Screen/Insights/widgets/insights_score_ring.dart';
import 'package:splitr/Screen/Insights/widgets/insights_social_trust_section.dart';
import 'package:splitr/Services/ai_service.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';
import 'package:splitr/Services/insights_briefing_cache.dart';
import 'package:splitr/Services/spending_intelligence_service.dart';
import 'package:splitr/Widgets/insights_pro_gate.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_dimensions.dart';

class ExpenseInsightsScreen extends StatefulWidget {
  const ExpenseInsightsScreen({super.key});

  @override
  State<ExpenseInsightsScreen> createState() => _ExpenseInsightsScreenState();
}

class _ExpenseInsightsScreenState extends State<ExpenseInsightsScreen> {
  final SpendingIntelligenceService _service = SpendingIntelligenceService();
  final AIService _aiService = AIService();

  late Future<Map<String, dynamic>> _liteFuture;
  late Future<Map<String, dynamic>> _fullFuture;
  late Future<Map<String, dynamic>> _briefingFuture;
  late Future<Map<String, double>> _categoriesFuture;

  bool _showAllActions = false;

  String get _sym => Get.isRegistered<CurrencyController>()
      ? Get.find<CurrencyController>().symbol
      : CurrencyService.symbolFor(CurrencyDefaults.code);

  bool get _isPro => Get.find<PremiumSubscriptionController>().isPremium.value;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh({bool forceBriefing = false}) {
    setState(() {
      _liteFuture = _service.getInsightsLite();
      _fullFuture = _service.getInsights();
      _categoriesFuture = _service.getCategoryBreakdown(DateTime.now());
      _briefingFuture = _loadBriefing(forceRefresh: forceBriefing);
      _showAllActions = false;
    });
  }

  Future<Map<String, dynamic>> _loadBriefing(
      {bool forceRefresh = false}) async {
    final full = await _service.getInsights();
    final context = await _service.buildAIBriefingContext();
    return _aiService.generateInsightsBriefing(
      context: context,
      fallbackDigest: full[InsightsPayloadKeys.monthlyDigest] as String,
      forceRefresh: forceRefresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: surface,
      appBar: SplitrDetailAppBar(
        title: AppStrings.insights.screenTitle,
        centerTitle: true,
        leading: SplitrDetailAppBar.iosBackLeading(
          context,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: groupOnSurface),
            onPressed: () async {
              await InsightsBriefingCache.clear();
              _refresh(forceBriefing: true);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: neopopAccent,
        onRefresh: () async {
          await InsightsBriefingCache.clear();
          _refresh(forceBriefing: true);
          await _liteFuture;
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.all(groupGutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<Map<String, dynamic>>(
                future: _liteFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _insightsLoadError();
                  }
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: groupGapXl),
                      child: Center(child: LoadingWidget()),
                    );
                  }
                  return _buildFreeZone(snapshot.data!);
                },
              ),
              const SizedBox(height: groupGapXl),
              _sectionTitle(AppStrings.insights.aiWeeklyBriefing),
              const SizedBox(height: groupGapSm),
              InsightsProGate(
                featureLabel: AppStrings.insights.aiBriefingFeature,
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _briefingFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return _insightsLoadError(padding: 48);
                    }
                    if (!snapshot.hasData) {
                      return const SizedBox(
                        height: groupEmojiPickerHeight,
                        child: Center(child: LoadingWidget()),
                      );
                    }
                    return _buildAIBriefing(snapshot.data!);
                  },
                ),
              ),
              const SizedBox(height: groupGapXl),
              _sectionTitle(AppStrings.insights.actionQueue),
              const SizedBox(height: groupGapSm),
              InsightsProGate(
                featureLabel: AppStrings.insights.smartActions,
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _fullFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    return _buildActionQueue(
                      snapshot.data![InsightsPayloadKeys.actionQueue]
                          as List<dynamic>,
                    );
                  },
                ),
              ),
              const SizedBox(height: groupGapXl),
              _sectionTitle(AppStrings.insights.healthScores),
              const SizedBox(height: groupGapSm),
              InsightsProGate(
                featureLabel: AppStrings.insights.healthScores,
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _fullFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    return _buildHealthScores(
                      snapshot.data![InsightsPayloadKeys.scoreBreakdown]
                          as Map<String, dynamic>,
                    );
                  },
                ),
              ),
              const SizedBox(height: groupGapXl),
              _sectionTitle(AppStrings.insights.spendingCoach),
              const SizedBox(height: groupGapSm),
              InsightsProGate(
                featureLabel: AppStrings.insights.spendingCoach,
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _fullFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    return _buildSpendingCoach(
                      snapshot.data![InsightsPayloadKeys.spendingCoach]
                          as Map<String, dynamic>,
                    );
                  },
                ),
              ),
              const SizedBox(height: groupGapXl),
              _sectionTitle(AppStrings.insights.socialTrust),
              const SizedBox(height: groupGapSm),
              InsightsProGate(
                featureLabel: AppStrings.insights.socialTrust,
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _fullFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    return InsightsSocialTrustSection(
                      social: Map<String, dynamic>.from(snapshot
                          .data![InsightsPayloadKeys.socialTrust] as Map),
                      currencySymbol: _sym,
                    );
                  },
                ),
              ),
              const SizedBox(height: groupGapXl),
              _sectionTitle(AppStrings.insights.spendingTrend),
              const SizedBox(height: groupGapMd),
              InsightsProGate(
                featureLabel: AppStrings.insights.spendingTrends,
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _fullFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    final trend =
                        snapshot.data![InsightsPayloadKeys.spendingTrend]
                            as List<dynamic>;
                    final monthsWithData =
                        snapshot.data![InsightsPayloadKeys.monthsWithData]
                                as int? ??
                            0;
                    return _buildTrendChart(trend, monthsWithData);
                  },
                ),
              ),
              const SizedBox(height: groupGapXl),
              _sectionTitle(AppStrings.insights.categories),
              const SizedBox(height: groupGapMd),
              InsightsProGate(
                featureLabel: AppStrings.insights.categoryBreakdown,
                child: FutureBuilder<Map<String, double>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    return _buildCategoryChart(snapshot.data!);
                  },
                ),
              ),
              const SizedBox(height: groupGapXl),
              InsightsProGate(
                featureLabel: AppStrings.insights.unusualExpenses,
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _fullFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    return _buildUnusualExpenses(
                      snapshot.data![InsightsPayloadKeys.unusualExpenses]
                          as List<dynamic>,
                    );
                  },
                ),
              ),
              const SizedBox(height: groupGapXl),
              InsightsProGate(
                featureLabel: AppStrings.insights.recurringBills,
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _fullFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    return _buildRecurringSubscriptions(
                      snapshot.data![InsightsPayloadKeys.recurringSubscriptions]
                          as List<dynamic>,
                    );
                  },
                ),
              ),
              const SizedBox(height: groupGapXl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: sub_headline4_text.copyWith(color: groupOnSurface),
    );
  }

  Widget _buildFreeZone(Map<String, dynamic> lite) {
    final percentChange = lite[InsightsLiteKeys.percentChange] as double;
    final miniTrend = lite[InsightsLiteKeys.miniTrend] as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          margin: EdgeInsets.zero,
          opacity: 0.06,
          padding: const EdgeInsets.all(groupGapMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.insights.totalSpentThisMonth,
                style: caption_text.copyWith(color: groupOnSurfaceMuted),
              ),
              const SizedBox(height: 8),
              Text(
                '$_sym${(lite[InsightsLiteKeys.thisMonthTotal] as num).toStringAsFixed(0)}',
                style: headline2_text.copyWith(color: neopopAccent),
              ),
              const SizedBox(height: 4),
              Text(
                AppStringFormat.insightsPercentVsLastMonth(
                  percentChange.toStringAsFixed(1),
                ),
                style: caption_text.copyWith(
                  color: percentChange > 0 ? neopopError : neopopSuccess,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: groupGapMd),
        Text(
          AppStrings.insights.recentTrend,
          style: caption_text.copyWith(color: groupOnSurfaceMuted),
        ),
        const SizedBox(height: groupGapSm),
        _buildMiniTrend(miniTrend),
        if (!_isPro) ...[
          const SizedBox(height: groupGapMd),
          Text(
            lite[InsightsLiteKeys.monthlyDigest] as String? ?? '',
            style: body2_text.copyWith(
              color: groupOnSurfaceMuted,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMiniTrend(List<dynamic> trend) {
    if (trend.isEmpty) return const SizedBox();

    final maxY = trend
        .map((e) => (e[UnifiedTxnKeys.total] as num).toDouble())
        .fold<double>(0, (a, b) => a > b ? a : b);

    return SizedBox(
      height: AppDimensions.insightsMiniTrendHeight,
      child: BarChart(
        BarChartData(
          maxY: maxY > 0 ? maxY * 1.2 : 100,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= trend.length) return const SizedBox();
                  return Text(
                    trend[i][RecurringMerchantKeys.label] as String,
                    style: caption_text.copyWith(
                      color: groupOnSurfaceMuted,
                      fontSize: splitrFontMicro,
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(trend.length, (i) {
            final total = (trend[i][UnifiedTxnKeys.total] as num).toDouble();
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: total,
                  color: neopopAccent,
                  width: 14,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAIBriefing(Map<String, dynamic> briefing) {
    final actions = briefing[AiResponseKeys.actions] as List<dynamic>? ?? [];
    final isAi = briefing[AiResponseKeys.isAi] == true;

    return GlassCard(
      margin: EdgeInsets.zero,
      opacity: 0.06,
      padding: const EdgeInsets.all(groupGapMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome,
                  color: ThemeAccentColors.highlight(context), size: 22),
              const SizedBox(width: groupGapSm),
              Expanded(
                child: Text(
                  briefing[AiResponseKeys.headline] as String? ??
                      AppStrings.insights.weeklyBriefing,
                  style: body1_text.copyWith(
                    color: groupOnSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isAi)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: groupGapSm, vertical: groupGap2),
                  decoration: BoxDecoration(
                    color: neopopYellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(groupControlRadiusSm),
                  ),
                  child: Text(AppStrings.insights.aiBadge,
                      style: caption_text.copyWith(color: groupOnSurface)),
                ),
            ],
          ),
          const SizedBox(height: groupGapSm),
          Text(
            briefing[AiResponseKeys.narrative] as String? ?? '',
            style: body2_text.copyWith(
              color: groupOnSurface,
              height: 1.45,
            ),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: groupGapMd),
            ...actions.asMap().entries.map((e) {
              final action = Map<String, dynamic>.from(e.value as Map);
              return InsightsActionCard(action: action, index: e.key + 1);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildActionQueue(List<dynamic> actions) {
    if (actions.isEmpty) {
      return Text(
        AppStrings.insights.noActionsNeeded,
        style: body2_text.copyWith(color: groupOnSurfaceMuted),
      );
    }

    final visible = _showAllActions ? actions : actions.take(3).toList();

    return Column(
      children: [
        ...visible.asMap().entries.map((e) {
          final action = Map<String, dynamic>.from(e.value as Map);
          return InsightsActionCard(action: action, index: e.key + 1);
        }),
        if (actions.length > 3 && !_showAllActions)
          TextButton(
            onPressed: () => setState(() => _showAllActions = true),
            child: Text(
              AppStringFormat.insightsSeeAllActions(actions.length),
              style: body2_text.copyWith(color: neopopAccent),
            ),
          ),
      ],
    );
  }

  Widget _buildHealthScores(Map<String, dynamic> breakdown) {
    final overall =
        breakdown[ScoreBreakdownKeys.overall] as Map<String, dynamic>;
    final spending =
        breakdown[ScoreBreakdownKeys.spending] as Map<String, dynamic>;
    final settleUp =
        breakdown[ScoreBreakdownKeys.settleUp] as Map<String, dynamic>;

    return Row(
      children: [
        Expanded(
          child: InsightsScoreRing(
            label: AppStrings.insights.overall,
            score: overall[ScoreBreakdownKeys.score] as int,
            accent: neopopAccent,
            explanation: overall[ScoreBreakdownKeys.explanation] as String,
          ),
        ),
        const SizedBox(width: groupGapSm),
        Expanded(
          child: InsightsScoreRing(
            label: AppStrings.insights.spending,
            score: spending[ScoreBreakdownKeys.score] as int,
            accent: ThemeAccentColors.highlight(context),
            explanation: spending[ScoreBreakdownKeys.explanation] as String,
          ),
        ),
        const SizedBox(width: groupGapSm),
        Expanded(
          child: InsightsScoreRing(
            label: AppStrings.insights.settleUp,
            score: settleUp[ScoreBreakdownKeys.score] as int,
            accent: neopopSuccess,
            explanation: settleUp[ScoreBreakdownKeys.explanation] as String,
          ),
        ),
      ],
    );
  }

  Widget _buildSpendingCoach(Map<String, dynamic> coach) {
    final projection =
        (coach[SpendingCoachKeys.projection] as num?)?.toDouble() ?? 0;
    final dailyBurn =
        (coach[SpendingCoachKeys.dailyBurn] as num?)?.toDouble() ?? 0;
    final topLeak = coach[SpendingCoachKeys.topLeak] as Map<String, dynamic>?;
    final biggest =
        coach[SpendingCoachKeys.biggestExpense] as Map<String, dynamic>?;

    return Column(
      children: [
        InsightsCoachCard(
          title: AppStrings.insights.monthEndProjection,
          value: '$_sym${projection.toStringAsFixed(0)}',
          subtitle: AppStringFormat.insightsDailyBurnSubtitle(
            _sym,
            dailyBurn.toStringAsFixed(0),
          ),
          icon: Icons.trending_up_rounded,
          accent: neopopAccent,
        ),
        if (topLeak != null)
          InsightsCoachCard(
            title: AppStrings.insights.categoryWatch,
            value: '${topLeak[UnifiedTxnKeys.category]}',
            subtitle: AppStringFormat.insightsCategoryWatchSubtitle(
              (topLeak[UnifiedTxnResponseKeys.percentChange] as num)
                  .toStringAsFixed(0),
              _sym,
              (topLeak[UnifiedTxnResponseKeys.current] as num)
                  .toStringAsFixed(0),
            ),
            icon: Icons.category_outlined,
            accent: ThemeAccentColors.highlight(context),
          ),
        if (biggest != null)
          InsightsCoachCard(
            title: AppStrings.insights.biggestExpense,
            value: biggest[UnifiedTxnKeys.title] as String? ??
                AppStrings.home.personalExpense,
            subtitle: AppStringFormat.insightsBiggestExpenseSubtitle(
              _sym,
              (biggest[UnifiedTxnKeys.amount] as num).toStringAsFixed(0),
              biggest[UnifiedTxnKeys.category] as String,
            ),
            icon: Icons.receipt_long_outlined,
            accent: InsightsChartPalette.purple,
          ),
      ],
    );
  }

  Widget _buildTrendChart(List<dynamic> trend, int monthsWithData) {
    if (trend.isEmpty) {
      return _buildBarChartPlaceholder(AppStrings.insights.noTrendData);
    }

    final maxY = trend
        .map((e) => (e[UnifiedTxnKeys.total] as num).toDouble())
        .fold<double>(0, (a, b) => a > b ? a : b);

    final historyNote = monthsWithData < trend.length
        ? AppStringFormat.insightsBuildingHistory(
            monthsWithData,
            trend.length,
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (historyNote != null) ...[
          Text(historyNote,
              style: caption_text.copyWith(color: groupOnSurfaceMuted)),
          const SizedBox(height: groupGapSm),
        ],
        GlassCard(
          margin: EdgeInsets.zero,
          opacity: 0.06,
          padding: const EdgeInsets.all(groupGapMd),
          child: SizedBox(
            height: AppDimensions.insightsChartHeight,
            child: BarChart(
              BarChartData(
                maxY: maxY > 0 ? maxY * 1.2 : 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 0 ? maxY / 3 : 33,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: groupSurfaceFillSoft,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: maxY > 0 ? maxY / 2 : 50,
                      getTitlesWidget: (value, meta) {
                        if (value == meta.max || value == 0) {
                          return Text(
                            '$_sym${value.toStringAsFixed(0)}',
                            style: caption_text.copyWith(
                              color: groupOnSurfaceMuted,
                              fontSize: splitrFontNanoSm,
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= trend.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: groupGapSm),
                          child: Text(
                            trend[i][RecurringMerchantKeys.label] as String,
                            style: caption_text.copyWith(
                              color: groupOnSurfaceMuted,
                              fontSize: splitrFontMicro,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(trend.length, (i) {
                  final total =
                      (trend[i][UnifiedTxnKeys.total] as num).toDouble();
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: total,
                        color:
                            total > 0 ? neopopAccent : groupSurfaceFillMedium,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChartPlaceholder(String message) {
    return Container(
      height: AppDimensions.insightsChartHeight,
      decoration: BoxDecoration(
        color: groupSurfaceFillFaint,
        borderRadius: BorderRadius.circular(groupCardRadius),
      ),
      child: Center(
        child: Text(message,
            style: body2_text.copyWith(color: groupOnSurfaceMuted)),
      ),
    );
  }

  Widget _buildCategoryChart(Map<String, double> categories) {
    if (categories.isEmpty) {
      return Center(
        child: Text(
          AppStrings.insights.noData,
          style: body2_text.copyWith(color: groupOnSurfaceMuted),
        ),
      );
    }

    final colors = [
      neopopAccent,
      neopopYellow,
      InsightsChartPalette.purple,
      InsightsChartPalette.blue,
      neopopError,
      InsightsChartPalette.teal,
    ];

    final sorted = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = sorted.fold<double>(0, (s, e) => s + e.value);

    int i = 0;
    final sections = sorted.map((entry) {
      final color = colors[i % colors.length];
      i++;
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '',
        radius: AppDimensions.chartPieRadiusSm,
      );
    }).toList();

    final legendColors = <Color>[];
    for (int j = 0; j < sorted.length; j++) {
      legendColors.add(colors[j % colors.length]);
    }

    return Column(
      children: [
        SizedBox(
          height: AppDimensions.insightsPieChartHeight,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 36,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: groupGapMd),
        ...sorted.asMap().entries.map((e) {
          final entry = e.value;
          final pct = total > 0 ? (entry.value / total * 100) : 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: groupGapXs),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: AppDimensions.insightsLegendBarHeight,
                  decoration: BoxDecoration(
                    color: legendColors[e.key],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(entry.key,
                      style: body2_text.copyWith(color: groupOnSurface)),
                ),
                Text(
                  '$_sym${entry.value.toStringAsFixed(0)} (${pct.toStringAsFixed(0)}%)',
                  style: caption_text.copyWith(color: groupOnSurfaceMuted),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildUnusualExpenses(List<dynamic> unusual) {
    if (unusual.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.insights.unusualThisMonth,
          style: sub_headline4_text.copyWith(color: groupOnSurface),
        ),
        const SizedBox(height: groupGapSm),
        ...unusual.map((u) {
          final map = u as Map<String, dynamic>;
          final date = map[UnifiedTxnKeys.date] as DateTime?;
          return Padding(
            padding: const EdgeInsets.only(bottom: groupGapSm),
            child: GlassCard(
              margin: EdgeInsets.zero,
              opacity: 0.06,
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(
                  Icons.warning_amber_rounded,
                  color: InsightsChartPalette.orange,
                ),
                title: Text(
                  map[UnifiedTxnKeys.title] as String? ??
                      AppStrings.home.personalExpense,
                  style: body2_text.copyWith(color: groupOnSurface),
                ),
                subtitle: Text(
                  date != null
                      ? DateFormat(AppDateFormats.shortDay).format(date)
                      : map[UnifiedTxnKeys.category] as String? ?? '',
                  style: caption_text.copyWith(color: groupOnSurfaceMuted),
                ),
                trailing: Text(
                  '$_sym${(map[UnifiedTxnKeys.amount] as double).toStringAsFixed(0)}',
                  style: body1_text.copyWith(
                    color: ThemeAccentColors.oweWarning(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecurringSubscriptions(List<dynamic> recurring) {
    if (recurring.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.insights.likelySubscriptions,
          style: sub_headline4_text.copyWith(color: groupOnSurface),
        ),
        const SizedBox(height: groupGapSm),
        ...recurring.map((item) {
          final map = item as Map<String, dynamic>;
          final nextRaw = map[RecurringMerchantKeys.nextExpected] as String?;
          final next = nextRaw != null ? DateTime.tryParse(nextRaw) : null;
          return Padding(
            padding: const EdgeInsets.only(bottom: groupGapSm),
            child: GlassCard(
              margin: EdgeInsets.zero,
              opacity: 0.06,
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(
                  Icons.autorenew_rounded,
                  color: neopopAccent,
                ),
                title: Text(
                  map[RecurringMerchantKeys.label] as String? ??
                      AppStrings.insights.merchant,
                  style: body2_text.copyWith(color: groupOnSurface),
                ),
                subtitle: Text(
                  AppStringFormat.insightsMonthlyCharges(
                        (map[RecurringMerchantKeys.occurrenceCount] as num?)
                                ?.toInt() ??
                            0,
                      ) +
                      (next != null
                          ? '${AppStrings.insights.nextApproxPrefix}${DateFormat(AppDateFormats.shortDay).format(next)}'
                          : ''),
                  style: caption_text.copyWith(color: groupOnSurfaceMuted),
                ),
                trailing: Text(
                  '$_sym${(map[RecurringMerchantKeys.typicalAmount] as num).toStringAsFixed(0)}',
                  style: body1_text.copyWith(
                    color: groupOnSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _insightsLoadError({double padding = groupGapXl}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: Center(
        child: Column(
          children: [
            Text(
              AppStrings.insights.loadError,
              style: body2_text.copyWith(color: groupOnSurfaceMuted),
            ),
            const SizedBox(height: groupGapSm),
            TextButton(
              onPressed: () => _refresh(forceBriefing: true),
              child: Text(
                AppStrings.actions.tryAgain,
                style: body2_text.copyWith(color: neopopAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
