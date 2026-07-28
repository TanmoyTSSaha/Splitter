import 'package:flutter/material.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:get/get.dart';
import 'package:neopop/neopop.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/shared.dart';
import 'package:splitr/Screen/AuthScreens/reset_password_screen.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/auth_validators.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _newPasswordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _newPasswordCtrl.text.trim()),
      );
      SplitrToast.show(AppStrings.auth.passwordUpdatedShort);
      Get.back();
    } on AuthException catch (e) {
      AppErrorReporter.userFacing(e.message, error: e);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: surface,
      appBar: SplitrDetailAppBar(title: AppStrings.auth.changePasswordTitle),
      body: Padding(
        padding: const EdgeInsets.all(groupGutter),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              PrimaryTextFormField(
                textEditingController: _newPasswordCtrl,
                fieldName: AppStrings.auth.newPassword,
                isObscure: true,
                validator: AuthValidators.password,
              ),
              const SizedBox(height: groupGapMd),
              PrimaryTextFormField(
                textEditingController: _confirmCtrl,
                fieldName: AppStrings.auth.confirmPasswordLabel,
                isObscure: true,
                validator: (v) {
                  if (v != _newPasswordCtrl.text) {
                    return AppStrings.auth.passwordsNoMatch;
                  }
                  return AuthValidators.password(v);
                },
              ),
              const SizedBox(height: groupGapXl),
              NeoPopButton(
                color: neopopAccent,
                enabled: !_submitting,
                onTapUp: _submitting ? null : _submit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: groupGutter),
                  child: Center(child: Text(AppStrings.auth.savePassword)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
