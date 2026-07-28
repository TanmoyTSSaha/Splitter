import 'package:get/get.dart';

/// Triggers a refresh of [LendingDashboard] when the lending tab is re-selected
/// or when loan state changes elsewhere (e.g. notifications).
class LendingRefreshController extends GetxController {
  final refreshTrigger = 0.obs;

  void triggerRefresh() {
    refreshTrigger.value++;
  }

  static void refreshFromAnywhere() {
    if (Get.isRegistered<LendingRefreshController>()) {
      Get.find<LendingRefreshController>().triggerRefresh();
    }
  }
}
