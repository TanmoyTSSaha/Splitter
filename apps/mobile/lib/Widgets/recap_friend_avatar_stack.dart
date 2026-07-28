import 'package:flutter/material.dart';

import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Widgets/user_avatar.dart';

/// Staggered overlapping avatars for recap group slide (F7).
class RecapFriendAvatarStack extends StatelessWidget {
  const RecapFriendAvatarStack({
    super.key,
    required this.peers,
    this.radius = groupCarouselIconLg,
  });

  final List<Map<String, dynamic>> peers;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (peers.isEmpty) return const SizedBox.shrink();

    final display = peers.take(3).toList();
    final overlap = radius * 1.15;

    return SizedBox(
      height: radius * 2,
      width: radius * 2 + overlap * (display.length - 1),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < display.length; i++)
            Positioned(
              left: i * overlap,
              child: _StaggeredAvatar(
                index: i,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  child: UserAvatar(
                    userID: display[i]['id'] as String? ?? '',
                    userName: display[i]['name'] as String? ??
                        DisplayFallbacks.aFriend,
                    imageUrl: display[i]['imageUrl'] as String?,
                    radius: radius,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StaggeredAvatar extends StatefulWidget {
  const _StaggeredAvatar({
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  State<_StaggeredAvatar> createState() => _StaggeredAvatarState();
}

class _StaggeredAvatarState extends State<_StaggeredAvatar> {
  var _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(
      Duration(milliseconds: 60 * widget.index),
      () {
        if (mounted) setState(() => _visible = true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: AppMotion.standard,
      curve: Curves.easeOut,
      child: AnimatedScale(
        scale: _visible ? 1 : 0.85,
        duration: AppMotion.standard,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
