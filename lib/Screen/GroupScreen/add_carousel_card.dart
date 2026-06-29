import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';

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
        width: 150,
        height: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: neopopAccent.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: neopopAccent.withOpacity(0.35),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: neopopAccent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                color: neopopAccent.withOpacity(0.9),
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Icon(
              icon,
              color: neopopAccent.withOpacity(0.5),
              size: 18,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: body2_text.copyWith(
                color: neopopBackground,
                fontWeight: FontWeight.w600,
                fontSize: 13,
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
