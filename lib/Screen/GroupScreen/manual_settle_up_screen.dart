import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Controller/settle_up_controller.dart';
import 'package:splitter/Model/group_model.dart';
import 'package:splitter/Widgets/user_avatar.dart';

class ManualSettleUpScreen extends StatefulWidget {
  final String groupID;
  final String currentUserID;

  const ManualSettleUpScreen({
    required this.groupID,
    required this.currentUserID,
    super.key,
  });

  @override
  State<ManualSettleUpScreen> createState() => _ManualSettleUpScreenState();
}

class _ManualSettleUpScreenState extends State<ManualSettleUpScreen> {
  final TextEditingController _amountController = TextEditingController();
  final SettleUpController _controller = Get.find<SettleUpController>();

  GroupMembersWithNameModel? _selectedMember;

  @override
  Widget build(BuildContext context) {
    // Filter out current user from dropdown list
    final availableMembers = _controller.groupMembers
        .where((m) => m.userID != widget.currentUserID)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        iconTheme: const IconThemeData(color: neopopBackground),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: neopopBackground),
        ),
        title: Text("Settle Up",
            style: sub_headline5_text.copyWith(color: neopopBackground)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select a person to pay",
              style: body1_text.copyWith(color: neopopGrey),
            ),
            SizedBox(height: height_10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: height_16),
              decoration: BoxDecoration(
                color: neopopBackground.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: neopopGrey.withOpacity(0.25)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<GroupMembersWithNameModel>(
                  value: _selectedMember,
                  hint: Text(
                    "Select Recipient",
                    style: body1_text.copyWith(color: neopopGrey),
                  ),
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: neopopAccent),
                  items: availableMembers.map((member) {
                    return DropdownMenuItem(
                      value: member,
                      child: Row(
                        children: [
                          UserAvatar(
                            userID: member.userID ?? "",
                            userName: member.userName ?? "Unknown",
                            imageUrl: member.userPic,
                            radius: 12,
                          ),
                          SizedBox(width: width_10),
                          Text(
                            member.userName ?? "Unknown",
                            style:
                                body1_text.copyWith(color: neopopBackground),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMember = value;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: height_16 * 2),
            Text(
              "Enter Amount",
              style: body1_text.copyWith(color: neopopGrey),
            ),
            SizedBox(height: height_10),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: headline1_text.copyWith(color: neopopAccent),
              decoration: InputDecoration(
                prefixText: "₹ ",
                prefixStyle: headline1_text.copyWith(color: neopopAccent),
                hintText: "0.00",
                hintStyle:
                    headline1_text.copyWith(color: neopopGrey.withOpacity(0.3)),
                filled: true,
                fillColor: neopopBackground.withOpacity(0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: neopopAccent.withOpacity(0.5)),
                ),
              ),
            ),
            const Spacer(),
            Obx(() {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _controller.isSettling.value
                      ? null
                      : () => _handleSettleUp(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neopopAccent,
                    padding: EdgeInsets.symmetric(vertical: height_16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: neopopAccent.withOpacity(0.5),
                  ),
                  child: _controller.isSettling.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: neopopBackground,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Settle Up",
                          style: button_text.copyWith(
                            color: neopopBackground,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
              );
            }),
            SizedBox(height: height_16),
          ],
        ),
      ),
    );
  }

  void _handleSettleUp() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _showToast("Please enter an amount", isError: true);
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showToast("Please enter a valid amount", isError: true);
      return;
    }

    if (_selectedMember == null) {
      _showToast("Please select a recipient", isError: true);
      return;
    }

    // Validation: Check if debt exists and amount is valid
    final fromId = widget.currentUserID;
    final toId = _selectedMember!.userID!;

    // Find relevant debt in simplified debts
    SimplifiedDebt? relevantDebt;
    try {
      relevantDebt = _controller.simplifiedDebts
          .firstWhere((d) => d.fromID == fromId && d.toID == toId);
    } catch (_) {
      relevantDebt = null;
    }

    if (relevantDebt == null) {
      _showToast("You don't own any money to ${_selectedMember!.userName}",
          isError: true);
      return;
    }

    if (amount > relevantDebt.amount) {
      _showToast("You only owe ₹${relevantDebt.amount.toStringAsFixed(2)}",
          isError: true);
      return;
    }

    // Construct the debt object (reusing SimplifiedDebt structure for convenience)
    final debt = SimplifiedDebt(
      fromID: fromId,
      fromName: "You", // Not used for recording
      toID: toId,
      toName: _selectedMember!.userName!,
      amount: amount,
    );

    final success = await _controller.recordSettlement(debt);

    if (success) {
      _showToast("Settlement recorded! ✅");
      Get.back(); // Go back to Group Screen
    } else {
      _showToast("Failed to record settlement", isError: true);
    }
  }

  void _showToast(String msg, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: msg,
      textColor: neopopBackground,
      backgroundColor: isError ? neopopYellow : neopopAccent,
      gravity: ToastGravity.BOTTOM,
    );
  }
}
