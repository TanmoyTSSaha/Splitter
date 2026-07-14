import 'package:flutter/material.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:splitr/Utils/currency_utils.dart';
import 'package:get/get.dart';

import '../../../Constants/constants.dart';
import '../../../Constants/shared.dart';
import '../../../Controller/add_transaction_controller.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

import '../../../Model/group_model.dart';
import 'package:splitr/Widgets/user_avatar.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/app_dimensions.dart';

class UnevenShareTab extends StatelessWidget {
  final List<GroupMembersWithNameModel> groupMembersWithNameModel;
  final double totalAmount;
  final AddTransactionScreenController _addTransactionScreenController =
      Get.put(AddTransactionScreenController());
  UnevenShareTab({
    super.key,
    required this.groupMembersWithNameModel,
    required this.totalAmount,
  }) {
    _addTransactionScreenController
        .initializeList(groupMembersWithNameModel.length);
    // _addTransactionScreenController
    //     .initializeControllers(groupMembersWithNameModel.length);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final addedAmount =
            _addTransactionScreenController.totalAddedAmount.value;
        final remaining = totalAmount - addedAmount;

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              SharingMode.byUnevenly.tabTitle,
              style: sub_headline4_text.copyWith(color: groupOnSurface),
            ),
            const SizedBox(height: groupGapSm),
            Text(
              SharingMode.byUnevenly.tabSubtitle,
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
                    AppStringFormat.amountOfTotal(
                      userCurrencySymbol(),
                      addedAmount.toString(),
                      totalAmount.toString(),
                    ),
                    style: sub_headline5_text.copyWith(
                        color: addedAmount == totalAmount
                            ? neopopAccent
                            : groupOnSurface),
                  ),
                  Text(
                    AppStringFormat.amountLeft(
                      userCurrencySymbol(),
                      remaining.toString(),
                    ),
                    style: body1_text.copyWith(
                        color: remaining < 0 ? neopopError : groupOnSurface),
                  ),
                ],
              ),
            ),
            const SizedBox(height: groupGapXl),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: groupMembersWithNameModel.length,
              itemBuilder: (context, index) {
                final extraSmallTextFieldTextEditingController =
                    _addTransactionScreenController.textControllers[index];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        UserAvatar(
                          userID: groupMembersWithNameModel[index].userID ?? "",
                          userName: groupMembersWithNameModel[index].userName ??
                              DisplayFallbacks.user,
                          imageUrl: groupMembersWithNameModel[index].userPic,
                          radius: AppDimensions.groupIconMd,
                        ),
                        const SizedBox(width: groupGap10),
                        Text(
                          groupMembersWithNameModel[index].userName!,
                          style: sub_headline5_text.copyWith(
                              color: groupOnSurface),
                        ),
                      ],
                    ),
                    ExtraSmallTextFormField(
                      extraSmallTextFieldTextEditingController:
                          extraSmallTextFieldTextEditingController,
                      validator: (value) {
                        if (value != null && value.isNumericOnly) {
                          return null;
                        } else if (value == null) {
                          SplitrToast.show(AppStrings.validation.needAmount);
                          return AppStrings.validation.needAmount;
                        } else if (!value.isNumericOnly) {
                          SplitrToast.show(AppStrings.validation.numbersOnly);
                          return AppStrings.validation.numbersOnly;
                        }

                        return null;
                      },
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _addTransactionScreenController.updateValue(index,
                            value, groupMembersWithNameModel[index].userID!);
                      },
                    ),
                  ],
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: groupGap10);
              },
            ),
          ],
        );
      },
    );
  }
}
