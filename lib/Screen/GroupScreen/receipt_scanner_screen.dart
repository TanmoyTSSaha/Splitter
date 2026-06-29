import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/glass_card.dart';
import 'package:splitter/Model/receipt_model.dart';
import 'package:splitter/Model/group_model.dart';
import 'package:splitter/Services/receipt_parser_service.dart';

import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';

import '../../Constants/shared.dart';

/// Camera → OCR → Itemized bill → Per-person assignment → Auto-split.
class ReceiptScannerScreen extends StatefulWidget {
  final String groupID;
  final List<GroupMembersWithNameModel> members;
  final Function(String category, double amount, String description,
      Map<String, double> memberShares) onTransactionCreated;

  const ReceiptScannerScreen({
    required this.groupID,
    required this.members,
    required this.onTransactionCreated,
    super.key,
  });

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  final _imagePicker = ImagePicker();
  final _parserService = ReceiptParserService();

  ReceiptData? _receiptData;
  bool _isProcessing = false;
  File? _imageFile;

  // Assignment: itemIndex → set of memberIDs
  Map<int, Set<String>> _assignments = {};

  @override
  void dispose() {
    _parserService.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        _isProcessing = true;
        _imageFile = File(pickedFile.path);
      });

      final receiptData = await _parserService.parseReceipt(_imageFile!);

      setState(() {
        _receiptData = receiptData;
        _isProcessing = false;
        // Initialize assignments: empty for each item
        _assignments = {};
        for (int i = 0; i < receiptData.lineItems.length; i++) {
          _assignments[i] = {};
        }
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      Fluttertoast.showToast(
        msg: "Failed to process receipt: $e",
        backgroundColor: neopopYellow,
        textColor: neopopBackground,
      );
    }
  }

  void _toggleMemberAssignment(int itemIndex, String memberID) {
    setState(() {
      if (_assignments[itemIndex]!.contains(memberID)) {
        _assignments[itemIndex]!.remove(memberID);
      } else {
        _assignments[itemIndex]!.add(memberID);
      }
    });
  }

  void _assignAllToItem(int itemIndex) {
    setState(() {
      final allIDs = widget.members.map((m) => m.userID!).toSet();
      if (_assignments[itemIndex]!.length == allIDs.length) {
        _assignments[itemIndex] = {};
      } else {
        _assignments[itemIndex] = allIDs;
      }
    });
  }

  Map<String, double> _calculateMemberShares() {
    final shares = <String, double>{};
    final receipt = _receiptData!;

    // Calculate per-item shares
    for (int i = 0; i < receipt.lineItems.length; i++) {
      final item = receipt.lineItems[i];
      final assignees = _assignments[i] ?? {};
      if (assignees.isEmpty) continue;

      final perPerson = item.totalPrice / assignees.length;
      for (var memberID in assignees) {
        shares[memberID] = (shares[memberID] ?? 0) + perPerson;
      }
    }

    // Distribute tax and tip proportionally
    final itemsTotal =
        receipt.lineItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    if (itemsTotal > 0) {
      final extras = (receipt.tax ?? 0) + (receipt.tip ?? 0);
      for (var entry in shares.entries) {
        final proportion = entry.value / itemsTotal;
        shares[entry.key] = entry.value + (extras * proportion);
      }
    }

    return shares;
  }

  void _createTransaction() {
    final shares = _calculateMemberShares();
    if (shares.isEmpty) {
      Fluttertoast.showToast(
        msg: "Assign at least one item to a member",
        backgroundColor: neopopYellow,
        textColor: neopopBackground,
      );
      return;
    }

    final total = shares.values.fold(0.0, (sum, v) => sum + v);
    widget.onTransactionCreated(
      "Food & Dining",
      total,
      _receiptData?.merchantName ?? "Receipt expense",
      shares,
    );

    Navigator.of(context).pop();
    Fluttertoast.showToast(
      msg: "Transaction created from receipt! 🧾",
      backgroundColor: neopopAccent,
      textColor: neopopBackground,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: groupOnSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Scan Receipt",
          style: sub_headline4_text.copyWith(color: groupOnSurface),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: groupOnSurface),
        actions: [
          if (_receiptData != null)
            TextButton(
              onPressed: _createTransaction,
              child: Text(
                "Done",
                style: button_text.copyWith(color: neopopAccent),
              ),
            ),
        ],
      ),
      body: _isProcessing
          ? _buildProcessingState()
          : _receiptData == null
              ? _buildPickerState()
              : _buildResultsState(),
    );
  }

  Widget _buildPickerState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 80,
            color: neopopAccent.withOpacity(0.5),
          ),
          SizedBox(height: height_16),
          Text(
            "Scan a receipt to auto-split",
            style: body1_text.copyWith(color: neopopGrey),
          ),
          SizedBox(height: height_16 * 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPickerButton(
                icon: Icons.camera_alt_rounded,
                label: "Camera",
                onTap: () => _pickImage(ImageSource.camera),
              ),
              SizedBox(width: width_16 * 2),
              _buildPickerButton(
                icon: Icons.photo_library_rounded,
                label: "Gallery",
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPickerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: EdgeInsets.symmetric(
            horizontal: width_16 * 2, vertical: height_16 * 1.5),
        child: Column(
          children: [
            Icon(icon, color: neopopAccent, size: 40),
            SizedBox(height: height_10),
            Text(label, style: caption_text),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingWidget(),
          SizedBox(height: height_16),
          Text(
            "Scanning receipt...",
            style: body1_text.copyWith(color: neopopGrey),
          ),
          SizedBox(height: height_10),
          Text(
            "All processing is on-device 🔒",
            style: caption_text.copyWith(color: neopopGrey.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsState() {
    final receipt = _receiptData!;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(width_16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Receipt header
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (receipt.merchantName != null)
                  Text(
                    receipt.merchantName!,
                    style: sub_headline4_text.copyWith(color: neopopAccent),
                  ),
                if (receipt.date != null)
                  Padding(
                    padding: EdgeInsets.only(top: height_10 / 2),
                    child: Text(
                      "${receipt.date!.day}/${receipt.date!.month}/${receipt.date!.year}",
                      style: caption_text.copyWith(color: neopopGrey),
                    ),
                  ),
                SizedBox(height: height_10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${receipt.lineItems.length} items found",
                        style: body2_text),
                    Text(
                      "Total: ₹${receipt.total?.toStringAsFixed(2) ?? '0.00'}",
                      style: body1_text.copyWith(
                        fontWeight: FontWeight.w700,
                        color: neopopAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: height_16),

          // Instructions
          Text(
            "Tap members to assign items",
            style: caption_text.copyWith(color: neopopGrey),
          ),
          SizedBox(height: height_10),

          // Line items with member assignment
          ...List.generate(receipt.lineItems.length, (index) {
            final item = receipt.lineItems[index];
            final assigned = _assignments[index] ?? {};

            return Padding(
              padding: EdgeInsets.only(bottom: height_10),
              child: GlassCard(
                opacity: 0.05,
                padding: EdgeInsets.all(height_10 * 1.2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item name and price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: body1_text.copyWith(
                                fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          "₹${item.totalPrice.toStringAsFixed(2)}",
                          style: body1_text.copyWith(
                            fontWeight: FontWeight.w600,
                            color: neopopYellow,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height_10),
                    // Member chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        // "All" chip
                        GestureDetector(
                          onTap: () => _assignAllToItem(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: assigned.length == widget.members.length
                                  ? neopopAccent.withOpacity(0.3)
                                  : neopopGrey.withOpacity(0.15),
                              border: Border.all(
                                color: assigned.length == widget.members.length
                                    ? neopopAccent
                                    : Colors.transparent,
                              ),
                            ),
                            child: Text(
                              "All",
                              style: caption_text.copyWith(
                                color: assigned.length == widget.members.length
                                    ? neopopAccent
                                    : neopopGrey,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        // Individual member chips
                        ...widget.members.map((member) {
                          final isAssigned = assigned.contains(member.userID);
                          return GestureDetector(
                            onTap: () =>
                                _toggleMemberAssignment(index, member.userID!),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: isAssigned
                                    ? neopopAccent.withOpacity(0.3)
                                    : neopopGrey.withOpacity(0.15),
                                border: Border.all(
                                  color: isAssigned
                                      ? neopopAccent
                                      : Colors.transparent,
                                ),
                              ),
                              child: Text(
                                member.userName ?? "?",
                                style: caption_text.copyWith(
                                  color: isAssigned ? neopopAccent : neopopGrey,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

          // Tax and tip info
          if (receipt.tax != null || receipt.tip != null)
            Padding(
              padding: EdgeInsets.only(top: height_10),
              child: GlassCard(
                opacity: 0.04,
                child: Column(
                  children: [
                    if (receipt.tax != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Tax/GST",
                              style: body2_text.copyWith(color: neopopGrey)),
                          Text("₹${receipt.tax!.toStringAsFixed(2)}",
                              style: body2_text),
                        ],
                      ),
                    if (receipt.tip != null) ...[
                      SizedBox(height: height_10 / 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Tip/Service",
                              style: body2_text.copyWith(color: neopopGrey)),
                          Text("₹${receipt.tip!.toStringAsFixed(2)}",
                              style: body2_text),
                        ],
                      ),
                    ],
                    SizedBox(height: height_10 / 2),
                    Text(
                      "Tax & tip will be split proportionally",
                      style: caption_text.copyWith(
                          color: neopopGrey.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
            ),

          // Per-member breakdown
          if (_assignments.values.any((s) => s.isNotEmpty)) ...[
            SizedBox(height: height_16),
            Text("Per-person breakdown",
                style: sub_headline4_text.copyWith(fontSize: 16)),
            SizedBox(height: height_10),
            ..._buildMemberBreakdown(),
          ],

          SizedBox(height: height_16 * 4),
        ],
      ),
    );
  }

  List<Widget> _buildMemberBreakdown() {
    final shares = _calculateMemberShares();
    return widget.members
        .where((m) => shares.containsKey(m.userID))
        .map((member) {
      final amount = shares[member.userID] ?? 0;
      return Padding(
        padding: EdgeInsets.only(bottom: height_10 / 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: neopopAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    (member.userName ?? "?")[0].toUpperCase(),
                    style: caption_text.copyWith(
                        color: neopopAccent, fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(width: width_10),
                Text(member.userName ?? "?", style: body2_text),
              ],
            ),
            Text(
              "₹${amount.toStringAsFixed(2)}",
              style: body1_text.copyWith(
                fontWeight: FontWeight.w600,
                color: neopopAccent,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
