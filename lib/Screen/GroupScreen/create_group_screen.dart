import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    try {
      final supabase = Supabase.instance.client;

      // Use RPC to bypass RLS — function runs with SECURITY DEFINER
      await supabase.rpc('create_group_with_member', params: {
        'p_group_name': _nameController.text.trim(),
      });

      Get.back(result: true);
      Get.snackbar(
        '🎉 Group Created',
        '${_nameController.text.trim()} is ready!',
        backgroundColor: neopopAccent.withOpacity(0.8),
        colorText: groupOnSurface,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not create group: $e',
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          elevation: 0,
          title: Text(
            'New Group',
            style: sub_headline5_text.copyWith(color: groupOnSurface),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(height_16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Group Name',
                  style: caption_text.copyWith(
                    color: groupOnSurfaceMuted,
                  ),
                ),
                SizedBox(height: height_10 / 2),
                TextFormField(
                  controller: _nameController,
                  style: body1_text.copyWith(color: groupOnSurface),
                  decoration: _inputDecoration('e.g. Weekend Trip Squad'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                SizedBox(height: height_16 * 3),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isCreating ? null : _createGroup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: neopopAccent,
                      foregroundColor: groupOnSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isCreating
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: groupOnSurface,
                            ),
                          )
                        : Text(
                            'Create Group',
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
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: body1_text.copyWith(color: groupOnSurfaceMuted),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: groupOnSurfaceMuted.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: neopopAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
