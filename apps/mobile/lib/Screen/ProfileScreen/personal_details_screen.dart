import 'dart:io';
import 'package:splitr/Widgets/splitr_toast.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Model/user_details_model.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:image_picker/image_picker.dart';
import 'package:splitr/Controller/profile_controller.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Widgets/bordered_input_field.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';
import 'package:splitr/Widgets/user_avatar.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Widgets/user_upi_accounts_editor.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

class PersonalDetailsScreen extends StatefulWidget {
  final UserDetails initialData;
  const PersonalDetailsScreen({super.key, required this.initialData});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  late final TextEditingController _userNameCtrl;
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  final ImagePicker _imagePicker = ImagePicker();

  bool _isSaving = false;
  bool _isUploadingPhoto = false;
  bool _isDirty = false;
  String? _phoneError;
  String? _profilePhotoUrl;

  late String _savedUserName;
  late String _savedFirstName;
  late String _savedLastName;
  late String _savedPhone;

  @override
  void initState() {
    super.initState();
    _profilePhotoUrl = widget.initialData.profilePictureURL;
    _userNameCtrl = TextEditingController(
      text: widget.initialData.userName ?? widget.initialData.firstName,
    );
    _firstNameCtrl = TextEditingController(text: widget.initialData.firstName);
    _lastNameCtrl = TextEditingController(text: widget.initialData.lastName);
    _phoneCtrl = TextEditingController(text: widget.initialData.phone);
    _emailCtrl = TextEditingController(text: widget.initialData.email);

    _savedUserName =
        widget.initialData.userName ?? widget.initialData.firstName ?? '';
    _savedFirstName = widget.initialData.firstName ?? '';
    _savedLastName = widget.initialData.lastName ?? '';
    _savedPhone = widget.initialData.phone ?? '';

    for (final c in [
      _userNameCtrl,
      _firstNameCtrl,
      _lastNameCtrl,
      _phoneCtrl
    ]) {
      c.addListener(_checkDirty);
    }
  }

  void _captureSavedBaseline() {
    _savedUserName = _userNameCtrl.text.trim();
    _savedFirstName = _firstNameCtrl.text.trim();
    _savedLastName = _lastNameCtrl.text.trim();
    _savedPhone = _phoneCtrl.text.trim();
  }

  void _checkDirty() {
    final phone = _phoneCtrl.text.trim();
    String? phoneErr;
    if (phone.isNotEmpty && phone.length != 10) {
      phoneErr = AppStrings.profile.phoneExactDigits;
    }
    final dirty = _userNameCtrl.text.trim() != _savedUserName ||
        _firstNameCtrl.text.trim() != _savedFirstName ||
        _lastNameCtrl.text.trim() != _savedLastName ||
        phone != _savedPhone;
    setState(() {
      _phoneError = phoneErr;
      _isDirty = dirty && phoneErr == null;
    });
  }

  @override
  void dispose() {
    _userNameCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_isDirty || _isSaving) return;
    final phone = _phoneCtrl.text.trim();
    if (phone.isNotEmpty && phone.length != 10) {
      setState(() => _phoneError = AppStrings.profile.phoneExactDigits);
      return;
    }
    setState(() => _isSaving = true);

