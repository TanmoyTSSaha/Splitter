import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/glass_card.dart';
import 'package:splitter/Constants/gradient_mesh_background.dart';
import 'package:splitter/Widgets/dark_surface_theme.dart';
import 'package:splitter/Controllers/currency_controller.dart';
import 'package:splitter/Services/spending_intelligence_service.dart';

class ExpenseInsightsScreen extends StatefulWidget {
  const ExpenseInsightsScreen({super.key});

  @override
  State<ExpenseInsightsScreen> createState() => _ExpenseInsightsScreenState();
}

class _ExpenseInsightsScreenState extends State<ExpenseInsightsScreen> {
  final SpendingIntelligenceService _service = SpendingIntelligenceService();
  late Future<Map<String, dynamic>> _insightsFuture;
  late Future<Map<String, double>> _categoriesFuture;

  String get _sym => Get.isRegistered<CurrencyController>()
      ? Get.find<CurrencyController>().symbol
      : '₹';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _insightsFuture = _service.getInsights();
      _categoriesFuture = _service.getCategoryBreakdown(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return DarkSurfaceTheme(
      child: Scaffold(
      backgroundColor: neopopBackground,
      body: Stack(
        children: [
          const GradientMeshBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(height_16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: height_16),
                  FutureBuilder<Map<String, dynamic>>(
                    future: _insightsFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final data = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDigestCard(data['monthlyDigest'] as String),
                          SizedBox(height: height_16),
                          _buildSummaryCards(data),
                          SizedBox(height: height_16),
                          _buildHealthScores(data),
                          SizedBox(height: height_16),
                          _buildUnusualExpenses(
                              data['unusualExpenses'] as List<dynamic>),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: height_16 * 2),
                  Text("Spending Trend",
                      style:
                          sub_headline4_text.copyWith(color: neopopOnPrimary)),
                  SizedBox(height: height_16),
                  FutureBuilder<Map<String, dynamic>>(
                    future: _insightsFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      final trend =
                          snapshot.data!['spendingTrend'] as List<dynamic>;
                      return _buildTrendChart(trend);
                    },
                  ),
                  SizedBox(height: height_16 * 2),
                  Text("Categories",
                      style:
                          sub_headline4_text.copyWith(color: neopopOnPrimary)),
                  SizedBox(height: height_16),
                  FutureBuilder<Map<String, double>>(
                    future: _categoriesFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      return _buildCategoryPieChart(snapshot.data!);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Insights",
                style: headline1_text.copyWith(color: neopopOnPrimary)),
            Text("Your spending intelligence",
                style: caption_text.copyWith(color: neopopGrey)),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: neopopOnPrimary),
        ),
      ],
    );
  }

  Widget _buildDigestCard(String digest) {
    return GlassCard(
      child: Padding(
        padding: EdgeInsets.all(height_16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.auto_awesome, color: neopopYellow, size: 22),
            SizedBox(width: width_10),
            Expanded(
              child: Text(digest, style: body2_text.copyWith(height: 1.4)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> data) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            child: Padding(
              padding: EdgeInsets.all(height_16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Spent",
                      style: caption_text.copyWith(color: neopopGrey)),
                  SizedBox(height: 8),
                  Text(
                      "$_sym${data['thisMonthTotal'].toStringAsFixed(0)}",
                      style: headline3_text.copyWith(color: neopopAccent)),
                  SizedBox(height: 4),
                  Text(
                    "${data['percentChange'].toStringAsFixed(1)}% vs last month",
                    style: caption_text.copyWith(
                        color: (data['percentChange'] as double) > 0
                            ? Colors.redAccent
                            : Colors.greenAccent),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: width_16),
        Expanded(
          child: GlassCard(
            child: Padding(
              padding: EdgeInsets.all(height_16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Top Category",
                      style: caption_text.copyWith(color: neopopGrey)),
                  SizedBox(height: 8),
                  Text("${data['topCategory']}",
                      style: headline3_text.copyWith(color: neopopYellow)),
                  SizedBox(height: 4),
                  Text(
                      "$_sym${data['topCategoryAmount'].toStringAsFixed(0)}",
                      style: caption_text.copyWith(color: neopopOnPrimary)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthScores(Map<String, dynamic> data) {
    return Row(
      children: [
        Expanded(
            child: _healthTile(
                'Overall', data['healthScore'] as int, neopopAccent)),
        SizedBox(width: width_10),
        Expanded(
            child: _healthTile('Spending',
                data['spendingHealthScore'] as int, neopopYellow)),
        SizedBox(width: width_10),
        Expanded(
            child: _healthTile('Settle-up',
                data['settleUpHealthScore'] as int, Colors.greenAccent)),
      ],
    );
  }

  Widget _healthTile(String label, int score, Color accent) {
    return GlassCard(
      child: Padding(
        padding: EdgeInsets.all(height_10),
        child: Column(
          children: [
            Text(label, style: caption_text.copyWith(color: neopopGrey)),
            SizedBox(height: 6),
            Text('$score',
                style: headline3_text.copyWith(
                    color: accent, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildUnusualExpenses(List<dynamic> unusual) {
    if (unusual.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: height_16),
        Text("Unusual This Month",
            style: sub_headline4_text.copyWith(color: neopopOnPrimary)),
        SizedBox(height: height_10),
        ...unusual.map((u) {
          final map = u as Map<String, dynamic>;
          final date = map['date'] as DateTime?;
          return GlassCard(
            child: ListTile(
              leading: const Icon(Icons.warning_amber_rounded,
                  color: Colors.orangeAccent),
              title: Text(map['title'] as String? ?? 'Expense',
                  style: body2_text),
              subtitle: Text(
                date != null
                    ? DateFormat('MMM d').format(date)
                    : map['category'] as String? ?? '',
                style: caption_text.copyWith(color: neopopGrey),
              ),
              trailing: Text(
                '$_sym${(map['amount'] as double).toStringAsFixed(0)}',
                style: body1_text.copyWith(
                    color: neopopYellow, fontWeight: FontWeight.w600),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTrendChart(List<dynamic> trend) {
    if (trend.isEmpty) {
      return _buildBarChartPlaceholder();
    }

    final maxY = trend
        .map((e) => (e['total'] as num).toDouble())
        .fold<double>(0, (a, b) => a > b ? a : b);

    return GlassCard(
      child: Padding(
        padding: EdgeInsets.all(height_16),
        child: SizedBox(
          height: 200,
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
                      if (i < 0 || i >= trend.length) {
                        return const SizedBox();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          trend[i]['label'] as String,
                          style: caption_text.copyWith(
                              color: neopopGrey, fontSize: 10),
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
                      width: 16,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6)),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChartPlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: neopopOnPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text("No trend data yet",
            style: body2_text.copyWith(color: neopopGrey)),
      ),
    );
  }

  Widget _buildCategoryPieChart(Map<String, double> categories) {
    if (categories.isEmpty) {
      return Center(
          child:
              Text("No data", style: body2_text.copyWith(color: neopopGrey)));
    }

    final List<Color> colors = [
      neopopAccent,
      neopopYellow,
      Colors.purpleAccent,
      Colors.blueAccent,
      Colors.redAccent,
      Colors.tealAccent,
    ];

    int i = 0;
    final sections = categories.entries.map((entry) {
      final color = colors[i % colors.length];
      i++;
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${entry.key}\n${entry.value.toStringAsFixed(0)}',
        radius: 60,
        titleStyle: caption_text.copyWith(
            color: neopopBackground, fontWeight: FontWeight.bold, fontSize: 10),
      );
    }).toList();

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }
}
