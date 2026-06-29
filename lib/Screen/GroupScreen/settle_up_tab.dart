import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/swipe_to_settle_widget.dart';
import 'package:splitter/Controller/group_screen_controller.dart';
import 'package:splitter/Controller/settle_up_controller.dart';
import 'package:splitter/Screen/GroupScreen/shareable_settlement_card.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitter/Widgets/user_avatar.dart';

import 'package:splitter/Widgets/tab_empty_state.dart';

import '../../Constants/shared.dart';

class SettleUpTab extends StatefulWidget {
  final String groupID;
  final String userID;
  final String groupName;

  const SettleUpTab({
    required this.groupID,
    required this.userID,
    required this.groupName,
    super.key,
  });

  @override
  State<SettleUpTab> createState() => _SettleUpTabState();
}

class _SettleUpTabState extends State<SettleUpTab> {
  late final SettleUpController _settleUpController;
  Worker? _refreshWorker;

  @override
  void initState() {
    super.initState();
    _settleUpController = Get.put(
      SettleUpController(
        groupID: widget.groupID,
        userID: widget.userID,
        groupName: widget.groupName,
      ),
      tag: widget.groupID,
    );
    if (Get.isRegistered<GroupScreenController>()) {
      final groupController = Get.find<GroupScreenController>();
      _refreshWorker = ever(groupController.refreshTrigger, (_) {
        _settleUpController.fetchAndSimplifyDebts(showLoading: false);
      });
    }
  }

