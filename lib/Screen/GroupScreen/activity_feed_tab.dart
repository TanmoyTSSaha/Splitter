import 'package:flutter/material.dart';

import 'package:splitter/Constants/constants.dart';

import 'package:splitter/Constants/emoji_reaction_widget.dart';

import 'package:splitter/Constants/staggered_list_animation.dart';

import 'package:splitter/Constants/shared.dart';

import 'package:splitter/Model/activity_model.dart';

import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';

import 'package:splitter/Services/activity_service.dart';

import 'package:splitter/Services/supabase_service.dart';

import 'package:intl/intl.dart';

import 'package:get/get.dart';

import 'package:splitter/Controller/group_screen_controller.dart';

import 'package:splitter/Widgets/activity_comments_sheet.dart';

import 'package:splitter/Widgets/tab_empty_state.dart';

import 'package:splitter/Widgets/user_avatar.dart';



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

    } catch (e) {

      if (mounted) {

        setState(() {

          _errorMessage = "Could not load activity feed.";

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

      return const TabEmptyState(

        variant: TabEmptyVariant.activity,

        title: 'No activity yet',

        subtitle: 'Group updates will show up here.',

      );

    }



    return ListView.separated(

      padding: EdgeInsets.all(height_16),

      itemCount: _activities.length,

      itemBuilder: (context, index) {

        return StaggeredListItem(

          index: index,

          child: _buildActivityCard(_activities[index]),

        );

      },

      separatorBuilder: (context, index) => SizedBox(height: height_16),

    );

  }



  Widget _buildActivityCard(ActivityItem item) {

    return Container(

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(

          color: neopopGrey.withValues(alpha: 0.35),

        ),

        boxShadow: [

          BoxShadow(

            color: groupOnSurface.withValues(alpha: 0.06),

            blurRadius: 12,

            offset: const Offset(0, 4),

          ),

        ],

      ),

      child: Padding(

        padding: EdgeInsets.all(height_16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Row(

              children: [

                UserAvatar(

                  userID: item.actorId,

                  userName: item.actorName,

                  radius: 16,

                  fontSize: 14,

                ),

                SizedBox(width: width_10),

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

                  DateFormat('MMM d, h:mm a').format(item.timestamp),

                  style: caption_text.copyWith(color: groupOnSurfaceMuted),

                ),

              ],

            ),

            if (item.metadata != null &&

                item.metadata!.containsKey('split_summary')) ...[

              SizedBox(height: height_10),

              Container(

                padding: EdgeInsets.all(height_10),

                decoration: BoxDecoration(

                  color: groupOnSurface.withValues(alpha: 0.06),

                  borderRadius: BorderRadius.circular(8),

                ),

                width: double.infinity,

                child: Text(

                  item.metadata!['split_summary'],

                  style: body2_text.copyWith(color: neopopAccent),

                ),

              ),

            ],

            SizedBox(height: height_16),

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

                      size: 18, color: groupOnSurfaceMuted),

                  label: Text(

                    item.commentCount > 0 ? '${item.commentCount}' : 'Comment',

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

          userName: 'You',

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

    } catch (e) {

      // 3. Revert on failure

      if (mounted) {

        setState(() {

          _activities[index] = previousState;

        });

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(content: Text("Failed to react: $e")),

        );

      }

    }

  }

}


