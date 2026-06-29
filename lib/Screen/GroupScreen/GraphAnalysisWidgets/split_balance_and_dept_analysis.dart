import 'package:fl_chart/fl_chart.dart';

import 'package:flutter/material.dart';



import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';

import 'package:splitter/Widgets/tab_empty_state.dart';



import '../../../Constants/constants.dart';

const Color _isOwedColor = Color(0xFF22C55E);
const Color _owesColor = neopopError;



/// Bar chart showing per-member net balance from group_balance.

class SplitBalanceAndDeptAnalysis extends StatefulWidget {

  final List<Map<String, dynamic>> memberBalances;



  const SplitBalanceAndDeptAnalysis({

    required this.memberBalances,

    super.key,

  });



  @override

  State<SplitBalanceAndDeptAnalysis> createState() =>

      _SplitBalanceAndDeptAnalysisState();

}



class _SplitBalanceAndDeptAnalysisState

    extends State<SplitBalanceAndDeptAnalysis> {

  @override

  Widget build(BuildContext context) {

    if (widget.memberBalances.isEmpty) {

      return const TabEmptyState(

        variant: TabEmptyVariant.analytics,

        title: 'No balance data yet',

        compact: true,

      );

    }



    final data = widget.memberBalances;

    final maxVal = data.fold<double>(0.0, (prev, e) {

      final net = (e['netBalance'] as num?)?.toDouble() ?? 0.0;

      return net.abs() > prev ? net.abs() : prev;

    });



    return SingleChildScrollView(

      physics: const BouncingScrollPhysics(),

      child: Column(

        mainAxisAlignment: MainAxisAlignment.start,

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(

            'Split Balances & Debt',

            style: body1_text.copyWith(

              fontWeight: FontWeight.w600,

              color: groupOnSurface,

            ),

          ),

          SizedBox(height: height_10),

          Text(

            'Net balance per member (same as Settle Up)',

            style: caption_text.copyWith(color: groupOnSurfaceMuted),

          ),

          SizedBox(height: height_10),

          Row(

            children: [

              _legendDot(_isOwedColor, 'Is owed'),
              SizedBox(width: width_16),
              _legendDot(_owesColor, 'Owes'),

            ],

          ),

          SizedBox(height: height_16),

          AspectRatio(

            aspectRatio: 1.8,

            child: BarChart(

              BarChartData(

                alignment: BarChartAlignment.spaceAround,

                maxY: maxVal > 0 ? maxVal * 1.2 : 1,

                titlesData: FlTitlesData(

                  leftTitles: const AxisTitles(),

                  rightTitles: const AxisTitles(),

                  topTitles: const AxisTitles(),

                  bottomTitles: AxisTitles(

                    sideTitles: SideTitles(

                      showTitles: true,

                      getTitlesWidget: (value, meta) {

                        final idx = value.toInt();

                        if (idx >= 0 && idx < data.length) {

                          String name = data[idx]['name'] ?? '';

                          if (name.length > 8) {

                            name = '${name.substring(0, 7)}…';

                          }

                          return SideTitleWidget(

                            axisSide: meta.axisSide,

                            child: Text(

                              name,

                              style: const TextStyle(

                                fontSize: 10,

                                color: groupOnSurface,

                              ),

                            ),

                          );

                        }

                        return const SizedBox.shrink();

                      },

                      reservedSize: 28,

                    ),

                  ),

                ),

                barTouchData: BarTouchData(

                  enabled: true,

                  touchTooltipData: BarTouchTooltipData(

                    getTooltipColor: (_) => neopopOnPrimary,

                    getTooltipItem: (group, groupIndex, rod, rodIndex) {

                      final net =

                          (data[groupIndex]['netBalance'] as num?)?.toDouble() ??

                              0.0;

                      final label = net >= 0 ? 'Is owed' : 'Owes';

                      return BarTooltipItem(

                        '$label: ₹${net.abs().toStringAsFixed(0)}',

                        body2_text.copyWith(color: neopopBackground),

                      );

                    },

                  ),

                ),

                borderData: FlBorderData(show: false),

                gridData: const FlGridData(show: false),

                barGroups: data.asMap().entries.map((entry) {

                  final i = entry.key;

                  final member = entry.value;

                  final net =

                      (member['netBalance'] as num?)?.toDouble() ?? 0.0;

                  final isOwed = net >= 0;



                  return BarChartGroupData(

                    x: i,

                    barRods: [

                      BarChartRodData(

                        toY: net.abs(),

                        color: isOwed ? _isOwedColor : _owesColor,

                        width: 16,

                        borderRadius: const BorderRadius.only(

                          topLeft: Radius.circular(3),

                          topRight: Radius.circular(3),

                        ),

                      ),

                    ],

                  );

                }).toList(),

              ),

            ),

          ),

          SizedBox(height: height_16),

          ...data.map((member) {

            final net =

                (member['netBalance'] as num?)?.toDouble() ?? 0.0;

            final isOwed = net >= 0;

            return Padding(

              padding: EdgeInsets.only(bottom: height_10),

              child: Row(

                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [

                  Expanded(

                    child: Text(

                      member['name'] ?? '',

                      style: body2_text.copyWith(color: groupOnSurface),

                      overflow: TextOverflow.ellipsis,

                    ),

                  ),

                  Text(

                    isOwed

                        ? 'Is owed ₹${net.abs().toStringAsFixed(0)}'

                        : 'Owes ₹${net.abs().toStringAsFixed(0)}',

                    style: caption_text.copyWith(

                      color: isOwed ? _isOwedColor : _owesColor,

                      fontWeight: FontWeight.w600,

                    ),

                  ),

                ],

              ),

            );

          }),

        ],

      ),

    );

  }



  Widget _legendDot(Color color, String label) {

    return Row(

      mainAxisSize: MainAxisSize.min,

      children: [

        Container(

          width: 12,

          height: 12,

          decoration: BoxDecoration(

            color: color,

            borderRadius: BorderRadius.circular(3),

          ),

        ),

        SizedBox(width: width_10 / 2),

        Text(label, style: caption_text.copyWith(color: groupOnSurface)),

      ],

    );

  }

}


