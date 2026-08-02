import 'package:flutter/material.dart';
import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/gradient_mesh_background.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

/// Full-bleed NeoPOP dark shell for monthly recap story slides.
class RecapSlideScaffold extends StatelessWidget {
  const RecapSlideScaffold({
    required this.child,
    this.showClose = false,
    this.onClose,
    super.key,
  });

  final Widget child;
  final bool showClose;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: neopopBackground,
      child: GradientMeshBackground(
        child: Stack(
          fit: StackFit.expand,
          children: [
            child,
            if (showClose)
              Positioned(
                top: MediaQuery.paddingOf(context).top + groupGapSm,
                right: groupGapLg,
                child: GestureDetector(
                  onTap: onClose ??
                      () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                  child: Container(
                    padding: const EdgeInsets.all(groupGapSm),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppPalette.recapBorder),
                      color: neopopBackground.withValues(alpha: 0.6),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppPalette.recapOnSurface,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
