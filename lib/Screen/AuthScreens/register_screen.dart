import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:neopop/neopop.dart';
import 'package:splitter/Screen/AuthScreens/login_screen.dart';

import '../../Constants/constants.dart';
import '../../Constants/shared.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController confirmPasswordTextEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus!.unfocus();
        },
        child: Scaffold(
          backgroundColor: neopopBackground,
          body: Container(
            height: Get.height,
            width: Get.width,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Register",
                  style: headline2_text.copyWith(
                    color: neopopOnBackground,
                  ),
                ),
                SizedBox(height: Get.height * 0.015),
                Text(
                  "Please provide us with the below information",
                  textAlign: TextAlign.center,
                  style: body2_text.copyWith(
                    color: neopopGrey,
                  ),
                ),
                SizedBox(height: Get.height * 0.05),
                PrimaryTextFormField(
                  textEditingController: nameTextEditingController,
                  fieldName: "Name",
                  isObscure: false,
                  validator: null,
                ),
                SizedBox(height: Get.height * 0.025),
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
                PrimaryTextFormField(
                  textEditingController: confirmPasswordTextEditingController,
                  fieldName: "Confirm Password",
                  isObscure: true,
                  validator: null,
                ),
                SizedBox(height: Get.height * 0.05),
                NeoPopButton(
                  color: neopopOnBackground,
                  enabled: true,
                  onTapUp: () {
                    debugPrint("Vibrate");
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
                          "Register",
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
                      "or sign up with",
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
                  // onTapDown: () {
                  //   HapticFeedback.vibrate();
                  //   print("Vibrate");
                  // },
                  onTapUp: () {
                    debugPrint("Sign up with Google");
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
                          "Sign Up with Google",
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
                    text: "Already have an account?",
                    style: caption_text.copyWith(
                      color: neopopGrey,
                    ),
                    children: [
                      TextSpan(
                        text: " Login now!",
                        style: caption_text.copyWith(
                          color: neopopOnBackground,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.to(() => LoginScreen());
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
