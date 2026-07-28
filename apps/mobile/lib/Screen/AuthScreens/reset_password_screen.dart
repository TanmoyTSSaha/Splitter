import 'package:flutter/material.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:get/get.dart';
import 'package:neopop/neopop.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/auth_validators.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/shared.dart';
import 'package:splitr/Screen/AuthScreens/login_screen.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Shown after the user opens a password-recovery link from email.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _passwordCtrl.text.trim()),
      );
      SplitrToast.show(AppStrings.auth.passwordUpdated);
      await Supabase.instance.client.auth.signOut();
      Get.offAll(() => const LoginScreen());
    } on AuthException catch (e) {
      AppErrorReporter.userFacing(e.message, error: e);
    } catch (e, stack) {
      AppErrorReporter.report(
        AppStrings.errors.passwordUpdateFailed,
        error: e,
        stack: stack,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: surface,
      appBar: SplitrDetailAppBar(title: AppStrings.auth.setNewPassword),
      body: Padding(
        padding: const EdgeInsets.all(groupGutter),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.auth.passwordHint,
                style: body2_text.copyWith(color: groupOnSurfaceMuted),
              ),
              const SizedBox(height: groupGapLg),
              PrimaryTextFormField(
                textEditingController: _passwordCtrl,
                fieldName: AppStrings.auth.newPassword,
                isObscure: true,
                validator: AuthValidators.password,
              ),
              const SizedBox(height: groupGapMd),
              PrimaryTextFormField(
                textEditingController: _confirmCtrl,
                fieldName: AppStrings.auth.confirmPasswordLabel,
                isObscure: true,
                validator: (v) =>
                    AuthValidators.confirmPassword(v, _passwordCtrl.text),
              ),
              const SizedBox(height: groupGapXl),
              NeoPopButton(
                color: neopopAccent,
                enabled: !_submitting,
                onTapUp: _submitting ? null : _submit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: groupGutter),
                  child: Center(
                    child: _submitting
                        ? const SizedBox(
                            width: AppDimensions.loadingIndicatorMd,
                            height: AppDimensions.loadingIndicatorMd,
                            child: CircularProgressIndicator(
                              strokeWidth: groupProgressStrokeWidth,
                            ),
                          )
                        : Text(
                            AppStrings.auth.updatePassword,
                            style: button_text.copyWith(color: groupOnSurface),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
