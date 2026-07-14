import 'package:flutter/material.dart';
import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Model/activity_model.dart';
import 'package:splitr/Services/supabase_service.dart';

/// Interactive emoji reaction row.
/// Shows existing reaction counts and allows toggling your own reaction.
class EmojiReactionWidget extends StatelessWidget {
  final List<Reaction> reactions;
  final Function(String emoji) onReactionSelected;

  const EmojiReactionWidget({
    required this.reactions,
    required this.onReactionSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Group reactions by emoji to count them
    final Map<String, List<Reaction>> grouped = {};
    for (final r in reactions) {
      if (!grouped.containsKey(r.emoji)) grouped[r.emoji] = [];
      grouped[r.emoji]!.add(r);
    }

    final currentUserId = SupabaseAuth().supabaseGetUserID();

    return Row(
      children: [
        // Existing reaction chips
        ...grouped.entries.map((entry) {
          final emoji = entry.key;
          final count = entry.value.length;
          final userReacted = entry.value.any((r) => r.userId == currentUserId);

          return GestureDetector(
            onTap: () => onReactionSelected(emoji),
            child: Container(
              margin: const EdgeInsets.only(right: groupGapSm),
              padding: const EdgeInsets.symmetric(
                  horizontal: groupGapSm, vertical: groupGapXxs),
              decoration: BoxDecoration(
                color: userReacted
                    ? neopopAccentFillStrong
                    : neopopOnPrimaryFillWhisper,
                borderRadius: BorderRadius.circular(groupControlRadius),
                border: Border.all(
                  color: userReacted ? neopopAccentIconMuted : groupTransparent,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: splitrFontBody)),
                  const SizedBox(width: groupGapXxs),
                  Text(
                    '$count',
                    style: caption_text.copyWith(
                      color:
                          userReacted ? neopopAccent : neopopOnPrimaryIconDim,
                      fontWeight:
                          userReacted ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        // Add Reaction Button
        GestureDetector(
          onTap: () => _showEmojiPicker(context),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: groupGapSm, vertical: groupGapXxs),
            decoration: BoxDecoration(
              color: neopopOnPrimaryFillWhisper,
              borderRadius: BorderRadius.circular(groupControlRadius),
            ),
            child: Icon(
              Icons.add_reaction_outlined,
              size: groupIconMd,
              color: neopopOnPrimaryIconDim,
            ),
          ),
        ),
      ],
    );
  }

  void _showEmojiPicker(BuildContext context) {
    // Simple overlay with common reactions
    const commonEmojis = DefaultReactionEmojis.list;

    showModalBottomSheet(
      context: context,
      backgroundColor: neopopBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: groupSheetTopBorderRadius,
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(groupGutter),
          height: groupEmojiPickerHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: commonEmojis.map((emoji) {
              return GestureDetector(
                onTap: () {
                  onReactionSelected(emoji);
                  Navigator.pop(context);
                },
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: splitrFontHeadline1),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
