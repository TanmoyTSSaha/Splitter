import 'package:flutter/material.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/glass_card.dart';
import 'package:splitr/Controller/profile_controller.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Services/razorpay_payment_service.dart';
import 'package:splitr/Widgets/bordered_input_field.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/domain_values.dart';

class DonateScreen extends StatefulWidget {
  const DonateScreen({super.key});

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  static const _presetAmounts = [49.0, 99.0, 199.0, 499.0];

  final _customAmountController = TextEditingController();
  double? _selectedPreset;
  bool _processing = false;

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  double? get _checkoutAmount {
    final custom = double.tryParse(_customAmountController.text.trim());
    if (custom != null && custom >= 1) return custom;
    return _selectedPreset;
  }

  Future<void> _donate() async {
    final amount = _checkoutAmount;
    if (amount == null || amount < 1) {
      SplitrToast.show(AppStrings.donate.minAmountError);
      return;
    }
    if (_processing) return;

    final profile = Get.find<ProfileController>();
    final user = profile.user.value;
    final email = user?.email ?? '';

    setState(() => _processing = true);

    final razorpay = Get.find<RazorpayPaymentService>();
    await razorpay.openCheckout(
      amountInr: amount,
      description: AppStrings.donate.checkoutDescription,
      payerContact: '',
      payerEmail: email,
      onSuccess: () {
        if (!mounted) return;
        SplitrToast.show(AppStrings.donate.thankYou);
        setState(() {
          _processing = false;
          _selectedPreset = null;
          _customAmountController.clear();
        });
      },
      onError: (_) {
        if (!mounted) return;
        SplitrToast.show(AppStrings.errors.paymentHumorous);
        setState(() => _processing = false);
      },
    );

    if (mounted && _processing && !RazorpayPaymentService.isConfigured) {
      setState(() => _processing = false);
    }
  }

  void _selectPreset(double amount) {
    setState(() {
      _selectedPreset = amount;
      _customAmountController.clear();
    });
  }

  void _onCustomChanged(String _) {
    setState(() {
      if (_selectedPreset != null) _selectedPreset = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final configured = RazorpayPaymentService.isConfigured;
    final amount = _checkoutAmount;

    return Scaffold(
      backgroundColor: surface,
      appBar: SplitrDetailAppBar(
        title: AppStrings.profile.donate,
        leading: SplitrDetailAppBar.iosBackLeading(
          context,
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(groupGutter, 8, groupGutter, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.donate.headline,
              style: TextStyle(
                fontFamily: kFontAlbra,
                fontSize: splitrFontRecapMd,
                fontWeight: FontWeight.w600,
                color: groupOnSurface,
                height: 1.1,
              ),
            ),
            const SizedBox(height: groupGapSm),
            Text(
              configured
                  ? AppStrings.donate.contributionConfigured
                  : AppStrings.donate.paymentsNotConfigured,
              style: TextStyle(
                fontFamily: kFontPoppins,
                fontSize: splitrFontBodySm,
                color: groupOnSurfaceMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: groupGapLg),
            GlassCard(
              margin: EdgeInsets.zero,
              opacity: 0.09,
              padding: const EdgeInsets.all(groupGapMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.donate.chooseAmount,
                    style: TextStyle(
                      fontFamily: kFontPoppins,
                      fontSize: splitrFontCaptionSm,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.4,
                      color: groupOnSurfaceMuted,
                    ),
                  ),
                  const SizedBox(height: groupGapMd),
                  Wrap(
                    spacing: groupGapSm,
                    runSpacing: groupGapSm,
                    children: _presetAmounts.map((preset) {
                      final selected = _selectedPreset == preset;
                      return _AmountChip(
                        label:
                            '${CurrencySymbols.inr}${preset.toStringAsFixed(0)}',
                        selected: selected,
                        onTap: configured && !_processing
                            ? () => _selectPreset(preset)
                            : null,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: groupGapMd),
                  BorderedInputField(
                    controller: _customAmountController,
                    enabled: configured && !_processing,
                    onChanged: _onCustomChanged,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    labelText: AppStrings.donate.customAmount,
                    prefixText: '${CurrencySymbols.inr} ',
                  ),
                ],
              ),
            ),
            const SizedBox(height: groupGapMd),
            SizedBox(
              width: double.infinity,
              height: groupCtaHeight,
              child: ElevatedButton(
                onPressed: !configured || _processing || amount == null
                    ? null
                    : _donate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: neopopAccent,
                  disabledBackgroundColor: groupMutedBorder,
                  foregroundColor: groupOnSurface,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(groupControlRadius),
                  ),
                ),
                child: _processing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: groupProgressStrokeWidth,
                          color: groupOnSurface,
                        ),
                      )
                    : Text(
                        amount != null
                            ? AppStringFormat.donateAmount(amount)
                            : AppStrings.profile.donate,
                        style: body1_text.copyWith(
                          fontWeight: FontWeight.w600,
                          color: groupOnSurface,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: groupGapMd),
            Text(
              AppStrings.donate.footerNote,
              style: TextStyle(
                fontFamily: kFontPoppins,
                fontSize: splitrFontCaption,
                color: groupOnSurfaceMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _AmountChip({
    required this.label,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? neopopAccent : groupMutedFillFaint,
      borderRadius: BorderRadius.circular(groupControlRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(groupControlRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: groupGap20, vertical: groupGap14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(groupControlRadius),
            border: Border.all(
              color: selected ? neopopAccent : groupMutedBorderHairline,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: kFontAlbra,
              fontSize: splitrFontTitle,
              fontWeight: FontWeight.bold,
              color: groupOnSurface,
            ),
          ),
        ),
      ),
    );
  }
}
