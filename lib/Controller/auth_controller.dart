import 'package:get/get.dart';

class AuthController extends GetxController {
  RxBool isAuthScreenLoading = false.obs;

  RxBool isAuthenticationSucceded = false.obs;

  void turnAuthScreenLoadingOff() {
    isAuthScreenLoading.value = false;
    update();
  }

  void turnAuthScreenLoadingOn() {
    isAuthScreenLoading.value = true;
    update();
  }

  void turnAuthSuccessOff() {
    isAuthenticationSucceded.value = false;
    update();
  }

  void turnAuthSuccessOn() {
    isAuthenticationSucceded.value = true;
    update();
  }
}
