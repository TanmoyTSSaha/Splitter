import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/glass_card.dart';
import 'package:splitter/Controllers/currency_controller.dart';
import 'package:splitter/Model/loan_model.dart';
import 'package:splitter/Model/repayment_schedule.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';

class LoanRepaymentScheduleScreen extends StatelessWidget {
  final LoanModel loan;

  const LoanRepaymentScheduleScreen({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    final schedule = LoanScheduleCalculator.build(loan);
    final sym = Get.find<CurrencyController>().symbol;
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: groupOnSurface),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Repayment Schedule',
          style: sub_headline5_text.copyWith(color: groupOnSurface),
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: schedule.monthCount == 0 || schedule.installments.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.all(groupGutter),
              children: [
                _buildSummaryCard(schedule, sym),
                const SizedBox(height: groupGapXl+groupGapSm),
                Text(
                  'Monthly installments',
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
          'Unable to build a repayment schedule. Check duration and due date.',
          textAlign: TextAlign.center,
          style: body2_text.copyWith(color: groupOnSurfaceMuted),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(RepaymentSchedule schedule, String sym) {
    final periodLabel =
        loan.interestPeriod == 'yearly' ? 'yearly' : 'monthly';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REPAYMENT BREAKDOWN',
          style: caption_text.copyWith(
            color: groupOnSurfaceMuted,
            letterSpacing: 1.2,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: groupGapLg),
        _breakdownLineItem(
          title: 'Principal',
          subtitle: 'Loan amount',
          amount: '$sym${schedule.principal.toStringAsFixed(2)}',
        ),
        const SizedBox(height: groupGapMd),
        _breakdownLineItem(
          title: 'Total interest',
          subtitle:
              '${loan.interestRate.toStringAsFixed(1)}% $periodLabel · ${loan.interestType}',
          amount: '$sym${schedule.totalInterest.toStringAsFixed(2)}',
        ),
        const SizedBox(height: groupGapMd),
        _breakdownLineItem(
          title: 'Monthly EMI',
          subtitle: 'Per installment',
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
                  color: groupOnSurfaceMuted.withValues(alpha: 0.35),
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
            const Text(
              'Total payable',
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
    fontFamily: 'Albra',
    fontSize: 28,
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
    final windowLabel =
        'Pay between ${dateFormat.format(inst.windowStart)} – ${dateFormat.format(inst.windowEnd)}';

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
                    'Month ${inst.index}',
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
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '$sym${inst.paidAmount!.toStringAsFixed(2)} paid of $sym${inst.amount.toStringAsFixed(2)}',
                        style: caption_text.copyWith(color: Colors.orange),
                      ),
                    ),
                ],
              ),
            ),
            _statusChip(inst.status),
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
        label = 'Paid';
      case InstallmentStatus.partial:
        color = Colors.orange;
        label = 'Partial';
      case InstallmentStatus.missed:
        color = Colors.redAccent;
        label = 'Missed';
      case InstallmentStatus.upcoming:
        color = groupOnSurfaceMuted;
        label = 'Upcoming';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
