import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Model/user_details_model.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitter/Services/supabase_service.dart';

const Color _cardBorder = Color(0xFFEEEEEE);
const Color _lockedField = Color(0xFFC8C8C8);

class PersonalDetailsScreen extends StatefulWidget {
  final UserDetails initialData;
  const PersonalDetailsScreen({super.key, required this.initialData});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;

  bool _isSaving = false;
  bool _isDirty = false;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: widget.initialData.firstName);
    _lastNameCtrl = TextEditingController(text: widget.initialData.lastName);
    _phoneCtrl = TextEditingController(text: widget.initialData.phone);
    _emailCtrl = TextEditingController(text: widget.initialData.email);

    for (final c in [_firstNameCtrl, _lastNameCtrl, _phoneCtrl]) {
      c.addListener(_checkDirty);
    }
  }

  void _checkDirty() {
    final phone = _phoneCtrl.text.trim();
    String? phoneErr;
    if (phone.isNotEmpty && phone.length != 10) {
      phoneErr = 'Phone number must be exactly 10 digits.';
    }
    final dirty = _firstNameCtrl.text.trim() != widget.initialData.firstName ||
        _lastNameCtrl.text.trim() != widget.initialData.lastName ||
        phone != widget.initialData.phone;
    setState(() {
      _phoneError = phoneErr;
      _isDirty = dirty && phoneErr == null;
    });
  }

  @override
  void dispose() {
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
      setState(() => _phoneError = 'Phone number must be exactly 10 digits.');
      return;
    }
    setState(() => _isSaving = true);

    final db = SupabaseDatabase();
    try {
      await db.updateUserProfile(
        userID: widget.initialData.userID ?? '',
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Profile updated successfully.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            backgroundColor: neopopYellow,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(groupGutter),
          ),
        );
        Get.back();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update profile: $e',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color(0xFFE53935),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(groupGutter),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: groupOnSurface),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Personal Details',
          style: headline3_text.copyWith(
            fontFamily: 'Albra',
            fontWeight: FontWeight.w600,
            color: groupOnSurface,
          ),
        ),
        centerTitle: false,
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
                  _buildSectionHeader('IDENTITY'),
                  const SizedBox(height: groupGapSm),
                  _buildFieldCard([
                    _buildField(
                      label: 'First Name',
                      controller: _firstNameCtrl,
                      hint: 'Enter your first name',
                    ),
                    _buildDivider(),
                    _buildField(
                      label: 'Last Name',
                      controller: _lastNameCtrl,
                      hint: 'Enter your last name',
                    ),
                  ]),
                  const SizedBox(height: groupGapLg),
                  _buildSectionHeader('CONTACT'),
                  const SizedBox(height: groupGapSm),
                  _buildFieldCard([
                    _buildLockedField(
                      label: 'Email',
                      controller: _emailCtrl,
                    ),
                    _buildDivider(),
                    _buildField(
                      label: 'Phone',
                      controller: _phoneCtrl,
                      hint: '10-digit phone number',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      errorText: _phoneError,
                      showCounter: true,
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
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 11,
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: groupOnSurfaceMuted,
            ),
          ),
          const SizedBox(height: groupGapSm),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: errorText != null
                  ? const Color(0xFFE53935)
                  : groupOnSurface,
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: neopopBackground, width: 1.5),
              ),
              hintText: hint,
              hintStyle: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: groupOnSurfaceMuted.withValues(alpha: 0.7),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              isDense: true,
            ),
          ),
          if (showCounter) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${controller.text.length}/10',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: controller.text.length == 10
                      ? const Color(0xFF4CAF50)
                      : groupOnSurfaceMuted,
                ),
              ),
            ),
          ],
          if (errorText != null) ...[
            const SizedBox(height: 6),
            Text(
              errorText,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE53935),
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
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: groupOnSurfaceMuted,
            ),
          ),
          const SizedBox(height: groupGapSm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _cardBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? 'Not set' : controller.text,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _lockedField,
                    ),
                  ),
                ),
                const Icon(Icons.lock_outline_rounded,
                    size: 16, color: _lockedField),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: _cardBorder,
      indent: groupGapMd,
      endIndent: groupGapMd,
    );
  }

  Widget _buildSaveButton() {
    return Container(
      color: const Color(0xFFFAFAFA),
      padding: const EdgeInsets.fromLTRB(groupGutter, groupGapSm, groupGutter, 32),
      child: GestureDetector(
        onTap: _isDirty ? _save : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: _isDirty ? neopopYellow : const Color(0xFFDDDDDD),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: _isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.black,
                  ),
                )
              : Text(
                  'SAVE CHANGES',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: _isDirty ? Colors.black : _lockedField,
                  ),
                ),
        ),
      ),
    );
  }
}
