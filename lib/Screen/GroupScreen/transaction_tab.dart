import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Services/supabase_service.dart';

import '../../Constants/shared.dart';
import '../../Model/group_model.dart';

class TransactionTab extends StatefulWidget {
  final List<String> expenseHistoryStrings;
  final String userID;
  final String groupID;
  const TransactionTab({
    required this.expenseHistoryStrings,
    required this.userID,
    required this.groupID,
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
        child: FutureBuilder<List<GroupTransactionModel>>(
          future: SupabaseDatabase().getGroupTransactionsData(
              userID: widget.userID, groupID: widget.groupID),
          builder: (context, groupTransactionSnapshot) {
            if (groupTransactionSnapshot.hasData) {
              List<ConsolidatedGroupTransactionModel> cnsGrpTrns =
                  SupabaseDatabase().getConsolidatedGroupTransactionData(
                      groupTransactionList: groupTransactionSnapshot.data!);

              return Container(
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
                  itemCount: cnsGrpTrns.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    double cardPrice = 0;
                    if (widget.userID == cnsGrpTrns[index].paidByUUID) {
                      for (var element in cnsGrpTrns[index].sharedWith!) {
                        cardPrice += element.sharedTransactionAmount!;
                      }
                    } else {
                      for (var element in cnsGrpTrns[index].sharedWith!) {
                        if (widget.userID == element.sharedWithUUID) {
                          cardPrice += element.sharedTransactionAmount!;
                        }
                      }
                    }
                    return TransactionCard(
                      index: index,
                      cardTitle: cnsGrpTrns[index].description!,
                      cardSubTitle: "Paid by ${cnsGrpTrns[index].paidByName!}",
                      cardDateTime: cnsGrpTrns[index].transactionDate!,
                      cardPrice: cardPrice,
                      categoryLogoURL: cnsGrpTrns[index].categoryLogo!,
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
              );
            } else if (groupTransactionSnapshot.hasError) {
              debugPrint("SNAPSHOT ERROR: ${groupTransactionSnapshot.error}");
              return Container(
                height: devSysHeight * 0.6,
                width: devSysWidth,
                decoration: const BoxDecoration(
                  color: neopopBackground,
                ),
                child: Center(
                  child: Text(
                    "Something went wrong!",
                    style: sub_headline5_text.copyWith(
                      color: neopopAccent,
                    ),
                  ),
                ),
              );
            }

            return Container(
              height: devSysHeight * 0.6,
              width: devSysWidth,
              decoration: const BoxDecoration(
                color: neopopBackground,
              ),
              alignment: Alignment.center,
              child: const LoadingWidget(),
            );
          },
        ),
      ),
    );
  }
}
