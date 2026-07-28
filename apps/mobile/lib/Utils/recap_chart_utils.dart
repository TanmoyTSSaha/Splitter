import 'package:fl_chart/fl_chart.dart';
import 'package:splitr/Utils/num_parsing.dart';

/// Builds [FlSpot] list + axis bounds from aggregator trend rows.
({List<FlSpot> spots, double minY, double maxY, double maxX}) recapTrendChart(
  List<Map<String, dynamic>> trend,
) {
  if (trend.isEmpty) {
    return (
      spots: const [FlSpot(0, 0)],
      minY: 0,
      maxY: 1,
      maxX: 0,
    );
  }

  final totals = trend.map((e) => asDouble(e['total'])).toList();
  final maxTotal = totals.reduce((a, b) => a > b ? a : b);
  final yMax = maxTotal > 0 ? maxTotal * 1.15 : 1.0;
  final spots = List<FlSpot>.generate(
    trend.length,
    (i) => FlSpot(i.toDouble(), totals[i]),
  );

  return (
    spots: spots,
    minY: 0,
    maxY: yMax,
    maxX: (trend.length - 1).toDouble(),
  );
}
