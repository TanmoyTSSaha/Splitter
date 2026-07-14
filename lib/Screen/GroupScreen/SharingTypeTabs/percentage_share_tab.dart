import 'package:flutter/material.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:splitr/Utils/currency_utils.dart';
import 'package:get/get.dart';

import '../../../Constants/constants.dart';
import '../../../Constants/shared.dart';
import '../../../Controller/add_transaction_controller.dart';
import '../../../Model/group_model.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Widgets/user_avatar.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/business_rules.dart';

class PercentageShareTab extends StatelessWidget {
  final List<GroupMembersWithNameModel> groupMembersWithNameModel;
  final double totalAmount;
  final AddTransactionScreenController _addTransactionScreenController =
      Get.put(AddTransactionScreenController());
  PercentageShareTab({
    super.key,
    required this.groupMembersWithNameModel,
    required this.totalAmount,
  }) {
    _addTransactionScreenController
        .initializePercentageList(groupMembersWithNameModel.length);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final totalPercentage =
            _addTransactionScreenController.totalPercentage.value;
        final remaining = GroupBusinessRules.percentageTotal - totalPercentage;
        final allocatedAmount =
            (totalAmount * totalPercentage / GroupBusinessRules.percentageTotal)
                .toStringAsFixed(DefaultDecimalPlaces.amount);
        final totalAmountText =
            totalAmount.toStringAsFixed(DefaultDecimalPlaces.amount);

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              SharingMode.byPercentage.tabTitle,
              style: sub_headline4_text.copyWith(color: groupOnSurface),
            ),
            const SizedBox(height: groupGapSm),
            Text(
              SharingMode.byPercentage.tabSubtitle,
              style: body1_text.copyWith(color: groupOnSurface),
            ),
            const SizedBox(height: groupGapXl),
            SizedBox(
              width: devSysWidth - (groupGutter * 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppStringFormat.percentageOfTotal(
                      totalPercentage
                          .toStringAsFixed(DefaultDecimalPlaces.percentage),
                      GroupBusinessRules.percentageTotal.toInt(),
                    ),
                    style: sub_headline5_text.copyWith(
                        color: totalPercentage ==
                                GroupBusinessRules.percentageTotal
                            ? neopopAccent
                            : groupOnSurface),
                  ),
                  Text(
                    AppStringFormat.percentageLeft(
                      remaining
                          .toStringAsFixed(DefaultDecimalPlaces.percentage),
                    ),
                    style: body1_text.copyWith(
                        color: remaining < 0 ? neopopError : groupOnSurface),
                  ),
                  const SizedBox(height: groupGapSm),
                  Text(
                    AppStringFormat.amountOfTotal(
                      userCurrencySymbol(),
                      allocatedAmount,
                      totalAmountText,
                    ),
                    style: body2_text.copyWith(color: neopopGrey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: groupGapXl),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: groupMembersWithNameModel.length,
                itemBuilder: (context, index) {
                  final percentageController = _addTransactionScreenController
                      .percentageTextControllers[index];
                  double memberPercentage = double.tryParse(
                          _addTransactionScreenController
                                  .percentageSplitDetails[index]
                              [SharingTypeValues.percentage]) ??
                      0.0;
                  double memberAmount = totalAmount *
                      memberPercentage /
                      GroupBusinessRules.percentageTotal;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            UserAvatar(
                              userID:
                                  groupMembersWithNameModel[index].userID ?? "",
                              userName:
                                  groupMembersWithNameModel[index].userName ??
                                      DisplayFallbacks.user,
                              imageUrl:
                                  groupMembersWithNameModel[index].userPic,
                              radius: AppDimensions.groupIconMd,
                            ),
                            const SizedBox(width: groupGap10),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    groupMembersWithNameModel[index].userName!,
                                    style: sub_headline5_text.copyWith(
                                        color: groupOnSurface),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "${userCurrencySymbol()}${memberAmount.toStringAsFixed(DefaultDecimalPlaces.amount)}",
                                    style: caption_text.copyWith(
                                        color: neopopGrey,
                                        fontStyle: FontStyle.normal),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: groupShareInputWidth,
                        child: ExtraSmallTextFormField(
                          extraSmallTextFieldTextEditingController:
                              percentageController,
                          validator: (value) {
                            if (value != null && value.isNumericOnly) {
                              return null;
                            } else if (value == null) {
                              SplitrToast.show(AppStrings.validation.needPercentage);
                              return AppStrings.validation.needPercentage;
                            } else if (!value.isNumericOnly) {
                              SplitrToast.show(AppStrings.validation.numbersOnly);
                              return AppStrings.validation.numbersOnly;
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _addTransactionScreenController
                                .updatePercentageValue(index, value,
                                    groupMembersWithNameModel[index].userID!);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: groupGap5),
                        child: Text(
                          AppDisplaySymbols.percent,
                          style: body1_text.copyWith(color: groupOnSurface),
                        ),
                      ),
                    ],
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: groupGap10);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
