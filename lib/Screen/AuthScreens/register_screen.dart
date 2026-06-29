import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:neopop/neopop.dart';
import 'package:splitter/Screen/AuthScreens/login_screen.dart';

import '../../Constants/constants.dart';
import '../../Constants/shared.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:splitter/Services/supabase_service.dart';
import 'package:splitter/Widgets/dark_surface_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController firstNameTextEditingController =
      TextEditingController();
  TextEditingController lastNameTextEditingController = TextEditingController();
  TextEditingController nameTextEditingController =
      TextEditingController(); // This is Username
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController confirmPasswordTextEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DarkSurfaceTheme(
      child: GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus!.unfocus();
      },
      child: Scaffold(
        backgroundColor: neopopBackground,
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: Get.height,
            ),
            child: Container(
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
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryTextFormField(
                          textEditingController: firstNameTextEditingController,
                          fieldName: "First Name",
                          isObscure: false,
                          validator: null,
                        ),
                      ),
                      SizedBox(width: width_10),
                      Expanded(
                        child: PrimaryTextFormField(
                          textEditingController: lastNameTextEditingController,
                          fieldName: "Last Name",
                          isObscure: false,
                          validator: null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Get.height * 0.025),
                  PrimaryTextFormField(
                    textEditingController: nameTextEditingController,
                    fieldName: "Username",
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
                    onTapUp: () async {
                      HapticFeedback.vibrate();
                      if (firstNameTextEditingController.text.isEmpty ||
                          lastNameTextEditingController.text.isEmpty ||
                          nameTextEditingController.text.isEmpty ||
                          emailTextEditingController.text.isEmpty ||
                          passwordTextEditingController.text.isEmpty ||
                          confirmPasswordTextEditingController.text.isEmpty) {
                        Fluttertoast.showToast(
                          msg: "Please fill all fields.",
                          textColor: neopopBackground,
                          backgroundColor: neopopYellow,
                        );
                        return;
                      }

                      if (passwordTextEditingController.text !=
                          confirmPasswordTextEditingController.text) {
                        Fluttertoast.showToast(
                          msg: "Passwords do not match.",
                          textColor: neopopBackground,
                          backgroundColor: neopopYellow,
                        );
                        return;
                      }

                      Get.dialog(const Center(child: LoadingWidget()),
                          barrierDismissible: false);

                      bool isSignedUp = await SupabaseAuth().supabaseSignUp(
                        userEmail: emailTextEditingController.text,
                        userPassword: passwordTextEditingController.text,
                        userName: nameTextEditingController.text,
                        firstName: firstNameTextEditingController.text,
                        lastName: lastNameTextEditingController.text,
                      );

                      Get.back(); // Close loading dialog

                      if (isSignedUp) {
                        Fluttertoast.showToast(
                          msg: "Registration successful! Please login.",
                          textColor: neopopBackground,
                          backgroundColor: neopopYellow,
                        );
                        Get.off(() => const LoginScreen());
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
                    onTapUp: () async {
                      HapticFeedback.vibrate();
                      bool isSuccess = await SupabaseAuth().googleSignIn();
                      if (isSuccess) {
                        // Handled by auth listener or deep link
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
          ),
        ),
      ),
    ),
    );
  }
}
