import 'package:flutter/material.dart';
import 'package:splitr/Utils/currency_utils.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/theme_accent_colors.dart';
import 'package:splitr/Controller/group_screen_controller.dart';
import 'package:splitr/Controller/settle_up_controller.dart';
import 'package:splitr/Screen/GroupScreen/manual_settle_up_screen.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Widgets/user_avatar.dart';

import 'package:splitr/Widgets/tab_empty_state.dart';

import '../../Constants/shared.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/domain_values.dart';

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
    return Obx(() {
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
                  size: groupCtaHeightCompact,
                ),
                SizedBox(height: groupGutter),
                Text(
                  _settleUpController.errorMessage.value,
                  style: body1_text.copyWith(color: neopopGrey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: groupGutter),
                ElevatedButton(
                  onPressed: () => _settleUpController.fetchAndSimplifyDebts(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neopopAccent,
                  ),
                  child: Text(
                    AppStrings.groups.retry,
                    style: button_text.copyWith(color: neopopOnAccent),
                  ),
                ),
              ],
            ),
          );
        }

        // Empty state
        if (!_settleUpController.hasBalanceData.value) {
          return TabEmptyState(
            variant: TabEmptyVariant.settleUpNoSplits,
            title: AppStrings.groups.noSplitsYet,
            subtitle: AppStrings.groups.noSplitsSubtitle,
          );
        }

        if (_settleUpController.simplifiedDebts.isEmpty) {
          return TabEmptyState(
            variant: TabEmptyVariant.settleUpAllSettled,
            title: AppStrings.groups.allSettledUp,
            subtitle: AppStrings.groups.allSettledUpSubtitle,
          );
        }

        // Debts list
        final debts = _settleUpController.simplifiedDebts;
        final maxAmount =
            debts.map((d) => d.amount).reduce((a, b) => a > b ? a : b);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: devSysWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.validation.selectBalance,
                  style: sub_headline4_text.copyWith(color: groupOnSurface),
                ),
                SizedBox(height: groupGap10),
                Text(
                  AppStringFormat.transfersNeeded(debts.length),
                  style: caption_text.copyWith(color: neopopGrey),
                ),
                SizedBox(height: groupGutter),
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
                        onTap: () async {
                          final settled = await Get.to<bool>(
                            () => ManualSettleUpScreen(
                              groupID: widget.groupID,
                              currentUserID: widget.userID,
                              groupName: widget.groupName,
                              initialDebt: debt,
                            ),
                          );
                          if (settled == true) {
                            _settleUpController.fetchAndSimplifyDebts(
                              showLoading: false,
                            );
                          }
                        },
                        child: Container(
                          width: devSysWidth,
                          padding: EdgeInsets.all(groupGutter),
                          decoration: BoxDecoration(
                            color: neopopBackgroundFillWhisper,
                            borderRadius:
                                BorderRadius.circular(groupControlRadius),
                            border: Border.all(
                              color: neopopGreyBorder,
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
                                    radius: groupGap20,
                                    fontSize:
                                        12, // matching caption_text size approx
                                  ),
                                  SizedBox(width: groupGap10),
                                  // Arrow
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: neopopGrey,
                                    size: groupGap20,
                                  ),
                                  SizedBox(width: groupGap10),
                                  // To user avatar
                                  UserAvatar(
                                    userID: debt.toID,
                                    userName: debt.toName,
                                    radius: groupGap20,
                                    fontSize: splitrFontCaption,
                                  ),
                                  const Spacer(),
                                  // Amount
                                  Text(
                                    "${userCurrencySymbol()}${debt.amount.toStringAsFixed(2)}",
                                    style: sub_headline4_text.copyWith(
                                      color: isCurrentUserDebtor
                                          ? ThemeAccentColors.oweWarning(context)
                                          : isCurrentUserCreditor
                                              ? neopopAccent
                                              : groupOnSurface,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: groupGap10),
                              // Description text
                              RichText(
                                text: TextSpan(
                                  style: body2_text.copyWith(
                                    color: groupOnSurface,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: isCurrentUserDebtor
                                          ? GroupCopy.self
                                          : debt.fromName,
                                      style: body2_text.copyWith(
                                        color: groupOnSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const TextSpan(text: GroupCopy.pays),
                                    TextSpan(
                                      text: isCurrentUserCreditor
                                          ? GroupCopy.selfLower
                                          : debt.toName,
                                      style: body2_text.copyWith(
                                        color: groupOnSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: groupGap10),
                              // Progress bar
                              LinearProgressIndicator(
                                value:
                                    maxAmount > 0 ? debt.amount / maxAmount : 0,
                                color: isCurrentUserDebtor
                                    ? neopopYellow
                                    : neopopAccent,
                                backgroundColor: neopopAccentFillMedium,
                                minHeight: 4,
                                borderRadius:
                                    BorderRadius.circular(groupRadiusMd),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        SizedBox(height: groupGap10),
                  ),
                ),
              ],
            ),
          ),
        );
      });
  }
}
