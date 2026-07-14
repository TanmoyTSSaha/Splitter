import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Model/group_invite_model.dart';
import 'package:splitr/Model/loan_model.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

/// Action card for a pending group invite (accept / decline).
class GroupInviteActionCard extends StatelessWidget {
  final GroupInviteModel invite;
  final VoidCallback onDecline;
  final VoidCallback onAccept;

  const GroupInviteActionCard({
    required this.invite,
    required this.onDecline,
    required this.onAccept,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(width_16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(groupControlRadius),
        border: Border.all(color: groupMutedBorderHairline),
        boxShadow: [
          BoxShadow(
            color: neopopBackground.withValues(alpha: 0.04),
            blurRadius: AppDimensions.groupCardShadowBlur,
            offset: const Offset(0, AppDimensions.groupCardShadowOffsetSmY),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(groupGap10),
                decoration: BoxDecoration(
                  color: neopopAccentFillLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.group_add_rounded, color: neopopAccent),
              ),
              const SizedBox(width: groupCarouselGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: invite.inviterName ?? DisplayFallbacks.someone,
                        style: sub_headline5_text.copyWith(
                          color: groupOnSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(
                            text: AppStrings.notifications.invitedYouToJoin,
                            style: body2_text.copyWith(color: neopopGrey),
                          ),
                          TextSpan(
                            text: invite.groupName ?? DisplayFallbacks.aGroup,
                            style: sub_headline5_text.copyWith(
                              color: neopopAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: groupGapXxs),
                    Text(
                      AppStrings.notifications.invitePending,
                      style: caption_text.copyWith(
                        color: neopopGrey,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: height_16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: neopopError,
                    side: const BorderSide(color: neopopError),
                    padding:
                        const EdgeInsets.symmetric(vertical: groupCarouselGap),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(groupControlRadiusSm),
                    ),
                  ),
                  child: Text(AppStrings.actions.decline),
                ),
              ),
              const SizedBox(width: groupCarouselGap),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neopopAccent,
                    foregroundColor: neopopOnPrimary,
                    padding:
                        const EdgeInsets.symmetric(vertical: groupCarouselGap),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(groupControlRadiusSm),
                    ),
                  ),
                  child: Text(AppStrings.actions.accept),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Action card for a pending loan request (reject / view).
class LoanRequestActionCard extends StatelessWidget {
  final LoanModel loan;
  final VoidCallback onReject;
  final VoidCallback onView;

  const LoanRequestActionCard({
    required this.loan,
    required this.onReject,
    required this.onView,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isLendOffer = loan.isLendOffer();
    final initiatorName = isLendOffer
        ? (loan.lenderName ?? DisplayFallbacks.someone)
        : (loan.borrowerName ?? DisplayFallbacks.someone);

    return Container(
      padding: EdgeInsets.all(width_16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(groupControlRadius),
        border: Border.all(color: groupMutedBorderHairline),
        boxShadow: [
          BoxShadow(
            color: neopopBackground.withValues(alpha: 0.04),
            blurRadius: AppDimensions.groupCardShadowBlur,
            offset: const Offset(0, AppDimensions.groupCardShadowOffsetSmY),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(groupGap10),
                decoration: BoxDecoration(
                  color: neopopAccentFillLight,
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.monetization_on_rounded, color: neopopAccent),
              ),
              const SizedBox(width: groupCarouselGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      final sym = Get.find<CurrencyController>().symbol;
                      final amount =
                          '$sym${loan.principalAmount.toStringAsFixed(0)}';
                      return RichText(
                        text: TextSpan(
                          text: initiatorName,
                          style: sub_headline5_text.copyWith(
                            color: groupOnSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            TextSpan(
                              text: isLendOffer
                                  ? AppStrings.notifications.offeredLoan
                                  : AppStrings.notifications.requestedBorrow,
                              style: body2_text.copyWith(color: neopopGrey),
                            ),
                            TextSpan(
                              text: isLendOffer
                                  ? amount
                                  : '$amount${AppStrings.notifications.fromYou}',
                              style: sub_headline5_text.copyWith(
                                color: neopopAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: groupGapXxs),
                    Text(
                      isLendOffer
                          ? AppStrings.notifications.loanOffer
                          : AppStrings.notifications.borrowRequest,
                      style: caption_text.copyWith(
                        color: neopopGrey,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: height_16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: neopopError,
                    side: const BorderSide(color: neopopError),
                    padding:
                        const EdgeInsets.symmetric(vertical: groupCarouselGap),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(groupControlRadius),
                    ),
                  ),
                  child: Text(AppStrings.actions.reject),
                ),
              ),
              const SizedBox(width: groupCarouselGap),
              Expanded(
                child: ElevatedButton(
                  onPressed: onView,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neopopBackground,
                    foregroundColor: neopopOnPrimary,
                    padding:
                        const EdgeInsets.symmetric(vertical: groupCarouselGap),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(groupControlRadius),
                    ),
                  ),
                  child: Text(AppStrings.actions.view),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
