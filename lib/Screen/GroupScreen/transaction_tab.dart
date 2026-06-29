import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/staggered_list_animation.dart';
import 'package:splitter/Constants/sync_indicator_widget.dart';
import 'package:splitter/Controller/group_screen_controller.dart';
import 'package:splitter/Controller/transaction_tab_controller.dart';
import 'package:splitter/Services/supabase_service.dart';

import 'package:splitter/Screen/GroupScreen/add_transaction_screen.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitter/Widgets/tab_empty_state.dart';
import '../../Constants/shared.dart';
import '../../Model/group_model.dart';

class TransactionTab extends StatefulWidget {
  final String userID;
  final String groupID;
  const TransactionTab({
    required this.userID,
    required this.groupID,
    super.key,
  });

  @override
  State<TransactionTab> createState() => _TransactionTabState();
}

class _TransactionTabState extends State<TransactionTab> {
  late final TransactionTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      TransactionTabController(groupId: widget.groupID, userId: widget.userID),
      tag: widget.groupID,
    );
    final GroupScreenController groupController = Get.find();
    ever(groupController.refreshTrigger, (_) => _controller.refresh());
  }

  @override
  void dispose() {
    Get.delete<TransactionTabController>(tag: widget.groupID);
    super.dispose();
  }

  void _showTransactionOptions(BuildContext context, String transactionGroupID,
      ConsolidatedGroupTransactionModel transactionModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(height_16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: neopopAccent),
                title: Text("Edit",
                    style: body1_text.copyWith(color: groupOnSurface)),
                onTap: () async {
                  Navigator.pop(context);

                  Get.dialog(const Center(child: LoadingWidget()),
                      barrierDismissible: false);

                  try {
                    List<GroupMembersWithNameModel> members =
                        await SupabaseDatabase().getGroupMembers(
                            groupID: widget.groupID,
                            currentUserID: widget.userID);

                    Get.back();

                    await Get.to(() => AddTransactionScreen(
                          userID: widget.userID,
                          groupMembersDetails: members,
                          groupDetails: {"group_id": widget.groupID},
                          transactionToEdit: transactionModel,
                        ));

                    _controller.refresh();
                  } catch (e) {
                    Get.back();
                    Get.snackbar("Error", "Failed to load group details: $e",
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white);
                  }
                },
              ),
              Divider(color: groupOnSurfaceMuted.withOpacity(0.3)),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.redAccent),
                title: Text("Delete",
                    style: body1_text.copyWith(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmationDialog(context, transactionGroupID);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, String transactionGroupID) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: neopopYellow,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          titlePadding: EdgeInsets.all(height_16),
          actionsPadding: EdgeInsets.all(height_16),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          title: Text(
            "Delete Transaction?",
            style: sub_headline5_text.copyWith(
              color: neopopBackground,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: Text(
            "This will delete the transaction and update balances for all members.",
            style: caption_text.copyWith(
              color: neopopBackground,
            ),
          ),
          actions: [
            CustomSecondaryButton(
              buttonText: "Yes",
              onPressed: () async {
                Get.back();
                Get.dialog(
                  const Center(child: LoadingWidget()),
                  barrierDismissible: false,
                );

                try {
                  await SupabaseDatabase().deleteGroupTransaction(
                      transactionGroupID: transactionGroupID);
                  Get.back();
                  await _controller.refresh();
                  Get.snackbar("Success", "Transaction deleted successfully",
                      backgroundColor: neopopAccent,
                      colorText: groupOnSurface);
                } catch (e) {
                  Get.back();
                  Get.snackbar("Error", "Failed to delete transaction",
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white);
                }
              },
              buttonHeight: height_16 * 2.5,
              buttonWidth: devSysWidth * 0.26,
            ),
            CustomSecondaryButton(
              buttonText: "No",
              onPressed: () {
                Get.back();
              },
              buttonHeight: height_16 * 2.5,
              buttonWidth: devSysWidth * 0.26,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        return Column(
          children: [
            SyncStatusBanner(status: _controller.syncStatus.value),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _controller.refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: _buildTransactionList(),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTransactionList() {
    if (_controller.isLoading.value &&
        _controller.consolidatedTransactions.isEmpty) {
      return SizedBox(
        height: devSysHeight * 0.6,
        width: devSysWidth,
        child: const Center(child: LoadingWidget()),
      );
    }

    if (_controller.errorMessage.value != null) {
      return SizedBox(
        height: devSysHeight * 0.6,
        width: devSysWidth,
        child: Center(
          child: Text(
            _controller.errorMessage.value!,
            style: sub_headline5_text.copyWith(color: neopopAccent),
          ),
        ),
      );
    }

    final cnsGrpTrns = _controller.consolidatedTransactions;
    if (cnsGrpTrns.isEmpty) {
      return SizedBox(
        height: devSysHeight * 0.55,
        width: double.infinity,
        child: const TabEmptyState(
          variant: TabEmptyVariant.transactions,
          title: 'No transactions yet',
          subtitle: 'Add an expense to start splitting.',
        ),
      );
    }

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
          Color amountColor = neopopAccent;
          if (widget.userID == cnsGrpTrns[index].paidByUUID) {
            amountColor = neopopAccent;
            for (var element in cnsGrpTrns[index].sharedWith!) {
              cardPrice += element.sharedTransactionAmount!;
            }
          } else {
            amountColor = neopopPrimary;
            for (var element in cnsGrpTrns[index].sharedWith!) {
              if (widget.userID == element.sharedWithUUID) {
                cardPrice += element.sharedTransactionAmount!;
              }
            }
          }
          return StaggeredListItem(
            index: index,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onLongPress: () {
                _showTransactionOptions(
                  context,
                  cnsGrpTrns[index].transactionGroupID!,
                  cnsGrpTrns[index],
                );
              },
              child: TransactionCard(
                index: index,
                forLightSurface: true,
                cardTitle: cnsGrpTrns[index].description!,
                cardSubTitle: widget.userID == cnsGrpTrns[index].paidByUUID
                    ? "Paid by You"
                    : "Paid by ${cnsGrpTrns[index].paidByName!}",
                cardDateTime: cnsGrpTrns[index].transactionDate!,
                cardPrice: cardPrice,
                categoryLogoURL: cnsGrpTrns[index].categoryLogo ?? '',
                category: cnsGrpTrns[index].category ?? '',
                amountColor: amountColor,
              ),
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
    );
  }
}
