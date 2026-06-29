import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Model/badge_model.dart';
import 'package:splitter/Services/gamification_service.dart';

class BadgesSectionWidget extends StatelessWidget {
  const BadgesSectionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BadgeModel>>(
      future: GamificationService().getBadges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final badges = snapshot.data!;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Achievements",
                style: sub_headline5_text.copyWith(
                  color: neopopBackground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: badges.map((badge) => _buildBadge(badge)).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge(BadgeModel badge) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      width: 100,
      child: Column(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: badge.isUnlocked
                  ? neopopAccent.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(
                color: badge.isUnlocked ? neopopAccent : Colors.grey,
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Opacity(
              opacity: badge.isUnlocked ? 1.0 : 0.4,
              child: Icon(
                // Using Icons for now as placeholders
                _getIconData(badge.id),
                size: 32,
                color: badge.isUnlocked ? neopopAccent : Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge.name,
            style: body2_text.copyWith(
              color: badge.isUnlocked ? neopopBackground : Colors.grey,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String badgeId) {
    switch (badgeId) {
      case 'first_trip':
        return Icons.explore;
      case 'big_spender':
        return Icons.attach_money;
      case 'settlement_hero':
        return Icons.handshake;
      case 'early_bird':
        return Icons.wb_sunny;
      default:
        return Icons.star;
    }
  }
}
