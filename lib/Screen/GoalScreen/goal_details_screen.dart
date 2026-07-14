import 'package:flutter/material.dart';
import 'package:splitr/Utils/currency_utils.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Controller/goal_details_controller.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Widgets/bordered_input_field.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';

class GoalDetailsScreen extends StatefulWidget {
  const GoalDetailsScreen({super.key});

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  late final GoalDetailsController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<GoalDetailsController>()) {
      Get.delete<GoalDetailsController>(force: true);
    }
    controller = Get.put(GoalDetailsController());
  }

  @override
  void dispose() {
    if (Get.isRegistered<GoalDetailsController>()) {
      Get.delete<GoalDetailsController>(force: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Get.back(result: controller.dataChanged);
        }
      },
      child: Scaffold(
        backgroundColor: surface,
        appBar: SplitrDetailAppBar(
          titleWidget: const SizedBox.shrink(),
          automaticallyImplyLeading: false,
          leading: SplitrDetailAppBar.iosBackLeading(
            context,
            onPressed: () => Get.back(result: controller.dataChanged),
          ),
          actions: [
            IconButton(
              onPressed: () => _showDeleteConfirmation(controller),
              icon: const Icon(Icons.delete_outline, color: neopopError),
            )
          ],
        ),
        body: GetBuilder<GoalDetailsController>(builder: (ctrl) {
          final progress =
              (ctrl.goal.currentAmount ?? 0) / (ctrl.goal.targetAmount ?? 1);
          final goalColor = ctrl.goal.colorHex != null
              ? Color(int.parse(ctrl.goal.colorHex!))
              : neopopAccent;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: width_16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: height_16),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: AppDimensions.groupGoalRingSize,
                      width: AppDimensions.groupGoalRingSize,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: AppDimensions.groupProgressStroke,
                        backgroundColor: groupMutedFillMedium,
                        valueColor: AlwaysStoppedAnimation<Color>(goalColor),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          ctrl.goal.icon ?? GoalDefaults.defaultEmoji,
                          style: const TextStyle(fontSize: splitrFontRecapXl),
                        ),
                        const SizedBox(height: groupGapSm),
                        Text(
                          AppStringFormat.progressPercent(
                            (progress * 100).toInt(),
                          ),
                          style: headline2_text.copyWith(
                            color: groupOnSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    )
                  ],
                ),
                SizedBox(height: height_16 * 2),
                Text(
                  ctrl.goal.title ?? DisplayFallbacks.goal,
                  style: headline2_text.copyWith(color: groupOnSurface),
                ),
                const SizedBox(height: groupGapSm),
                Text(
                  '${userCurrencySymbol()}${ctrl.goal.currentAmount?.toStringAsFixed(0)} / ${userCurrencySymbol()}${ctrl.goal.targetAmount?.toStringAsFixed(0)}',
                  style: body1_text.copyWith(color: groupOnSurfaceMuted),
                ),
                if (ctrl.goal.description != null &&
                    ctrl.goal.description!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: height_16),
                    child: Text(
                      ctrl.goal.description!,
                      textAlign: TextAlign.center,
                      style: body1_text.copyWith(
                        color: groupOnSurfaceMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                if (ctrl.goal.goalType != null &&
                    ctrl.goal.goalType!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: groupCarouselGap, vertical: groupGapXs),
                    decoration: BoxDecoration(
                      color: neopopAccentFillSoft,
                      borderRadius: BorderRadius.circular(groupCardRadiusLg),
                      border: Border.all(
                        color: neopopAccentBorderSoft,
                      ),
                    ),
                    child: Text(
                      ctrl.goal.goalType!,
                      style: caption_text.copyWith(color: neopopAccent),
                    ),
                  ),
                SizedBox(height: height_16 * 2),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showTransactionDialog(
                            context, controller, GoalTransactionTypes.deposit),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: neopopAccent,
                          padding:
                              const EdgeInsets.symmetric(vertical: groupGutter),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(groupControlRadius),
                          ),
                        ),
                        child: Text(
                          AppStrings.goals.addFunds,
                          style: button_text.copyWith(color: groupOnSurface),
                        ),
                      ),
                    ),
                    SizedBox(width: width_16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showTransactionDialog(
                            context, controller, GoalTransactionTypes.withdraw),
                        style: OutlinedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: groupGutter),
                          side: BorderSide(
                            color: groupMutedBorderHeavy,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(groupControlRadius),
                          ),
                        ),
                        child: Text(
                          AppStrings.goals.withdraw,
                          style: button_text.copyWith(color: groupOnSurface),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height_16 * 3),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppStrings.goals.history,
                    style: headline3_text.copyWith(color: groupOnSurface),
                  ),
                ),
                SizedBox(height: height_16),
                Obx(() {
                  if (controller.transactions.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          AppStrings.goals.historyEmpty,
                          style: caption_text.copyWith(
                            color: groupOnSurfaceMuted,
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.transactions.length,
                    itemBuilder: (context, index) {
                      final t = controller.transactions[index];
                      final isDeposit = t.type == GoalTransactionTypes.deposit;
                      return Container(
                        margin: const EdgeInsets.only(bottom: groupCarouselGap),
                        padding: const EdgeInsets.all(groupCarouselGap),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius:
                              BorderRadius.circular(groupControlRadius),
                          border: Border.all(
                            color: groupMutedBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(groupGapSm),
                                  decoration: BoxDecoration(
                                    color: isDeposit
                                        ? neopopSuccessBright.withValues(
                                            alpha: 0.15)
                                        : neopopError.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isDeposit
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: isDeposit
                                        ? neopopSuccessBright
                                        : neopopError,
                                    size: groupIconMd,
                                  ),
                                ),
                                const SizedBox(width: groupCarouselGap),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isDeposit
                                          ? AppStrings.goals.deposit
                                          : AppStrings.goals.withdrawal,
                                      style: body2_text.copyWith(
                                        color: groupOnSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      DateFormat(AppDateFormats.shortDay)
                                          .format(t.transactionDate ??
                                              DateTime.now()),
                                      style: caption_text.copyWith(
                                        color: groupOnSurfaceMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              '${isDeposit ? '+' : '-'} ${userCurrencySymbol()}${t.amount?.toStringAsFixed(0)}',
                              style: body1_text.copyWith(
                                color: isDeposit
                                    ? neopopSuccessBright
                                    : groupOnSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                })
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showTransactionDialog(
      BuildContext context, GoalDetailsController controller, String type) {
    final amountCtrl = TextEditingController();
    final surface = Theme.of(context).colorScheme.surface;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(groupGutter),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: groupSheetTopBorderRadiusLg,
          border: Border.all(color: neopopAccentBorderStrong),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              type == GoalTransactionTypes.deposit
                  ? AppStrings.goals.addToGoal
                  : AppStrings.goals.withdrawFromGoal,
              style: headline3_text.copyWith(color: groupOnSurface),
            ),
            const SizedBox(height: groupGapMd),
            BorderedInputField(
              controller: amountCtrl,
              hintText: AppAmountHints.zero,
              prefixText: currencyPrefixText(),
              keyboardType: TextInputType.number,
              style: headline1_text.copyWith(color: groupOnSurface),
            ),
            const SizedBox(height: groupGapLg),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final val = double.tryParse(amountCtrl.text);
                  if (val != null && val > 0) {
                    controller.addTransaction(
                        val, type, GoalDefaults.manualEntry);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: neopopAccent),
                child: Text(
                  AppStrings.actions.confirm,
                  style: button_text.copyWith(color: groupOnSurface),
                ),
              ),
            ),
            const SizedBox(height: groupGapMd),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(GoalDetailsController controller) {
    Get.defaultDialog(
      title: AppStrings.goals.deleteGoalTitle,
      titleStyle: headline3_text.copyWith(color: neopopError),
      middleText: AppStrings.goals.deleteGoalBody,
      middleTextStyle: body2_text.copyWith(color: groupOnSurfaceMuted),
      backgroundColor: Theme.of(Get.context!).colorScheme.surface,
      confirm: TextButton(
        onPressed: () => controller.deleteGoal(),
        child: Text(AppStrings.actions.delete.toUpperCase(),
            style: const TextStyle(color: neopopError)),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: Text(AppStrings.actions.cancel,
            style: const TextStyle(color: groupOnSurface)),
      ),
    );
  }
}
