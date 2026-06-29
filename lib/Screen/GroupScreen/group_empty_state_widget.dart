import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neopop/neopop.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Screen/GroupScreen/create_group_screen.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';

class GroupEmptyState extends StatefulWidget {
  final Future<void> Function() onActionComplete;

  const GroupEmptyState({
    super.key,
    required this.onActionComplete,
  });

  @override
  State<GroupEmptyState> createState() => _GroupEmptyStateState();
}

class _GroupEmptyStateState extends State<GroupEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigateAndRefresh(Future<dynamic>? navigation) async {
    final result = await navigation;
    if (result == true) {
      await widget.onActionComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: groupGutter,
        vertical: groupGapMd,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: Get.height * 0.04),
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: child,
              );
            },
            child: Container(
              height: 220,
              width: 220,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage(
                    'assets/dev_images/premium_empty_state_splitting_bills.png',
                  ),
                  fit: BoxFit.contain,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: neopopAccent.withOpacity(0.12),
                    blurRadius: 60,
                    spreadRadius: -10,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: height_16 * 2),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                const Text(
                  'No groups yet',
                  style: TextStyle(
                    fontFamily: 'Albra',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: neopopBackground,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height_10),
                Text(
                  'Create a group to split bills with friends, roommates, or coworkers.',
                  style: body1_text.copyWith(
                    color: neopopGrey,
                    height: 1.5,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: height_16 * 2),
          SizedBox(
            width: double.infinity,
            child: NeoPopButton(
              color: neopopAccent,
              buttonPosition: Position.fullBottom,
              onTapUp: () => _navigateAndRefresh(
                Get.to(() => const CreateGroupScreen()),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width_16,
                  vertical: height_16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.groups_2_rounded,
                      color: neopopBackground,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Create Group',
                      style: button_text.copyWith(
                        color: neopopBackground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: height_10 * 6),
        ],
      ),
    );
  }
}
