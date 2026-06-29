import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../../Constants/constants.dart';
import '../../../Constants/shared.dart';
import '../../../Controller/add_transaction_controller.dart';
import '../../../Model/group_model.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitter/Widgets/user_avatar.dart';

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
              "Split by Shares",
              style: sub_headline4_text.copyWith(color: groupOnSurface),
            ),
            SizedBox(height: height_16 / 2),
            Text(
              "Assign shares to each person",
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
                    "₹${perShareAmount.toStringAsFixed(2)} / share",
                    style: sub_headline5_text.copyWith(
                        color: currentTotalShares > 0
                            ? neopopAccent
                            : groupOnSurface),
                  ),
                  Text(
                    "(${currentTotalShares} ${currentTotalShares == 1 ? 'share' : 'shares'} total)",
                    style: body1_text.copyWith(color: groupOnSurface),
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
                  final sharesController = _addTransactionScreenController
                      .sharesTextControllers[index];
                  int memberShares = int.tryParse(
                          _addTransactionScreenController
                              .sharesSplitDetails[index]["shares"]) ??
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
                              sharesController,
                          validator: (value) {
                            if (value != null && value.isNumericOnly) {
                              return null;
                            } else if (value == null) {
                              Fluttertoast.showToast(
                                msg: "Need shares here!",
                                textColor: neopopBackground,
                                backgroundColor: neopopYellow,
                              );
                              return "Need shares here!";
                            } else if (!value.isNumericOnly) {
                              Fluttertoast.showToast(
                                msg: "Only whole numbers are allowed!",
                                textColor: neopopBackground,
                                backgroundColor: neopopYellow,
                              );
                              return "Only whole numbers are allowed!";
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
                      Padding(
                        padding: EdgeInsets.only(left: width_10 / 2),
                        child: Icon(
                          Icons.pie_chart_outline_rounded,
                          color: neopopGrey,
                          size: height_16,
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
