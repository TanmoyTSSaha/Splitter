import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Controller/add_transaction_controller.dart';

import '../../../Model/group_model.dart';

class EvenShareTab extends StatefulWidget {
  final double totalAmount;
  final List<GroupMembersWithNameModel> groupMembersWithNameModel;
  const EvenShareTab({
    super.key,
    required this.groupMembersWithNameModel,
    required this.totalAmount,
  });

  @override
  State<EvenShareTab> createState() => _EvenShareTabState();
}

class _EvenShareTabState extends State<EvenShareTab> {
  // List<bool> checkBoxBool = [];
  bool allCheckBoxState = true;
  final AddTransactionScreenController _addTransactionScreenController =
      Get.put(AddTransactionScreenController());

  @override
  void initState() {
    super.initState();

    _addTransactionScreenController
        .addAllCheckBoxValue(widget.groupMembersWithNameModel.length);

    if (_addTransactionScreenController.involvedPersons.value == 0) {
      _addTransactionScreenController.involvedPersons.value =
          widget.groupMembersWithNameModel.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    for (var i = 0;
        i < _addTransactionScreenController.checkBoxBool.length;
        i++) {}
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Obx(
        () {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Split evenly",
                style: sub_headline4_text.copyWith(color: neopopOnBackground),
              ),
              SizedBox(height: height_16 / 2),
              Text(
                "Select who owns the even share in the split",
                style: body1_text.copyWith(color: neopopOnBackground),
              ),
              SizedBox(height: height_16 * 2),
              Container(
                width: devSysWidth - (height_16 * 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: (devSysWidth * 0.7) - height_16,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "₹${(widget.totalAmount / _addTransactionScreenController.involvedPersons.value).toStringAsFixed(2)} / Person",
                            style: sub_headline5_text.copyWith(
                                color: neopopOnBackground),
                          ),
                          Text(
                            "(${_addTransactionScreenController.involvedPersons.value} ${_addTransactionScreenController.involvedPersons.value > 1 ? 'Peoples' : 'People'})",
                            style:
                                body1_text.copyWith(color: neopopOnBackground),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: (devSysWidth * 0.3) - height_16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "All",
                            style:
                                body1_text.copyWith(color: neopopOnBackground),
                          ),
                          Checkbox(
                            activeColor: neopopAccent,
                            value: _addTransactionScreenController
                                .allCheckBoxSelector.value,
                            onChanged: (value) {
                              _addTransactionScreenController
                                  .changeAllCheckBoxSelectorState();
                              _addTransactionScreenController
                                  .selectOrDeselectAllCheckBoxAtOnce();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height_16 * 2),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.groupMembersWithNameModel.length,
                itemBuilder: (context, index) {
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
                                widget.groupMembersWithNameModel[index].userPic
                                        .toString()
                                        .trim()
                                        .isNotEmpty
                                    ? widget.groupMembersWithNameModel[index]
                                        .userPic!
                                    : "https://odlzzaroffbgbmiwvcqr.supabase.co/storage/v1/object/sign/splitter_bucket/user_profile_pictures/default_profile_picture_avatar.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJzcGxpdHRlcl9idWNrZXQvdXNlcl9wcm9maWxlX3BpY3R1cmVzL2RlZmF1bHRfcHJvZmlsZV9waWN0dXJlX2F2YXRhci5wbmciLCJpYXQiOjE3MzI5NTk1NDQsImV4cCI6MTc2NDQ5NTU0NH0.W1G8X4v_3kcqo2IMUCphY3EnOvxD077foLBfoaIOaPc&t=2024-11-30T09%3A39%3A04.548Z",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: width_10),
                          Text(
                            widget.groupMembersWithNameModel[index].userName!,
                            style: sub_headline5_text.copyWith(
                                color: neopopOnBackground),
                          ),
                        ],
                      ),
                      Checkbox(
                        activeColor: neopopAccent,
                        value: _addTransactionScreenController
                            .checkBoxBool[index].value,
                        onChanged: (value) {
                          _addTransactionScreenController
                              .selectOrDeselectOneCheckBox(index);

                          if (_addTransactionScreenController
                                      .checkBoxBool[index].value ==
                                  false &&
                              _addTransactionScreenController
                                      .involvedPersons.value >
                                  0) {
                            _addTransactionScreenController
                                .decreaseInvolvedPersons();
                          } else {
                            if (widget.groupMembersWithNameModel.length >
                                _addTransactionScreenController
                                    .involvedPersons.value) {
                              _addTransactionScreenController
                                  .increaseInvolvedPersons();
                            }
                          }

                          if (_addTransactionScreenController
                                      .involvedPersons.value ==
                                  0 &&
                              _addTransactionScreenController
                                      .allCheckBoxSelector.value ==
                                  true) {
                            _addTransactionScreenController
                                .changeAllCheckBoxSelectorState(isChanged: 2);
                          } else if (_addTransactionScreenController
                                      .involvedPersons.value >
                                  0 &&
                              _addTransactionScreenController
                                      .allCheckBoxSelector.value ==
                                  false) {
                            _addTransactionScreenController
                                .changeAllCheckBoxSelectorState(isChanged: 1);
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
      ),
    );
  }
}
