import 'package:flutter/material.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Model/friend_model.dart';
import 'package:splitr/Model/loan_model.dart';
import 'package:splitr/Repository/friend_repository.dart';
import 'package:splitr/Repository/loan_repository.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Screen/LendingScreen/loan_repayment_schedule_screen.dart';
import 'package:splitr/Services/export_service.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Widgets/premium_gate.dart';
import 'package:splitr/Widgets/bordered_input_field.dart';
import 'package:splitr/Widgets/smart_decimal_text_field.dart';
import 'package:splitr/Widgets/hero_amount_field.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';
import 'package:splitr/Widgets/user_avatar.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

enum LoanFormMode { lend, borrow }

class LoanContractFormScreen extends StatefulWidget {
  final LoanFormMode mode;

  const LoanContractFormScreen({super.key, required this.mode});

  @override
  State<LoanContractFormScreen> createState() => _LoanContractFormScreenState();
}

class _LoanContractFormScreenState extends State<LoanContractFormScreen> {
  final SupabaseDatabase _supabase = SupabaseDatabase();
  FriendRepository get _friendRepo => Get.find<FriendRepository>();
  LoanRepository get _loanRepo => Get.find<LoanRepository>();
  final String _userID = SupabaseAuth().supabaseGetUserID();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  List<FriendModel> _friends = [];
  FriendModel? _selectedFriend;
  bool _isSelectingFriend = true;
  String _interestType = LoanInterestTypes.simple;
  String _interestPeriod = LoanFrequencyValues.monthly;
  final DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  int _duration = 1;
  String _durationUnit = LoanDurationUnits.months;
  int _repaymentStartDay = 1;
  int _repaymentEndDay = 5;
  bool _isLoading = false;

  bool get _isLendMode => widget.mode == LoanFormMode.lend;

