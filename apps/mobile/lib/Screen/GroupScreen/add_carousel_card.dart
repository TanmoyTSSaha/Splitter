import 'package:flutter/material.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

class AddCarouselCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const AddCarouselCard({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: groupCarouselCardWidth,
        height: groupCarouselCardHeight,
        padding: const EdgeInsets.all(groupGutter),
        decoration: BoxDecoration(
          color: neopopAccentFillSubtle,
          borderRadius: BorderRadius.circular(groupCardRadius),
          border: Border.all(
            color: neopopAccentBorder,
            width: groupAccentBorderWidth,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(groupCarouselGap),
              decoration: BoxDecoration(
                color: neopopAccentFillLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                color: neopopAccentIconStrong,
                size: groupCarouselIconLg,
              ),
            ),
            const SizedBox(height: groupCarouselGap),
            Icon(
              icon,
              color: neopopAccentIconMuted,
              size: groupCarouselIconSm,
            ),
            const SizedBox(height: groupGapXs),
            Text(
              label,
              style: caption_text.copyWith(
                color: groupOnSurface,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
