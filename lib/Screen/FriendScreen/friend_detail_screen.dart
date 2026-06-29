import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/shared.dart';
import 'package:splitter/Model/friend_model.dart';
import 'package:splitter/Screen/FriendScreen/quick_split_screen.dart';
import 'package:splitter/Services/gamification_service.dart';

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
      balanceColor = neopopYellow;
      balanceLabel = "you owe";
    } else {
      balanceColor = neopopGrey;
      balanceLabel = "settled up";
    }

    return Scaffold(
      backgroundColor: neopopBackground,
      appBar: AppBar(
        backgroundColor: neopopBackground,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: neopopOnBackground),
        ),
        title: Text(
          friendBalance.friendName ?? 'Friend',
          style: sub_headline4_text,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(width_16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Friend header card
              Container(
                width: devSysWidth,
                padding: EdgeInsets.all(height_16 * 1.5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      balanceColor.withOpacity(0.15),
                      balanceColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: balanceColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: height_10 * 7,
                      height: height_10 * 7,
                      decoration: BoxDecoration(
                        color: getRandomBrightColor(),
                        borderRadius: BorderRadius.circular(height_10 * 3.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        getInitials(friendBalance.friendName ?? '?'),
                        style: headline1_text.copyWith(
                          color: neopopBackground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: height_10),
                    Text(
                      friendBalance.friendName ?? 'Unknown',
                      style: headline2_text,
                    ),
                    if (friendBalance.friendEmail != null)
                      Text(
                        friendBalance.friendEmail!,
                        style: caption_text.copyWith(color: neopopGrey),
                      ),
                    SizedBox(height: height_16),
                    // Balance
                    Text(
                      balanceLabel,
                      style: caption_text.copyWith(color: balanceColor),
                    ),
                    Text(
                      "₹${friendBalance.netBalance.abs().toStringAsFixed(2)}",
                      style: headline1_text.copyWith(
                        color: balanceColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              if (friendBalance.friendUserID != null) ...[
                SizedBox(height: height_16),
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
                    final color = score >= 75
                        ? neopopAccent
                        : score >= 50
                            ? neopopYellow
                            : Colors.orangeAccent;
                    return Container(
                      width: devSysWidth,
                      padding: EdgeInsets.all(height_16),
                      decoration: BoxDecoration(
                        color: neopopOnPrimary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.speed_rounded, color: color),
                          SizedBox(width: width_10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Settlement promptness',
                                    style: body2_text.copyWith(
                                        fontWeight: FontWeight.w600)),
                                Text(
                                  score >= 75
                                      ? 'Usually settles quickly'
                                      : score >= 50
                                          ? 'Average settle-up speed'
                                          : 'Balances tend to linger',
                                  style: caption_text.copyWith(color: neopopGrey),
                                ),
                              ],
                            ),
                          ),
                          Text('$score',
                              style: headline2_text.copyWith(color: color)),
                        ],
                      ),
                    );
                  },
                ),
              ],

              SizedBox(height: height_16 * 2),

              // Group breakdown
              if (friendBalance.groupBreakdown.isNotEmpty) ...[
                Text(
                  "Group Breakdown",
                  style: sub_headline4_text,
                ),
                SizedBox(height: height_10),
                ...friendBalance.groupBreakdown.map((gb) {
                  bool positive = gb.amount >= 0;
                  return Container(
                    margin: EdgeInsets.only(bottom: height_10),
                    padding: EdgeInsets.all(height_16),
                    decoration: BoxDecoration(
                      color: neopopOnPrimary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: neopopGrey.withOpacity(0.12)),
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
                                    fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                positive ? "they owe you" : "you owe them",
                                style: caption_text.copyWith(
                                  color: positive ? neopopAccent : neopopYellow,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "${positive ? '+' : '-'}₹${gb.amount.abs().toStringAsFixed(2)}",
                          style: sub_headline4_text.copyWith(
                            color: positive ? neopopAccent : neopopYellow,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ] else ...[
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: height_16 * 3),
                    child: Text(
                      "No shared group balances.",
                      style: body2_text.copyWith(color: neopopGrey),
                    ),
                  ),
                ),
              ],
            ],
          ),
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
              backgroundColor: neopopAccent,
              icon: const Icon(Icons.bolt_rounded, color: neopopOnBackground),
              label: Text('Quick split',
                  style: button_text.copyWith(color: neopopOnBackground)),
            )
          : null,
    );
  }
}
