import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Widgets/bordered_input_field.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

/// Screen to create a new group with a name.
class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<bool> _hasConnection() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;

    if (!await _hasConnection()) {
      SplitrToast.show(SplitrToast.join(AppStrings.groups.offline, AppStrings.groups.createGroupNeedsInternet));
      return;
    }

    setState(() => _isCreating = true);

    try {
      final supabase = Supabase.instance.client;

      await supabase.rpc(SupabaseRpc.createGroupWithMember, params: {
        SupabaseColumns.pGroupName: _nameController.text.trim(),
      });

      Get.back(result: true);
      SplitrToast.show(SplitrToast.join(AppStrings.groups.groupCreatedTitle, AppStringFormat.groupReady(_nameController.text.trim())));
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        AppStrings.groups.couldNotCreateGroupPrefix,
        error: e,
        stack: stack,
      );
    } finally {
      setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
        backgroundColor: surface,
        appBar: SplitrDetailAppBar(
          title: AppStrings.groups.newGroup,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            groupGutter,
            groupGutter,
            groupGutter,
            groupGutter + MediaQuery.paddingOf(context).bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.groups.groupName,
                  style: caption_text.copyWith(
                    color: groupOnSurfaceMuted,
                  ),
                ),
                const SizedBox(height: groupGapSm),
                BorderedInputField(
                  controller: _nameController,
                  hintText: AppStrings.groups.groupNameHint,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? AppStrings.validation.required
                      : null,
                ),
                const SizedBox(height: groupGapXl * 2),
                SizedBox(
                  width: double.infinity,
                  height: groupCtaHeight,
                  child: ElevatedButton(
                    onPressed: _isCreating ? null : _createGroup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: neopopAccent,
                      foregroundColor: groupOnSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(groupControlRadius),
                      ),
                      elevation: 0,
                    ),
                    child: _isCreating
                        ? const SizedBox(
                            width: groupProgressIndicatorSize,
                            height: groupProgressIndicatorSize,
                            child: CircularProgressIndicator(
                              strokeWidth: groupProgressStrokeWidth,
                              color: groupOnSurface,
                            ),
                          )
                        : Text(
                            AppStrings.groups.createGroup,
                            style: body1_text.copyWith(
                              color: groupOnSurface,
                              fontWeight: FontWeight.w600,
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
