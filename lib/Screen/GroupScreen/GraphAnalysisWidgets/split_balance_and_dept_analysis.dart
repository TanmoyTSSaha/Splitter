import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:splitter/Constants/shared.dart';
import '../../../Constants/constants.dart';

class SplitBalanceAndDeptAnalysis extends StatefulWidget {
  const SplitBalanceAndDeptAnalysis({super.key});

  @override
  State<SplitBalanceAndDeptAnalysis> createState() =>
      _SplitBalanceAndDeptAnalysisState();
}

class _SplitBalanceAndDeptAnalysisState
    extends State<SplitBalanceAndDeptAnalysis> {
  final pilateColor = neopopAccent;
  final cyclingColor = neopopAccent.withOpacity(0.66);
  final quickWorkoutColor = neopopAccent.withOpacity(0.33);
  final betweenSpace = 0.2;

  final participentOneColor = getRandomBrightColor();
  final participentTwoColor = getRandomBrightColor();
  final participentThreeColor = getRandomBrightColor();
  final participentFourColor = getRandomBrightColor();
  final participentFiveColor = getRandomBrightColor();

  final List<Map<String, dynamic>> splitData = [
    {
      "name": "Tanmoy",
      "splits": [
        {
          "name": "Hardik",
          "price": 100,
        },
        {
          "name": "Deepesh",
          "price": 300,
        },
        {
          "name": "Gourav",
          "price": 0,
        },
        {
          "name": "Durgesh",
          "price": 500,
        },
      ],
    },
    {
      "name": "Hardik",
      "splits": [
        {
          "name": "Tanmoy",
          "price": 400,
        },
        {
          "name": "Deepesh",
          "price": 0,
        },
        {
          "name": "Gourav",
          "price": 200,
        },
        {
          "name": "Durgesh",
          "price": 700,
        },
      ],
    },
    {
      "name": "Deepesh",
      "splits": [
        {
          "name": "Tanmoy",
          "price": 400,
        },
        {
          "name": "Hardik",
          "price": 0,
        },
        {
          "name": "Gourav",
          "price": 200,
        },
        {
          "name": "Durgesh",
          "price": 700,
        },
      ],
    },
    {
      "name": "Gourav",
      "splits": [
        {
          "name": "Tanmoy",
          "price": 500,
        },
        {
          "name": "Hardik",
          "price": 100,
        },
        {
          "name": "Deepesh",
          "price": 200,
        },
        {
          "name": "Durgesh",
          "price": 500,
        },
      ],
    },
    {
      "name": "Gourav",
      "splits": [
        {
          "name": "Tanmoy",
          "price": 900,
        },
        {
          "name": "Hardik",
          "price": 200,
        },
        {
          "name": "Deepesh",
          "price": 300,
        },
        {
          "name": "Gourav",
          "price": 200,
        },
      ],
    },
  ];

  List<BarChartGroupData> barChartGroup = [];

  BarChartGroupData generateGroupData2(
    int x,
    Map<String, dynamic> splitDetails,
  ) {
    List<BarChartRodData> barRods = [];
    double previousY = 0; // Tracks the previous bar's ending point

    // Loop through each split in the splits list
    List<Map<String, dynamic>> splits = splitDetails['splits'];
    for (int i = 0; i < splits.length; i++) {
      var split = splits[i];
      double price = split['price'].toDouble();
      Color color;

      // Dynamically assign a color, e.g., based on the index or a predefined set of colors
      switch (i) {
        case 0:
          color = Colors.red;
          break;
        case 1:
          color = Colors.green;
          break;
        case 2:
          color = Colors.blue;
          break;
        case 3:
          color = Colors.orange;
          break;
        default:
          color = Colors.purple;
      }

      // Create a new BarChartRodData for each split
      barRods.add(
        BarChartRodData(
          fromY: previousY,
          toY: previousY + price,
          color: color,
          width: 5,
        ),
      );

      // Update previousY for the next rod, with spacing
      previousY += price + betweenSpace;
    }

    return BarChartGroupData(
      x: x,
      groupVertically: true,
      barRods: barRods,
    );
  }

  BarChartGroupData generateGroupData(
    int x,
    double participentOne,
    double participentTwo,
    double participentThree,
    double participentFour,
    double participentFive,
  ) {
    return BarChartGroupData(
      x: x,
      groupVertically: true,
      barRods: [
        BarChartRodData(
          fromY: 0,
          toY: participentOne,
          color: participentOneColor,
          width: 5,
        ),
        BarChartRodData(
          fromY: participentOne + betweenSpace + participentTwo + betweenSpace,
          toY: participentOne +
              betweenSpace +
              participentTwo +
              betweenSpace +
              participentFour,
          color: participentTwoColor,
          width: 5,
        ),
        BarChartRodData(
          fromY: participentOne + betweenSpace + participentTwo + betweenSpace,
          toY: participentOne +
              betweenSpace +
              participentTwo +
              betweenSpace +
              participentThree,
          color: participentThreeColor,
          width: 5,
        ),
        BarChartRodData(
          fromY: participentOne +
              betweenSpace +
              participentTwo +
              betweenSpace +
              participentThree +
              betweenSpace,
          toY: participentOne +
              betweenSpace +
              participentTwo +
              betweenSpace +
              participentThree +
              betweenSpace +
              participentFour,
          color: participentFourColor,
          width: 5,
        ),
        BarChartRodData(
          fromY: participentOne +
              betweenSpace +
              participentTwo +
              betweenSpace +
              participentThree +
              betweenSpace,
          toY: participentOne +
              betweenSpace +
              participentTwo +
              betweenSpace +
              participentThree +
              betweenSpace +
              participentFive,
          color: participentFiveColor,
          width: 5,
        ),
      ],
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);

    // Ensure that the value is within the valid range of the list
    if (value.toInt() >= 0 && value.toInt() < splitData.length) {
      // Get the corresponding string based on the index
      String text = splitData[value.toInt()]["name"];

      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(text, style: style),
      );
    } else {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: const Text('',
            style: style), // Return empty text for invalid indices
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    for (var i = 0; i < splitData.length; i++) {
      barChartGroup.add(generateGroupData2(i, splitData[i]));
    }
    return Container(
      width: devSysWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LegendsListWidget(
          //   legends: [
          //     Legend('Pilates', pilateColor),
          //     Legend('Quick workouts', quickWorkoutColor),
          //     Legend('Cycling', cyclingColor),
          //   ],
          // ),
          SizedBox(height: height_16),
          AspectRatio(
            aspectRatio: 2,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: bottomTitles,
                      reservedSize: 24,
                    ),
                  ),
                ),
                barTouchData: BarTouchData(enabled: false),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: barChartGroup,
                maxY: 1500 + (betweenSpace * 3),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: 3.3,
                      color: pilateColor,
                      strokeWidth: 1,
                      dashArray: [20, 4],
                    ),
                    HorizontalLine(
                      y: 8,
                      color: quickWorkoutColor,
                      strokeWidth: 1,
                      dashArray: [20, 4],
                    ),
                    HorizontalLine(
                      y: 11,
                      color: cyclingColor,
                      strokeWidth: 1,
                      dashArray: [20, 4],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
