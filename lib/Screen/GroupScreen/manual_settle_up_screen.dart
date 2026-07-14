import 'package:flutter/foundation.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:flutter/material.dart';
import 'package:splitr/Utils/currency_utils.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Controller/group_screen_controller.dart';
import 'package:splitr/Controller/settle_up_controller.dart';
import 'package:splitr/Model/group_model.dart';
import 'package:splitr/Model/user_upi_account_model.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Services/upi_settle_service.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Widgets/bordered_input_field.dart';
import 'package:splitr/Widgets/manual_payee_vpa_sheet.dart';
import 'package:splitr/Widgets/payee_upi_picker_sheet.dart';
import 'package:splitr/Widgets/premium_gate.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';
import 'package:splitr/Widgets/upi_payment_confirm_bar.dart';
import 'package:splitr/Widgets/user_avatar.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Utils/settle_debt_resolver.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

class ManualSettleUpScreen extends StatefulWidget {
  final String groupID;
  final String currentUserID;
  final String groupName;
  final SimplifiedDebt? initialDebt;

  const ManualSettleUpScreen({
    required this.groupID,
    required this.currentUserID,
    required this.groupName,
    this.initialDebt,
    super.key,
  });

  @override
  State<ManualSettleUpScreen> createState() => _ManualSettleUpScreenState();
}

