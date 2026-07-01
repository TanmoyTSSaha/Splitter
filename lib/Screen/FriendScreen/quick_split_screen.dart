import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Controllers/currency_controller.dart';
import 'package:splitter/Model/friend_model.dart';
import 'package:splitter/Screen/GroupScreen/group_detailed_screen.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitter/Services/supabase_service.dart';

const Color _lightBg = Color(0xFFFAFAFA);
const Color _cardBorder = Color(0xFFEEEEEE);

/// Lightweight 1:1 expense flow — reuses or creates a 2-member group.
class QuickSplitScreen extends StatefulWidget {
  final String userID;
  final FriendBalanceModel friend;

  const QuickSplitScreen({
    required this.userID,
    required this.friend,
    super.key,
  });

  @override
  State<QuickSplitScreen> createState() => _QuickSplitScreenState();
}

class _QuickSplitScreenState extends State<QuickSplitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _friendPaid = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontFamily: 'Poppins',
        color: groupOnSurfaceMuted,
      ),
      filled: true,
      fillColor: Colors.white,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.friend.friendUserID == null) return;

    setState(() => _isSubmitting = true);
    try {
      final amount = double.parse(_amountController.text.trim());
      final description = _descriptionController.text.trim().isEmpty
          ? 'Quick split'
          : _descriptionController.text.trim();
      final friendId = widget.friend.friendUserID!;
      final friendName = widget.friend.friendName ?? 'Friend';

      final group = await SupabaseDatabase().getOrCreateDirectSplitGroup(
        userID: widget.userID,
        friendUserId: friendId,
        friendName: friendName,
      );

      final paidBy = _friendPaid ? friendId : widget.userID;
      final owedBy = _friendPaid ? widget.userID : friendId;
      final splits = {owedBy: amount};

      await SupabaseDatabase().addGroupExpense(
        groupID: group.groupID!,
        paidByUserID: paidBy,
        totalAmount: amount,
        description: description,
        category: 'General',
        splits: splits,
        currency: Get.find<CurrencyController>().code,
        sharingType: 'evenly',
      );

      Get.back();
      Get.to(() => GroupDetailedScreen(
            groupModel: group,
            userID: widget.userID,
          ));
      Fluttertoast.showToast(
        msg: 'Split recorded!',
        backgroundColor: neopopAccent,
        textColor: neopopBackground,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed: $e',
        backgroundColor: neopopYellow,
        textColor: neopopBackground,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      appBar: AppBar(
        backgroundColor: _lightBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: groupOnSurface),
        ),
        title: Text(
          'Quick split',
          style: headline3_text.copyWith(
            fontFamily: 'Albra',
            fontWeight: FontWeight.w600,
            color: groupOnSurface,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(groupGutter),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'with ${widget.friend.friendName ?? 'friend'}',
                style: body1_text.copyWith(color: groupOnSurfaceMuted),
              ),
              const SizedBox(height: groupGapMd),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: body1_text.copyWith(color: groupOnSurface),
                decoration: _fieldDecoration('Amount').copyWith(
                  prefixText: '₹ ',
                  prefixStyle: body1_text.copyWith(color: groupOnSurface),
                ),
                validator: (v) {
                  final n = double.tryParse(v?.trim() ?? '');
                  if (n == null || n <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: groupGapMd),
              TextFormField(
                controller: _descriptionController,
                style: body1_text.copyWith(color: groupOnSurface),
                decoration: _fieldDecoration('What for?'),
              ),
              const SizedBox(height: groupGapSm),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _cardBorder),
                ),
                child: SwitchListTile(
                  title: Text(
                    '${widget.friend.friendName} paid',
                    style: body1_text.copyWith(color: groupOnSurface),
                  ),
                  subtitle: Text(
                    _friendPaid ? 'You owe them' : 'They owe you',
                    style: caption_text.copyWith(color: groupOnSurfaceMuted),
                  ),
                  value: _friendPaid,
                  activeThumbColor: neopopAccent,
                  onChanged: (v) => setState(() => _friendPaid = v),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: neopopBackground,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Split now',
                        style: button_text.copyWith(color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
