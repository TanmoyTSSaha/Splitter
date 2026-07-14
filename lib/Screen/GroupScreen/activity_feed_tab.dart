import 'package:flutter/material.dart';

import 'package:splitr/Constants/constants.dart';

import 'package:splitr/Constants/emoji_reaction_widget.dart';

import 'package:splitr/Constants/staggered_list_animation.dart';

import 'package:splitr/Constants/shared.dart';

import 'package:splitr/Model/activity_model.dart';

import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

import 'package:splitr/Services/activity_service.dart';

import 'package:splitr/Services/supabase_service.dart';

import 'package:get/get.dart';

import 'package:splitr/Controller/group_screen_controller.dart';

import 'package:splitr/Widgets/activity_comments_sheet.dart';

import 'package:splitr/Widgets/tab_empty_state.dart';

import 'package:splitr/Widgets/user_avatar.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/Utils/transaction_date_formatter.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_keys.dart';

class ActivityFeedTab extends StatefulWidget {
  final String groupId;

  const ActivityFeedTab({required this.groupId, super.key});

  @override
  State<ActivityFeedTab> createState() => _ActivityFeedTabState();
}

class _ActivityFeedTabState extends State<ActivityFeedTab> {
  final ActivityService _activityService = ActivityService();

  // Local state for optimistic updates

  List<ActivityItem> _activities = [];

  bool _isLoading = true;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _loadActivities();
  }

  Future<void> _loadActivities() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;

      _errorMessage = null;
    });

    try {
      final items = await _activityService.getGroupActivities(widget.groupId);

      if (mounted) {
        setState(() {
          _activities = items;

          _isLoading = false;
        });
      }
    } catch (e, stack) {
      AppErrorReporter.report(
        AppStrings.errors.loadActivityFeed,
        error: e,
        stack: stack,
      );
      if (mounted) {
        setState(() {
          _errorMessage = AppStrings.errors.loadActivityFeed;

          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final GroupScreenController groupController = Get.find();

    // Listen to refresh trigger

    ever(groupController.refreshTrigger, (_) {
      _loadActivities();
    });

    if (_isLoading) {
      return const Center(child: LoadingWidget());
    } else if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: sub_headline5_text.copyWith(color: neopopAccent),
        ),
      );
    } else if (_activities.isEmpty) {
      return TabEmptyState(
        variant: TabEmptyVariant.activity,
        title: AppStrings.groups.noActivityYet,
        subtitle: AppStrings.groups.noActivitySubtitle,
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(groupGutter),
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        return StaggeredListItem(
          index: index,
          child: _buildActivityCard(_activities[index]),
        );
      },
      separatorBuilder: (context, index) => SizedBox(height: groupGutter),
    );
  }

  Widget _buildActivityCard(ActivityItem item) {
    return Container(
      decoration: BoxDecoration(
        color: groupCardFill,
        borderRadius: BorderRadius.circular(groupCardRadius),
        border: Border.all(
          color: groupMutedBorderStrong,
        ),
        boxShadow: [
          BoxShadow(
            color: groupSurfaceFillFaint,
            blurRadius: AppDimensions.groupCardShadowBlur,
            offset: const Offset(0, AppDimensions.groupCardShadowOffsetY),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(groupGutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserAvatar(
                  userID: item.actorId,
                  userName: item.actorName,
                  radius: 16,
                  fontSize: splitrFontBody,
                ),
                SizedBox(width: groupGap10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: "${item.actorName} ",
                      style: body1_text.copyWith(
                        color: groupOnSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: item.description,
                          style: body1_text.copyWith(
                            color: groupOnSurface,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  TransactionDateFormatter.formatDateTime(item.timestamp),
                  style: caption_text.copyWith(color: groupOnSurfaceMuted),
                ),
              ],
            ),
            if (item.metadata != null &&
                item.metadata!.containsKey(MetadataKeys.splitSummary)) ...[
              SizedBox(height: groupGap10),
              Container(
                padding: EdgeInsets.all(groupGap10),
                decoration: BoxDecoration(
                  color: groupSurfaceFillFaint,
                  borderRadius: BorderRadius.circular(groupControlRadiusSm),
                ),
                width: double.infinity,
                child: Text(
                  item.metadata![MetadataKeys.splitSummary],
                  style: body2_text.copyWith(color: neopopAccent),
                ),
              ),
            ],
            SizedBox(height: groupGutter),
            Row(
              children: [
                Expanded(
                  child: EmojiReactionWidget(
                    reactions: item.reactions,
                    onReactionSelected: (emoji) => _handleReaction(item, emoji),
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await ActivityCommentsSheet.show(context, item);

                    _loadActivities();
                  },
                  icon: const Icon(Icons.chat_bubble_outline,
                      size: groupCarouselIconSm, color: groupOnSurfaceMuted),
                  label: Text(
                    item.commentCount > 0
                        ? '${item.commentCount}'
                        : AppStrings.groups.comment,
                    style: caption_text.copyWith(color: groupOnSurfaceMuted),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleReaction(ActivityItem item, String emoji) async {
    final userId = SupabaseAuth().supabaseGetUserID();

    // 1. Optimistic Update

    final index = _activities.indexOf(item);

    if (index == -1) return;

    final hasReacted =
        item.reactions.any((r) => r.userId == userId && r.emoji == emoji);

    List<Reaction> updatedReactions = List.from(item.reactions);

    // Snapshot of previous state for revert

    final previousState = item;

    setState(() {
      if (hasReacted) {
        updatedReactions
            .removeWhere((r) => r.userId == userId && r.emoji == emoji);
      } else {
        updatedReactions.add(Reaction(
          userId: userId,
          userName: GroupCopy.self,
          emoji: emoji,
        ));
      }

      _activities[index] = ActivityItem(
        id: item.id,
        groupId: item.groupId,
        type: item.type,
        actorId: item.actorId,
        actorName: item.actorName,
        description: item.description,
        amount: item.amount,
        timestamp: item.timestamp,
        metadata: item.metadata,
        reactions: updatedReactions,
        commentCount: item.commentCount,
      );
    });

    // 2. Call Service

    try {
      await _activityService.addReaction(item.id, emoji, userId);
    } catch (e, stack) {
      AppErrorReporter.report(
        AppStrings.errors.failedToReactPrefix,
        error: e,
        stack: stack,
      );
      // 3. Revert on failure

      if (mounted) {
        setState(() {
          _activities[index] = previousState;
        });
      }
    }
  }
}
