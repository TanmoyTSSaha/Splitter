import 'dart:io';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:flutter/material.dart';
import 'package:splitr/Utils/currency_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/theme_accent_colors.dart';
import 'package:splitr/Constants/glass_card.dart';
import 'package:splitr/Model/receipt_model.dart';
import 'package:splitr/Model/group_model.dart';
import 'package:splitr/Services/receipt_parser_service.dart';

import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

import '../../Constants/shared.dart';
import '../../Widgets/splitr_detail_app_bar.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

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
    } catch (e, stack) {
      setState(() => _isProcessing = false);
      AppErrorReporter.reportActionFailure(
        AppStrings.errors.failedProcessReceiptPrefix,
        error: e,
        stack: stack,
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
      SplitrToast.show(AppStrings.validation.assignItemToMember);
      return;
    }

    final total = shares.values.fold(0.0, (sum, v) => sum + v);
    widget.onTransactionCreated(
      CategoryDefaults.foodAndDining,
      total,
      _receiptData?.merchantName ?? CategoryDefaults.receiptExpense,
      shares,
    );

    Navigator.of(context).pop();
    SplitrToast.show(AppStrings.groups.receiptExpenseCreated);
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: surface,
      appBar: SplitrDetailAppBar(
        title: AppStrings.groups.scanReceipt,
        centerTitle: true,
        leading: SplitrDetailAppBar.iosBackLeading(
          context,
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_receiptData != null)
            TextButton(
              onPressed: _createTransaction,
              child: Text(
                AppStrings.actions.done,
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
            size: AppDimensions.receiptPickerIconLg,
            color: neopopAccentIconMuted,
          ),
          SizedBox(height: groupGutter),
          Text(
            AppStrings.groups.scanReceiptSubtitle,
            style: body1_text.copyWith(color: neopopGrey),
          ),
          const SizedBox(height: groupGapXl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPickerButton(
                icon: Icons.camera_alt_rounded,
                label: AppStrings.groups.camera,
                onTap: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(width: groupGapXl),
              _buildPickerButton(
                icon: Icons.photo_library_rounded,
                label: AppStrings.groups.gallery,
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
        padding:
            EdgeInsets.symmetric(horizontal: groupGapXl, vertical: groupGapLg),
        child: Column(
          children: [
            Icon(icon,
                color: neopopAccent, size: AppDimensions.receiptPickerIconMd),
            SizedBox(height: groupGap10),
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
          SizedBox(height: groupGutter),
          Text(
            AppStrings.groups.scanningReceipt,
            style: body1_text.copyWith(color: neopopGrey),
          ),
          SizedBox(height: groupGap10),
          Text(
            AppStrings.groups.onDeviceProcessing,
            style: caption_text.copyWith(color: neopopGreyIconDim),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsState() {
    final receipt = _receiptData!;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(groupGutter),
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
                    padding: const EdgeInsets.only(top: groupGapSm),
                    child: Text(
                      "${receipt.date!.day}/${receipt.date!.month}/${receipt.date!.year}",
                      style: caption_text.copyWith(color: neopopGrey),
                    ),
                  ),
                SizedBox(height: groupGap10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppStringFormat.itemsFound(receipt.lineItems.length),
                        style: body2_text),
                    Text(
                      AppStringFormat.totalWithSymbol(
                        userCurrencySymbol(),
                        receipt.total?.toStringAsFixed(2) ??
                            AppAmountHints.decimal,
                      ),
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

          SizedBox(height: groupGutter),

          // Instructions
          Text(
            AppStrings.groups.tapMembersToAssign,
            style: caption_text.copyWith(color: neopopGrey),
          ),
          SizedBox(height: groupGap10),

          // Line items with member assignment
          ...List.generate(receipt.lineItems.length, (index) {
            final item = receipt.lineItems[index];
            final assigned = _assignments[index] ?? {};

            return Padding(
              padding: EdgeInsets.only(bottom: groupGap10),
              child: GlassCard(
                opacity: AppDimensions.glassCardOpacitySubtle,
                padding: EdgeInsets.all(groupCarouselGap),
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
                          "${userCurrencySymbol()}${item.totalPrice.toStringAsFixed(2)}",
                          style: body1_text.copyWith(
                            fontWeight: FontWeight.w600,
                            color: ThemeAccentColors.amount(context),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: groupGap10),
                    // Member chips
                    Wrap(
                      spacing: groupGapXs,
                      runSpacing: groupGapXs,
                      children: [
                        // AppStrings.trips.all chip
                        GestureDetector(
                          onTap: () => _assignAllToItem(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: groupGap10, vertical: groupGap5),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(groupControlRadius),
                              color: assigned.length == widget.members.length
                                  ? neopopAccentBorderSoft
                                  : neopopGreyFillMedium,
                              border: Border.all(
                                color: assigned.length == widget.members.length
                                    ? neopopAccent
                                    : groupTransparent,
                              ),
                            ),
                            child: Text(
                              AppStrings.trips.all,
                              style: caption_text.copyWith(
                                color: assigned.length == widget.members.length
                                    ? neopopAccent
                                    : neopopGrey,
                                fontSize: splitrFontCaptionSm,
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
                                  horizontal: groupGap10, vertical: groupGap5),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(groupControlRadius),
                                color: isAssigned
                                    ? neopopAccentBorderSoft
                                    : neopopGreyFillMedium,
                                border: Border.all(
                                  color: isAssigned
                                      ? neopopAccent
                                      : groupTransparent,
                                ),
                              ),
                              child: Text(
                                member.userName ??
                                    DisplayFallbacks.questionMark,
                                style: caption_text.copyWith(
                                  color: isAssigned ? neopopAccent : neopopGrey,
                                  fontSize: splitrFontCaptionSm,
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
              padding: EdgeInsets.only(top: groupGap10),
              child: GlassCard(
                opacity: AppDimensions.glassCardOpacityWhisper,
                child: Column(
                  children: [
                    if (receipt.tax != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppStrings.groups.taxGst,
                              style: body2_text.copyWith(color: neopopGrey)),
                          Text(
                              "${userCurrencySymbol()}${receipt.tax!.toStringAsFixed(2)}",
                              style: body2_text),
                        ],
                      ),
                    if (receipt.tip != null) ...[
                      const SizedBox(height: groupGapSm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppStrings.groups.tipService,
                              style: body2_text.copyWith(color: neopopGrey)),
                          Text(
                              "${userCurrencySymbol()}${receipt.tip!.toStringAsFixed(2)}",
                              style: body2_text),
                        ],
                      ),
                    ],
                    const SizedBox(height: groupGapSm),
                    Text(
                      AppStrings.groups.taxTipSplitProportionally,
                      style: caption_text.copyWith(color: neopopGreyIconDim),
                    ),
                  ],
                ),
              ),
            ),

          // Per-member breakdown
          if (_assignments.values.any((s) => s.isNotEmpty)) ...[
            SizedBox(height: groupGutter),
            Text(AppStrings.groups.perPersonBreakdown,
                style: sub_headline4_text.copyWith(fontSize: splitrFontBodyLg)),
            SizedBox(height: groupGap10),
            ..._buildMemberBreakdown(),
          ],

          SizedBox(height: AppDimensions.swipeSettleTrackHeight),
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
        padding: const EdgeInsets.only(bottom: groupGapSm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: AppDimensions.receiptAvatarSize,
                  height: AppDimensions.receiptAvatarSize,
                  decoration: BoxDecoration(
                    color: neopopAccentFillStrong,
                    borderRadius: BorderRadius.circular(groupRadiusLgSm),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    (member.userName ?? DisplayFallbacks.questionMark)[0]
                        .toUpperCase(),
                    style: caption_text.copyWith(
                        color: neopopAccent, fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(width: groupGap10),
                Text(member.userName ?? DisplayFallbacks.questionMark,
                    style: body2_text),
              ],
            ),
            Text(
              "${userCurrencySymbol()}${amount.toStringAsFixed(2)}",
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
