import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../../Constants/constants.dart';
import '../../../Constants/shared.dart';
import '../../../Controller/add_transaction_controller.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';

import '../../../Model/group_model.dart';
import 'package:splitter/Widgets/user_avatar.dart';

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
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Split Unevenly",
              style: sub_headline4_text.copyWith(color: groupOnSurface),
            ),
            SizedBox(height: height_16 / 2),
            Text(
              "Split exactly how much each person owes",
              style: body1_text.copyWith(color: groupOnSurface),
            ),
            SizedBox(height: height_16 * 2),
            Container(
              width: devSysWidth - (height_16 * 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "₹${_addTransactionScreenController.totalAddedAmount.value} of ₹$totalAmount",
                    style: sub_headline5_text.copyWith(
                        color: _addTransactionScreenController
                                    .totalAddedAmount.value ==
                                totalAmount
                            ? neopopAccent
                            : groupOnSurface),
                  ),
                  Text(
                    "₹${totalAmount - _addTransactionScreenController.totalAddedAmount.value} left",
                    style: body1_text.copyWith(
                        color: totalAmount -
                                    _addTransactionScreenController
                                        .totalAddedAmount.value <
                                0
                            ? neopopError
                            : groupOnSurface),
                  ),
                ],
              ),
            ),
            SizedBox(height: height_16 * 2),
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
                              "User",
                          imageUrl: groupMembersWithNameModel[index].userPic,
                          radius: height_16 * 1.25,
                        ),
                        SizedBox(width: width_10),
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
                          Fluttertoast.showToast(
                            msg: "Need amount here!",
                            textColor: neopopBackground,
                            backgroundColor: neopopYellow,
                          );
                          return "Need amount here!";
                        } else if (!value.isNumericOnly) {
                          Fluttertoast.showToast(
                            msg: "Only numbers are allowed here!",
                            textColor: neopopBackground,
                            backgroundColor: neopopYellow,
                          );
                          return "Only numbers are allowed here!";
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
                return SizedBox(height: height_10);
              },
            ),
          ],
        );
      },
    );
  }
}
