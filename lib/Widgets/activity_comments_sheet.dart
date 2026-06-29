import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splitter/Constants/app_themes.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/shared.dart';
import 'package:splitter/Model/activity_model.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitter/Services/activity_service.dart';
import 'package:splitter/Services/supabase_service.dart';
import 'package:splitter/Widgets/user_avatar.dart';

/// Inline comment thread for a single activity feed item.
class ActivityCommentsSheet extends StatefulWidget {
  final ActivityItem activity;

  const ActivityCommentsSheet({required this.activity, super.key});

  static Future<void> show(BuildContext context, ActivityItem activity) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not post comment: $e')),
        );
      }
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
        height: devSysHeight * 0.55,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(height_16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Comments',
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
                            'Start the conversation',
                            style: body2_text.copyWith(
                              color: groupOnSurfaceMuted,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: width_16),
                          itemCount: _comments.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(height: height_10),
                          itemBuilder: (context, index) {
                            final c = _comments[index];
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                UserAvatar(
                                  userID: c.userId,
                                  userName: c.userName,
                                  radius: 16,
                                  fontSize: 12,
                                ),
                                SizedBox(width: width_10),
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
                                            DateFormat('MMM d, h:mm a')
                                                .format(c.createdAt),
                                            style: caption_text.copyWith(
                                              color: groupOnSurfaceMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
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
            Divider(color: neopopGrey.withOpacity(0.3), height: 1),
            Padding(
              padding: EdgeInsets.all(height_16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: body1_text.copyWith(color: groupOnSurface),
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: body2_text.copyWith(
                          color: groupOnSurfaceMuted,
                        ),
                        filled: true,
                        fillColor: groupOnSurface.withOpacity(0.04),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: neopopGrey.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: neopopGrey.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: neopopAccent,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: width_16,
                          vertical: height_10,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  SizedBox(width: width_10),
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
