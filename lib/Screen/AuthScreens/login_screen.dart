import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:neopop/neopop.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/shared.dart';
import 'package:splitter/Controller/auth_controller.dart';
import 'package:splitter/Screen/AuthScreens/register_screen.dart';
import 'package:splitter/Controllers/premium_subscription_controller.dart';
import 'package:splitter/Screen/BottomNavigationController/bottom_navigation_controller.dart';
import 'package:splitter/Services/deep_link_service.dart';
import 'package:splitter/Services/supabase_service.dart';
import 'package:splitter/Widgets/dark_surface_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  final AuthController _authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return DarkSurfaceTheme(
      child: GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus!.unfocus();
      },
      child: Scaffold(
        backgroundColor: neopopBackground,
        body: Obx(
          () {
            return Stack(
              alignment: Alignment.center,
              children: [
                SingleChildScrollView(
                  child: Container(
                    width: Get.width,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: MediaQuery.of(context).size.height * 0.08,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Login",
                          style: headline2_text.copyWith(
                            color: neopopOnBackground,
                          ),
                        ),
                        SizedBox(height: Get.height * 0.015),
                        Text(
                          "Hello welcome back!\nYou have been missed.",
                          textAlign: TextAlign.center,
                          style: body2_text.copyWith(
                            color: neopopGrey,
                          ),
                        ),
                        SizedBox(height: Get.height * 0.05),
                        PrimaryTextFormField(
                          textEditingController: emailTextEditingController,
                          fieldName: "Email ID",
                          isObscure: false,
                          validator: null,
                        ),
                        SizedBox(height: Get.height * 0.025),
                        PrimaryTextFormField(
                          textEditingController: passwordTextEditingController,
                          fieldName: "Password",
                          isObscure: true,
                          validator: null,
                        ),
                        SizedBox(height: Get.height * 0.025),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              debugPrint("Forgot Password!");
                            },
                            child: Text(
                              "Forgot Password?",
                              style: button_text.copyWith(
                                color: neopopGrey,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: Get.height * 0.05),
                        NeoPopButton(
                          color: neopopOnBackground,
                          enabled: true,
                          onTapUp: () async {
                            _authController.turnAuthScreenLoadingOn();
                            try {
                              debugPrint("Vibrate");
                              bool isLoggedIn = await SupabaseAuth()
                                  .supabaseEmailPassSignIn(
                                      userEmail:
                                          emailTextEditingController.text,
                                      userPassword:
                                          passwordTextEditingController.text);

                              if (isLoggedIn) {
                                _authController.turnAuthScreenLoadingOff();
                                await Get.find<PremiumSubscriptionController>()
                                    .refreshStatus();
                                await Get.find<DeepLinkService>()
                                    .processPendingInvite();
                                Fluttertoast.showToast(
                                  msg: "Yay! Logged in successfully.",
                                  textColor: neopopBackground,
                                  backgroundColor: neopopYellow,
                                );
                                Get.to(
                                    () => const BottomNavigationController());
                              } else {
                                _authController.turnAuthScreenLoadingOff();
                              }
                            } catch (e) {
                              debugPrint(e.toString());
                              _authController.turnAuthScreenLoadingOff();
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: Get.height * 0.0175,
                                horizontal: Get.height * 0.1),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Login",
                                  style: button_text.copyWith(
                                    color: neopopBackground,
                                  ),
                                ),
                                SizedBox(
                                  width: Get.width * 0.025,
                                ),
                                SvgPicture.asset(
                                  height: 24,
                                  width: 24,
                                  "assets/icons/svg/solar--arrow-right-outline.svg",
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: Get.height * 0.025),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              color: neopopSecondaryGrey,
                              height: 2.5,
                              width: Get.width * 0.3,
                            ),
                            Text(
                              "or sign in with",
                              style: caption_text.copyWith(
                                color: neopopGrey,
                              ),
                            ),
                            Container(
                              color: neopopSecondaryGrey,
                              height: 2.5,
                              width: Get.width * 0.3,
                            ),
                          ],
                        ),
                        SizedBox(height: Get.height * 0.025),
                        NeoPopButton(
                          color: neopopOnBackground,
                          enabled: true,
                          onTapUp: () async {
                            HapticFeedback.vibrate();
                            debugPrint("Vibrate");
                            bool isSuccess =
                                await SupabaseAuth().googleSignIn();
                            if (isSuccess) {
                              // Handled by deep link or listener
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: Get.height * 0.0175,
                                horizontal: Get.height * 0.1),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  height: 24,
                                  width: 24,
                                  "assets/icons/svg/devicon--google.svg",
                                ),
                                SizedBox(
                                  width: Get.width * 0.025,
                                ),
                                Text(
                                  "Sign In with Google",
                                  style: button_text.copyWith(
                                    color: neopopBackground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: Get.height * 0.05),
                        RichText(
                          text: TextSpan(
                            text: "Don't have an account?",
                            style: caption_text.copyWith(
                              color: neopopGrey,
                            ),
                            children: [
                              TextSpan(
                                text: " Register now!",
                                style: caption_text.copyWith(
                                  color: neopopOnBackground,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Get.to(
                                      () => const RegisterScreen(),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_authController.isAuthScreenLoading.value)
                  Container(
                    height: devSysHeight,
                    width: devSysWidth,
                    color: neopopOnPrimary.withOpacity(0.15),
                    child: const LoadingWidget(),
                  ),
              ],
            );
          },
        ),
      ),
    ),
    );
  }
}
