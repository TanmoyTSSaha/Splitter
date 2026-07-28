import 'package:flutter/foundation.dart';

import 'package:splitr/Widgets/splitr_toast.dart';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:splitr/Constants/constants.dart';

import 'package:splitr/Controllers/premium_subscription_controller.dart';

import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

import 'package:splitr/Widgets/splitr_detail_app_bar.dart';

import 'package:splitr/Constants/app_motion.dart';

import 'package:splitr/Constants/app_palette.dart';

import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

class PremiumPlanScreen extends StatefulWidget {
  final String? highlightFeature;

  const PremiumPlanScreen({this.highlightFeature, super.key});

  @override
  State<PremiumPlanScreen> createState() => _PremiumPlanScreenState();
}

class _PremiumPlanScreenState extends State<PremiumPlanScreen> {
  bool _isYearly = false;

  late final PremiumSubscriptionController _premium;

  @override
  void initState() {
    super.initState();

    _premium = Get.find<PremiumSubscriptionController>();
  }

  Future<void> _confirmCancelSubscription() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.premium.cancelSubscription),
        content: Text(AppStrings.premium.cancelSubscriptionConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.actions.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.actions.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _premium.cancelSubscription();

      if (mounted) {
        SplitrToast.showFromContext(
          context,
          AppStrings.premium.cancelSubscription,
        );
      }
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        AppStrings.premium.cancelSubscriptionFailedPrefix,
        error: e,
        stack: stack,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: surface,
      appBar: SplitrDetailAppBar(
        title: AppStrings.premium.plansTitle,
        leading: SplitrDetailAppBar.iosBackLeading(
          context,
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          groupGutter,
          groupGapSm,
          groupGutter,
          groupGapXl + groupGapSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.premium.headline,
              style: TextStyle(
                fontFamily: kFontAlbra,
                fontSize: splitrFontHeadline1,
                fontWeight: FontWeight.w400,
                height: 1.2,
                color: groupOnSurface,
              ),
            ),
            const SizedBox(height: groupGapSm),
            Text(
              AppStrings.premium.tagline,
              style: body2_text.copyWith(
                fontSize: splitrFontBodySm,
                fontWeight: FontWeight.w400,
                color: groupOnSurfaceMuted,
              ),
            ),
            const SizedBox(height: groupGapLg + groupGapSm),
            if (widget.highlightFeature != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(groupGap14),
                decoration: BoxDecoration(
                  color: neopopYellowFillMedium,
                  borderRadius: BorderRadius.circular(groupControlRadius),
                  border: Border.all(color: neopopYellowBorderStrong),
                ),
                child: Text(
                  AppStringFormat.unlockFeature(widget.highlightFeature!),
                  style: body2_text.copyWith(
                    fontSize: splitrFontBodySm,
                    fontWeight: FontWeight.w600,
                    color: groupOnSurface,
                  ),
                ),
              ),
              const SizedBox(height: groupCarouselGap + groupGapSm),
            ],
            _buildBillingToggle(context),
            const SizedBox(height: groupGapLg + groupGapSm),
            _buildBasicCard(context),
            const SizedBox(height: groupGapMd),
            _buildPremiumCard(),
            const SizedBox(height: groupGapLg),
            Center(
              child: Text(
                AppStrings.premium.cancelAnytime,
                style: caption_text.copyWith(
                  fontSize: splitrFontCaptionSm,
                  fontStyle: FontStyle.normal,
                  color: groupMutedTextSecondary,
                ),
              ),
            ),
            const SizedBox(height: groupCarouselGap),
            Center(
              child: TextButton(
                onPressed: () async {
                  try {
                    await _premium.refreshStatus();

                    if (_premium.isPremium.value && mounted) {
                      Get.back(result: true);
                    }
                  } catch (e, stack) {
                    AppErrorReporter.reportActionFailure(
                      AppStrings.premium.refreshFailedPrefix,
                      error: e,
                      stack: stack,
                    );
                  }
                },
                child: Text(
                  AppStrings.premium.refreshStatus,
                  style: caption_text.copyWith(
                    fontStyle: FontStyle.normal,
                    color: groupOnSurfaceMuted,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            Obx(() {
              if (!_premium.isPremium.value) return const SizedBox.shrink();

              return Center(
                child: TextButton(
                  onPressed: _premium.isLoading.value
                      ? null
                      : _confirmCancelSubscription,
                  child: Text(
                    AppStrings.premium.cancelSubscription,
                    style: caption_text.copyWith(
                      fontStyle: FontStyle.normal,
                      color: groupOnSurfaceMuted,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              );
            }),
            if (kDebugMode) ...[
              const SizedBox(height: groupGapSm),
              Center(
                child: TextButton(
                  onPressed: () async {
                    await _premium.enableDevPremium();

                    if (mounted) Get.back(result: true);
                  },
                  child: Text(
                    AppStrings.premium.devPro,
                    style: caption_text.copyWith(
                      fontSize: splitrFontCaptionSm,
                      fontStyle: FontStyle.normal,
                      color: AppPalette.accentPurple,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBillingToggle(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;

    final borderColor = groupMutedBorderHairline;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(groupControlRadius),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(groupGapXxs),
      child: Row(
        children: [
          _buildToggleOption(AppStrings.premium.monthly, !_isYearly),
          _buildToggleOption(AppStrings.premium.yearlySave, _isYearly),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(
            () => _isYearly = label.startsWith(AppStrings.durations.yearly)),
        child: AnimatedContainer(
          duration: AppMotion.standard,
          padding: const EdgeInsets.symmetric(vertical: groupGap10),
          decoration: BoxDecoration(
            color: isActive ? groupOnSurface : groupTransparent,
            borderRadius: BorderRadius.circular(groupRadiusChip),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: caption_text.copyWith(
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : groupOnSurfaceMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicCard(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;

    final borderColor = groupMutedBorderHairline;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(groupCardRadiusLg),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(groupGap22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.premium.basic,
                style: caption_text.copyWith(
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: groupOnSurfaceMuted,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: groupGap10, vertical: groupGapXxs),
                decoration: BoxDecoration(
                  color: AppPalette.surfaceMuted,
                  borderRadius: BorderRadius.circular(groupCardRadiusLg),
                ),
                child: Text(
                  AppStrings.premium.currentPlan,
                  style: caption_text.copyWith(
                    fontSize: splitrFontMicro,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: groupOnSurfaceMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: groupGapSm),
          Text(
            AppStrings.premium.free,
            style: TextStyle(
              fontFamily: kFontAlbra,
              fontSize: splitrFontHeadline2,
              fontWeight: FontWeight.w400,
              color: groupOnSurface,
            ),
          ),
          const SizedBox(height: groupGapMd),
          Divider(height: 1, color: borderColor),
          const SizedBox(height: groupGapMd),
          _buildFeatureRow(AppStrings.premium.featureUnlimitedSplitting, true),
          _buildFeatureRow(AppStrings.premium.featureUnlimitedGroups, true),
          _buildFeatureRow(AppStrings.premium.featureBasicStats, true),
          _buildFeatureRow(AppStrings.premium.featureStandardSupport, true),
          _buildFeatureRow(AppStrings.premium.featureAiReceipt, false),
          _buildFeatureRow(AppStrings.premium.featureUpiSettle, false),
          _buildFeatureRow(AppStrings.premium.featureAdvancedAnalytics, false),
          _buildFeatureRow(AppStrings.premium.featureExport, false),
        ],
      ),
    );
  }

  Widget _buildPremiumCard() {
    final price = _premium.priceLabelFor(_isYearly);

    final sub = _premium.billingLabelFor(_isYearly);

    return Container(
      decoration: BoxDecoration(
        color: AppPalette.premiumDark,
        borderRadius: BorderRadius.circular(groupCardRadiusLg),
        boxShadow: [
          BoxShadow(
              color: neopopAccentBorderHairline,
              blurRadius: 32,
              offset: const Offset(-4, 8)),
          BoxShadow(
              color: AppPalette.accentPurple.withOpacity(0.25),
              blurRadius: 32,
              offset: const Offset(4, -8)),
        ],
      ),
      padding: const EdgeInsets.all(groupGap22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.premium.premium,
                style: caption_text.copyWith(
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: neopopYellow,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: groupGap10, vertical: groupGapXxs),
                decoration: BoxDecoration(
                  color: neopopYellow.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(groupCardRadiusLg),
                  border: Border.all(color: neopopYellowBorderStrong),
                ),
                child: Text(
                  AppStrings.premium.recommended,
                  style: caption_text.copyWith(
                    fontSize: splitrFontMicro,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: neopopYellow,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: groupGapSm),
          Text(
            price,
            style: TextStyle(
              fontFamily: kFontAlbra,
              fontSize: splitrFontHeadline1,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: caption_text.copyWith(
              fontSize: splitrFontCaptionSm,
              fontStyle: FontStyle.normal,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: groupGapMd),
          Divider(height: 1, color: shareCardOnSurface.withValues(alpha: 0.1)),
          const SizedBox(height: groupGapMd),
          _buildPremiumFeatureRow(AppStrings.premium.featureEverythingBasic),
          _buildPremiumFeatureRow(AppStrings.premium.featureAiReceiptOcr),
          _buildPremiumFeatureRow(AppStrings.premium.featureUpiSettleLinks),
          _buildPremiumFeatureRow(AppStrings.premium.featureAdvancedCharts),
          _buildPremiumFeatureRow(AppStrings.premium.featureCsvPdfExport),
          _buildPremiumFeatureRow(AppStrings.trips.multiCurrencyLedger),
          _buildPremiumFeatureRow(AppStrings.lending.contractPdf),
          _buildPremiumFeatureRow(AppStrings.reminders.escalatedCadence),
          _buildPremiumFeatureRow(AppStrings.premium.featureAiInsights),
          _buildPremiumFeatureRow(AppStrings.premium.featureEliteBadge),
          const SizedBox(height: groupCarouselGap + groupGapSm),
          Obx(() {
            final loading = _premium.isLoading.value;

            final isPro = _premium.isPremium.value;

            final pending = _premium.subscriptionStatus.value ==
                PremiumSubscriptionStatus.pending;

            return GestureDetector(
              onTap: loading || isPro
                  ? null
                  : () async {
                      try {
                        if (_isYearly) {
                          await _premium.purchaseYearly();
                        } else {
                          await _premium.purchaseMonthly();
                        }

                        if (_premium.isPremium.value && mounted) {
                          Get.back(result: true);
                        }
                      } catch (e, stack) {
                        AppErrorReporter.reportActionFailure(
                          AppStrings.premium.purchaseFailedPrefix,
                          error: e,
                          stack: stack,
                        );
                      }
                    },
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: isPro ? neopopAccent : neopopYellow,
                  borderRadius: BorderRadius.circular(groupRadiusLgSm),
                ),
                alignment: Alignment.center,
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: groupProgressStrokeWidth,
                          color: groupOnSurface,
                        ),
                      )
                    : Text(
                        isPro
                            ? AppStrings.premium.onPro
                            : pending
                                ? AppStrings.premium.subscriptionPending
                                : AppStringFormat.premiumSubscribe(price),
                        style: body2_text.copyWith(
                          fontSize: splitrFontBodySm,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: groupOnSurface,
                        ),
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String label, bool included) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: groupGap5),
      child: Row(
        children: [
          Icon(
            included ? Icons.check_circle_rounded : Icons.cancel_outlined,
            size: 17,
            color: included ? neopopSuccessBright : neopopDisabledMuted,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: body2_text.copyWith(
              fontSize: splitrFontBodySm,
              fontWeight: FontWeight.w500,
              color: included ? groupOnSurface : groupOnSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFeatureRow(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: groupGap5),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, size: 17, color: neopopAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: body2_text.copyWith(
                fontSize: splitrFontBodySm,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
