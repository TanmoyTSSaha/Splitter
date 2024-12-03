import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddTransactionScreenController extends GetxController {
  RxBool isTheStateNeedToBeRefreshed = false.obs;

  void updateStateRefresh() {
    isTheStateNeedToBeRefreshed.value = !isTheStateNeedToBeRefreshed.value;
    update();
  }

  // EVEN SHARES CONTROLLERS
  RxInt involvedPersons = 0.obs;

  void increaseInvolvedPersons() {
    involvedPersons.value = involvedPersons.value + 1;
  }

  void decreaseInvolvedPersons() {
    involvedPersons.value = involvedPersons.value - 1;
  }

  List<RxBool> checkBoxBool = [];

  void addAllCheckBoxValue(int length) {
    checkBoxBool.clear(); // Clear the list to avoid mismatches
    for (var i = 0; i < length; i++) {
      checkBoxBool.add(true.obs);
    }
  }

  void selectOrDeselectOneCheckBox(int index) {
    if (index < checkBoxBool.length) {
      checkBoxBool[index].value = !checkBoxBool[index].value;
    }
  }

  void selectOrDeselectAllCheckBox(int length) {
    if (checkBoxBool.length == length) {
      for (var i = 0; i < length; i++) {
        checkBoxBool[i].value = !checkBoxBool[i].value;
      }
    }
  }

  RxBool allCheckBoxSelector = true.obs;
  void changeAllCheckBoxSelectorState({int isChanged = 0}) {
    if (isChanged == 0) {
      allCheckBoxSelector.value = !allCheckBoxSelector.value;
    } else if (isChanged == 1) {
      allCheckBoxSelector.value = true;
    } else if (isChanged == 2) {
      allCheckBoxSelector.value = false;
    } else {
      allCheckBoxSelector.value = !allCheckBoxSelector.value;
    }
  }

  void selectOrDeselectAllCheckBoxAtOnce() {
    if (allCheckBoxSelector.value) {
      involvedPersons.value = checkBoxBool.length;
    } else {
      involvedPersons.value = 0;
    }

    for (var i = 0; i < checkBoxBool.length; i++) {
      checkBoxBool[i].value = allCheckBoxSelector.value;
    }
  }

  // UNEVEN SHARE CONTROLLER LOGICS
  RxList<RxMap<String, dynamic>> userAndSplitDetails =
      <RxMap<String, dynamic>>[].obs;

  RxDouble totalAddedAmount = 0.0.obs;

  final List<TextEditingController> textControllers = [];

  void initializeList(int count) {
    if (userAndSplitDetails.isEmpty) {
      // Initialize user and split details only once
      userAndSplitDetails.value = List.generate(count, (_) {
        RxMap<String, dynamic> details = <String, dynamic>{}.obs;
        details["user_id"] = "";
        details["amount"] = "0.0";
        return details;
      });

      // Initialize TextEditingControllers only once
      for (int i = 0; i < count; i++) {
        textControllers.add(
          TextEditingController(
            text: userAndSplitDetails[i]["amount"], // Default to "0.0"
          ),
        );
      }
    }
  }

  void updateValue(int index, String value, String userID) {
    if (index < userAndSplitDetails.length) {
      // Parse the previous and new values
      double oldValue =
          double.tryParse(userAndSplitDetails[index]["amount"]) ?? 0.0;
      double newValue = double.tryParse(value) ?? 0.0;

      // Update the total added amount
      totalAddedAmount.value += (newValue - oldValue);

      // Update the specific user's details
      userAndSplitDetails[index]["amount"] = value;
      userAndSplitDetails[index]["user_id"] = userID;
    }
  }
}
