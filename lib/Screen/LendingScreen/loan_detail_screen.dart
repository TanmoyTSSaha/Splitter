import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/glass_card.dart';
import 'package:splitter/Controllers/currency_controller.dart';
import 'package:splitter/Model/loan_model.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitter/Screen/LendingScreen/loan_repayment_schedule_screen.dart';
import 'package:splitter/Services/supabase_service.dart';
import 'package:splitter/Widgets/user_avatar.dart';

class LoanDetailScreen extends StatefulWidget {
  final LoanModel loan;

  const LoanDetailScreen({super.key, required this.loan});

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen> {
  final SupabaseDatabase _supabase = SupabaseDatabase();
  final String _userID = SupabaseAuth().supabaseGetUserID();
  final TextEditingController _paymentController = TextEditingController();

  late LoanModel _loan;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loan = widget.loan;
  }

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }

  bool get _isLender => _loan.lenderID == _userID;
  bool get _isActive => _loan.status == 'active';
  bool get _isPending => _loan.status == 'pending';

  bool get _canViewSchedule =>
      _loan.duration != null &&
      _loan.dueDate != null &&
      _loan.repaymentStartDay != null &&
      _loan.repaymentEndDay != null;

  String get _counterpartyName => _isLender
      ? (_loan.borrowerName ?? 'Borrower')
      : (_loan.lenderName ?? 'Lender');

  String get _counterpartyAvatar =>
      _isLender ? (_loan.borrowerAvatar ?? '') : (_loan.lenderAvatar ?? '');

  String get _counterpartyId =>
      _isLender ? _loan.borrowerID : _loan.lenderID;

  Future<void> _recordPayment() async {
    final payment = double.tryParse(_paymentController.text);
    if (payment == null || payment <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid payment amount',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (payment > _loan.currentAmountOwed) {
      Get.snackbar(
        'Error',
        'Payment exceeds remaining balance',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _supabase.recordLoanPayment(
        loanID: _loan.id!,
        paymentAmount: payment,
      );
      final updated = await _supabase.getLoanById(_loan.id!);
      if (updated != null && mounted) {
        setState(() {
          _loan = updated;
          _paymentController.clear();
        });
      }
      Get.snackbar(
        'Success',
        'Payment recorded',
        backgroundColor: neopopBackground,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
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
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: groupOnSurface),
            onPressed: () => Get.back(result: true),
          ),
          title: Text(
            'Contract Details',
            style: sub_headline5_text.copyWith(color: groupOnSurface),
          ),
          centerTitle: true,
          scrolledUnderElevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(groupGutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: groupGapMd),
              _buildDetailsCard(),
              if (_isPending) ...[
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
      ),
    );
  }

  Widget _buildHeaderCard() {
    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(groupGapLg),
      opacity: 0.1,
      child: Column(
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
                      _isLender ? 'Borrower' : 'Lender',
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
                      'Remaining',
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
                      'Principal',
                      style: caption_text.copyWith(color: groupOnSurfaceMuted),
                    ),
                    Text(
                      '$sym${_loan.principalAmount.toStringAsFixed(0)}',
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
          const SizedBox(height: groupGapMd),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _loan.repaymentProgress,
              backgroundColor: neopopSecondaryGrey.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(neopopAccent),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final badgeColor = _loan.status == 'active'
        ? neopopAccent
        : (_loan.status == 'pending' ? Colors.orangeAccent : Colors.grey);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor),
      ),
      child: Text(
        _loan.status.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(groupGapLg),
      opacity: 0.08,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Terms',
            style: body1_text.copyWith(
              fontWeight: FontWeight.bold,
              color: groupOnSurface,
            ),
          ),
          const SizedBox(height: groupGapMd),
          _detailRow(
            'Interest rate',
            '${_loan.interestRate.toStringAsFixed(1)}% monthly (${_loan.interestType})',
          ),
          if (_loan.duration != null && _loan.durationUnit != null)
            _detailRow('Duration', '${_loan.duration} ${_loan.durationUnit}'),
          if (_loan.dueDate != null)
            _detailRow(
              'Due date',
              DateFormat('MMM d, yyyy').format(_loan.dueDate!),
            ),
          if (_loan.repaymentStartDay != null && _loan.repaymentEndDay != null)
            _detailRow(
              'Repayment window',
              'Day ${_loan.repaymentStartDay} – ${_loan.repaymentEndDay} each month',
            ),
          if (_canViewSchedule) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Get.to(
                  () => LoanRepaymentScheduleScreen(loan: _loan),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View repayment schedule',
                  style: body2_text.copyWith(
                    fontWeight: FontWeight.w600,
                    color: neopopBackground,
                  ),
                ),
              ),
            ),
          ],
          Obx(() {
            final sym = Get.find<CurrencyController>().symbol;
            return _detailRow(
              'Total repaid',
              '$sym${_loan.repaymentAmount.toStringAsFixed(0)}',
            );
          }),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
        color: neopopAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: neopopAccent.withValues(alpha: 0.25)),
      ),
      child: Text(
        initiatedByMe
            ? 'Awaiting the other party\'s response.'
            : 'Accept or decline this offer in Notifications.',
        style: body2_text.copyWith(color: groupOnSurface),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(groupGapLg),
      opacity: 0.08,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Record Payment',
            style: body1_text.copyWith(
              fontWeight: FontWeight.bold,
              color: groupOnSurface,
            ),
          ),
          const SizedBox(height: groupGapSm),
          Text(
            'Either party can log a repayment.',
            style: caption_text.copyWith(color: groupOnSurfaceMuted),
          ),
          const SizedBox(height: groupGapMd),
          Obx(() {
            final sym = Get.find<CurrencyController>().symbol;
            return TextField(
              controller: _paymentController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: body1_text.copyWith(color: groupOnSurface),
              decoration: InputDecoration(
                prefixText: '$sym ',
                prefixStyle: body1_text.copyWith(
                  fontWeight: FontWeight.bold,
                  color: groupOnSurface,
                ),
                filled: true,
                fillColor: neopopSecondaryGrey.withValues(alpha: 0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintText: '0',
                hintStyle: body1_text.copyWith(color: groupOnSurfaceMuted),
              ),
            );
          }),
          const SizedBox(height: groupGapMd),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _recordPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: neopopAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.black, width: 2),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: groupOnSurface)
                  : Text(
                      'RECORD PAYMENT',
                      style: body1_text.copyWith(
                        fontWeight: FontWeight.w900,
                        color: groupOnSurface,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
