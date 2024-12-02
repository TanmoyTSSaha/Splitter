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
  List<Map<String, dynamic>> userAndSplitDetails = [];
  RxDouble totalAddedAmount = 0.0.obs;

  void addMembersToTheUnEvenSplitList(String userID, double amount) {
    userAndSplitDetails.add({"user_id": userID, "amount": amount});
    totalAddedAmount.value = totalAddedAmount.value + amount;
    update();
  }

  void removeMembersToTheUnEvenSplitList(String userID) {
    List<Map<String, dynamic>> tempList = [];
    for (Map<String, dynamic> dtls in userAndSplitDetails) {
      if (dtls["user_id"] == userID) {
        totalAddedAmount.value = totalAddedAmount.value - dtls["amount"];
      } else {
        tempList.add(dtls);
      }
    }

    userAndSplitDetails = tempList;
    update();
  }
}
