import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/shared.dart';

import '../../../Constants/constants.dart';
import '../../../Controller/add_transaction_controller.dart';
import '../../../Model/group_model.dart';

class UnevenShareTab extends StatelessWidget {
  final List<GroupMembersWithNameModel> groupMembersWithNameModel;
  final double totalAmount;
  const UnevenShareTab({
    super.key,
    required this.groupMembersWithNameModel,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final AddTransactionScreenController _addTransactionScreenController =
        Get.put(AddTransactionScreenController());
    return Obx(
      () {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Split Unevenly",
              style: sub_headline4_text.copyWith(color: neopopOnBackground),
            ),
            SizedBox(height: height_16 / 2),
            Text(
              "Split exactly how much each person owes",
              style: body1_text.copyWith(color: neopopOnBackground),
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
                    style:
                        sub_headline5_text.copyWith(color: neopopOnBackground),
                  ),
                  Text(
                    "₹${totalAmount - _addTransactionScreenController.totalAddedAmount.value} left",
                    style: body1_text.copyWith(color: neopopOnBackground),
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
                TextEditingController
                    _extraSmallTextFieldTextEditingController =
                    TextEditingController();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: height_16 * 2.5,
                          width: height_16 * 2.5,
                          decoration: BoxDecoration(
                            color: neopopAccent,
                            borderRadius:
                                BorderRadius.circular(height_16 * 2.5),
                          ),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(height_16 * 2.5),
                            child: Image.network(
                              groupMembersWithNameModel[index]
                                      .userPic
                                      .toString()
                                      .trim()
                                      .isNotEmpty
                                  ? groupMembersWithNameModel[index].userPic!
                                  : "https://odlzzaroffbgbmiwvcqr.supabase.co/storage/v1/object/sign/splitter_bucket/user_profile_pictures/default_profile_picture_avatar.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJzcGxpdHRlcl9idWNrZXQvdXNlcl9wcm9maWxlX3BpY3R1cmVzL2RlZmF1bHRfcHJvZmlsZV9waWN0dXJlX2F2YXRhci5wbmciLCJpYXQiOjE3MzI5NTk1NDQsImV4cCI6MTc2NDQ5NTU0NH0.W1G8X4v_3kcqo2IMUCphY3EnOvxD077foLBfoaIOaPc&t=2024-11-30T09%3A39%3A04.548Z",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: width_10),
                        Text(
                          groupMembersWithNameModel[index].userName!,
                          style: sub_headline5_text.copyWith(
                              color: neopopOnBackground),
                        ),
                      ],
                    ),
                    ExtraSmallTextFormField(
                      extraSmallTextFieldTextEditingController:
                          _extraSmallTextFieldTextEditingController,
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
                        if (isNumeric(value)) {
                          _addTransactionScreenController
                              .addMembersToTheUnEvenSplitList(
                                  groupMembersWithNameModel[index].userID!,
                                  double.parse(value));
                        }
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

class ExtraSmallTextFormField extends StatelessWidget {
  final TextEditingController extraSmallTextFieldTextEditingController;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final void Function(String)? onChanged;
  const ExtraSmallTextFormField({
    super.key,
    required this.extraSmallTextFieldTextEditingController,
    required this.keyboardType,
    required this.validator,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height_10 * 5,
      width: height_16 * 5,
      child: TextFormField(
        obscureText: false,
        onChanged: onChanged,
        controller: extraSmallTextFieldTextEditingController,
        validator: validator,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(height_16 / 4),
            borderSide: const BorderSide(
              color: neopopGrey,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(height_16 / 4),
            borderSide: const BorderSide(
              color: neopopGrey,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(height_16 / 4),
            borderSide: const BorderSide(
              color: neopopGrey,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(height_16 / 4),
            borderSide: const BorderSide(
              color: neopopError,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(height_16 / 4),
            borderSide: const BorderSide(
              color: neopopError,
              width: 2,
            ),
          ),
          errorStyle: const TextStyle(
            fontSize: 0,
          ),
          hintText: "₹0.00",
          hintStyle: sub_headline5_text.copyWith(
            color: neopopGrey,
          ),
        ),
      ),
    );
  }
}
