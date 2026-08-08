import 'package:flutter/gestures.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:neopop/neopop.dart';
import 'package:splitr/Constants/app_assets.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/auth_validators.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/shared.dart';
import 'package:splitr/Controller/auth_controller.dart';
import 'package:splitr/Controllers/premium_subscription_controller.dart';
import 'package:splitr/Screen/AuthScreens/register_screen.dart';
import 'package:splitr/Screen/BottomNavigationController/bottom_navigation_controller.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Services/auth_flow_coordinator.dart';
import 'package:splitr/Services/deep_link_service.dart';
import 'package:splitr/Services/google_auth_result.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  final AuthController _authController = Get.put(AuthController());
  final _formKey = GlobalKey<FormState>();
  bool _sendingPasswordReset = false;
  String? _lastUsedLoginMethod;

  @override
  void initState() {
    super.initState();
    _loadLastUsedLoginMethod();
  }

  Future<void> _loadLastUsedLoginMethod() async {
    final method = await SupabaseAuth().getLastUsedLoginMethod();
    if (!mounted) return;
    setState(() => _lastUsedLoginMethod = method);
  }

  Widget _lastUsedBadge({
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Positioned(
      top: -6,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          AppStrings.auth.lastUsed,
          style: caption_text.copyWith(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus!.unfocus();
      },
      child: Scaffold(
        backgroundColor: surface,
        body: Obx(
          () {
            return Stack(
              alignment: Alignment.center,
              children: [
                SingleChildScrollView(
                  child: Container(
                    width: Get.width,
                    padding: EdgeInsets.symmetric(
                      horizontal: groupGutter,
                      vertical: MediaQuery.of(context).size.height * 0.08,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.auth.login,
                            style: headline2_text.copyWith(
                              color: groupOnSurface,
                            ),
                          ),
                          SizedBox(height: Get.height * 0.015),
                          Text(
                            AppStrings.auth.loginSubtitle,
                            textAlign: TextAlign.center,
                            style: body2_text.copyWith(
                              color: groupOnSurfaceMuted,
                            ),
                          ),
                          SizedBox(height: Get.height * 0.05),
                          PrimaryTextFormField(
                            textEditingController: emailTextEditingController,
                            fieldName: AppStrings.auth.email,
                            isObscure: false,
                            validator: AuthValidators.email,
                          ),
                          SizedBox(height: Get.height * 0.025),
                          PrimaryTextFormField(
                            textEditingController:
                                passwordTextEditingController,
                            fieldName: AppStrings.auth.password,
                            isObscure: true,
                            validator: AuthValidators.password,
                          ),
                          SizedBox(height: Get.height * 0.025),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: _sendingPasswordReset
                                  ? null
                                  : () async {
                                      final email =
                                          emailTextEditingController.text
                                              .trim();
                                      final validationError =
                                          AuthValidators.email(email);
                                      if (validationError != null) {
                                        SplitrToast.show(validationError);
                                        return;
                                      }
                                      setState(
                                          () => _sendingPasswordReset = true);
                                      try {
                                        await SupabaseAuth().resetPassword(
                                          email: email,
                                        );
                                      } finally {
                                        if (mounted) {
                                          setState(
                                            () => _sendingPasswordReset = false,
                                          );
                                        }
                                      }
                                    },
                              child: Text(
                                _sendingPasswordReset
                                    ? AppStrings.auth.sendingResetLink
                                    : AppStrings.auth.forgotPassword,
                                style: button_text.copyWith(
                                  color: neopopAccent,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: Get.height * 0.05),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              NeoPopButton(
                                color: neopopAccent,
                                enabled: true,
                                onTapUp: () async {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }
                                  _authController.turnAuthScreenLoadingOn();
                                  try {
                                    bool isLoggedIn = await SupabaseAuth()
                                        .supabaseEmailPassSignIn(
                                            userEmail:
                                                emailTextEditingController.text,
                                            userPassword:
                                                passwordTextEditingController
                                                    .text);

                                    if (isLoggedIn) {
                                      _authController
                                          .turnAuthScreenLoadingOff();
                                      await Get.find<
                                              PremiumSubscriptionController>()
                                          .refreshStatus();
                                      await Get.find<DeepLinkService>()
                                          .processPendingInvite();
                                      SplitrToast.show(
                                          AppStrings.auth.loginSuccess);
                                      Get.offAll(() =>
                                          const BottomNavigationController());
                                    } else {
                                      _authController
                                          .turnAuthScreenLoadingOff();
                                    }
                                  } catch (e, stack) {
                                    _authController.turnAuthScreenLoadingOff();
                                    AppErrorReporter.report(
                                      'Login failed',
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppStrings.auth.login,
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
                              if (_lastUsedLoginMethod == LoginMethods.email)
                                _lastUsedBadge(
                                  backgroundColor: neopopYellow,
                                  textColor: groupOnSurface,
                                ),
                            ],
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
                                AppStrings.auth.orSignInWith,
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
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              NeoPopButton(
                                color: neopopYellow,
                                enabled: true,
                                onTapUp: () async {
                                  HapticFeedback.vibrate();
                                  _authController.turnAuthScreenLoadingOn();
                                  try {
                                    final result =
                                        await SupabaseAuth().signInWithGoogle();
                                    if (!mounted) {
                                      _authController
                                          .turnAuthScreenLoadingOff();
                                      return;
                                    }
                                    if (result.outcome == GoogleAuthOutcome.cancelled) {
                                      _authController.turnAuthScreenLoadingOff();
                                      SplitrToast.show(
                                        AppStrings.services.auth
                                            .googleSignInCancelled,
                                      );
                                      return;
                                    }
                                    if (!result.isCompleted) {
                                      _authController
                                          .turnAuthScreenLoadingOff();
                                      final message = result.userMessage;
                                      if (message != null &&
                                          message.isNotEmpty) {
                                        SplitrToast.show(message);
                                      }
                                      return;
                                    }
                                    _authController.turnAuthScreenLoadingOff();
                                    await AuthFlowCoordinator.completeSignIn();
                                  } catch (e, stack) {
                                    _authController.turnAuthScreenLoadingOff();
                                    AppErrorReporter.report(
                                      'Google sign-in failed',
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                        AppStrings.auth.signInGoogle,
                                        style: button_text.copyWith(
                                          color: groupOnSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (_lastUsedLoginMethod == LoginMethods.google)
                                _lastUsedBadge(
                                  backgroundColor: neopopSuccessBright,
                                  textColor: neopopOnPrimary,
                                ),
                            ],
                          ),
                          SizedBox(height: Get.height * 0.05),
                          RichText(
                            text: TextSpan(
                              text: AppStrings.auth.noAccount,
                              style: caption_text.copyWith(
                                color: groupOnSurfaceMuted,
                              ),
                              children: [
                                TextSpan(
                                  text: AppStrings.auth.registerNow,
                                  style: caption_text.copyWith(
                                    color: neopopAccent,
                                    fontWeight: FontWeight.w600,
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
                ),
                if (_authController.isAuthScreenLoading.value)
                  Container(
                    height: devSysHeight,
                    width: devSysWidth,
                    color: groupSurfaceFillSoft,
                    child: const LoadingWidget(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
