import 'package:flutter/material.dart';
import 'package:splitr/Constants/app_assets.dart';

/// Maps achievement [icon_key] from DB to bundled asset paths.
/// ponytail: missing PNGs fall back to Material icons until art ships.
abstract final class AchievementIconMap {
  static String? assetFor(String iconKey) {
    switch (iconKey) {
      case 'explorer':
        return AppAssets.badgeExplorer;
      case 'money_bag':
        return AppAssets.badgeMoneyBag;
      case 'handshake':
        return AppAssets.badgeHandshake;
      case 'sun':
        return AppAssets.badgeSun;
      default:
        return null;
    }
  }

  static IconData iconFor(String iconKey) {
    switch (iconKey) {
      case 'explorer':
        return Icons.explore;
      case 'money_bag':
        return Icons.attach_money;
      case 'handshake':
        return Icons.handshake;
      case 'sun':
        return Icons.wb_sunny;
      case 'group':
        return Icons.groups;
      case 'friend':
        return Icons.person_add;
      case 'split':
      case 'split_regular':
        return Icons.receipt_long;
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      case 'goal':
        return Icons.flag_outlined;
      case 'loan':
        return Icons.handshake_outlined;
      case 'social':
        return Icons.people;
      default:
        return Icons.emoji_events;
    }
  }
}