  @override
  void initState() {
    super.initState();
    _interestController.text = '5';
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
      await _friendRepo.refreshFromServer(_userID);
      final friends = await _friendRepo.getFriends(_userID);
      if (mounted) {
        setState(() => _friends = friends
            .where((f) => f.status == GroupInviteStatusValues.accepted)
            .toList());
      }
    } catch (e) {
      // Friend picker stays empty on failure.
    }
  }

  void _calculateEndDate() {
    if (_durationController.text.isEmpty) return;
    final d = int.tryParse(_durationController.text) ?? 0;
    if (d <= 0) return;

    setState(() {
      _duration = d;
      if (_durationUnit == LoanDurationUnits.months) {
        _endDate =
            DateTime(_startDate.year, _startDate.month + d, _startDate.day);
      } else if (_durationUnit == LoanDurationUnits.years) {
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
      SplitrToast.show(SplitrToast.join(AppStrings.errors.errorTitle, AppStrings.lending.userNotFoundEmail));
    }
    return user?.userID;
  }

  bool _validateForm() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      SplitrToast.show(SplitrToast.join(AppStrings.errors.errorTitle, AppStrings.validation.validAmount));
      return false;
    }

    if (_repaymentStartDay > _repaymentEndDay) {
      SplitrToast.show(SplitrToast.join(AppStrings.errors.errorTitle, AppStrings.lending.repaymentStartBeforeEnd));
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
      status: GroupInviteStatusValues.pending,
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
      SplitrToast.show(SplitrToast.join(AppStrings.errors.errorTitle, _isSelectingFriend
            ? (_isLendMode
                ? AppStrings.lending.selectValidBorrower
                : AppStrings.lending.selectValidLender)
            : AppStrings.lending.enterValidEmail));
      return;
    }

    final lenderID = _isLendMode ? _userID : counterpartyID;
    final borrowerID = _isLendMode ? counterpartyID : _userID;

    if (lenderID == borrowerID) {
      if (mounted) setState(() => _isLoading = false);
      SplitrToast.show(SplitrToast.join(AppStrings.errors.errorTitle, AppStrings.lending.cannotLoanSelf));
      return;
    }

    try {
      final loan = _buildDraftLoan(
        lenderID: lenderID,
        borrowerID: borrowerID,
      );

      final created = await _loanRepo.createLoan(loan);
      Get.back();
      _showSuccessDialog(created);
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        AppStrings.lending.createLoanFailedPrefix,
        error: e,
        stack: stack,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(LoanModel loan) {
    final canExport = _canPreviewSchedule();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(groupCardRadiusLg)),
        child: Padding(
          padding: const EdgeInsets.all(groupGapLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(groupGutter),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.green, size: 40),
              ),
              const SizedBox(height: groupGapMd),
              Text(
                _isLendMode
                    ? AppStrings.lending.contractSent
                    : AppStrings.lending.requestSent,
                style: headline3_text,
              ),
              const SizedBox(height: groupGapSm),
              Text(
                _isLendMode
                    ? AppStrings.lending.offerSentBorrower
                    : AppStrings.lending.requestSentLender,
                textAlign: TextAlign.center,
                style: body2_text.copyWith(color: groupOnSurfaceMuted),
              ),
              const SizedBox(height: groupGapLg),
              if (canExport) ...[
                SizedBox(
                  width: double.infinity,
                  height: groupCtaHeightCompact,
                  child: OutlinedButton(
                    onPressed: () => _exportContractPdf(loan),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: neopopAccent.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(groupControlRadius),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.lending.exportContractPdf,
                          style: body2_text.copyWith(
                            fontWeight: FontWeight.w600,
                            color: neopopAccent,
                          ),
                        ),
                        const SizedBox(width: groupGapSm),
                        const PremiumLockBadge(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: groupGapSm),
              ],
              SizedBox(
                width: double.infinity,
                height: groupCtaHeightCompact,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neopopBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(groupControlRadius),
                    ),
                  ),
                  child: Text(AppStrings.actions.done,
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportContractPdf(LoanModel loan) async {
    final ok = await requirePremium(
      featureLabel: AppStrings.lending.contractPdf,
    );
    if (!ok) return;

    try {
      await ExportService().exportLoanContractPdf(loan: loan);
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        AppStrings.errors.exportFailed,
        error: e,
        stack: stack,
        context: {'feature': 'export'},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: surface,
      appBar: SplitrDetailAppBar(
        title: _isLendMode
            ? AppStrings.lending.createContract
            : AppStrings.lending.requestLoan,
        centerTitle: true,
        leading: SplitrDetailAppBar.iosBackLeading(
          context,
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(groupGutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAmountSection(),
            const SizedBox(height: groupGapLg),
            _buildCounterpartySection(),
            const SizedBox(height: groupGapXl),
            _buildInterestSection(),
            const SizedBox(height: groupGapXl),
            _buildDurationSection(),
            const SizedBox(height: groupGapXl),
            _buildRepaymentSchedule(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(groupGutter),
        color: groupCardFill,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: _canPreviewSchedule() && !_isLoading
                    ? _openPreviewSchedule
                    : null,
                child: Text(
                  AppStrings.lending.previewRepaymentSchedule,
                  style: body1_text.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _canPreviewSchedule()
                        ? neopopBackground
                        : groupOnSurfaceMuted,
                  ),
                ),
              ),
              const SizedBox(height: groupGapSm),
              SizedBox(
                width: double.infinity,
                height: groupCtaHeight,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neopopBackground,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(groupControlRadius),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: groupProgressIndicatorSize,
                          height: groupProgressIndicatorSize,
                          child: CircularProgressIndicator(
                            strokeWidth: groupProgressStrokeWidth,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isLendMode
                              ? AppStrings.lending.sendOffer
                              : AppStrings.lending.sendRequest,
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
    return HeroAmountField(
      label: _isLendMode
          ? AppStrings.lending.wantToLend
          : AppStrings.lending.wantToBorrow,
      controller: _amountController,
      onChanged: (_) => setState(() {}),
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
      fillColor: groupMutedFillFaint,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: groupGapMd,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(groupControlRadius),
        borderSide: BorderSide(
          color: groupMutedBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(groupControlRadius),
        borderSide: BorderSide(
          color: groupMutedBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(groupControlRadius),
        borderSide: const BorderSide(color: neopopAccent, width: 1.5),
      ),
    );
  }

  Widget _buildCounterpartySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              _isLendMode ? AppStrings.home.to : AppStrings.home.from,
              style: caption_text.copyWith(color: groupOnSurfaceMuted),
            ),
            const Spacer(),
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  height: 28,
                  padding: const EdgeInsets.all(groupGap2),
                  decoration: BoxDecoration(
                    color: groupChipTrackBg,
                    borderRadius: BorderRadius.circular(groupControlRadiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildToggleOption(DisplayFallbacks.friend, true),
                      _buildToggleOption(AppStrings.lending.emailTab, false),
                    ],
                  ),
                ),
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
                          userName:
                              friend.friendName ?? DisplayFallbacks.unknownUser,
                          imageUrl: friend.friendPic,
                          radius: 12,
                        ),
                        const SizedBox(width: groupGapSm),
                        Expanded(
                          child: Text(
                            friend.friendName ?? DisplayFallbacks.unknownUser,
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
            decoration: _counterpartyFieldDecoration(
              hintText: AppStrings.lending.selectFriend,
            ),
            dropdownColor: groupCardFill,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: groupOnSurface,
            ),
          )
        else
          BorderedInputField(
            controller: _emailController,
            hintText: AppStrings.lending.enterEmailAddress,
            prefixIcon: const Icon(
              Icons.alternate_email,
              color: groupOnSurfaceMuted,
              size: 20,
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
        padding: const EdgeInsets.symmetric(
            horizontal: groupGap10, vertical: groupGapXxs),
        decoration: BoxDecoration(
          color: isSelected ? groupCardFill : groupTransparent,
          borderRadius: BorderRadius.circular(groupRadiusMdSm),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: groupSurfaceFillFaint,
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
            fontSize: splitrFontCaption,
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
          AppStringFormat.interestRateWithPeriod(
            _interestPeriod == LoanFrequencyValues.yearly
                ? AppStrings.lending.yearly
                : AppStrings.premium.monthly,
          ),
          style: body2_text.copyWith(color: groupOnSurfaceMuted),
        ),
        const SizedBox(height: groupGapSm),
        SmartDecimalTextField(
          controller: _interestController,
          maxDecimalPlaces: 2,
          style: body1_text.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: splitrFontSubhead,
            color: groupOnSurface,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: groupMutedFillFaint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(groupControlRadius),
              borderSide: BorderSide.none,
            ),
            suffixText: AppDisplaySymbols.percent,
            suffixStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: groupOnSurface,
            ),
          ),
        ),
        const SizedBox(height: groupGapSm),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _interestPeriod,
                items: [
                  DropdownMenuItem(
                      value: LoanFrequencyValues.monthly,
                      child: Text(AppStrings.premium.monthly)),
                  DropdownMenuItem(
                    value: LoanFrequencyValues.yearly,
                    child: Text(AppStrings.lending.yearly),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _interestPeriod = val);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: groupMutedFillFaint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(groupControlRadius),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: groupCardFill,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: groupOnSurface),
              ),
            ),
            const SizedBox(width: groupGapSm),
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _interestType,
                items: [
                  DropdownMenuItem(
                    value: LoanInterestTypes.simple,
                    child: Text(AppStrings.lending.simple),
                  ),
                  DropdownMenuItem(
                    value: LoanInterestTypes.compound,
                    child: Text(
                      AppStrings.lending.compound,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DropdownMenuItem(
                    value: LoanInterestTypes.flat,
                    child: Text(AppStrings.lending.flat),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _interestType = val);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: groupMutedFillFaint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(groupControlRadius),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: groupCardFill,
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
        Text(AppStrings.lending.duration,
            style: body2_text.copyWith(color: groupOnSurfaceMuted)),
        const SizedBox(height: groupGapSm),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: BorderedInputField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculateEndDate(),
                style: body1_text.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: splitrFontSubhead,
                  color: groupOnSurface,
                ),
              ),
            ),
            const SizedBox(width: groupGapSm),
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _durationUnit,
                items: [
                  LoanDurationUnits.months,
                  LoanDurationUnits.days,
                  LoanDurationUnits.years
                ]
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
                  fillColor: groupMutedFillFaint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(groupControlRadius),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: groupCardFill,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: groupOnSurface),
              ),
            ),
          ],
        ),
        if (_endDate != null) ...[
          const SizedBox(height: groupGapSm),
          Text(
            AppStringFormat.endsOn(
              DateFormat(AppDateFormats.shortDayYear).format(_endDate!),
            ),
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
          AppStrings.lending.monthlyRepaymentWindow,
          style: body2_text.copyWith(color: groupOnSurfaceMuted),
        ),
        const SizedBox(height: 4),
        Text(
          AppStrings.lending.borrowerPayBetween,
          style: caption_text.copyWith(color: groupOnSurfaceMuted),
        ),
        const SizedBox(height: groupGapSm),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.lending.fromDay,
                    style: caption_text.copyWith(color: groupOnSurfaceMuted),
                  ),
                  const SizedBox(height: groupGapSm),
                  DropdownButtonFormField<int>(
                    isExpanded: true,
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
                      fillColor: groupMutedFillFaint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(groupControlRadius),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    dropdownColor: groupCardFill,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: groupOnSurface),
                  ),
                ],
              ),
            ),
            const SizedBox(width: groupGapSm),
            Text(
              AppStrings.lending.toConnector,
              style: caption_text.copyWith(
                color: groupOnSurfaceMuted,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: groupGapSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.lending.toDay,
                    style: caption_text.copyWith(color: groupOnSurfaceMuted),
                  ),
                  const SizedBox(height: groupGapSm),
                  DropdownButtonFormField<int>(
                    isExpanded: true,
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
                      fillColor: groupMutedFillFaint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(groupControlRadius),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    dropdownColor: groupCardFill,
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
