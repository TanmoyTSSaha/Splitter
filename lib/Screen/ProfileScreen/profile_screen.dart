import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/glass_card.dart';
import 'package:splitter/Constants/gradient_mesh_background.dart';
import 'package:splitter/Constants/shared.dart';
import 'package:splitter/Model/user_details_model.dart';
import 'package:splitter/Screen/AuthScreens/login_screen.dart';
import 'package:splitter/Screen/FeatureComingUp/feature_coming_up_next.dart';
import 'package:splitter/Screen/FriendScreen/friends_screen.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitter/Screen/ProfileScreen/badges_section_widget.dart';
import 'package:splitter/Screen/ProfileScreen/edit_currency_screen.dart';
import 'package:splitter/Screen/Insights/expense_insights_screen.dart';
import 'package:splitter/Widgets/animated_glass_bottom_nav_bar.dart';
import 'package:splitter/Screen/ProfileScreen/notifications_screen.dart';
import 'package:splitter/Screen/ProfileScreen/personal_details_screen.dart';
import 'package:splitter/Screen/ProfileScreen/premium_plan_screen.dart';
import 'package:splitter/Screen/ProfileScreen/request_feature_screen.dart';
import 'package:splitter/Services/biometric_auth_service.dart';
import 'package:splitter/Controllers/currency_controller.dart';
import 'package:splitter/Services/SupabaseServices/transaction_service.dart';
import 'package:splitter/Services/supabase_service.dart';
import 'package:splitter/Widgets/user_avatar.dart';

