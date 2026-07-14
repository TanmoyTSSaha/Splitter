import 'package:flutter/material.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Model/loan_model.dart';
import 'package:splitr/Model/repayment_schedule.dart';
import 'package:splitr/Repository/loan_repository.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Widgets/bordered_input_field.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

typedef LoanPaymentSuccess = void Function(LoanModel updatedLoan);

class LoanPaymentSheet extends StatefulWidget {
  final LoanModel loan;
  final double? initialAmount;

  const LoanPaymentSheet({
    super.key,
    required this.loan,
    this.initialAmount,
  });

  static Future<LoanModel?> show(
    BuildContext context, {
    required LoanModel loan,
    double? initialAmount,
  }) {
    return showModalBottomSheet<LoanModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: groupSheetTopBorderRadius,
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: LoanPaymentSheet(
          loan: loan,
          initialAmount: initialAmount,
        ),
      ),
    );
  }

  @override
  State<LoanPaymentSheet> createState() => _LoanPaymentSheetState();
}

class _LoanPaymentSheetState extends State<LoanPaymentSheet> {
  LoanRepository get _loanRepo => Get.find<LoanRepository>();
  late final TextEditingController _paymentController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _paymentController = TextEditingController(
      text: widget.initialAmount != null
          ? widget.initialAmount!.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }

  Future<void> _recordPayment() async {
    final payment = double.tryParse(_paymentController.text);
    if (payment == null || payment <= 0) {
      SplitrToast.show(SplitrToast.join(AppStrings.errors.errorTitle, AppStrings.validation.validPaymentAmount));
      return;
    }

    if (payment > widget.loan.currentAmountOwed) {
      SplitrToast.show(SplitrToast.join(AppStrings.errors.errorTitle, AppStrings.validation.paymentExceedsBalance));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _loanRepo.recordLoanPayment(
        loanId: widget.loan.id!,
        paymentAmount: payment,
      );
      final updated = await _loanRepo.getLoanById(widget.loan.id!);
      if (updated != null && mounted) {
        SplitrToast.show(SplitrToast.join(AppStrings.notifications.inviteSuccess, AppStrings.lending.paymentRecorded));
        Navigator.of(context).pop(updated);
      }
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        AppStrings.lending.paymentRecorded,
        error: e,
        stack: stack,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          groupGutter,
          groupGapMd,
          groupGutter,
          groupGutter,
        ),
        child: LoanPaymentForm(
          loan: widget.loan,
          controller: _paymentController,
          isSubmitting: _isSubmitting,
          onSubmit: _recordPayment,
          submitLabel: AppStrings.lending.recordPayment,
        ),
      ),
    );
  }
}

class LoanPaymentForm extends StatelessWidget {
  final LoanModel loan;
  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final String? submitLabel;

  LoanPaymentForm({
    super.key,
    required this.loan,
    required this.controller,
    required this.isSubmitting,
    required this.onSubmit,
    this.submitLabel,
  });

  String get _effectiveSubmitLabel =>
      submitLabel ?? AppStrings.lending.recordPayment;

  @override
  Widget build(BuildContext context) {
    final schedule = LoanScheduleCalculator.build(loan);
    final payable = LoanScheduleCalculator.currentPayableInstallment(
      schedule,
      DateTime.now(),
    );
    final sym = Get.find<CurrencyController>().symbol;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.lending.recordPaymentTitle,
          style: body1_text.copyWith(
            fontWeight: FontWeight.bold,
            color: groupOnSurface,
          ),
        ),
        const SizedBox(height: groupGapSm),
        Text(
          AppStrings.lending.eitherPartyCanLog,
          style: caption_text.copyWith(color: groupOnSurfaceMuted),
        ),
        if (payable != null) ...[
          const SizedBox(height: groupGapSm),
          Text(
            AppStringFormat.currentInstallmentDue(
              sym,
              LoanScheduleCalculator.remainingDue(payable).toStringAsFixed(2),
            ),
            style: caption_text.copyWith(
              color: groupOnSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 4),
        Text(
          AppStringFormat.remainingBalance(
            sym,
            loan.currentAmountOwed.toStringAsFixed(2),
          ),
          style: caption_text.copyWith(color: groupOnSurfaceMuted),
        ),
        const SizedBox(height: groupGapMd),
        BorderedInputField(
          controller: controller,
          hintText: AppAmountHints.zero,
          prefixText: '$sym ',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: body1_text.copyWith(
            fontWeight: FontWeight.bold,
            color: groupOnSurface,
          ),
        ),
        const SizedBox(height: groupGapMd),
        SizedBox(
          width: double.infinity,
          height: groupCtaHeightCompact,
          child: ElevatedButton(
            onPressed: isSubmitting ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: neopopBackground,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(groupControlRadius),
              ),
              elevation: 0,
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: groupProgressIndicatorSize,
                    height: groupProgressIndicatorSize,
                    child: CircularProgressIndicator(
                      strokeWidth: groupProgressStrokeWidth,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _effectiveSubmitLabel,
                    style: body1_text.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
