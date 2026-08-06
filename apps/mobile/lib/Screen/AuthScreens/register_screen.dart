import 'package:flutter/gestures.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:neopop/neopop.dart';
import 'package:splitr/Screen/AuthScreens/login_screen.dart';

import 'package:splitr/Constants/app_assets.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/auth_validators.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/shared.dart';
import 'package:flutter/services.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Controller/auth_controller.dart';
import 'package:splitr/Services/auth_flow_coordinator.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController _authController = Get.put(AuthController());
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController firstNameTextEditingController =
      TextEditingController();
  TextEditingController lastNameTextEditingController = TextEditingController();
  TextEditingController nameTextEditingController =
      TextEditingController(); // This is Username
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController confirmPasswordTextEditingController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus!.unfocus();
      },
      child: Scaffold(
        backgroundColor: surface,
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: Get.height,
            ),
            child: Container(
              width: Get.width,
              padding: const EdgeInsets.all(groupGutter),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.auth.register,
                      style: headline2_text.copyWith(
                        color: groupOnSurface,
                      ),
                    ),
                    SizedBox(height: Get.height * 0.015),
                    Text(
                      AppStrings.auth.registerSubtitle,
                      textAlign: TextAlign.center,
                      style: body2_text.copyWith(
                        color: groupOnSurfaceMuted,
                      ),
                    ),
                    SizedBox(height: Get.height * 0.05),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryTextFormField(
                            textEditingController:
                                firstNameTextEditingController,
                            fieldName: AppStrings.auth.firstName,
                            isObscure: false,
                            validator: (v) => AuthValidators.requiredName(
                              v,
                              AuthValidators.firstNameLabel,
                            ),
                          ),
                        ),
                        const SizedBox(width: groupGapSm),
                        Expanded(
                          child: PrimaryTextFormField(
                            textEditingController:
                                lastNameTextEditingController,
                            fieldName: AppStrings.auth.lastName,
                            isObscure: false,
                            validator: (v) => AuthValidators.requiredName(
                              v,
                              AuthValidators.lastNameLabel,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Get.height * 0.025),
                    PrimaryTextFormField(
                      textEditingController: nameTextEditingController,
                      fieldName: AppStrings.auth.username,
                      isObscure: false,
                      validator: null,
                    ),
                    SizedBox(height: Get.height * 0.025),
                    PrimaryTextFormField(
                      textEditingController: emailTextEditingController,
                      fieldName: AppStrings.auth.email,
                      isObscure: false,
                      validator: AuthValidators.email,
                    ),
                    SizedBox(height: Get.height * 0.025),
                    PrimaryTextFormField(
                      textEditingController: passwordTextEditingController,
                      fieldName: AppStrings.auth.password,
                      isObscure: true,
                      validator: AuthValidators.password,
                    ),
                    SizedBox(height: Get.height * 0.025),
                    PrimaryTextFormField(
                      textEditingController:
                          confirmPasswordTextEditingController,
                      fieldName: AppStrings.auth.confirmPassword,
                      isObscure: true,
                      validator: (v) => AuthValidators.confirmPassword(
                        v,
                        passwordTextEditingController.text,
                      ),
                    ),
                    SizedBox(height: Get.height * 0.05),
                    NeoPopButton(
                      color: neopopAccent,
                      enabled: true,
                      onTapUp: () async {
                        HapticFeedback.vibrate();
                        if (!_formKey.currentState!.validate()) return;

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
                          SplitrToast.show(AppStrings.auth.registerSuccess);
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
                              AppStrings.auth.register,
                              style: button_text.copyWith(
                                color: groupOnSurface,
                              ),
                            ),
                            SizedBox(
                              width: Get.width * 0.025,
                            ),
                            SvgPicture.asset(
                              height: groupProgressIndicatorSize,
                              width: groupProgressIndicatorSize,
                              AppAssets.iconArrowRight,
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
                          color: groupMutedBorderHairline,
                          height: 2.5,
                          width: Get.width * 0.3,
                        ),
                        Text(
                          AppStrings.auth.orSignUpWith,
                          style: caption_text.copyWith(
                            color: groupOnSurfaceMuted,
                          ),
                        ),
                        Container(
                          color: groupMutedBorderHairline,
                          height: 2.5,
                          width: Get.width * 0.3,
                        ),
                      ],
                    ),
                    SizedBox(height: Get.height * 0.025),
                    NeoPopButton(
                      color: neopopAccent,
                      enabled: true,
                      onTapUp: () async {
                        HapticFeedback.vibrate();
                        _authController.turnAuthScreenLoadingOn();
                        try {
                          final result =
                              await SupabaseAuth().signInWithGoogle();
                          if (!mounted) {
                            _authController.turnAuthScreenLoadingOff();
                            return;
                          }
                          if (result.isPendingBrowser) {
                            _authController.turnAuthScreenLoadingOff();
                            return;
                          }
                          if (!result.isCompleted) {
                            _authController.turnAuthScreenLoadingOff();
                            final message = result.userMessage;
                            if (message != null && message.isNotEmpty) {
                              SplitrToast.show(message);
                            }
                            return;
                          }
                          _authController.turnAuthScreenLoadingOff();
                          await AuthFlowCoordinator.completeSignIn();
                        } catch (e, stack) {
                          _authController.turnAuthScreenLoadingOff();
                          AppErrorReporter.report(
                            'Google sign-up failed',
                            error: e,
                            stack: stack,
                          );
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
                              height: groupProgressIndicatorSize,
                              width: groupProgressIndicatorSize,
                              AppAssets.iconGoogle,
                            ),
                            SizedBox(
                              width: Get.width * 0.025,
                            ),
                            Text(
                              AppStrings.auth.signUpGoogle,
                              style: button_text.copyWith(
                                color: groupOnSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: Get.height * 0.05),
                    RichText(
                      text: TextSpan(
                        text: AppStrings.auth.hasAccount,
                        style: caption_text.copyWith(
                          color: groupOnSurfaceMuted,
                        ),
                        children: [
                          TextSpan(
                            text: AppStrings.auth.loginNow,
                            style: caption_text.copyWith(
                              color: groupOnSurface,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.to(() => const LoginScreen());
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
