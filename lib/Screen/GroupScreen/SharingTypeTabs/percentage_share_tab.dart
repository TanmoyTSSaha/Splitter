import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../../Constants/constants.dart';
import '../../../Constants/shared.dart';
import '../../../Controller/add_transaction_controller.dart';
import '../../../Model/group_model.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitter/Widgets/user_avatar.dart';

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
        double remaining =
            100.0 - _addTransactionScreenController.totalPercentage.value;
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Split by Percentage",
              style: sub_headline4_text.copyWith(color: groupOnSurface),
            ),
            SizedBox(height: height_16 / 2),
            Text(
              "Specify the percentage each person owes",
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
                    "${_addTransactionScreenController.totalPercentage.value.toStringAsFixed(1)}% of 100%",
                    style: sub_headline5_text.copyWith(
                        color: _addTransactionScreenController
                                    .totalPercentage.value ==
                                100.0
                            ? neopopAccent
                            : groupOnSurface),
                  ),
                  Text(
                    "${remaining.toStringAsFixed(1)}% left",
                    style: body1_text.copyWith(
                        color:
                            remaining < 0 ? neopopError : groupOnSurface),
                  ),
                  SizedBox(height: height_16 / 2),
                  Text(
                    "₹${(totalAmount * _addTransactionScreenController.totalPercentage.value / 100).toStringAsFixed(2)} of ₹${totalAmount.toStringAsFixed(2)}",
                    style: body2_text.copyWith(color: neopopGrey),
                  ),
                ],
              ),
            ),
            SizedBox(height: height_16 * 2),
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
                              .percentageSplitDetails[index]["percentage"]) ??
                      0.0;
                  double memberAmount = totalAmount * memberPercentage / 100;
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
                                      "User",
                              imageUrl:
                                  groupMembersWithNameModel[index].userPic,
                              radius: height_16 * 1.25,
                            ),
                            SizedBox(width: width_10),
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
                                    "₹${memberAmount.toStringAsFixed(2)}",
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
                        width: width_10 * 8,
                        child: ExtraSmallTextFormField(
                          extraSmallTextFieldTextEditingController:
                              percentageController,
                          validator: (value) {
                            if (value != null && value.isNumericOnly) {
                              return null;
                            } else if (value == null) {
                              Fluttertoast.showToast(
                                msg: "Need percentage here!",
                                textColor: neopopBackground,
                                backgroundColor: neopopYellow,
                              );
                              return "Need percentage here!";
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
                            _addTransactionScreenController
                                .updatePercentageValue(index, value,
                                    groupMembersWithNameModel[index].userID!);
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: width_10 / 2),
                        child: Text(
                          "%",
                          style: body1_text.copyWith(color: groupOnSurface),
                        ),
                      ),
                    ],
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: height_10);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