    final db = SupabaseDatabase();
    try {
      await db.updateUserProfile(
        userID: widget.initialData.userID ?? '',
        userName: _userNameCtrl.text.trim(),
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      );
      if (Get.isRegistered<ProfileController>()) {
        try {
          await Get.find<ProfileController>().fetchProfileData();
        } catch (_) {
          // Profile saved; refresh failure should not block success UX.
        }
      }
      if (mounted) {
        setState(() {
          _captureSavedBaseline();
          _isDirty = false;
        });
        SplitrToast.show(AppStrings.profile.profileUpdated);
      }
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        AppStrings.profile.profileUpdateFailedPrefix,
        error: e,
        stack: stack,
        context: {'feature': 'profile', 'operation': 'saveProfile'},
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickProfilePhoto() async {
    if (_isUploadingPhoto) return;
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _isUploadingPhoto = true);
    final db = SupabaseDatabase();
    try {
      final url = await db.uploadProfilePhoto(
        userID: widget.initialData.userID ?? '',
        imageFile: File(picked.path),
      );
      if (!mounted) return;
      setState(() => _profilePhotoUrl = url);
      if (Get.isRegistered<ProfileController>()) {
        await Get.find<ProfileController>().fetchProfileData();
      }
      SplitrToast.showFromContext(context, AppStrings.profile.photoUpdated);
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        AppStrings.profile.photoUploadFailedPrefix,
        error: e,
        stack: stack,
        context: {'feature': 'profile', 'operation': 'uploadPhoto'},
      );
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final borderColor = groupMutedBorderHairline;
    return Scaffold(
      backgroundColor: surface,
      appBar: SplitrDetailAppBar(
        title: AppStrings.profile.personalDetails,
        leading: SplitrDetailAppBar.iosBackLeading(
          context,
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                groupGutter,
                groupGapSm,
                groupGutter,
                groupGapLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        UserAvatar(
                          userID: widget.initialData.userID ?? '',
                          userName: _userNameCtrl.text.trim().isNotEmpty
                              ? _userNameCtrl.text.trim()
                              : DisplayFallbacks.user,
                          imageUrl: _profilePhotoUrl,
                          radius: AppDimensions.profileAvatarRadius,
                        ),
                        const SizedBox(height: groupGapSm),
                        TextButton.icon(
                          onPressed:
                              _isUploadingPhoto ? null : _pickProfilePhoto,
                          icon: _isUploadingPhoto
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: groupProgressStrokeWidth,
                                    color: neopopAccent,
                                  ),
                                )
                              : const Icon(Icons.photo_camera_outlined,
                                  size: 18),
                          label: Text(
                            _isUploadingPhoto
                                ? AppStrings.profile.uploading
                                : AppStrings.profile.changePhoto,
                            style: body2_text.copyWith(color: neopopAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: groupGapLg),
                  _buildSectionHeader(AppStrings.profile.identitySection),
                  const SizedBox(height: groupGapSm),
                  _buildFieldCard([
                    _buildField(
                      label: AppStrings.auth.username,
                      controller: _userNameCtrl,
                      hint: AppStrings.profile.usernameHint,
                    ),
                    _buildDivider(),
                    _buildField(
                      label: AppStrings.auth.firstName,
                      controller: _firstNameCtrl,
                      hint: AppStrings.profile.firstNameHint,
                    ),
                    _buildDivider(),
                    _buildField(
                      label: AppStrings.auth.lastName,
                      controller: _lastNameCtrl,
                      hint: AppStrings.profile.lastNameHint,
                    ),
                  ]),
                  const SizedBox(height: groupGapLg),
                  _buildSectionHeader(AppStrings.profile.contactSection),
                  const SizedBox(height: groupGapSm),
                  _buildFieldCard([
                    _buildLockedField(
                      label: AppStrings.auth.email,
                      controller: _emailCtrl,
                    ),
                    _buildDivider(),
                    _buildField(
                      label: AppStrings.profile.phone,
                      controller: _phoneCtrl,
                      hint: AppStrings.profile.phoneHint,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      errorText: _phoneError,
                      showCounter: true,
                    ),
                  ]),
                  const SizedBox(height: groupGapLg),
                  _buildSectionHeader(AppStrings.profile.paymentSection),
                  const SizedBox(height: groupGapSm),
                  Text(
                    AppStrings.profile.upiAccountsSection,
                    style: body2_text.copyWith(color: groupOnSurfaceMuted),
                  ),
                  const SizedBox(height: groupGapSm),
                  _buildFieldCard([
                    Padding(
                      padding: const EdgeInsets.all(groupGapMd),
                      child: UserUpiAccountsEditor(
                        userId: widget.initialData.userID ?? '',
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: kFontPoppins,
        fontSize: splitrFontCaptionSm,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.6,
        color: groupOnSurfaceMuted,
      ),
    );
  }

  Widget _buildFieldCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(groupCardRadius),
        border: Border.all(color: groupMutedBorderHairline),
        boxShadow: [
          BoxShadow(
            color: groupSurfaceFillWhisper,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? errorText,
    bool showCounter = false,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        groupGapMd,
        groupGapMd,
        groupGapMd,
        groupGapMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: kFontPoppins,
              fontSize: splitrFontCaptionSm,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: groupOnSurfaceMuted,
            ),
          ),
          const SizedBox(height: groupGapSm),
          BorderedInputField(
            controller: controller,
            hintText: hint,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: TextStyle(
              fontFamily: kFontPoppins,
              fontSize: splitrFontBodyMd,
              fontWeight: FontWeight.w600,
              color: errorText != null ? neopopAlert : groupOnSurface,
            ),
          ),
          if (showCounter) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${controller.text.length}/10',
                style: TextStyle(
                  fontFamily: kFontPoppins,
                  fontSize: splitrFontCaptionSm,
                  color: controller.text.length == 10
                      ? neopopSuccessBright
                      : groupOnSurfaceMuted,
                ),
              ),
            ),
          ],
          if (errorText != null) ...[
            const SizedBox(height: 6),
            Text(
              errorText,
              style: TextStyle(
                fontFamily: kFontPoppins,
                fontSize: splitrFontCaptionSm,
                fontWeight: FontWeight.w500,
                color: neopopAlert,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLockedField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        groupGapMd,
        groupGapMd,
        groupGapMd,
        groupGapMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: kFontPoppins,
              fontSize: splitrFontCaptionSm,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: groupOnSurfaceMuted,
            ),
          ),
          const SizedBox(height: groupGapSm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: groupGap14, vertical: groupGap14),
            decoration: BoxDecoration(
              color: groupSurfaceMutedFill,
              borderRadius: BorderRadius.circular(groupControlRadius),
              border: Border.all(color: groupMutedBorderHairline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.text.isEmpty
                        ? AppStrings.profile.notSet
                        : controller.text,
                    style: TextStyle(
                      fontFamily: kFontPoppins,
                      fontSize: splitrFontBodyMd,
                      fontWeight: FontWeight.w500,
                      color: neopopGrey,
                    ),
                  ),
                ),
                const Icon(Icons.lock_outline_rounded,
                    size: groupIconMd, color: neopopGrey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: groupMutedBorderHairline,
      indent: groupGapMd,
      endIndent: groupGapMd,
    );
  }

  Widget _buildSaveButton() {
    final surface = Theme.of(context).colorScheme.surface;
    return Container(
      color: surface,
      padding: const EdgeInsets.fromLTRB(
          groupGutter, groupGapSm, groupGutter, groupGapXl),
      child: GestureDetector(
        onTap: _isDirty ? _save : null,
        child: AnimatedContainer(
          duration: AppMotion.standard,
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: _isDirty ? neopopYellow : neopopDisabledBg,
            borderRadius: BorderRadius.circular(groupRadiusLgSm),
          ),
          alignment: Alignment.center,
          child: _isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: groupProgressStrokeWidthMedium,
                    color: groupOnSurface,
                  ),
                )
              : Text(
                  AppStrings.actions.saveChanges,
                  style: TextStyle(
                    fontFamily: kFontPoppins,
                    fontSize: splitrFontBodySm,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: _isDirty ? groupOnSurface : neopopGrey,
                  ),
                ),
        ),
      ),
    );
  }
}
