import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/glass_card.dart';
import 'package:splitter/Constants/shared.dart';
import 'package:splitter/Controllers/currency_controller.dart';
import 'package:splitter/Controllers/premium_subscription_controller.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitter/Screen/Insights/widgets/insights_action_card.dart';
import 'package:splitter/Screen/Insights/widgets/insights_coach_card.dart';
import 'package:splitter/Screen/Insights/widgets/insights_score_ring.dart';
import 'package:splitter/Screen/Insights/widgets/insights_social_trust_section.dart';
import 'package:splitter/Services/ai_service.dart';
import 'package:splitter/Services/insights_briefing_cache.dart';
import 'package:splitter/Services/spending_intelligence_service.dart';
import 'package:splitter/Widgets/insights_pro_gate.dart';

const Color _lightBg = Color(0xFFFAFAFA);
const Color _positiveChange = Color(0xFF2E7D32);
const Color _negativeChange = Color(0xFFC62828);

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
      : '₹';

  bool get _isPro =>
      Get.find<PremiumSubscriptionController>().isPremium.value;

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

  Future<Map<String, dynamic>> _loadBriefing({bool forceRefresh = false}) async {
    final full = await _service.getInsights();
    final context = await _service.buildAIBriefingContext();
    return _aiService.generateInsightsBriefing(
      context: context,
      fallbackDigest: full['monthlyDigest'] as String,
      forceRefresh: forceRefresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: groupOnSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Insights',
          style: sub_headline5_text.copyWith(color: groupOnSurface),
        ),
        centerTitle: true,
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
              _sectionTitle('AI Weekly Briefing'),
              const SizedBox(height: groupGapSm),
              InsightsProGate(
                featureLabel: 'AI Briefing',
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _briefingFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox(
                        height: 120,
                        child: Center(child: LoadingWidget()),
                      );
                    }
                    return _buildAIBriefing(snapshot.data!);
                  },
                ),
              ),
              const SizedBox(height: groupGapXl),
              _sectionTitle('Action Queue'),
              const SizedBox(height: groupGapSm),
              InsightsProGate(
                featureLabel: 'Smart Actions',
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _fullFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    return _buildActionQueue(
                      snapshot.data!['actionQueue'] as List<dynamic>,
                    );
                  },
                ),
              ),
              const SizedBox(height: groupGapXl),
              _sectionTitle('Health Scores'),
              const SizedBox(height: groupGapSm),
              InsightsProGate(
                featureLabel: 'Health Scores',
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _fullFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    return _buildHealthScores(
                      snapshot.data!['scoreBreakdown'] as Map<String, dynamic>,
                    );
                  },
                ),
              ),
              const SizedBox(height: groupGapXl),
              _sectionTitle('Spending Coach'),
              const SizedBox(height: groupGapSm),
              InsightsProGate(
                featureLabel: 'Spending Coach',
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _fullFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    return _buildSpendingCoach(
                      snapshot.data!['spendingCoach'] as Map<String, dynamic>,
                    );
                  },
                ),
              ),
              const SizedBox(height: groupGapXl),
              _sectionTitle('Social Trust'),
              const SizedBox(height: groupGapSm),
              InsightsProGate(
                featureLabel: 'Social Trust',
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _fullFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    return InsightsSocialTrustSection(
                      social: Map<String, dynamic>.from(
                          snapshot.data!['socialTrust'] as Map),
                      currencySymbol: _sym,
                    );
                  },
                ),
              ),
              const SizedBox(height: groupGapXl),
              _sectionTitle('Spending Trend'),
              const SizedBox(height: groupGapMd),
              InsightsProGate(
                featureLabel: 'Spending Trends',
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _fullFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    final trend =
                        snapshot.data!['spendingTrend'] as List<dynamic>;
                    final monthsWithData =
                        snapshot.data!['monthsWithData'] as int? ?? 0;
                    return _buildTrendChart(trend, monthsWithData);
                  },
                ),
              ),
              const SizedBox(height: groupGapXl),
              _sectionTitle('Categories'),
              const SizedBox(height: groupGapMd),
              InsightsProGate(
                featureLabel: 'Category Breakdown',
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
                featureLabel: 'Unusual Expenses',
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _fullFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    return _buildUnusualExpenses(
                      snapshot.data!['unusualExpenses'] as List<dynamic>,
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
    final percentChange = lite['percentChange'] as double;
    final miniTrend = lite['miniTrend'] as List<dynamic>;

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
                'Total Spent This Month',
                style: caption_text.copyWith(color: groupOnSurfaceMuted),
              ),
              const SizedBox(height: 8),
              Text(
                '$_sym${(lite['thisMonthTotal'] as num).toStringAsFixed(0)}',
                style: headline2_text.copyWith(color: neopopAccent),
              ),
              const SizedBox(height: 4),
              Text(
                '${percentChange.toStringAsFixed(1)}% vs last month',
                style: caption_text.copyWith(
                  color: percentChange > 0 ? _negativeChange : _positiveChange,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: groupGapMd),
        Text(
          'Recent trend',
          style: caption_text.copyWith(color: groupOnSurfaceMuted),
        ),
        const SizedBox(height: groupGapSm),
        _buildMiniTrend(miniTrend),
        if (!_isPro) ...[
          const SizedBox(height: groupGapMd),
          Text(
            lite['monthlyDigest'] as String? ?? '',
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
        .map((e) => (e['total'] as num).toDouble())
        .fold<double>(0, (a, b) => a > b ? a : b);

    return SizedBox(
      height: 72,
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
                    trend[i]['label'] as String,
                    style: caption_text.copyWith(
                      color: groupOnSurfaceMuted,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(trend.length, (i) {
            final total = (trend[i]['total'] as num).toDouble();
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
    final actions = briefing['actions'] as List<dynamic>? ?? [];
    final isAi = briefing['is_ai'] == true;

    return GlassCard(
      margin: EdgeInsets.zero,
      opacity: 0.06,
      padding: const EdgeInsets.all(groupGapMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: neopopYellow, size: 22),
              const SizedBox(width: groupGapSm),
              Expanded(
                child: Text(
                  briefing['headline'] as String? ?? 'Weekly briefing',
                  style: body1_text.copyWith(
                    color: groupOnSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isAi)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: neopopYellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('AI',
                      style: caption_text.copyWith(color: groupOnSurface)),
                ),
            ],
          ),
          const SizedBox(height: groupGapSm),
          Text(
            briefing['narrative'] as String? ?? '',
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
        'No actions needed — you\'re in good shape.',
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
            child: Text('See all ${actions.length} actions',
                style: body2_text.copyWith(color: neopopAccent)),
          ),
      ],
    );
  }

  Widget _buildHealthScores(Map<String, dynamic> breakdown) {
    final overall = breakdown['overall'] as Map<String, dynamic>;
    final spending = breakdown['spending'] as Map<String, dynamic>;
    final settleUp = breakdown['settleUp'] as Map<String, dynamic>;

    return Row(
      children: [
        Expanded(
          child: InsightsScoreRing(
            label: 'Overall',
            score: overall['score'] as int,
            accent: neopopAccent,
            explanation: overall['explanation'] as String,
          ),
        ),
        const SizedBox(width: groupGapSm),
        Expanded(
          child: InsightsScoreRing(
            label: 'Spending',
            score: spending['score'] as int,
            accent: neopopYellow,
            explanation: spending['explanation'] as String,
          ),
        ),
        const SizedBox(width: groupGapSm),
        Expanded(
          child: InsightsScoreRing(
            label: 'Settle-up',
            score: settleUp['score'] as int,
            accent: _positiveChange,
            explanation: settleUp['explanation'] as String,
          ),
        ),
      ],
    );
  }

  Widget _buildSpendingCoach(Map<String, dynamic> coach) {
    final projection = (coach['projection'] as num?)?.toDouble() ?? 0;
    final dailyBurn = (coach['dailyBurn'] as num?)?.toDouble() ?? 0;
    final topLeak = coach['topLeak'] as Map<String, dynamic>?;
    final biggest = coach['biggestExpense'] as Map<String, dynamic>?;

    return Column(
      children: [
        InsightsCoachCard(
          title: 'Month-end projection',
          value: '$_sym${projection.toStringAsFixed(0)}',
          subtitle: 'At current daily burn of $_sym${dailyBurn.toStringAsFixed(0)}/day',
          icon: Icons.trending_up_rounded,
          accent: neopopAccent,
        ),
        if (topLeak != null)
          InsightsCoachCard(
            title: 'Category watch',
            value: '${topLeak['category']}',
            subtitle:
                '${(topLeak['percentChange'] as num).toStringAsFixed(0)}% vs last month · $_sym${(topLeak['current'] as num).toStringAsFixed(0)}',
            icon: Icons.category_outlined,
            accent: neopopYellow,
          ),
        if (biggest != null)
          InsightsCoachCard(
            title: 'Biggest expense',
            value: biggest['title'] as String? ?? 'Expense',
            subtitle:
                '$_sym${(biggest['amount'] as num).toStringAsFixed(0)} · ${biggest['category']}',
            icon: Icons.receipt_long_outlined,
            accent: Colors.purpleAccent,
          ),
      ],
    );
  }

  Widget _buildTrendChart(List<dynamic> trend, int monthsWithData) {
    if (trend.isEmpty) return _buildBarChartPlaceholder('No trend data yet');

    final maxY = trend
        .map((e) => (e['total'] as num).toDouble())
        .fold<double>(0, (a, b) => a > b ? a : b);

    final historyNote = monthsWithData < trend.length
        ? 'Building history — $monthsWithData of ${trend.length} months tracked'
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
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxY > 0 ? maxY * 1.2 : 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 0 ? maxY / 3 : 33,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: groupOnSurface.withValues(alpha: 0.08),
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
                              fontSize: 9,
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= trend.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            trend[i]['label'] as String,
                            style: caption_text.copyWith(
                              color: groupOnSurfaceMuted,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(trend.length, (i) {
                  final total = (trend[i]['total'] as num).toDouble();
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: total,
                        color: total > 0
                            ? neopopAccent
                            : groupOnSurface.withValues(alpha: 0.15),
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
      height: 200,
      decoration: BoxDecoration(
        color: groupOnSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
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
        child: Text('No data',
            style: body2_text.copyWith(color: groupOnSurfaceMuted)),
      );
    }

    final colors = [
      neopopAccent,
      neopopYellow,
      Colors.purpleAccent,
      Colors.blueAccent,
      Colors.redAccent,
      Colors.tealAccent,
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
        radius: 50,
      );
    }).toList();

    final legendColors = <Color>[];
    for (int j = 0; j < sorted.length; j++) {
      legendColors.add(colors[j % colors.length]);
    }

    return Column(
      children: [
        SizedBox(
          height: 160,
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
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
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
        Text('Unusual This Month',
            style: sub_headline4_text.copyWith(color: groupOnSurface)),
        const SizedBox(height: groupGapSm),
        ...unusual.map((u) {
          final map = u as Map<String, dynamic>;
          final date = map['date'] as DateTime?;
          return Padding(
            padding: const EdgeInsets.only(bottom: groupGapSm),
            child: GlassCard(
              margin: EdgeInsets.zero,
              opacity: 0.06,
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orangeAccent,
                ),
                title: Text(
                  map['title'] as String? ?? 'Expense',
                  style: body2_text.copyWith(color: groupOnSurface),
                ),
                subtitle: Text(
                  date != null
                      ? DateFormat('MMM d').format(date)
                      : map['category'] as String? ?? '',
                  style: caption_text.copyWith(color: groupOnSurfaceMuted),
                ),
                trailing: Text(
                  '$_sym${(map['amount'] as double).toStringAsFixed(0)}',
                  style: body1_text.copyWith(
                    color: neopopYellow,
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
}