const Color _logoutRed = Color(0xFFE53935);
const double _avatarRadius = 54;
const double _avatarRingRadius = _avatarRadius + 6;
const double _avatarShadowBleed = 44;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _formatAmount(double value) {
    String trimDecimal(double v) {
      if (v == v.truncateToDouble()) return v.truncate().toString();
      return v.toStringAsFixed(1);
    }

    final abs = value.abs();
    final sym = Get.find<CurrencyController>().symbol;
    if (abs >= 1e7) return '$sym${trimDecimal(abs / 1e7)}Cr';
    if (abs >= 1e5) return '$sym${trimDecimal(abs / 1e5)}L';
    if (abs >= 1e3) return '$sym${trimDecimal(abs / 1e3)}K';
    return '$sym${abs.toStringAsFixed(0)}';
  }

  Future<void> _showLogOutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: neopopYellow,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          titlePadding: EdgeInsets.all(height_16),
          actionsPadding: EdgeInsets.all(height_16),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          title: Text(
            "Are you sure?",
            style: sub_headline5_text.copyWith(
              color: neopopBackground,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: Text(
            "Do you really wanted to logout?",
            style: caption_text.copyWith(
              color: neopopBackground,
            ),
          ),
          actions: [
            CustomSecondaryButton(
              buttonText: "Yes",
              onPressed: () {
                SupabaseAuth().supabaseSignOut();
                setState(() {
                  Get.offAll(() => const LoginScreen());
                });
              },
              buttonHeight: height_16 * 2.5,
              buttonWidth: devSysWidth * 0.26,
            ),
            CustomSecondaryButton(
              buttonText: "No",
              onPressed: () {
                Get.back();
              },
              buttonHeight: height_16 * 2.5,
              buttonWidth: devSysWidth * 0.26,
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _fetchProfileData() async {
    final userId = SupabaseAuth().supabaseGetUserID();
    final results = await Future.wait([
      SupabaseDatabase().getCurrentUserProfile(userID: userId),
      TransactionService().getLifetimeStats(userID: userId),
    ]);
    return {
      'user': results[0],
      'stats': results[1],
    };
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _fetchProfileData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: LoadingWidget());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Something went wrong!\n${snapshot.error}",
                  style: body2_text.copyWith(color: neopopError),
                  textAlign: TextAlign.center,
                ),
              );
            }

            final user = snapshot.data!['user'] as UserDetails;
            final stats = snapshot.data!['stats'] as Map<String, double>;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  groupGutter,
                  groupGapLg,
                  groupGutter,
                  bottomNavClearance,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHeroCard(user, stats),
                    const SizedBox(height: groupGapXl),
                    const BadgesSectionWidget(),
                    const SizedBox(height: groupGapLg),
                    _buildSectionHeader("ACCOUNT INFO"),
                    const SizedBox(height: groupGapSm),
                    _buildMenuCard([
                      _buildMenuTile(
                        icon: Icons.person_outline_rounded,
                        title: "Personal Details",
                        subtitle: "Name, email, phone number",
                        onTap: () => Get.to(
                          () => PersonalDetailsScreen(initialData: user),
                        ),
                      ),
                      _buildMenuTile(
                        icon: Icons.people_outline_rounded,
                        title: "Friends",
                        subtitle: "Manage your connections",
                        onTap: () => Get.to(() => const FriendsScreen()),
                      ),
                      _buildMenuTile(
                        icon: Icons.insights_outlined,
                        title: "Expense Insights",
                        subtitle: "Trends, unusual spends, settle-up health",
                        onTap: () => Get.to(() => const ExpenseInsightsScreen()),
                      ),
                      _buildMenuTile(
                        icon: Icons.diamond_outlined,
                        title: "Premium Plan",
                        subtitle: "Upgrade your experience",
                        onTap: () => Get.to(() => const PremiumPlanScreen()),
                        isLast: true,
                      ),
                    ]),
                    const SizedBox(height: groupGapLg),
                    _buildSectionHeader("APP SETTINGS"),
                    const SizedBox(height: groupGapSm),
                    _buildMenuCard([
                      _buildBiometricTile(),
                      _buildMenuTile(
                        icon: Icons.currency_rupee_rounded,
                        title: "Edit Currency",
                        subtitle: "Change your default currency",
                        onTap: () => Get.to(() => const EditCurrencyScreen()),
                      ),
                      _buildMenuTile(
                        icon: Icons.notifications_outlined,
                        title: "Notifications",
                        subtitle: "Expense alerts, reminders",
                        onTap: () =>
                            Get.to(() => NotificationsScreen(user: user)),
                        isLast: true,
                      ),
                    ]),
                    const SizedBox(height: groupGapLg),
                    _buildSectionHeader("GENEROUS"),
                    const SizedBox(height: groupGapSm),
                    _buildMenuCard([
                      _buildMenuTile(
                        icon: Icons.volunteer_activism_outlined,
                        title: "Donate",
                        subtitle: "Support the project",
                        onTap: () => Get.to(() => const FeatureComingUpNext()),
                      ),
                      _buildMenuTile(
                        icon: Icons.edit_note_rounded,
                        title: "Request a Feature",
                        subtitle: "Tell us what you need",
                        onTap: () =>
                            Get.to(() => RequestFeatureScreen(user: user)),
                        isLast: true,
                      ),
                    ]),
                    const SizedBox(height: groupGapLg),
                    _buildMenuCard([
                      _buildMenuTile(
                        icon: Icons.logout_rounded,
                        title: "Logout",
                        subtitle: "Sign out of your account",
                        onTap: _showLogOutDialog,
                        titleColor: _logoutRed,
                        iconColor: _logoutRed,
                        showChevron: false,
                        isLast: true,
                      ),
                    ]),
                    const SizedBox(height: groupGapXl),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroCard(UserDetails user, Map<String, double> stats) {
    return GradientMeshBackground(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: groupGapSm),
          _buildAvatar(user),
          const SizedBox(height: groupGapMd),
          GlassCard(
            margin: EdgeInsets.zero,
            opacity: 0.12,
            padding: const EdgeInsets.fromLTRB(
              groupGapMd,
              groupGapLg,
              groupGapMd,
              groupGapLg,
            ),
            child: Column(
              children: [
                Text(
                  "${user.firstName ?? 'User'} ${user.lastName ?? ''}".trim(),
                  style: const TextStyle(
                    fontFamily: 'Albra',
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: groupOnSurface,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  "JUST VIBING",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: groupOnSurfaceMuted,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: groupGapMd),
                _buildStatChips(stats),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(UserDetails user) {
    final ringSize = _avatarRingRadius * 2;
    final frameSize = ringSize + _avatarShadowBleed * 2;

    return GestureDetector(
      onTap: () => Get.to(() => PersonalDetailsScreen(initialData: user)),
      child: SizedBox(
        width: frameSize,
        height: frameSize,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: ringSize,
              height: ringSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB5F542).withValues(alpha: 0.6),
                    blurRadius: 42,
                    spreadRadius: 0,
                    offset: const Offset(-10, 12),
                  ),
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.55),
                    blurRadius: 42,
                    spreadRadius: 0,
                    offset: const Offset(10, -12),
                  ),
                  BoxShadow(
                    color: neopopAccent.withValues(alpha: 0.14),
                    blurRadius: 64,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
            UserAvatar(
              userID: user.userID ?? '',
              userName: '${user.firstName ?? 'U'} ${user.lastName ?? ''}',
              imageUrl: user.profilePictureURL,
              radius: _avatarRadius,
            ),
            Positioned(
              bottom: _avatarShadowBleed + 6,
              right: _avatarShadowBleed + 6,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: neopopYellow,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 15,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChips(Map<String, double> stats) {
    return Row(
      children: [
        Expanded(
          child: _buildChip(
            label: "TOTAL SPENT",
            value: _formatAmount(stats['totalSpent'] ?? 0),
          ),
        ),
        const SizedBox(width: groupCarouselGap),
        Expanded(
          child: _buildChip(
            label: "TOTAL RECEIVED",
            value: _formatAmount(stats['totalReceived'] ?? 0),
          ),
        ),
      ],
    );
  }

  Widget _buildChip({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "$label: ",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: groupOnSurfaceMuted,
                  letterSpacing: 0.8,
                ),
              ),
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: groupOnSurface,
                ),
              ),
            ],
          ),
          maxLines: 1,
          softWrap: false,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: groupOnSurfaceMuted,
          letterSpacing: 1.8,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> tiles) {
    return GlassCard(
      margin: EdgeInsets.zero,
      opacity: 0.09,
      padding: EdgeInsets.zero,
      child: Column(children: tiles),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
    bool showChevron = true,
    bool isLast = false,
  }) {
    final effectiveIcon = iconColor ?? groupOnSurface;
    final effectiveTitle = titleColor ?? groupOnSurface;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    border: Border.all(
                      color: groupOnSurface,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: effectiveIcon,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Albra',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: effectiveTitle,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: groupOnSurfaceMuted,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showChevron)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: groupOnSurfaceMuted,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            color: const Color(0xFFEEEEEE),
            indent: 70,
          ),
      ],
    );
  }

  Widget _buildBiometricTile() {
    return _BiometricMenuTile();
  }
}

