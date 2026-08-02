import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/glass_card.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Model/loan_model.dart';
import 'package:splitr/Model/repayment_schedule.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Screen/LendingScreen/widgets/loan_payment_sheet.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/domain_values.dart';

class LoanRepaymentScheduleScreen extends StatefulWidget {
  final LoanModel loan;

  const LoanRepaymentScheduleScreen({super.key, required this.loan});

  @override
  State<LoanRepaymentScheduleScreen> createState() =>
      _LoanRepaymentScheduleScreenState();
}

class _LoanRepaymentScheduleScreenState
    extends State<LoanRepaymentScheduleScreen> {
  late LoanModel _loan;

  @override
  void initState() {
    super.initState();
    _loan = widget.loan;
  }

  Future<void> _openPaymentSheet(RepaymentInstallment inst) async {
    final updated = await LoanPaymentSheet.show(
      context,
      loan: _loan,
      initialAmount: LoanScheduleCalculator.remainingDue(inst),
    );
    if (updated != null && mounted) {
      setState(() => _loan = updated);
    }
  }

  bool _canPayInstallment(RepaymentInstallment inst) {
    if (_loan.status != LoanStatusValues.active) return false;
    if (inst.status != InstallmentStatus.upcoming &&
        inst.status != InstallmentStatus.partial) {
      return false;
    }
    return LoanScheduleCalculator.isInPaymentWindow(inst, DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final schedule = LoanScheduleCalculator.build(_loan);
    final sym = Get.find<CurrencyController>().symbol;
    final dateFormat = DateFormat(AppDateFormats.shortDayYear);

    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: surface,
      appBar: SplitrDetailAppBar(
        title: AppStrings.lending.repaymentSchedule,
        centerTitle: true,
        leading: SplitrDetailAppBar.iosBackLeading(
          context,
          onPressed: () => Get.back(result: _loan != widget.loan),
        ),
      ),
      body: schedule.monthCount == 0 || schedule.installments.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.all(groupGutter),
              children: [
                _buildSummaryCard(schedule, sym),
                const SizedBox(height: groupGapXl + groupGapSm),
                Text(
                  AppStrings.lending.monthlyInstallments,
                  style: body1_text.copyWith(
                    fontWeight: FontWeight.bold,
                    color: groupOnSurface,
                  ),
                ),
                const SizedBox(height: groupGapSm),
                ...schedule.installments.map(
                  (inst) => _buildInstallmentRow(inst, sym, dateFormat),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(groupGutter),
        child: Text(
          AppStrings.lending.scheduleBuildError,
          textAlign: TextAlign.center,
          style: body2_text.copyWith(color: groupOnSurfaceMuted),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(RepaymentSchedule schedule, String sym) {
    final periodLabel = _loan.interestPeriod == LoanFrequencyValues.yearly
        ? LoanFrequencyValues.yearly
        : LoanFrequencyValues.monthly;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.lending.repaymentBreakdown,
          style: caption_text.copyWith(
            color: groupOnSurfaceMuted,
            letterSpacing: 1.2,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: groupGapLg),
        _breakdownLineItem(
          title: AppStrings.lending.principal,
          subtitle: AppStrings.lending.loanAmount,
          amount: '$sym${schedule.principal.toStringAsFixed(2)}',
        ),
        const SizedBox(height: groupGapMd),
        _breakdownLineItem(
          title: AppStrings.lending.totalInterest,
          subtitle:
              '${_loan.interestRate.toStringAsFixed(1)}% $periodLabel · ${_loan.interestType}',
          amount: '$sym${schedule.totalInterest.toStringAsFixed(2)}',
        ),
        const SizedBox(height: groupGapMd),
        _breakdownLineItem(
          title: AppStrings.lending.monthlyEmi,
          subtitle: AppStrings.lending.perInstallment,
          amount: '$sym${schedule.monthlyEmi.toStringAsFixed(2)}',
        ),
        const SizedBox(height: groupGapLg),
        LayoutBuilder(
          builder: (context, constraints) {
            const dashWidth = 6.0;
            const dashSpace = 4.0;
            final dashCount =
                (constraints.maxWidth / (dashWidth + dashSpace)).floor();
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                dashCount,
                (_) => Container(
                  width: dashWidth,
                  height: 1,
                  color: groupMutedBorderStrong,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: groupGapLg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AppStrings.lending.totalPayable,
              style: _totalPayableTextStyle,
            ),
            Flexible(
              child: Text(
                '$sym${schedule.totalPayable.toStringAsFixed(2)}',
                style: _totalPayableTextStyle,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static const TextStyle _totalPayableTextStyle = TextStyle(
    fontFamily: kFontAlbra,
    fontSize: splitrFontHeadline2,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: groupOnSurface,
  );

  Widget _breakdownLineItem({
    required String title,
    required String subtitle,
    required String amount,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: body1_text.copyWith(
                  fontWeight: FontWeight.normal,
                  color: groupOnSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: caption_text.copyWith(color: groupOnSurfaceMuted),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: body1_text.copyWith(
            fontWeight: FontWeight.normal,
            color: groupOnSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildInstallmentRow(
    RepaymentInstallment inst,
    String sym,
    DateFormat dateFormat,
  ) {
    final windowLabel = AppStringFormat.payBetween(
      dateFormat.format(inst.windowStart),
      dateFormat.format(inst.windowEnd),
    );
    final showPay = _canPayInstallment(inst);

    return Padding(
      padding: const EdgeInsets.only(bottom: groupGapSm),
      child: GlassCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(groupGapMd),
        opacity: 0.06,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStringFormat.monthLabel(inst.index),
                    style: body1_text.copyWith(
                      fontWeight: FontWeight.w600,
                      color: groupOnSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    windowLabel,
                    style: caption_text.copyWith(color: groupOnSurfaceMuted),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$sym${inst.amount.toStringAsFixed(2)}',
                    style: body2_text.copyWith(
                      fontWeight: FontWeight.w700,
                      color: groupOnSurface,
                    ),
                  ),
                  if (inst.status == InstallmentStatus.partial &&
                      inst.paidAmount != null)
                    Padding(
                      padding: const EdgeInsets.only(top: groupGapXxs),
                      child: Text(
                        AppStringFormat.paidOfAmount(
                          sym,
                          inst.paidAmount!.toStringAsFixed(2),
                          inst.amount.toStringAsFixed(2),
                        ),
                        style: caption_text.copyWith(color: Colors.orange),
                      ),
                    ),
                  if (inst.status == InstallmentStatus.prepaid &&
                      inst.paidAmount != null)
                    Padding(
                      padding: const EdgeInsets.only(top: groupGapXxs),
                      child: Text(
                        AppStringFormat.paidOfAmount(
                          sym,
                          inst.paidAmount!.toStringAsFixed(2),
                          inst.amount.toStringAsFixed(2),
                        ),
                        style: caption_text.copyWith(color: Colors.teal),
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _statusChip(inst.status),
                if (showPay) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () => _openPaymentSheet(inst),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: neopopBackground,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(horizontal: groupGap14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(groupControlRadiusSm),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppStrings.lending.pay,
                        style: body2_text.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(InstallmentStatus status) {
    final Color color;
    final String label;
    switch (status) {
      case InstallmentStatus.paid:
        color = Colors.green;
        label = AppStrings.lending.paid;
      case InstallmentStatus.prepaid:
        color = Colors.teal;
        label = AppStrings.lending.prepaid;
      case InstallmentStatus.partial:
        color = Colors.orange;
        label = AppStrings.lending.partial;
      case InstallmentStatus.missed:
        color = neopopError;
        label = AppStrings.lending.missed;
      case InstallmentStatus.upcoming:
        color = groupOnSurfaceMuted;
        label = AppStrings.lending.upcoming;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: groupGap10, vertical: groupGapXxs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(groupControlRadiusSm),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: splitrFontCaptionSm,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
