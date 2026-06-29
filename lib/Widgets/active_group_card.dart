import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Model/group_model.dart';

class ActiveGroupCard extends StatelessWidget {
  final GroupModel groupModel;
  final VoidCallback onTap;

  const ActiveGroupCard({
    super.key,
    required this.groupModel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine color and icon based on group name or type (fallback for now)
    final Color cardColor = _getGroupColor(groupModel.groupName ?? "");
    final IconData cardIcon = _getGroupIcon(groupModel.groupName ?? "");

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: cardColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 4,
                    backgroundColor: neopopPrimary,
                  ),
                ),
                Icon(
                  cardIcon,
                  color: Colors.white.withOpacity(0.5),
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "MONTHLY",
                  style: caption_text.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold,
                    fontSize: 8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  groupModel.groupName ?? "Untitled Group",
                  style: sub_headline5_text.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Albra',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getGroupColor(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains("apartment") || lowerName.contains("rent"))
      return const Color(0xFF1E1E1E);
    if (lowerName.contains("dining") || lowerName.contains("food"))
      return neopopAccent;
    if (lowerName.contains("trip") || lowerName.contains("travel"))
      return Colors.blueAccent;
    return neopopSecondaryGrey;
  }

  IconData _getGroupIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains("apartment") || lowerName.contains("rent"))
      return Icons.home_rounded;
    if (lowerName.contains("dining") || lowerName.contains("food"))
      return Icons.restaurant_rounded;
    return Icons.group_rounded;
  }
}
