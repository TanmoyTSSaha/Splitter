import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Controllers/currency_controller.dart';
import 'package:splitter/Model/friend_model.dart';
import 'package:splitter/Model/loan_model.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitter/Screen/LendingScreen/loan_repayment_schedule_screen.dart';
import 'package:splitter/Services/supabase_service.dart';
import 'package:splitter/Widgets/smart_decimal_text_field.dart';
import 'package:splitter/Widgets/user_avatar.dart';

enum LoanFormMode { lend, borrow }

class LoanContractFormScreen extends StatefulWidget {
  final LoanFormMode mode;

  const LoanContractFormScreen({super.key, required this.mode});

  @override
  State<LoanContractFormScreen> createState() => _LoanContractFormScreenState();
}

class _LoanContractFormScreenState extends State<LoanContractFormScreen> {
  final SupabaseDatabase _supabase = SupabaseDatabase();
  final String _userID = SupabaseAuth().supabaseGetUserID();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  List<FriendModel> _friends = [];
  FriendModel? _selectedFriend;
  bool _isSelectingFriend = true;
  String _interestType = 'simple';
  String _interestPeriod = 'monthly';
  final DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  int _duration = 1;
  String _durationUnit = 'months';
  int _repaymentStartDay = 1;
  int _repaymentEndDay = 5;
  bool _isLoading = false;

  bool get _isLendMode => widget.mode == LoanFormMode.lend;

