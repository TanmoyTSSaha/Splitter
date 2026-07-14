import 'package:flutter/material.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Model/friend_model.dart';
import 'package:splitr/Screen/GroupScreen/group_detailed_screen.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Repository/group_repository.dart';
import 'package:splitr/Repository/transaction_repository.dart';
import 'package:splitr/Widgets/bordered_input_field.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/Utils/transaction_date_formatter.dart';

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.friend.friendUserID == null) return;

    setState(() => _isSubmitting = true);
    try {
      final amount = double.parse(_amountController.text.trim());
      final description = _descriptionController.text.trim().isEmpty
          ? AppStrings.friends.quickSplitDefaultDescription
          : _descriptionController.text.trim();
      final friendId = widget.friend.friendUserID!;
      final friendName = widget.friend.friendName ?? DisplayFallbacks.friend;

      final group =
          await Get.find<GroupRepository>().getOrCreateDirectSplitGroup(
        userId: widget.userID,
        friendUserId: friendId,
        friendName: friendName,
      );

      final paidBy = _friendPaid ? friendId : widget.userID;
      final owedBy = _friendPaid ? widget.userID : friendId;
      final splits = {owedBy: amount};

      await Get.find<TransactionRepository>().addGroupExpense(
        groupID: group.groupID!,
        paidByUserID: paidBy,
        totalAmount: amount,
        description: description,
        category: CategoryDefaults.general,
        splits: splits,
        currency: Get.find<CurrencyController>().code,
        sharingType: SharingTypeValues.evenly,
        transactionDate: TransactionDateFormatter.nowForTransaction(),
      );

      Get.back();
      Get.to(() => GroupDetailedScreen(
            groupModel: group,
            userID: widget.userID,
          ));
      SplitrToast.show(AppStrings.friends.splitRecorded);
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        AppStrings.friends.failedPrefix,
        error: e,
        stack: stack,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final borderColor = groupMutedBorderHairline;
    return Scaffold(
      backgroundColor: surface,
      appBar: SplitrDetailAppBar(
        title: AppStrings.friends.quickSplit,
        leading: SplitrDetailAppBar.iosBackLeading(
          context,
          onPressed: () => Navigator.pop(context),
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
                '${AppStrings.friends.quickSplitWithPrefix}${widget.friend.friendName ?? DisplayFallbacks.friend.toLowerCase()}',
                style: body1_text.copyWith(color: groupOnSurfaceMuted),
              ),
              const SizedBox(height: groupGapMd),
              BorderedInputField.amount(
                controller: _amountController,
                labelText: AppStrings.home.amount,
                validator: (v) {
                  final n = double.tryParse(v?.trim() ?? '');
                  if (n == null || n <= 0) {
                    return AppStrings.validation.validAmount;
                  }
                  return null;
                },
              ),
              const SizedBox(height: groupGapMd),
              BorderedInputField(
                controller: _descriptionController,
                labelText: AppStrings.friends.whatForShort,
              ),
              const SizedBox(height: groupGapSm),
              Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(groupCardRadius),
                  border: Border.all(color: borderColor),
                ),
                child: SwitchListTile(
                  title: Text(
                    '${widget.friend.friendName}${AppStrings.friends.friendPaidSuffix}',
                    style: body1_text.copyWith(color: groupOnSurface),
                  ),
                  subtitle: Text(
                    _friendPaid
                        ? AppStrings.friends.youOweThemShort
                        : AppStrings.friends.theyOweYouShort,
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
                  minimumSize:
                      const Size(double.infinity, AppDimensions.groupCtaHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(groupRadiusLgSm),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: AppDimensions.loadingIndicatorSm,
                        width: AppDimensions.loadingIndicatorSm,
                        child: CircularProgressIndicator(
                          strokeWidth: groupProgressStrokeWidth,
                          color: neopopOnPrimary,
                        ),
                      )
                    : Text(
                        AppStrings.friends.quickSplitSubmit,
                        style: button_text.copyWith(color: neopopOnPrimary),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
