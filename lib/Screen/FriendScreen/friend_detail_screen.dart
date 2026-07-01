import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Model/friend_model.dart';
import 'package:splitter/Screen/FriendScreen/quick_split_screen.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitter/Services/gamification_service.dart';
import 'package:splitter/Widgets/user_avatar.dart';

const Color _lightBg = Color(0xFFFAFAFA);
const Color _cardBorder = Color(0xFFEEEEEE);
const Color _promptnessGood = Color(0xFF2E7D32);
const Color _promptnessPoor = Color(0xFFE53935);

Color _promptnessColor(int score) =>
    score >= 50 ? _promptnessGood : _promptnessPoor;

String _promptnessSubtitle(int score) {
  if (score >= 75) return 'Usually settles quickly';
  if (score >= 50) return 'Average settle-up speed';
  return 'Balances tend to linger';
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
    Color balanceColor;
    String balanceLabel;
    if (friendBalance.netBalance > 0.01) {
      balanceColor = neopopAccent;
      balanceLabel = "owes you";
    } else if (friendBalance.netBalance < -0.01) {
      balanceColor = const Color(0xFFE6A800);
      balanceLabel = "you owe";
    } else {
      balanceColor = groupOnSurfaceMuted;
      balanceLabel = "settled up";
    }

    return Scaffold(
      backgroundColor: _lightBg,
      appBar: AppBar(
        backgroundColor: _lightBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: groupOnSurface),
        ),
        title: Text(
          friendBalance.friendName ?? 'Friend',
          style: headline3_text.copyWith(
            fontFamily: 'Albra',
            fontWeight: FontWeight.w600,
            color: groupOnSurface,
          ),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                    userName: friendBalance.friendName ?? '?',
                    radius: 36,
                    fontSize: 24,
                  ),
                  const SizedBox(height: groupGapSm),
                  Text(
                    friendBalance.friendName ?? 'Unknown',
                    style: headline3_text.copyWith(
                      fontFamily: 'Albra',
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
                    "₹${friendBalance.netBalance.abs().toStringAsFixed(2)}",
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
                      height: 48,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }
                  final color = _promptnessColor(score);
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(groupGapMd),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                                'Settlement promptness',
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
                "Group Breakdown",
                style: headline3_text.copyWith(
                  fontFamily: 'Albra',
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _cardBorder),
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
                              positive ? "they owe you" : "you owe them",
                              style: caption_text.copyWith(
                                color: positive
                                    ? neopopAccent
                                    : const Color(0xFFE6A800),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "${positive ? '+' : '-'}₹${gb.amount.abs().toStringAsFixed(2)}",
                        style: sub_headline4_text.copyWith(
                          color: positive
                              ? neopopAccent
                              : const Color(0xFFE6A800),
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
                    "No shared group balances.",
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
              icon: const Icon(Icons.bolt_rounded, color: Colors.white),
              label: Text(
                'Quick split',
                style: button_text.copyWith(color: Colors.white),
              ),
            )
          : null,
    );
  }
}
