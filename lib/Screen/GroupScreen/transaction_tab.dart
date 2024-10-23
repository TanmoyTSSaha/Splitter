import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';

import '../../Constants/shared.dart';

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
              color: neopopGrey.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.expenseHistoryStrings.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return TransactionCard(
                index: index,
                cardTitle: widget.expenseHistoryStrings[index % 6],
                cardSubTitle: "Mysuru Trip paid by Tanmoy",
                cardDateTime: DateTime.now(),
                cardPrice: 600,
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
