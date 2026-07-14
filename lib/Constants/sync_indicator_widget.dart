import 'package:flutter/material.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/theme_accent_colors.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Services/sync_service.dart';

/// Subtle dot indicator showing sync status on unsynced items.
class SyncIndicator extends StatelessWidget {
  final SyncStatus status;
  final double size;

  const SyncIndicator({
    required this.status,
    this.size = AppDimensions.syncIndicatorSize,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData? icon;

    switch (status) {
      case SyncStatus.synced:
        return const SizedBox.shrink(); // No indicator when synced
      case SyncStatus.syncing:
        color = neopopYellow;
        icon = null; // Will use animated dot
        break;
      case SyncStatus.error:
        color = neopopError;
        icon = Icons.error_outline_rounded;
        break;
    }

    if (icon != null) {
      return Icon(icon, color: color, size: size * 2);
    }

    // Animated pulsing dot for syncing state
    return _PulsingDot(color: color, size: size);
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const _PulsingDot({required this.color, required this.size});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.syncPulse,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(0.4 + 0.6 * _controller.value),
          ),
        );
      },
    );
  }
}

/// Banner widget showing global sync status at the top of a screen.
class SyncStatusBanner extends StatelessWidget {
  final SyncStatus status;

  const SyncStatusBanner({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    if (status == SyncStatus.synced) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: groupGutter, vertical: groupGapSm),
      color: status == SyncStatus.syncing
          ? neopopYellowFillSoft
          : neopopErrorFillSoft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SyncIndicator(status: status, size: AppDimensions.syncIndicatorPulse),
          const SizedBox(width: AppDimensions.bottomNavBottomPadding),
          Text(
            status == SyncStatus.syncing
                ? AppStrings.sync.syncing
                : AppStrings.sync.errorRetry,
            style: TextStyle(
              color: status == SyncStatus.syncing
                  ? ThemeAccentColors.oweWarning(context)
                  : neopopError,
              fontSize: splitrFontCaption,
            ),
          ),
        ],
      ),
    );
  }
}