  @override
  void initState() {
    super.initState();
    _interestController.text = '5.0';
    _durationController.text = '1';
    _calculateEndDate();
    _fetchFriends();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _interestController.dispose();
    _durationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _fetchFriends() async {
    try {
      final friends = await _supabase.getFriends(userID: _userID);
      if (mounted) setState(() => _friends = friends);
    } catch (e) {
      debugPrint('Error fetching friends: $e');
    }
  }

  void _calculateEndDate() {
    if (_durationController.text.isEmpty) return;
    final d = int.tryParse(_durationController.text) ?? 0;
    if (d <= 0) return;

    setState(() {
      _duration = d;
      if (_durationUnit == 'months') {
        _endDate =
            DateTime(_startDate.year, _startDate.month + d, _startDate.day);
      } else if (_durationUnit == 'years') {
        _endDate =
            DateTime(_startDate.year + d, _startDate.month, _startDate.day);
      } else {
        _endDate = _startDate.add(Duration(days: d));
      }
    });
  }

  Future<String?> _resolveCounterpartyID() async {
    if (_isSelectingFriend) {
      return _selectedFriend?.friendUserID;
    }

    final email = _emailController.text.trim();
    if (email.isEmpty) return null;

    final user = await _supabase.getUserByEmail(email);
    if (user?.userID == null) {
      Get.snackbar(
        'Error',
        'User not found with this email',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
    return user?.userID;
  }

  bool _validateForm() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }

    if (_repaymentStartDay > _repaymentEndDay) {
      Get.snackbar(
        'Error',
        'Repayment start day must be on or before end day',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  bool _canPreviewSchedule() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return false;
    if (_repaymentStartDay > _repaymentEndDay) return false;
    if (_duration <= 0 || _endDate == null) return false;
    return true;
  }

  LoanModel _buildDraftLoan({String? lenderID, String? borrowerID}) {
    return LoanModel(
      lenderID: lenderID ?? _userID,
      borrowerID: borrowerID ?? _userID,
      createdBy: _userID,
      principalAmount: double.parse(_amountController.text),
      interestRate: double.tryParse(_interestController.text) ?? 5.0,
      interestType: _interestType,
      interestPeriod: _interestPeriod,
      startDate: _startDate,
      dueDate: _endDate,
      repaymentEndDate: _endDate,
      repaymentStartDate: _startDate,
      duration: _duration,
      durationUnit: _durationUnit,
      repaymentStartDay: _repaymentStartDay,
      repaymentEndDay: _repaymentEndDay,
      status: 'pending',
      currency: Get.find<CurrencyController>().code,
    );
  }

  void _openPreviewSchedule() {
    if (!_validateForm()) return;
    Get.to(() => LoanRepaymentScheduleScreen(loan: _buildDraftLoan()));
  }

  Future<void> _submit() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);
    final counterpartyID = await _resolveCounterpartyID();

    if (counterpartyID == null) {
      if (mounted) setState(() => _isLoading = false);
      Get.snackbar(
        'Error',
        _isSelectingFriend
            ? 'Please select a valid ${_isLendMode ? 'borrower' : 'lender'}'
            : 'Please enter a valid email',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final lenderID = _isLendMode ? _userID : counterpartyID;
    final borrowerID = _isLendMode ? counterpartyID : _userID;

    if (lenderID == borrowerID) {
      if (mounted) setState(() => _isLoading = false);
      Get.snackbar(
        'Error',
        'You cannot create a loan with yourself',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final loan = _buildDraftLoan(
        lenderID: lenderID,
        borrowerID: borrowerID,
      );

      await _supabase.createLoan(loan);
      Get.back();
      _showSuccessDialog();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create loan: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.green, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                _isLendMode ? 'Contract Sent!' : 'Request Sent!',
                style: headline3_text,
              ),
              const SizedBox(height: 8),
              Text(
                _isLendMode
                    ? 'Your loan offer has been sent to the borrower for approval.'
                    : 'Your borrow request has been sent to the lender for approval.',
                textAlign: TextAlign.center,
                style: body2_text.copyWith(color: groupOnSurfaceMuted),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neopopBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      const Text('Done', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: groupOnSurface),
          onPressed: () => Get.back(),
        ),
        title: Text(
          _isLendMode ? 'Create Contract' : 'Request Loan',
          style: sub_headline5_text.copyWith(color: groupOnSurface),
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(groupGutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAmountSection(),
            const SizedBox(height: groupGapLg),
            _buildCounterpartySection(),
            const SizedBox(height: 32),
            _buildInterestSection(),
            const SizedBox(height: 32),
            _buildDurationSection(),
            const SizedBox(height: 32),
            _buildRepaymentSchedule(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(groupGutter),
        color: Colors.white,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: _canPreviewSchedule() && !_isLoading
                    ? _openPreviewSchedule
                    : null,
                child: Text(
                  'Preview repayment schedule',
                  style: body1_text.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _canPreviewSchedule()
                        ? neopopBackground
                        : groupOnSurfaceMuted,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neopopBackground,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isLendMode ? 'SEND OFFER' : 'SEND REQUEST',
                          style: body1_text.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isLendMode ? 'I want to lend' : 'I want to borrow',
          style: caption_text.copyWith(color: groupOnSurfaceMuted),
        ),
        const SizedBox(height: groupGapSm),
        Obx(() {
          final sym = Get.find<CurrencyController>().symbol;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                sym,
                style: const TextStyle(
                  fontFamily: 'Albra',
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: groupOnSurface,
                ),
              ),
              const SizedBox(width: groupGapSm),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                    fontFamily: 'Albra',
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: groupOnSurface,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    filled: false,
                    hintText: '0',
                    hintStyle: TextStyle(
                      fontFamily: 'Albra',
                      fontSize: 48,
                      color: groupOnSurfaceMuted.withValues(alpha: 0.5),
                    ),
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    isCollapsed: true,
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  InputDecoration _counterpartyFieldDecoration({
    String? hintText,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: body1_text.copyWith(color: groupOnSurfaceMuted),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: neopopSecondaryGrey.withValues(alpha: 0.08),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: groupGapMd,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: groupOnSurfaceMuted.withValues(alpha: 0.2),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: groupOnSurfaceMuted.withValues(alpha: 0.2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: neopopAccent, width: 1.5),
      ),
    );
  }

  Widget _buildCounterpartySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _isLendMode ? 'To' : 'From',
              style: caption_text.copyWith(color: groupOnSurfaceMuted),
            ),
            const Spacer(),
            Container(
              height: 28,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: neopopSecondaryGrey.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleOption('Friend', true),
                  _buildToggleOption('Email', false),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: groupGapMd),
        if (_isSelectingFriend)
          DropdownButtonFormField<FriendModel>(
            isExpanded: true,
            initialValue: _selectedFriend,
            items: _friends
                .map(
                  (friend) => DropdownMenuItem(
                    value: friend,
                    child: Row(
                      children: [
                        UserAvatar(
                          userID: friend.friendUserID ?? '',
                          userName: friend.friendName ?? 'Unknown',
                          imageUrl: friend.friendPic,
                          radius: 12,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            friend.friendName ?? 'Unknown',
                            style: body1_text.copyWith(color: groupOnSurface),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) => setState(() => _selectedFriend = val),
            decoration: _counterpartyFieldDecoration(hintText: 'Select Friend'),
            dropdownColor: Colors.white,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: groupOnSurface,
            ),
          )
        else
          TextField(
            controller: _emailController,
            style: body1_text.copyWith(color: groupOnSurface),
            decoration: _counterpartyFieldDecoration(
              hintText: 'Enter email address',
              prefixIcon: Icon(
                Icons.alternate_email,
                color: groupOnSurfaceMuted,
                size: 20,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildToggleOption(String label, bool isFriend) {
    final isSelected = _isSelectingFriend == isFriend;
    return GestureDetector(
      onTap: () => setState(() => _isSelectingFriend = isFriend),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: groupOnSurface.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: caption_text.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? groupOnSurface : groupOnSurfaceMuted,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildInterestSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interest Rate (${_interestPeriod == 'yearly' ? 'Yearly' : 'Monthly'})',
          style: body2_text.copyWith(color: groupOnSurfaceMuted),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: SmartDecimalTextField(
                controller: _interestController,
                maxDecimalPlaces: 2,
                style: body1_text.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: groupOnSurface,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: neopopSecondaryGrey.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixText: '%',
                  suffixStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: groupOnSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _interestPeriod,
                items: const [
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _interestPeriod = val);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: neopopSecondaryGrey.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: Colors.white,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: groupOnSurface),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _interestType,
                items: const [
                  DropdownMenuItem(value: 'simple', child: Text('Simple')),
                  DropdownMenuItem(value: 'compound', child: Text('Compound')),
                  DropdownMenuItem(value: 'flat', child: Text('Flat')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _interestType = val);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: neopopSecondaryGrey.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: Colors.white,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: groupOnSurface),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Duration',
            style: body2_text.copyWith(color: groupOnSurfaceMuted)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                style: body1_text.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: groupOnSurface,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: neopopSecondaryGrey.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) => _calculateEndDate(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<String>(
                initialValue: _durationUnit,
                items: ['months', 'days', 'years']
                    .map(
                      (unit) => DropdownMenuItem(
                        value: unit,
                        child: Text(
                          unit,
                          style: body1_text.copyWith(color: groupOnSurface),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _durationUnit = val;
                      _calculateEndDate();
                    });
                  }
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: neopopSecondaryGrey.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: Colors.white,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: groupOnSurface),
              ),
            ),
          ],
        ),
        if (_endDate != null) ...[
          const SizedBox(height: 8),
          Text(
            'Ends on ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
            style: caption_text.copyWith(color: groupOnSurfaceMuted),
          ),
        ],
      ],
    );
  }

  Widget _buildRepaymentSchedule() {
    final days = List.generate(31, (index) => index + 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Repayment Window',
          style: body2_text.copyWith(color: groupOnSurfaceMuted),
        ),
        const SizedBox(height: 4),
        Text(
          'Borrower should pay between these days each month:',
          style: caption_text.copyWith(color: groupOnSurfaceMuted),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From Day',
                    style: caption_text.copyWith(color: groupOnSurfaceMuted),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: _repaymentStartDay,
                    items: days
                        .map(
                          (day) => DropdownMenuItem(
                            value: day,
                            child: Text(
                              day.toString(),
                              style: body1_text.copyWith(color: groupOnSurface),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _repaymentStartDay = val);
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: neopopSecondaryGrey.withValues(alpha: 0.08),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    dropdownColor: Colors.white,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: groupOnSurface),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'to',
              style: TextStyle(
                color: groupOnSurfaceMuted,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'To Day',
                    style: caption_text.copyWith(color: groupOnSurfaceMuted),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: _repaymentEndDay,
                    items: days
                        .map(
                          (day) => DropdownMenuItem(
                            value: day,
                            child: Text(
                              day.toString(),
                              style: body1_text.copyWith(color: groupOnSurface),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _repaymentEndDay = val);
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: neopopSecondaryGrey.withValues(alpha: 0.08),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    dropdownColor: Colors.white,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: groupOnSurface),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