class _ManualSettleUpScreenState extends State<ManualSettleUpScreen>
    with WidgetsBindingObserver {
  final TextEditingController _amountController = TextEditingController();
  late final SettleUpController _controller;

  GroupMembersWithNameModel? _selectedMember;

  bool _awaitingUpiReturn = false;
  bool _confirmPromptVisible = false;
  SimplifiedDebt? _pendingUpiDebt;

  Worker? _prefillWorker;

  bool get _isUpiAvailable =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) &&
      userCurrencyCode() == CurrencyDefaults.code;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final tag = widget.groupID;
    if (Get.isRegistered<SettleUpController>(tag: tag)) {
      _controller = Get.find<SettleUpController>(tag: tag);
    } else {
      _controller = Get.put(
        SettleUpController(
          groupID: widget.groupID,
          userID: widget.currentUserID,
          groupName: widget.groupName,
        ),
        tag: tag,
      );
    }

    final initialDebt = widget.initialDebt;
    if (initialDebt != null) {
      if (_controller.groupMembers.isNotEmpty) {
        _applyInitialDebt(initialDebt);
      } else {
        _prefillWorker = ever(_controller.groupMembers, (_) {
          if (_selectedMember == null && widget.initialDebt != null) {
            _applyInitialDebt(widget.initialDebt!);
          }
        });
      }
    }
  }

  void _applyInitialDebt(SimplifiedDebt debt) {
    final counterpartyId =
        counterpartyIdForDebt(debt, widget.currentUserID);

    GroupMembersWithNameModel? match;
    for (final member in _controller.groupMembers) {
      if (member.userID == counterpartyId &&
          member.userID != widget.currentUserID) {
        match = member;
        break;
      }
    }
    if (match == null) return;

    if (!mounted) return;
    setState(() {
      _selectedMember = match;
      _amountController.text = debt.amount
          .toStringAsFixed(DefaultDecimalPlaces.amount);
    });
  }

  bool get _canUseUpiForSelection {
    final counterpartyId = _selectedMember?.userID;
    if (counterpartyId == null) return false;
    return isCurrentUserDebtor(
      debts: _controller.simplifiedDebts,
      currentUserId: widget.currentUserID,
      counterpartyId: counterpartyId,
    );
  }

  String get _payeeDisplayName =>
      _selectedMember?.userName ?? DisplayFallbacks.friend;

  void _finishSettleUp() {
    SplitrToast.show(AppStringFormat.settlementRecordedToast(_payeeDisplayName));
    if (Get.isRegistered<GroupScreenController>()) {
      Get.find<GroupScreenController>().triggerRefresh();
    }

    void pop() {
      if (context.mounted) {
        Navigator.of(context).pop(true);
      } else {
        Get.back(result: true);
      }
    }

    if (context.mounted) {
      pop();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => pop());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _prefillWorker?.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _awaitingUpiReturn &&
        !_confirmPromptVisible &&
        mounted) {
      setState(() => _confirmPromptVisible = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableMembers = _controller.groupMembers
        .where((m) => m.userID != widget.currentUserID)
        .toList();

    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: surface,
      appBar: SplitrDetailAppBar(
        title: AppStrings.settle.title,
        leading: SplitrDetailAppBar.iosBackLeading(
          context,
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(groupGutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.groups.selectRecipient,
                  style: body1_text.copyWith(color: groupOnSurfaceMuted),
                ),
                const SizedBox(height: groupGapSm),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: groupGutter),
                  decoration: BoxDecoration(
                    color: groupSurfaceFillWhisper,
                    borderRadius: BorderRadius.circular(groupControlRadius),
                    border: Border.all(
                      color: groupMutedBorderHairline,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<GroupMembersWithNameModel>(
                      value: _selectedMember,
                      hint: Text(
                        AppStrings.validation.selectRecipient,
                        style:
                            body1_text.copyWith(color: groupOnSurfaceMuted),
                      ),
                      isExpanded: true,
                      dropdownColor: groupCardFill,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: neopopAccent),
                      items: availableMembers.map((member) {
                        return DropdownMenuItem(
                          value: member,
                          child: Row(
                            children: [
                              UserAvatar(
                                userID: member.userID ?? '',
                                userName: member.userName ??
                                    DisplayFallbacks.unknownUser,
                                imageUrl: member.userPic,
                                radius: groupControlRadius,
                              ),
                              const SizedBox(width: groupGapSm),
                              Text(
                                member.userName ??
                                    DisplayFallbacks.unknownUser,
                                style:
                                    body1_text.copyWith(color: groupOnSurface),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMember = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: groupGapLg),
                Text(
                  AppStrings.groups.enterAmount,
                  style: body1_text.copyWith(color: groupOnSurfaceMuted),
                ),
                const SizedBox(height: groupGapSm),
                BorderedInputField(
                  controller: _amountController,
                  hintText: AppAmountHints.decimalWithSymbol,
                  prefixText: currencyPrefixText(),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: headline1_text.copyWith(color: neopopAccent),
                ),
                const Spacer(),
                if (_isUpiAvailable && _canUseUpiForSelection) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _controller.isSettling.value
                          ? null
                          : () => _handleUpiQuickSettle(),
                      icon: const Icon(Icons.qr_code_2_rounded,
                          color: neopopAccent),
                      label: Text(
                        AppStrings.groups.upiQuickSettlePro,
                        style: button_text.copyWith(color: neopopAccent),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: groupGapMd),
                        side: const BorderSide(color: neopopAccent),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(groupControlRadius),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: groupGapSm),
                  // Razorpay settle-up disabled — UPI deep link; Razorpay used for donate + Pro subscriptions.
                ],
                Obx(() {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _controller.isSettling.value
                          ? null
                          : () => _handleSettleUp(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: neopopAccent,
                        padding:
                            const EdgeInsets.symmetric(vertical: groupGapMd),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(groupControlRadius),
                        ),
                        disabledBackgroundColor: neopopAccentIconMuted,
                      ),
                      child: _controller.isSettling.value
                          ? const SizedBox(
                              height: AppDimensions.loadingIndicatorSm,
                              width: AppDimensions.loadingIndicatorSm,
                              child: CircularProgressIndicator(
                                color: neopopBackground,
                                strokeWidth: groupProgressStrokeWidth,
                              ),
                            )
                          : Text(
                              AppStrings.settle.title,
                              style: button_text.copyWith(
                                color: neopopBackground,
                                fontWeight: FontWeight.w600,
                                fontSize: splitrFontBodyLg,
                              ),
                            ),
                    ),
                  );
                }),
                const SizedBox(height: groupGutter),
              ],
            ),
          ),
          if (_confirmPromptVisible)
            Positioned(
              left: groupGutter,
              right: groupGutter,
              bottom: groupGutter,
              child: Obx(
                () => UpiPaymentConfirmBar(
                  enabled: !_controller.isSettling.value,
                  onYes: _onUpiPaymentConfirmedYes,
                  onNo: _onUpiPaymentConfirmedNo,
                ),
              ),
            ),
        ],
      ),
    );
  }

  SimplifiedDebt? _buildDebtForAmount(double amount) {
    if (_selectedMember == null) return null;

    final counterpartyId = _selectedMember!.userID!;
    final relevantDebt = findDebtForCounterparty(
      debts: _controller.simplifiedDebts,
      currentUserId: widget.currentUserID,
      counterpartyId: counterpartyId,
    );

    if (relevantDebt == null) {
      SplitrToast.show(
        AppStringFormat.dontOwnMoneyTo(
          _selectedMember!.userName ?? DisplayFallbacks.friend,
        ),
      );
      return null;
    }

    if (amount > relevantDebt.amount) {
      SplitrToast.show(
        AppStringFormat.onlyOweAmount(
          userCurrencySymbol(),
          relevantDebt.amount.toStringAsFixed(2),
        ),
      );
      return null;
    }

    return buildSettlementDebt(relevantDebt: relevantDebt, amount: amount);
  }

  Future<void> _handleUpiQuickSettle() async {
    final ok = await requirePremium(
      featureLabel: AppStrings.groups.featureUpiQuickSettle,
    );
    if (!ok) return;

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      SplitrToast.show(AppStrings.validation.enterAmount);
      return;
    }
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      SplitrToast.show(AppStrings.validation.validAmount);
      return;
    }
    if (_selectedMember == null) {
      SplitrToast.show(AppStrings.validation.selectRecipient);
      return;
    }

    final debt = _buildDebtForAmount(amount);
    if (debt == null) return;

    final payeeId = _selectedMember!.userID!;
    List<UserUpiAccount> accounts;
    try {
      accounts = await SupabaseDatabase().listUpiAccounts(payeeId);
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        'Failed to load payee UPI accounts',
        error: e,
        stack: stack,
      );
      return;
    }

    if (accounts.isEmpty) {
      if (!mounted) return;
      final manualVpa = await ManualPayeeVpaSheet.show(
        context,
        payeeName: _selectedMember!.userName ?? DisplayFallbacks.friend,
      );
      if (manualVpa == null) return;
      await _launchUpiPayment(
        vpa: manualVpa,
        amount: amount,
        debt: debt,
      );
      return;
    }

    UserUpiAccount selected;
    if (accounts.length == 1) {
      selected = accounts.first;
    } else {
      if (!mounted) return;
      final picked = await PayeeUpiPickerSheet.show(
        context,
        accounts: accounts,
        payeeName: _selectedMember!.userName ?? DisplayFallbacks.friend,
      );
      if (picked == null) return;
      selected = picked;
    }

    await _launchUpiPayment(
      vpa: selected.vpa,
      amount: amount,
      debt: debt,
    );
  }

  Future<void> _launchUpiPayment({
    required String vpa,
    required double amount,
    required SimplifiedDebt debt,
  }) async {
    final launched = await UpiSettleService.openUpiApp(
      payeeVpa: vpa,
      payeeName: _payeeDisplayName,
      amountInr: amount,
      note: AppStringFormat.upiSettleNote(_payeeDisplayName),
    );
    if (!launched) {
      SplitrToast.show(AppStrings.errors.noUpiApp);
      return;
    }

    setState(() {
      _awaitingUpiReturn = true;
      _confirmPromptVisible = false;
      _pendingUpiDebt = debt;
    });
  }

  void _onUpiPaymentConfirmedNo() {
    setState(() {
      _awaitingUpiReturn = false;
      _confirmPromptVisible = false;
      _pendingUpiDebt = null;
    });
  }

  Future<void> _onUpiPaymentConfirmedYes() async {
    final pending = _pendingUpiDebt;
    if (pending == null) {
      _onUpiPaymentConfirmedNo();
      return;
    }

    setState(() {
      _confirmPromptVisible = false;
      _awaitingUpiReturn = false;
      _pendingUpiDebt = null;
    });

    final success = await _recordSettlement(pending);

    if (success) {
      _finishSettleUp();
    } else if (mounted) {
      SplitrToast.show(AppStrings.groups.failedRecordSettlement);
    }
  }

  Future<void> _handleSettleUp() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      SplitrToast.show(AppStrings.validation.enterAmount);
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      SplitrToast.show(AppStrings.validation.validAmount);
      return;
    }

    if (_selectedMember == null) {
      SplitrToast.show(AppStrings.validation.selectRecipient);
      return;
    }

    final debt = _buildDebtForAmount(amount);
    if (debt == null) return;

    final success = await _recordSettlement(debt);

    if (!mounted) return;
    if (success) {
      _finishSettleUp();
    } else {
      SplitrToast.show(AppStrings.groups.failedRecordSettlement);
    }
  }

  Future<bool> _recordSettlement(SimplifiedDebt debt) async {
    return _controller.recordSettlement(debt);
  }
}
