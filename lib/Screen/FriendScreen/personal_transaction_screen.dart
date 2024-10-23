import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../Constants/constants.dart';
import '../../Constants/shared.dart';

class PersonalTransactionScreen extends StatefulWidget {
  const PersonalTransactionScreen({super.key});

  @override
  State<PersonalTransactionScreen> createState() =>
      _PersonalTransactionScreenState();
}

class _PersonalTransactionScreenState extends State<PersonalTransactionScreen> {
  List<String> expenseHistoryStrings = [
    "Flight Confirmation",
    "Hotel Reservation",
    "Activity Planning",
    "Packing List",
    "Travel Insurance",
    "Resort Booking",
  ];

  final TextEditingController durationController = TextEditingController();

  final double width = 7;

  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;

  int touchedGroupIndex = -1;

  @override
  void initState() {
    super.initState();
    final barGroup1 = makeGroupData(0, 5, 12);
    final barGroup2 = makeGroupData(1, 16, 12);
    final barGroup3 = makeGroupData(2, 18, 5);
    final barGroup4 = makeGroupData(3, 20, 16);
    final barGroup5 = makeGroupData(4, 17, 6);
    final barGroup6 = makeGroupData(5, 19, 1.5);
    final barGroup7 = makeGroupData(6, 10, 1.5);

    final items = [
      barGroup1,
      barGroup2,
      barGroup3,
      barGroup4,
      barGroup5,
      barGroup6,
      barGroup7,
    ];

    rawBarGroups = items;

    showingBarGroups = rawBarGroups;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: neopopBackground,
        appBar: AppBar(
          primary: true,
          backgroundColor: neopopBackground,
          automaticallyImplyLeading: false,
          leadingWidth: height_10 * 7.2,
          centerTitle: true,
          elevation: 0,
          title: Text(
            "Personal Expenses",
            style: sub_headline4_text,
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus!.unfocus();
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              width: devSysWidth,
              padding: const EdgeInsets.symmetric(
                vertical: 24,
                horizontal: 16,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DropdownMenu<DurationLabel>(
                        initialSelection: DurationLabel.monthly,
                        controller: durationController,
                        requestFocusOnTap: true,
                        label: const Text('Duration'),
                        dropdownMenuEntries: DurationLabel.values
                            .map<DropdownMenuEntry<DurationLabel>>(
                                (DurationLabel lbl) {
                          return DropdownMenuEntry<DurationLabel>(
                            value: lbl,
                            label: lbl.label,
                          );
                        }).toList(),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: height_16,
                            width: width_16,
                            decoration: BoxDecoration(
                              color: neopopYellow,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(width: width_10 / 2),
                          Text(
                            "Expense",
                            style: caption_text.copyWith(color: neopopYellow),
                          ),
                        ],
                      ),
                      SizedBox(width: width_10 * 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: height_16,
                            width: width_16,
                            decoration: BoxDecoration(
                              color: neopopAccent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(width: width_10 / 2),
                          Text(
                            "Income",
                            style: caption_text.copyWith(color: neopopAccent),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(top: height_16 * 2),
                    width: devSysWidth,
                    height: devSysHeight * 0.25,
                    child: BarChart(
                      BarChartData(
                        maxY: 20,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: ((group) {
                              return Colors.grey;
                            }),
                            getTooltipItem: (a, b, c, d) => null,
                          ),
                          touchCallback: (FlTouchEvent event, response) {
                            if (response == null || response.spot == null) {
                              setState(() {
                                touchedGroupIndex = -1;
                                showingBarGroups = List.of(rawBarGroups);
                              });
                              return;
                            }

                            touchedGroupIndex =
                                response.spot!.touchedBarGroupIndex;

                            setState(() {
                              if (!event.isInterestedForInteractions) {
                                touchedGroupIndex = -1;
                                showingBarGroups = List.of(rawBarGroups);
                                return;
                              }
                              showingBarGroups = List.of(rawBarGroups);
                              if (touchedGroupIndex != -1) {
                                var sum = 0.0;
                                for (final rod
                                    in showingBarGroups[touchedGroupIndex]
                                        .barRods) {
                                  sum += rod.toY;
                                }
                                final avg = sum /
                                    showingBarGroups[touchedGroupIndex]
                                        .barRods
                                        .length;

                                showingBarGroups[touchedGroupIndex] =
                                    showingBarGroups[touchedGroupIndex]
                                        .copyWith(
                                  barRods: showingBarGroups[touchedGroupIndex]
                                      .barRods
                                      .map((rod) {
                                    return rod.copyWith(
                                        toY: avg, color: neopopAccent);
                                  }).toList(),
                                );
                              }
                            });
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: bottomTitles,
                              reservedSize: 42,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              interval: 1,
                              getTitlesWidget: leftTitles,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        barGroups: showingBarGroups,
                        gridData: const FlGridData(show: false),
                      ),
                    ),
                  ),
                  SizedBox(height: height_16),
                  Container(
                    width: devSysWidth * 0.875,
                    // height: devSysHeight * 0.1,
                    decoration: const BoxDecoration(
                      color: neopopOnPrimary,
                    ),
                    padding: EdgeInsets.all(height_16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/icons/svg/clarity--piggy-bank-line.svg",
                              height: height_10 * 3.6,
                              width: height_10 * 3.6,
                              fit: BoxFit.contain,
                              color: neopopAccent,
                            ),
                            SizedBox(width: width_16),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Income",
                                  style: body1_text.copyWith(
                                    color: neopopBackground,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "₹120 more then Sept.",
                                  style: caption_text.copyWith(
                                    color: neopopBackground,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              "₹1230",
                              style: sub_headline4_text.copyWith(
                                color: neopopBackground,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: width_10),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: neopopBackground,
                              size: height_10 * 1.8,
                            ),
                          ],
                        ),
                        SizedBox(height: height_16),
                        const Divider(
                          color: neopopBackground,
                          height: 1,
                          thickness: 1,
                        ),
                        SizedBox(height: height_16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/icons/svg/mingcute--bill-line.svg",
                              height: height_10 * 3.6,
                              width: height_10 * 3.6,
                              fit: BoxFit.contain,
                              color: neopopAccent,
                            ),
                            SizedBox(width: width_16),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Expense",
                                  style: body1_text.copyWith(
                                    color: neopopBackground,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "215 more then Sept.",
                                  style: caption_text.copyWith(
                                    color: neopopBackground,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              "₹3478",
                              style: sub_headline4_text.copyWith(
                                color: neopopBackground,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: width_10),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: neopopBackground,
                              size: height_10 * 1.8,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height_16 * 1.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Top Transactions",
                        style: sub_headline4_text.copyWith(
                          color: neopopOnBackground,
                        ),
                      ),
                      NeoPopCustomTextButton(
                        buttonName: "View all",
                        buttonForegroundColor: neopopAccent,
                        buttonTextColor: neopopOnBackground,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  SizedBox(height: height_10),
                  Container(
                    width: devSysWidth,
                    padding: EdgeInsets.symmetric(horizontal: height_16),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: neopopGrey.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 6,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return TransactionCard(
                          index: index,
                          cardTitle: expenseHistoryStrings[index % 6],
                          cardSubTitle: "Trip to Paris - Paid by Rini",
                          cardDateTime: DateTime.now(),
                          cardPrice: 600,
                        );
                      },
                      separatorBuilder: (context, index) => Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: height_10, vertical: 0),
                        child: const Divider(
                          height: 1,
                          thickness: 2,
                          color: neopopSecondaryGrey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: neopopAccent,
            minimumSize: Size(devSysWidth * 0.35, height_16 * 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(devSysWidth * 0.5),
            ),
          ),
          child: Text(
            "Add Transaction",
            style: button_text.copyWith(
              color: neopopOnBackground,
            ),
          ),
        ),
      ),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    if (value == 0) {
      text = '1K';
    } else if (value == 10) {
      text = '5K';
    } else if (value == 19) {
      text = '10K';
    } else {
      return Container();
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Text(text, style: style),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    final titles = <String>['Mn', 'Te', 'Wd', 'Tu', 'Fr', 'St', 'Su'];

    final Widget text = Text(
      titles[value.toInt()],
      style: const TextStyle(
        color: Color(0xff7589a2),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16, //margin top
      child: text,
    );
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: neopopYellow,
          width: width,
        ),
        BarChartRodData(
          toY: y2,
          color: neopopAccent,
          width: width,
        ),
      ],
    );
  }
}
