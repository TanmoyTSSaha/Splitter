import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splitter/Constants/constants.dart';

class TransactionTab extends StatefulWidget {
  final List<String> expenseHistoryStrings;
  const TransactionTab({
    required this.expenseHistoryStrings,
    super.key,
  });

  @override
  State<TransactionTab> createState() => _TransactionTabState();
}

class _TransactionTabState extends State<TransactionTab> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          width: devSysWidth,
          padding: EdgeInsets.symmetric(horizontal: height_16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: neopopGrey,
              width: 1,
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.expenseHistoryStrings.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: height_10 * 2.4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(56),
                      child: Image.network(
                        "https://placedog.net/50${(index + 1) * 2}/50${(index + 1) * 2}",
                        height: height_16 * 3,
                        width: width_16 * 3,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: width_10 * 2,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: (devSysWidth * 0.4),
                            child: Text(
                              widget.expenseHistoryStrings[index % 6],
                              overflow: TextOverflow.ellipsis,
                              style: body1_text.copyWith(
                                color: neopopOnBackground,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: height_10),
                          SizedBox(
                            width: (devSysWidth * 0.4),
                            child: Text(
                              "Trip to Paris - Paid by Rini",
                              overflow: TextOverflow.ellipsis,
                              style: caption_text.copyWith(
                                color: neopopGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat('HH:mm \t EEE d MMM')
                              .format(DateTime.now()),
                          style: caption_text.copyWith(
                            color: neopopOnBackground,
                          ),
                        ),
                        SizedBox(height: height_10),
                        Text(
                          "₹600",
                          style: body1_text.copyWith(
                            color: neopopAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: height_10, vertical: 0),
              child: const Divider(
                height: 1,
                thickness: 2,
                color: neopopSecondaryGrey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
