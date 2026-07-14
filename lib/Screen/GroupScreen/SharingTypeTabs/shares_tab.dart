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

class SharesTab extends StatelessWidget {
  final List<GroupMembersWithNameModel> groupMembersWithNameModel;
  final double totalAmount;
  final AddTransactionScreenController _addTransactionScreenController =
      Get.put(AddTransactionScreenController());
  SharesTab({
    super.key,
    required this.groupMembersWithNameModel,
    required this.totalAmount,
  }) {
    _addTransactionScreenController
        .initializeSharesList(groupMembersWithNameModel.length);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        int currentTotalShares =
            _addTransactionScreenController.totalShares.value;
        double perShareAmount =
            currentTotalShares > 0 ? totalAmount / currentTotalShares : 0.0;
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              SharingMode.byShares.tabTitle,
              style: sub_headline4_text.copyWith(color: groupOnSurface),
            ),
            const SizedBox(height: groupGapSm),
            Text(
              SharingMode.byShares.tabSubtitle,
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
                    AppStringFormat.perShareRate(
                      userCurrencySymbol(),
                      perShareAmount
                          .toStringAsFixed(DefaultDecimalPlaces.amount),
                    ),
                    style: sub_headline5_text.copyWith(
                        color: currentTotalShares > 0
                            ? neopopAccent
                            : groupOnSurface),
                  ),
                  Text(
                    AppStringFormat.sharesTotalCount(currentTotalShares),
                    style: body1_text.copyWith(color: groupOnSurface),
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
                  final sharesController = _addTransactionScreenController
                      .sharesTextControllers[index];
                  int memberShares = int.tryParse(
                          _addTransactionScreenController
                                  .sharesSplitDetails[index]
                              [SharingTypeValues.shares]) ??
                      0;
                  double memberAmount = perShareAmount * memberShares;
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
                              sharesController,
                          validator: (value) {
                            if (value != null && value.isNumericOnly) {
                              return null;
                            } else if (value == null) {
                              SplitrToast.show(AppStrings.validation.needShares);
                              return AppStrings.validation.needShares;
                            } else if (!value.isNumericOnly) {
                              SplitrToast.show(AppStrings.validation.wholeNumbersOnly);
                              return AppStrings.validation.wholeNumbersOnly;
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _addTransactionScreenController.updateSharesValue(
                                index,
                                value,
                                groupMembersWithNameModel[index].userID!);
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: groupGap5),
                        child: Icon(
                          Icons.pie_chart_outline_rounded,
                          color: neopopGrey,
                          size: groupIconMd,
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
