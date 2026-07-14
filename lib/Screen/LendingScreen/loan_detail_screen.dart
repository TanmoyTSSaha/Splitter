import 'package:flutter/material.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/glass_card.dart';
import 'package:splitr/Controller/lending_refresh_controller.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Model/loan_model.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Screen/LendingScreen/loan_repayment_schedule_screen.dart';
import 'package:splitr/Screen/LendingScreen/widgets/loan_payment_sheet.dart';
import 'package:splitr/Screen/LendingScreen/widgets/loan_repayment_progress_bar.dart';
import 'package:splitr/Repository/loan_repository.dart';
import 'package:splitr/Services/export_service.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Widgets/premium_gate.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';
import 'package:splitr/Widgets/user_avatar.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

class LoanDetailScreen extends StatefulWidget {
  final LoanModel loan;
  final double? initialPaymentAmount;

  const LoanDetailScreen({
    super.key,
    required this.loan,
    this.initialPaymentAmount,
  });

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen> {
  LoanRepository get _loanRepo => Get.find<LoanRepository>();
  final String _userID = SupabaseAuth().supabaseGetUserID();
  final TextEditingController _paymentController = TextEditingController();

  late LoanModel _loan;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loan = widget.loan;
    if (widget.initialPaymentAmount != null) {
      _paymentController.text = widget.initialPaymentAmount!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }

  bool get _isLender => _loan.lenderID == _userID;
  bool get _isActive => _loan.status == LoanStatusValues.active;
  bool get _isPending => _loan.status == GroupInviteStatusValues.pending;

  bool get _canViewSchedule =>
      _loan.duration != null &&
      _loan.dueDate != null &&
      _loan.repaymentStartDay != null &&
      _loan.repaymentEndDay != null;

  bool get _canRespondToPending =>
      _isPending && _loan.createdBy != null && _loan.createdBy != _userID;

  String get _interestPeriodLabel =>
      _loan.interestPeriod == LoanFrequencyValues.yearly
          ? LoanFrequencyValues.yearly
          : LoanFrequencyValues.monthly;

  String get _counterpartyName => _isLender
      ? (_loan.borrowerName ?? LoanRoleFallbacks.borrower)
      : (_loan.lenderName ?? LoanRoleFallbacks.lender);

  String get _counterpartyAvatar =>
      _isLender ? (_loan.borrowerAvatar ?? '') : (_loan.lenderAvatar ?? '');

  String get _counterpartyId => _isLender ? _loan.borrowerID : _loan.lenderID;

  Future<void> _recordPayment() async {
    final payment = double.tryParse(_paymentController.text);
    if (payment == null || payment <= 0) {
      SplitrToast.show(SplitrToast.join(AppStrings.errors.errorTitle, AppStrings.validation.validPaymentAmount));
      return;
    }

    if (payment > _loan.currentAmountOwed) {
      SplitrToast.show(SplitrToast.join(AppStrings.errors.errorTitle, AppStrings.validation.paymentExceedsBalance));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _loanRepo.recordLoanPayment(
        loanId: _loan.id!,
        paymentAmount: payment,
      );
      final updated = await _loanRepo.getLoanById(_loan.id!);
      if (updated != null && mounted) {
        setState(() {
          _loan = updated;
          _paymentController.clear();
        });
      }
      SplitrToast.show(SplitrToast.join(AppStrings.notifications.inviteSuccess, AppStrings.lending.paymentRecorded));
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

  Future<void> _handleLoanResponse(bool accept) async {
    if (_loan.id == null) return;

    setState(() => _isSubmitting = true);
    try {
      await _loanRepo.updateLoanStatus(
        loanId: _loan.id!,
        status: accept ? LoanStatusValues.active : LoanStatusValues.rejected,
      );
      LendingRefreshController.refreshFromAnywhere();
      SplitrToast.show(SplitrToast.join(accept
            ? AppStrings.notifications.loanAcceptedTitle
            : AppStrings.notifications.loanRejectedTitle, accept
            ? AppStrings.notifications.loanNowActive
            : AppStrings.notifications.loanOfferRejected));
      Get.back(result: true);
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        AppStrings.notifications.actionFailed,
        error: e,
        stack: stack,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Get.back(result: true);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: SplitrDetailAppBar(
          title: AppStrings.lending.contractDetails,
          centerTitle: true,
          leading: SplitrDetailAppBar.iosBackLeading(
            context,
            onPressed: () => Get.back(result: true),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            groupGutter,
            groupGapSm,
            groupGutter,
            _canRespondToPending ? 120 : groupGutter,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: groupGapMd),
              _buildDetailsCard(),
              if (_isPending && !_canRespondToPending) ...[
                const SizedBox(height: groupGapMd),
                _buildPendingNotice(),
              ],
              if (_isActive) ...[
                const SizedBox(height: groupGapMd),
                _buildPaymentSection(),
              ],
            ],
          ),
        ),
        bottomSheet: _canRespondToPending ? _buildResponseActions() : null,
      ),
    );
  }

