import 'package:get/get.dart';

class GroupScreenController extends GetxController {
  var tabIndex = 0.obs;

  void updateTabIndex(int index) {
    tabIndex.value = index;
  }
}
