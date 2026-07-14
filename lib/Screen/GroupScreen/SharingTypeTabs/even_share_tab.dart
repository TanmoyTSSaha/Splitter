import 'package:flutter/material.dart';
import 'package:splitr/Utils/currency_utils.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Controller/add_transaction_controller.dart';

import 'package:splitr/Widgets/user_avatar.dart';

import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

import '../../../Model/group_model.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_dimensions.dart';

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

    final memberCount = widget.groupMembersWithNameModel.length;
    if (_addTransactionScreenController.checkBoxBool.length != memberCount) {
      _addTransactionScreenController.addAllCheckBoxValue(memberCount);
      _addTransactionScreenController.involvedPersons.value = memberCount;
    } else if (_addTransactionScreenController.involvedPersons.value == 0) {
      _addTransactionScreenController.involvedPersons.value = memberCount;
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
          final perPersonAmount = (widget.totalAmount /
                  _addTransactionScreenController.involvedPersons.value)
              .toStringAsFixed(DefaultDecimalPlaces.amount);
          final involvedCount =
              _addTransactionScreenController.involvedPersons.value;

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                SharingMode.byEvenly.tabTitle,
                style: sub_headline4_text.copyWith(color: groupOnSurface),
              ),
              const SizedBox(height: groupGapSm),
              Text(
                SharingMode.byEvenly.tabSubtitle,
                style: body1_text.copyWith(color: groupOnSurface),
              ),
              const SizedBox(height: groupGapXl),
              SizedBox(
                width: devSysWidth - (groupGutter * 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: (devSysWidth * groupShareSummaryWidthFactor) -
                          groupGutter,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            AppStringFormat.perPersonRate(
                              userCurrencySymbol(),
                              perPersonAmount,
                            ),
                            style: sub_headline5_text.copyWith(
                                color: groupOnSurface),
                          ),
                          Text(
                            AppStringFormat.evenSharePeopleLabel(involvedCount),
                            style: body1_text.copyWith(color: groupOnSurface),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: (devSysWidth * groupShareControlsWidthFactor) -
                          groupGutter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.trips.all,
                            style: body1_text.copyWith(color: groupOnSurface),
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
              const SizedBox(height: groupGapXl),
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
                          UserAvatar(
                            userID: widget
                                    .groupMembersWithNameModel[index].userID ??
                                "",
                            userName: widget.groupMembersWithNameModel[index]
                                    .userName ??
                                DisplayFallbacks.user,
                            imageUrl:
                                widget.groupMembersWithNameModel[index].userPic,
                            radius: AppDimensions.groupIconMd,
                          ),
                          const SizedBox(width: groupGap10),
                          Text(
                            widget.groupMembersWithNameModel[index].userName!,
                            style: sub_headline5_text.copyWith(
                                color: groupOnSurface),
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
                  return const SizedBox(height: groupGap10);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
