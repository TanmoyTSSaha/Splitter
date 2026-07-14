import 'package:flutter/material.dart';
import 'package:splitr/Utils/currency_utils.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/theme_accent_colors.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Model/friend_model.dart';
import 'package:splitr/Screen/FriendScreen/quick_split_screen.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Services/gamification_service.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';
import 'package:splitr/Widgets/user_avatar.dart';

Color _promptnessColor(int score) =>
    score >= PromptnessScoreTiers.good ? neopopSuccess : neopopAlert;

String _promptnessSubtitle(int score) {
  if (score >= PromptnessScoreTiers.excellent) {
    return AppStrings.friends.promptnessFast;
  }
  if (score >= PromptnessScoreTiers.good) {
    return AppStrings.friends.promptnessAverage;
  }
  return AppStrings.friends.promptnessSlow;
}

class FriendDetailScreen extends StatelessWidget {
  final FriendBalanceModel friendBalance;
  final String? userID;

  const FriendDetailScreen({
    required this.friendBalance,
    this.userID,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    Color balanceColor;
    String balanceLabel;
    if (friendBalance.netBalance > MoneyEpsilon.balanceSettled) {
      balanceColor = neopopAccent;
      balanceLabel = AppStrings.friends.owesYou;
    } else if (friendBalance.netBalance < -MoneyEpsilon.balanceSettled) {
      balanceColor = ThemeAccentColors.oweWarning(context);
      balanceLabel = AppStrings.friends.youOwe;
    } else {
      balanceColor = groupOnSurfaceMuted;
      balanceLabel = AppStrings.friends.settledUp;
    }

    return Scaffold(
      backgroundColor: surface,
      appBar: SplitrDetailAppBar(
        title: friendBalance.friendName ?? DisplayFallbacks.friend,
        leading: SplitrDetailAppBar.iosBackLeading(
          context,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(groupGutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(groupGapLg),
              decoration: BoxDecoration(
                color: groupCardFill,
                borderRadius: BorderRadius.circular(groupCardRadius),
                border: Border.all(color: balanceColor.withValues(alpha: 0.35)),
                boxShadow: [
                  BoxShadow(
                    color: balanceColor.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  UserAvatar(
                    userID: friendBalance.friendUserID ?? '',
                    userName: friendBalance.friendName ??
                        DisplayFallbacks.questionMark,
                    radius: 36,
                    fontSize: splitrFontHeadline3,
                  ),
                  const SizedBox(height: groupGapSm),
                  Text(
                    friendBalance.friendName ?? DisplayFallbacks.unknown,
                    style: headline3_text.copyWith(
                      fontFamily: kFontAlbra,
                      color: groupOnSurface,
                    ),
                  ),
                  if (friendBalance.friendEmail != null)
                    Text(
                      friendBalance.friendEmail!,
                      style: caption_text.copyWith(color: groupOnSurfaceMuted),
                    ),
                  const SizedBox(height: groupGapMd),
                  Text(
                    balanceLabel,
                    style: caption_text.copyWith(color: balanceColor),
                  ),
                  Text(
                    "${userCurrencySymbol()}${friendBalance.netBalance.abs().toStringAsFixed(DefaultDecimalPlaces.amount)}",
                    style: headline2_text.copyWith(
                      color: balanceColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (friendBalance.friendUserID != null) ...[
              const SizedBox(height: groupGapMd),
              FutureBuilder<int>(
                future: GamificationService()
                    .computeFriendPromptnessScore(friendBalance.friendUserID!),
                builder: (context, snapshot) {
                  final score = snapshot.data;
                  if (score == null) {
                    return const SizedBox(
                      height: groupCtaHeightCompact,
                      child: Center(
                        child: SizedBox(
                          width: AppDimensions.loadingIndicatorSm,
                          height: AppDimensions.loadingIndicatorSm,
                          child: CircularProgressIndicator(
                              strokeWidth: groupProgressStrokeWidth),
                        ),
                      ),
                    );
                  }
                  final color = _promptnessColor(score);
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(groupGapMd),
                    decoration: BoxDecoration(
                      color: groupCardFill,
                      borderRadius: BorderRadius.circular(groupCardRadius),
                      border: Border.all(color: color.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.speed_rounded, color: color),
                        const SizedBox(width: groupGapSm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.friends.settlementPromptness,
                                style: body2_text.copyWith(
                                  color: groupOnSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _promptnessSubtitle(score),
                                style: caption_text.copyWith(
                                    color: groupOnSurfaceMuted),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '$score',
                          style: headline2_text.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: groupGapLg),
            if (friendBalance.groupBreakdown.isNotEmpty) ...[
              Text(
                AppStrings.friends.groupBreakdown,
                style: headline3_text.copyWith(
                  fontFamily: kFontAlbra,
                  fontWeight: FontWeight.w600,
                  color: groupOnSurface,
                ),
              ),
              const SizedBox(height: groupGapSm),
              ...friendBalance.groupBreakdown.map((gb) {
                final positive = gb.amount >= 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: groupGapSm),
                  padding: const EdgeInsets.all(groupGapMd),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(groupCardRadius),
                    border: Border.all(color: groupMutedBorderHairline),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gb.groupName,
                              style: body1_text.copyWith(
                                color: groupOnSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              positive
                                  ? AppStrings.friends.theyOweYou
                                  : AppStrings.friends.youOweThem,
                              style: caption_text.copyWith(
                                color: positive
                                    ? neopopAccent
                                    : ThemeAccentColors.oweWarning(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "${positive ? '+' : '-'}${userCurrencySymbol()}${gb.amount.abs().toStringAsFixed(DefaultDecimalPlaces.amount)}",
                        style: sub_headline4_text.copyWith(
                          color: positive
                              ? neopopAccent
                              : ThemeAccentColors.oweWarning(context),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ] else ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: groupGapXl),
                  child: Text(
                    AppStrings.friends.noGroupBalances,
                    style: body2_text.copyWith(color: groupOnSurfaceMuted),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: userID != null && friendBalance.friendUserID != null
          ? FloatingActionButton.extended(
              onPressed: () {
                Get.to(() => QuickSplitScreen(
                      userID: userID!,
                      friend: friendBalance,
                    ));
              },
              backgroundColor: neopopBackground,
              icon: const Icon(Icons.bolt_rounded, color: groupChipSelectedFg),
              label: Text(
                AppStrings.friends.quickSplit,
                style: button_text.copyWith(color: groupChipSelectedFg),
              ),
            )
          : null,
    );
  }
}
