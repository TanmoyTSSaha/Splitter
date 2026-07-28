import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/app_themes.dart';

import 'package:splitr/Constants/constants.dart';

import 'package:splitr/Constants/shared.dart';

import 'package:splitr/Model/activity_model.dart';

import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

import 'package:splitr/Services/activity_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

import 'package:splitr/Services/supabase_service.dart';

import 'package:splitr/Widgets/user_avatar.dart';

/// Inline comment thread for a single activity feed item.

class ActivityCommentsSheet extends StatefulWidget {
  final ActivityItem activity;

  const ActivityCommentsSheet({required this.activity, super.key});

  static Future<void> show(BuildContext context, ActivityItem activity) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: groupSheetTopBorderRadiusLg,
      ),
      builder: (_) => Theme(
        data: AppThemes.light,
        child: ActivityCommentsSheet(activity: activity),
      ),
    );
  }

  @override
  State<ActivityCommentsSheet> createState() => _ActivityCommentsSheetState();
}

class _ActivityCommentsSheetState extends State<ActivityCommentsSheet> {
  final _controller = TextEditingController();

  final _service = ActivityService();

  List<ActivityComment> _comments = [];

  bool _loading = true;

  bool _sending = false;

  @override
  void initState() {
    super.initState();

    _load();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  Future<void> _load() async {
    final comments = await _service.getComments(widget.activity.id);

    if (mounted) {
      setState(() {
        _comments = comments;

        _loading = false;
      });
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();

    if (text.isEmpty) return;

    setState(() => _sending = true);

    try {
      final userId = SupabaseAuth().supabaseGetUserID();

      await _service.addComment(
        activityId: widget.activity.id,
        groupId: widget.activity.groupId,
        userId: userId,
        body: text,
      );

      _controller.clear();

      await _load();
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        AppStrings.errors.postCommentFailed,
        error: e,
        stack: stack,
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SizedBox(
        height: devSysHeight * AppDimensions.commentsSheetHeightRatio,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(groupGutter),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.comments.title,
                      style: sub_headline4_text.copyWith(color: groupOnSurface),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: groupOnSurface),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: LoadingWidget())
                  : _comments.isEmpty
                      ? Center(
                          child: Text(
                            AppStrings.comments.empty,
                            style: body2_text.copyWith(
                              color: groupOnSurfaceMuted,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding:
                              EdgeInsets.symmetric(horizontal: groupGutter),
                          itemCount: _comments.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(height: groupGap10),
                          itemBuilder: (context, index) {
                            final c = _comments[index];

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                UserAvatar(
                                  userID: c.userId,
                                  userName: c.userName,
                                  radius: groupGutter,
                                  fontSize: splitrFontCaption,
                                ),
                                SizedBox(width: groupGap10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            c.userName,
                                            style: body2_text.copyWith(
                                              color: groupOnSurface,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            DateFormat(AppDateFormats
                                                    .activityTimestamp)
                                                .format(c.createdAt),
                                            style: caption_text.copyWith(
                                              color: groupOnSurfaceMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: groupGapXxs),
                                      Text(
                                        c.body,
                                        style: body2_text.copyWith(
                                          color: groupOnSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
            ),
            Divider(
              color: neopopGreyBorderSoft,
              height: AppDimensions.borderWidthHairline,
            ),
            Padding(
              padding: EdgeInsets.all(groupGutter),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: body1_text.copyWith(color: groupOnSurface),
                      decoration: InputDecoration(
                        hintText: AppStrings.comments.hint,
                        hintStyle: body2_text.copyWith(
                          color: groupOnSurfaceMuted,
                        ),
                        filled: true,
                        fillColor: groupSurfaceFillWhisper,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(groupCardRadiusXl),
                          borderSide: BorderSide(
                            color: neopopGreyBorderSoft,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(groupCardRadiusXl),
                          borderSide: BorderSide(
                            color: neopopGreyBorderSoft,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(groupCardRadiusXl),
                          borderSide: const BorderSide(
                            color: neopopAccent,
                            width: AppDimensions.borderWidthFocus,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: groupGutter,
                          vertical: groupGap10,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  SizedBox(width: groupGap10),
                  IconButton(
                    onPressed: _sending ? null : _send,
                    icon: Icon(
                      Icons.send_rounded,
                      color: _sending ? groupOnSurfaceMuted : neopopAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