  @override
  void dispose() {
    _refreshWorker?.dispose();
    Get.delete<SettleUpController>(tag: widget.groupID);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        // Loading state
        if (_settleUpController.isLoading.value) {
          return const Center(
            child: LoadingWidget(),
          );
        }

        // Error state
        if (_settleUpController.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: neopopGrey,
                  size: height_10 * 4.8,
                ),
                SizedBox(height: height_16),
                Text(
                  _settleUpController.errorMessage.value,
                  style: body1_text.copyWith(color: neopopGrey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height_16),
                ElevatedButton(
                  onPressed: () => _settleUpController.fetchAndSimplifyDebts(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neopopAccent,
                  ),
                  child: Text(
                    "Retry",
                    style: button_text.copyWith(color: neopopOnAccent),
                  ),
                ),
              ],
            ),
          );
        }

        // Empty state
        if (!_settleUpController.hasBalanceData.value) {
          return const TabEmptyState(
            variant: TabEmptyVariant.settleUpNoSplits,
            title: 'No splits yet',
            subtitle: 'Add a group expense to see who owes what.',
          );
        }

        if (_settleUpController.simplifiedDebts.isEmpty) {
          return const TabEmptyState(
            variant: TabEmptyVariant.settleUpAllSettled,
            title: 'All settled up',
            subtitle: 'No outstanding balances in this group.',
          );
        }

        // Debts list
        final debts = _settleUpController.simplifiedDebts;
        final maxAmount =
            debts.map((d) => d.amount).reduce((a, b) => a > b ? a : b);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            width: devSysWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select a balance to settle!",
                  style: sub_headline4_text.copyWith(color: groupOnSurface),
                ),
                SizedBox(height: height_10),
                Text(
                  "${debts.length} transfer${debts.length > 1 ? 's' : ''} needed",
                  style: caption_text.copyWith(color: neopopGrey),
                ),
                SizedBox(height: height_16),
                SizedBox(
                  width: devSysWidth,
                  child: ListView.separated(
                    itemCount: debts.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final debt = debts[index];
                      final isCurrentUserDebtor = debt.fromID == widget.userID;
                      final isCurrentUserCreditor = debt.toID == widget.userID;

                      return GestureDetector(
                        onTap: () => _openSwipeToSettle(debt),
                        child: Container(
                          width: devSysWidth,
                          padding: EdgeInsets.all(height_16),
                          decoration: BoxDecoration(
                            color: neopopBackground.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: neopopGrey.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // From user avatar
                                  UserAvatar(
                                    userID: debt.fromID,
                                    userName: debt.fromName,
                                    radius: height_10 * 2,
                                    fontSize:
                                        12, // matching caption_text size approx
                                  ),
                                  SizedBox(width: width_10),
                                  // Arrow
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: neopopGrey,
                                    size: height_10 * 2,
                                  ),
                                  SizedBox(width: width_10),
                                  // To user avatar
                                  UserAvatar(
                                    userID: debt.toID,
                                    userName: debt.toName,
                                    radius: height_10 * 2,
                                    fontSize: 12,
                                  ),
                                  const Spacer(),
                                  // Amount
                                  Text(
                                    "₹${debt.amount.toStringAsFixed(2)}",
                                    style: sub_headline4_text.copyWith(
                                      color: isCurrentUserDebtor
                                          ? neopopYellow
                                          : isCurrentUserCreditor
                                              ? neopopAccent
                                              : groupOnSurface,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: height_10),
                              // Description text
                              RichText(
                                text: TextSpan(
                                  style: body2_text.copyWith(
                                    color: groupOnSurface,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: isCurrentUserDebtor
                                          ? "You"
                                          : debt.fromName,
                                      style: body2_text.copyWith(
                                        color: groupOnSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const TextSpan(text: " pays "),
                                    TextSpan(
                                      text: isCurrentUserCreditor
                                          ? "you"
                                          : debt.toName,
                                      style: body2_text.copyWith(
                                        color: groupOnSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: height_10),
                              // Progress bar
                              LinearProgressIndicator(
                                value:
                                    maxAmount > 0 ? debt.amount / maxAmount : 0,
                                color: isCurrentUserDebtor
                                    ? neopopYellow
                                    : neopopAccent,
                                backgroundColor: neopopAccent.withOpacity(0.15),
                                minHeight: 4,
                                borderRadius: BorderRadius.circular(height_10),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        SizedBox(height: height_10),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// Opens the swipe-to-settle fullscreen gesture overlay.
  void _openSwipeToSettle(SimplifiedDebt debt) {
    final isCurrentUserDebtor = debt.fromID == widget.userID;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return SwipeToSettleWidget(
            amount: debt.amount,
            fromName: isCurrentUserDebtor ? "You" : debt.fromName,
            toName: debt.toID == widget.userID ? "You" : debt.toName,
            onSettled: () async {
              final success = await _settleUpController.recordSettlement(
                debt,
                requireBiometric: true,
              );
              if (context.mounted) {
                Navigator.of(context).pop();
              }
              if (success) {
                Fluttertoast.showToast(
                  msg: "Settlement recorded! ✅",
                  textColor: neopopBackground,
                  backgroundColor: neopopAccent,
                );
                // Show shareable settlement card
                if (context.mounted) {
                  _showShareableSettlementCard(
                    debt: debt,
                    isCurrentUserDebtor: isCurrentUserDebtor,
                  );
                }
              } else {
                Fluttertoast.showToast(
                  msg: "Failed to record settlement.",
                  textColor: neopopBackground,
                  backgroundColor: neopopYellow,
                );
              }
            },
            onCancel: () => Navigator.of(context).pop(),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
      ),
    );
  }

  /// Shows a bottom sheet with the shareable settlement card.
  void _showShareableSettlementCard({
    required SimplifiedDebt debt,
    required bool isCurrentUserDebtor,
  }) {
    final cardKey = GlobalKey();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            top: 24,
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: neopopBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: neopopGrey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Share Settlement',
                style: sub_headline5_text.copyWith(color: neopopOnPrimary),
              ),
              const SizedBox(height: 20),
              ShareableSettlementCard(
                fromName: isCurrentUserDebtor ? "You" : debt.fromName,
                toName: debt.toID == widget.userID ? "You" : debt.toName,
                amount: debt.amount,
                groupName: widget.groupName,
                settledDate: DateTime.now(),
                repaintKey: cardKey,
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
