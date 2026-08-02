import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Utils/recap_chart_utils.dart';

/// Compact 6-month sparkline for recap hero slide.
class RecapSparkline extends StatelessWidget {
  const RecapSparkline({
    required this.trend,
    this.height = 56,
    super.key,
  });

  final List<Map<String, dynamic>> trend;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (trend.length < 2) return const SizedBox.shrink();

    final chart = recapTrendChart(trend);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: chart.maxX,
          minY: chart.minY,
          maxY: chart.maxY,
          lineTouchData: const LineTouchData(enabled: false),
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: chart.spots,
              isCurved: true,
              color: neopopAccent,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: neopopAccentFillWhisper,
              ),
            ),
          ],
        ),
        duration: AppMotion.slide,
        curve: AppCurves.staggerSlide,
      ),
    );
  }
}

/// Category bar that grows in with staggered delay.
class RecapAnimatedCategoryBar extends StatefulWidget {
  const RecapAnimatedCategoryBar({
    required this.fraction,
    required this.color,
    this.delay = Duration.zero,
    super.key,
  });

  final double fraction;
  final Color color;
  final Duration delay;

  @override
  State<RecapAnimatedCategoryBar> createState() =>
      _RecapAnimatedCategoryBarState();
}

class _RecapAnimatedCategoryBarState extends State<RecapAnimatedCategoryBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _width;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.slide,
    );
    _width = Tween<double>(begin: 0, end: widget.fraction.clamp(0.0, 1.0))
        .animate(CurvedAnimation(parent: _controller, curve: AppCurves.staggerSlide));
    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _width,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 8,
              decoration: BoxDecoration(
                color: groupMutedBorderHairline,
                borderRadius: BorderRadius.circular(groupRadiusXs),
              ),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: _width.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(groupRadiusXs),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
