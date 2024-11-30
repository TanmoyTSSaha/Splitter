import 'package:get/get.dart';

class AddTransactionScreenController extends GetxController {
  RxBool isTheStateNeedToBeRefreshed = false.obs;

  void updateStateRefresh() {
    isTheStateNeedToBeRefreshed.value = !isTheStateNeedToBeRefreshed.value;
    update();
  }
}
