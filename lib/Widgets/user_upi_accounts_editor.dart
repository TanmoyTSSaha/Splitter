import 'package:flutter/material.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Model/master_upi_bank_model.dart';
import 'package:splitr/Model/user_upi_account_model.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/Utils/upi_bank_dropdown_utils.dart';
import 'package:splitr/Utils/upi_vpa_utils.dart';
import 'package:splitr/Widgets/bordered_input_field.dart';
import 'package:splitr/Widgets/app_bottom_sheet.dart';
import 'package:splitr/Widgets/splitr_inline_error.dart';
import 'package:splitr/Constants/app_strings.dart';

/// Profile section for managing multiple UPI VPAs with bank aliases.
class UserUpiAccountsEditor extends StatefulWidget {
  final String userId;

  const UserUpiAccountsEditor({super.key, required this.userId});

  @override
  State<UserUpiAccountsEditor> createState() => _UserUpiAccountsEditorState();
}

class _UserUpiAccountsEditorState extends State<UserUpiAccountsEditor> {
  final _db = SupabaseDatabase();
  List<UserUpiAccount> _accounts = [];
  List<MasterUpiBank> _masterBanks = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _loadMasterBanks() async {
    final banks = await _db.listMasterUpiBanks();
    _masterBanks = dedupeMasterUpiBanks(banks);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _loadMasterBanks();
      final list = await _db.listUpiAccounts(widget.userId);
      if (!mounted) return;
      setState(() {
        _accounts = list;
        _loading = false;
      });
    } catch (e, stack) {
      if (!mounted) return;
      AppErrorReporter.unexpected(
        'UserUpiAccountsEditor._load failed',
        error: e,
        stack: stack,
        context: {'feature': 'profile', 'operation': 'loadUpiAccounts'},
      );
      setState(() {
        _error = AppStrings.errors.loadHumorous;
        _loading = false;
      });
    }
  }

  Future<void> _showEditor({UserUpiAccount? existing}) async {
    if (existing == null &&
        _accounts.length >= UpiAccountRules.maxPerUser) {
      _snack(AppStrings.profile.maxUpiAccountsReached, isError: true);
      return;
    }

    List<MasterUpiBank> sheetBanks = List<MasterUpiBank>.from(_masterBanks);
    var banksLoading = sheetBanks.isEmpty;
    var banksError = false;

    if (sheetBanks.isEmpty) {
      try {
        sheetBanks = dedupeMasterUpiBanks(await _db.listMasterUpiBanks());
        banksLoading = false;
      } catch (_) {
        banksLoading = false;
        banksError = true;
      }
    }

    final vpaCtrl = TextEditingController(text: existing?.vpa ?? '');
    String selectedSlug = resolveUpiBankDropdownSlug(
      bankAlias: existing?.bankAlias,
      banks: sheetBanks,
    );
    final customBankCtrl = TextEditingController(
      text: existing != null && isOtherBankSlug(selectedSlug)
          ? existing.bankAlias
          : '',
    );

    await showAppThemedBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: groupGutter,
            right: groupGutter,
            top: groupGapLg,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + groupGapLg,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              final showCustom = isOtherBankSlug(selectedSlug);
              final dropdownItems = <DropdownMenuItem<String>>[
                for (final bank in sheetBanks)
                  DropdownMenuItem(
                    value: bank.bankSlug,
                    child: Text(
                      bank.bankName,
                      style: body1_text.copyWith(color: groupOnSurface),
                    ),
                  ),
                DropdownMenuItem(
                  value: UpiBankDropdownSentinel.other,
                  child: Text(
                    upiBankOtherLabel,
                    style: body1_text.copyWith(color: groupOnSurface),
                  ),
                ),
              ];

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existing == null
                        ? AppStrings.profile.addUpiAccount
                        : AppStrings.profile.editUpiAccount,
                    style: sub_headline5_text.copyWith(color: groupOnSurface),
                  ),
                  const SizedBox(height: groupGapMd),
                  Text(
                    AppStrings.profile.bankLabel,
                    style: caption_text.copyWith(color: groupOnSurfaceMuted),
                  ),
                  const SizedBox(height: groupGapSm),
                  if (banksLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: groupGapMd),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else if (banksError)
                    Text(
                      AppStrings.errors.loadBalancesPullToRetry,
                      style: body2_text.copyWith(color: neopopAlert),
                    )
                  else
                    ThemedDropdownField<String>(
                      value: dropdownItems
                              .any((item) => item.value == selectedSlug)
                          ? selectedSlug
                          : UpiBankDropdownSentinel.other,
                      items: dropdownItems,
                      onChanged: (v) {
                        if (v == null) return;
                        setSheetState(() => selectedSlug = v);
                      },
                    ),
                  if (showCustom) ...[
                    const SizedBox(height: groupGapMd),
                    BorderedInputField(
                      controller: customBankCtrl,
                      hintText: AppStrings.profile.customBankHint,
                      labelText: AppStrings.upi.otherBank,
                    ),
                  ],
                  const SizedBox(height: groupGapMd),
                  BorderedInputField(
                    controller: vpaCtrl,
                    hintText: AppStrings.groups.nameUpiHint,
                    labelText: AppStrings.profile.vpaLabel,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: groupGapLg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: banksLoading
                          ? null
                          : () async {
                              final vpa = UpiVpaUtils.validateAndNormalize(
                                  vpaCtrl.text);
                              if (vpa == null) {
                                _snack(AppStrings.profile.invalidVpa,
                                    isError: true);
                                return;
                              }
                              final alias = bankAliasForSlug(
                                selectedSlug: selectedSlug,
                                banks: sheetBanks,
                                customBankName: customBankCtrl.text,
                              );
                              if (alias.length <
                                  UpiAccountRules.minCustomBankAliasLength) {
                                _snack(AppStrings.validation.required,
                                    isError: true);
                                return;
                              }
                              try {
                                await _db.upsertUpiAccount(
                                  userId: widget.userId,
                                  vpa: vpa,
                                  bankAlias: alias,
                                  existingId: existing?.id,
                                );
                                if (!ctx.mounted) return;
                                Navigator.pop(ctx);
                                await _load();
                                _snack(existing == null
                                    ? AppStrings.profile.upiAccountAdded
                                    : AppStrings.profile.upiAccountUpdated);
                              } catch (e, stack) {
                                final raw = e.toString();
                                if (raw.contains(UpiAccountErrors.duplicateVpa) ||
                                    raw.contains('23505')) {
                                  _snack(AppStrings.profile.duplicateVpa,
                                      isError: true);
                                  return;
                                }
                                if (raw.contains('Maximum')) {
                                  _snack(AppStrings.profile.maxUpiAccountsReached,
                                      isError: true);
                                  return;
                                }
                                AppErrorReporter.reportActionFailure(
                                  AppStrings.profile.profileUpdateFailedPrefix,
                                  error: e,
                                  stack: stack,
                                  context: {
                                    'feature': 'profile',
                                    'operation': 'upsertUpiAccount',
                                  },
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: neopopAccent,
                        padding: const EdgeInsets.symmetric(
                            vertical: groupGapMd),
                      ),
                      child: Text(
                        AppStrings.actions.save,
                        style: button_text.copyWith(color: neopopBackground),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _delete(UserUpiAccount account) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.profile.deleteUpiAccountTitle),
        content: Text(AppStrings.profile.deleteUpiAccountBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.actions.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.actions.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await _db.deleteUpiAccount(
        userId: widget.userId,
        accountId: account.id,
      );
      await _load();
      _snack(AppStrings.profile.upiAccountDeleted);
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        AppStrings.profile.profileUpdateFailedPrefix,
        error: e,
        stack: stack,
        context: {'feature': 'profile', 'operation': 'deleteUpiAccount'},
      );
    }
  }

  Future<void> _setPrimary(UserUpiAccount account) async {
    try {
      await _db.setPrimaryUpiAccount(
        userId: widget.userId,
        accountId: account.id,
      );
      await _load();
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        AppStrings.profile.profileUpdateFailedPrefix,
        error: e,
        stack: stack,
        context: {'feature': 'profile', 'operation': 'setPrimaryUpiAccount'},
      );
    }
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    SplitrToast.showFromContext(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: groupGapLg),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_error != null) {
      return SplitrInlineError(
        message: _error!,
        onRetry: _load,
        padding: const EdgeInsets.symmetric(vertical: groupGapMd),
        centered: false,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_accounts.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: groupGapSm),
            child: Text(
              AppStrings.profile.noUpiAccounts,
              style: body2_text.copyWith(color: groupOnSurfaceMuted),
            ),
          ),
        ..._accounts.map(_buildRow),
        const SizedBox(height: groupGapSm),
        TextButton.icon(
          onPressed: () => _showEditor(),
          icon: const Icon(Icons.add_rounded, color: neopopAccent),
          label: Text(
            AppStrings.profile.addUpiAccount,
            style: body2_text.copyWith(color: neopopAccent),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(UserUpiAccount account) {
    return Container(
      margin: const EdgeInsets.only(bottom: groupGapSm),
      padding: const EdgeInsets.all(groupGapMd),
      decoration: BoxDecoration(
        color: groupSurfaceFillWhisper,
        borderRadius: BorderRadius.circular(groupControlRadius),
        border: Border.all(color: groupMutedBorderHairline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        account.bankAlias,
                        style: body1_text.copyWith(
                          color: groupOnSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (account.isPrimary) ...[
                      const SizedBox(width: groupGapSm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: groupGapSm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: neopopAccentFillMedium,
                          borderRadius:
                              BorderRadius.circular(groupRadiusHairline),
                        ),
                        child: Text(
                          AppStrings.profile.primaryBadge,
                          style: caption_text.copyWith(color: neopopAccent),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  UpiVpaUtils.maskVpa(account.vpa),
                  style: body2_text.copyWith(color: groupOnSurfaceMuted),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: groupOnSurface),
            onSelected: (action) {
              switch (action) {
                case 'edit':
                  _showEditor(existing: account);
                  break;
                case 'primary':
                  _setPrimary(account);
                  break;
                case 'delete':
                  _delete(account);
                  break;
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'edit',
                child: Text(AppStrings.actions.edit),
              ),
              if (!account.isPrimary)
                PopupMenuItem(
                  value: 'primary',
                  child: Text(AppStrings.profile.setAsDefault),
                ),
              PopupMenuItem(
                value: 'delete',
                child: Text(AppStrings.actions.delete),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