  Widget _buildResponseActions() {
    return Container(
      padding: const EdgeInsets.all(groupGutter),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: groupCtaHeight,
                child: OutlinedButton(
                  onPressed:
                      _isSubmitting ? null : () => _handleLoanResponse(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: neopopError,
                    side: const BorderSide(color: neopopError),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(groupControlRadius),
                    ),
                  ),
                  child: Text(
                    AppStrings.lending.reject,
                    style: body1_text.copyWith(
                      fontWeight: FontWeight.w600,
                      color: neopopError,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: groupCtaHeight,
                child: ElevatedButton(
                  onPressed:
                      _isSubmitting ? null : () => _handleLoanResponse(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neopopBackground,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(groupControlRadius),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: groupProgressIndicatorSize,
                          height: groupProgressIndicatorSize,
                          child: CircularProgressIndicator(
                            strokeWidth: groupProgressStrokeWidth,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          AppStrings.lending.accept,
                          style: body1_text.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(groupGapMd),
      opacity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              UserAvatar(
                userID: _counterpartyId,
                userName: _counterpartyName,
                imageUrl: _counterpartyAvatar,
                radius: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _counterpartyName,
                      style: body1_text.copyWith(
                        fontWeight: FontWeight.bold,
                        color: groupOnSurface,
                      ),
                    ),
                    Text(
                      _isLender
                          ? LoanRoleFallbacks.borrower
                          : LoanRoleFallbacks.lender,
                      style: caption_text.copyWith(color: groupOnSurfaceMuted),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: groupGapLg),
          Obx(() {
            final sym = Get.find<CurrencyController>().symbol;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.lending.remaining,
                      style: caption_text.copyWith(color: groupOnSurfaceMuted),
                    ),
                    Text(
                      '$sym${_loan.currentAmountOwed.toStringAsFixed(0)}',
                      style: headline3_text.copyWith(
                        fontWeight: FontWeight.bold,
                        color: groupOnSurface,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppStrings.lending.totalPayable,
                      style: caption_text.copyWith(color: groupOnSurfaceMuted),
                    ),
                    Text(
                      '$sym${_loan.totalContractPayable.toStringAsFixed(0)}',
                      style: body1_text.copyWith(
                        fontWeight: FontWeight.w600,
                        color: groupOnSurface,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
          if (_loan.status == LoanStatusValues.active) ...[
            const SizedBox(height: groupGapMd),
            LoanRepaymentProgressBar.fromLoan(_loan),
            const SizedBox(height: groupGapXs),
            _buildRepaymentProgressLegend(),
          ],
        ],
      ),
    );
  }

  Widget _buildRepaymentProgressLegend() {
    Widget legendItem(Color color, String label) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: groupGapXxs),
          Text(
            label,
            style: caption_text.copyWith(
              color: groupOnSurfaceMuted,
              fontSize: splitrFontCaptionSm,
            ),
          ),
        ],
      );
    }

    return Wrap(
      spacing: groupGapMd,
      runSpacing: groupGapXs,
      children: [
        legendItem(
          LoanRepaymentProgressBar.principalPaidColor,
          AppStrings.lending.principalPaid,
        ),
        legendItem(
          LoanRepaymentProgressBar.interestPaidColor,
          AppStrings.lending.interestPaid,
        ),
        legendItem(
          LoanRepaymentProgressBar.remainingTrackColor,
          AppStrings.lending.remaining,
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final badgeColor = _loan.status == LoanStatusValues.active
        ? neopopAccent
        : (_loan.status == GroupInviteStatusValues.pending
            ? Colors.orangeAccent
            : Colors.grey);

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: groupGap10, vertical: groupGapXxs),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(groupControlRadiusSm),
        border: Border.all(color: badgeColor),
      ),
      child: Text(
        _loan.status.toUpperCase(),
        style: const TextStyle(
          fontSize: splitrFontMicro,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(groupGapMd),
      opacity: 0.08,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.lending.terms,
            style: body1_text.copyWith(
              fontWeight: FontWeight.bold,
              color: groupOnSurface,
            ),
          ),
          const SizedBox(height: groupGapMd),
          _detailRow(
            AppStrings.lending.interestRate,
            '${_loan.interestRate.toStringAsFixed(1)}% $_interestPeriodLabel (${_loan.interestType})',
          ),
          if (_loan.duration != null && _loan.durationUnit != null)
            _detailRow(
              AppStrings.lending.duration,
              '${_loan.duration} ${_loan.durationUnit}',
            ),
          if (_loan.dueDate != null)
            _detailRow(
              AppStrings.lending.dueDate,
              DateFormat(AppDateFormats.shortDayYear).format(_loan.dueDate!),
            ),
          if (_loan.repaymentStartDay != null && _loan.repaymentEndDay != null)
            _detailRow(
              AppStrings.lending.repaymentWindow,
              AppStringFormat.repaymentWindowMonthly(
                _loan.repaymentStartDay!,
                _loan.repaymentEndDay!,
              ),
            ),
          Obx(() {
            final sym = Get.find<CurrencyController>().symbol;
            return _detailRow(
              AppStrings.lending.totalRepaid,
              '$sym${_loan.repaymentAmount.toStringAsFixed(0)}',
            );
          }),
          if (_canViewSchedule) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Get.to(
                  () => LoanRepaymentScheduleScreen(loan: _loan),
                ),
                child: Text(
                  AppStrings.lending.viewRepaymentSchedule,
                  style: body2_text.copyWith(
                    fontWeight: FontWeight.w600,
                    color: neopopPrimary,
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.dotted,
                    decorationColor: neopopPrimary,
                  ),
                ),
              ),
            ),
          ],
          if (_loan.status != LoanStatusValues.rejected) ...[
            const SizedBox(height: groupGapSm),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  const Icon(Icons.description_outlined, color: neopopAccent),
              title: Text(
                AppStrings.lending.exportContractPdf,
                style: body2_text.copyWith(
                  fontWeight: FontWeight.w600,
                  color: groupOnSurface,
                ),
              ),
              subtitle: Text(
                AppStrings.lending.contractPdfSummary,
                style: caption_text.copyWith(color: groupOnSurfaceMuted),
              ),
              trailing: const PremiumLockBadge(),
              onTap: _exportContractPdf,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _exportContractPdf() async {
    final ok = await requirePremium(
      featureLabel: AppStrings.lending.contractPdf,
    );
    if (!ok) return;

    try {
      await ExportService().exportLoanContractPdf(loan: _loan);
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        AppStrings.errors.exportFailed,
        error: e,
        stack: stack,
        context: {'feature': 'export'},
      );
    }
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: groupGap10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: body2_text.copyWith(color: groupOnSurfaceMuted)),
          Flexible(
            child: Text(
              value,
              style: body2_text.copyWith(
                fontWeight: FontWeight.w600,
                color: groupOnSurface,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingNotice() {
    final initiatedByMe = _loan.createdBy == _userID;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(groupGapMd),
      decoration: BoxDecoration(
        color: neopopAccentFillSoft,
        borderRadius: BorderRadius.circular(groupCardRadius),
        border: Border.all(color: neopopAccentBorderHairline),
      ),
      child: Text(
        initiatedByMe
            ? AppStrings.lending.awaitingOtherParty
            : AppStrings.lending.reviewTerms,
        style: body2_text.copyWith(color: groupOnSurface),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(groupGapMd),
      opacity: 0.08,
      child: LoanPaymentForm(
        loan: _loan,
        controller: _paymentController,
        isSubmitting: _isSubmitting,
        onSubmit: _recordPayment,
      ),
    );
  }
}
