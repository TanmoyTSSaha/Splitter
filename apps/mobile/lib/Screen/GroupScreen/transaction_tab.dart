import 'package:flutter/material.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/staggered_list_animation.dart';
import 'package:splitr/Constants/sync_indicator_widget.dart';
import 'package:splitr/Controller/group_screen_controller.dart';
import 'package:splitr/Controller/transaction_tab_controller.dart';
import 'package:splitr/Repository/transaction_repository.dart';
import 'package:splitr/Services/supabase_service.dart';

import 'package:splitr/Screen/GroupScreen/add_transaction_screen.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Widgets/tab_empty_state.dart';
import '../../Constants/shared.dart';
import '../../Model/group_model.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

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
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: groupSheetTopBorderRadius,
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(groupGutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: neopopAccent),
                title: Text(AppStrings.actions.edit,
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
                          groupDetails: {
                            UnifiedTxnKeys.groupId: widget.groupID
                          },
                          transactionToEdit: transactionModel,
                        ));

                    _controller.refresh();
                  } catch (e, stack) {
                    Get.back();
                    AppErrorReporter.report(
                      AppStrings.errors.loadGroupDetailsPrefix,
                      error: e,
                      stack: stack,
                    );
                  }
                },
              ),
              Divider(color: groupMutedBorderSoft),
              ListTile(
                leading: const Icon(Icons.delete, color: neopopError),
                title: Text(AppStrings.actions.delete,
                    style: body1_text.copyWith(color: neopopError)),
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
          titlePadding: EdgeInsets.all(groupGutter),
          actionsPadding: EdgeInsets.all(groupGutter),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          title: Text(
            AppStrings.groups.deleteTransactionTitle,
            style: sub_headline5_text.copyWith(
              color: neopopBackground,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: Text(
            AppStrings.groups.deleteTransactionGroupConfirm,
            style: caption_text.copyWith(
              color: neopopBackground,
            ),
          ),
          actions: [
            CustomSecondaryButton(
              buttonText: AppStrings.actions.yes,
              onPressed: () async {
                Get.back();
                Get.dialog(
                  const Center(child: LoadingWidget()),
                  barrierDismissible: false,
                );

                try {
                  await Get.find<TransactionRepository>()
                      .deleteGroupTransaction(
                          transactionGroupID: transactionGroupID,
                          groupID: widget.groupID);
                  Get.back();
                  await _controller.refresh();
                  SplitrToast.show(SplitrToast.join(AppStrings.notifications.inviteSuccess, AppStrings.groups.transactionDeletedSuccess));
                } catch (e, stack) {
                  Get.back();
                  AppErrorReporter.report(
                    AppStrings.home.transactionDeleteFailed,
                    error: e,
                    stack: stack,
                  );
                }
              },
              buttonHeight: groupGutter * 2.5,
              buttonWidth: devSysWidth * 0.26,
            ),
            CustomSecondaryButton(
              buttonText: AppStrings.actions.no,
              onPressed: () {
                Get.back();
              },
              buttonHeight: groupGutter * 2.5,
              buttonWidth: devSysWidth * 0.26,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() => SyncStatusBanner(status: _controller.syncStatus.value)),
        Expanded(child: Obx(() => _buildTransactionBody(context))),
      ],
    );
  }

  Widget _buildTransactionBody(BuildContext context) {
    if (_controller.isLoading.value &&
        _controller.consolidatedTransactions.isEmpty) {
      return const Center(child: LoadingWidget());
    }

    if (_controller.errorMessage.value != null) {
      return Center(
        child: Text(
          _controller.errorMessage.value!,
          style: sub_headline5_text.copyWith(color: neopopAccent),
        ),
      );
    }

    final cnsGrpTrns = _controller.consolidatedTransactions;
    if (cnsGrpTrns.isEmpty) {
      return RefreshIndicator(
        onRefresh: _controller.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: devSysHeight * 0.55,
              child: TabEmptyState(
                variant: TabEmptyVariant.transactions,
                title: AppStrings.groups.noTransactionsYet,
                subtitle: AppStrings.groups.addExpenseToStart,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _controller.refresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: groupGutter),
        itemCount: cnsGrpTrns.length,
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
          return Column(
            children: [
              if (index > 0)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: groupGap10,
                    vertical: groupGapNone,
                  ),
                  child: Divider(
                    height: 1,
                    thickness: 2,
                    color: groupMutedBorderHairline,
                  ),
                ),
              Container(
                width: devSysWidth,
                decoration: BoxDecoration(
                  color: groupTransparent,
                  borderRadius: BorderRadius.circular(groupRadiusSm),
                  border: Border.all(
                    color: neopopGreyIconMuted,
                    width: 1,
                  ),
                ),
                child: StaggeredListItem(
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
                      cardSubTitle:
                          widget.userID == cnsGrpTrns[index].paidByUUID
                              ? GroupCopy.paidByYou
                              : AppStringFormat.paidBy(
                                  cnsGrpTrns[index].paidByName!),
                      cardDateTime: cnsGrpTrns[index].transactionDate!,
                      cardPrice: cardPrice,
                      categoryLogoURL: cnsGrpTrns[index].categoryLogo ?? '',
                      category: cnsGrpTrns[index].category ?? '',
                      amountColor: amountColor,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
