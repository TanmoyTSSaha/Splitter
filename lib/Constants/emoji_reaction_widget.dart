import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Model/activity_model.dart';
import 'package:splitter/Services/supabase_service.dart';

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
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: userReacted
                    ? neopopAccent.withOpacity(0.2)
                    : neopopOnPrimary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: userReacted
                      ? neopopAccent.withOpacity(0.5)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    '$count',
                    style: caption_text.copyWith(
                      color: userReacted
                          ? neopopAccent
                          : neopopOnPrimary.withOpacity(0.6),
                      fontWeight:
                          userReacted ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),

        // Add Reaction Button
        GestureDetector(
          onTap: () => _showEmojiPicker(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: neopopOnPrimary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.add_reaction_outlined,
              size: 16,
              color: neopopOnPrimary.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }

  void _showEmojiPicker(BuildContext context) {
    // Simple overlay with common reactions
    final commonEmojis = ['👍', '❤️', '😂', '😮', '😢', '💸'];

    showModalBottomSheet(
      context: context,
      backgroundColor: neopopBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(height_16),
          height: 120,
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
                  style: const TextStyle(fontSize: 32),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