class _BiometricMenuTile extends StatefulWidget {
  @override
  State<_BiometricMenuTile> createState() => _BiometricMenuTileState();
}

class _BiometricMenuTileState extends State<_BiometricMenuTile> {
  final BiometricAuthService _bioService = BiometricAuthService();
  bool _isSupported = false;
  bool _isEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final supported = await _bioService.isDeviceSupported();
    final enabled = await _bioService.isEnabled();
    if (mounted) {
      setState(() {
        _isSupported = supported;
        _isEnabled = enabled;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 66,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: groupOnSurface.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.fingerprint_rounded,
                  size: 20,
                  color: groupOnSurface,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Biometric Lock",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: groupOnSurface,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _isSupported
                          ? "Require auth on app open"
                          : "Not supported on this device",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: groupOnSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.82,
                child: Switch(
                  value: _isEnabled,
                  thumbColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? neopopAccent
                        : Colors.white,
                  ),
                  trackColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? neopopAccent.withOpacity(0.4)
                        : Colors.grey.shade300,
                  ),
                  onChanged: _isSupported
                      ? (value) async {
                          if (value) {
                            final messenger = ScaffoldMessenger.of(context);
                            final result = await _bioService.authenticate(
                              reason:
                                  'Verify your fingerprint to enable biometric lock',
                            );
                            if (!mounted) return;
                            if (!result.isSuccess) {
                              if (result.status !=
                                      BiometricAuthStatus.cancelled &&
                                  result.message != null) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(result.message!),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                              return;
                            }
                            await _bioService.setEnabled(true);
                            setState(() => _isEnabled = true);
                          } else {
                            await _bioService.setEnabled(false);
                            setState(() => _isEnabled = false);
                          }
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 68),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade100,
          ),
        ),
      ],
    );
  }
}
