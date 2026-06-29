import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neopop/neopop.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Screen/GoalScreen/create_goal_screen.dart';
import 'package:splitter/Screen/GroupScreen/create_group_screen.dart';
import 'package:splitter/Screen/HomeScreen/add_personal_transaction_screen.dart';

class HomeEmptyState extends StatefulWidget {
  final String? userName;
  final Future<void> Function() onActionComplete;

  const HomeEmptyState({
    super.key,
    this.userName,
    required this.onActionComplete,
  });

  @override
  State<HomeEmptyState> createState() => _HomeEmptyStateState();
}

class _HomeEmptyStateState extends State<HomeEmptyState>
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
    final greetingName = widget.userName?.trim();
    final title = (greetingName != null && greetingName.isNotEmpty)
        ? 'Welcome, $greetingName'
        : 'Welcome to SplitO';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: width_16, vertical: height_16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: Get.height * 0.02),
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
                Text(
                  title,
                  style: const TextStyle(
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
                  'Split bills, track spending, and reach your goals. Pick a first step below.',
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
          _buildPrimaryCta(
            label: 'Create Group',
            icon: Icons.groups_2_rounded,
            onTap: () => _navigateAndRefresh(
              Get.to(() => const CreateGroupScreen()),
            ),
          ),
          SizedBox(height: height_10),
          _buildSecondaryCta(
            label: 'Add Transaction',
            icon: Icons.receipt_long_rounded,
            onTap: () => _navigateAndRefresh(
              Get.to(() => const AddPersonalTransactionScreen()),
            ),
          ),
          SizedBox(height: height_10),
          _buildSecondaryCta(
            label: 'Set a Goal',
            icon: Icons.flag_rounded,
            onTap: () => _navigateAndRefresh(
              Get.to(() => const CreateGoalScreen()),
            ),
          ),
          SizedBox(height: height_10 * 6),
        ],
      ),
    );
  }

  Widget _buildPrimaryCta({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: NeoPopButton(
        color: neopopAccent,
        buttonPosition: Position.fullBottom,
        onTapUp: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width_16, vertical: height_16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: neopopBackground, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: button_text.copyWith(
                  color: neopopBackground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryCta({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: neopopBackground,
          side: BorderSide(color: neopopBackground.withOpacity(0.2)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: button_text.copyWith(
                color: neopopBackground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
