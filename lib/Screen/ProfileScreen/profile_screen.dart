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
import 'package:splitter/Screen/ProfileScreen/edit_currency_screen.dart';
import 'package:splitter/Screen/Insights/expense_insights_screen.dart';
import 'package:splitter/Screen/ProfileScreen/monthly_recap_screen.dart';
import 'package:splitter/Widgets/animated_glass_bottom_nav_bar.dart';
import 'package:splitter/Widgets/premium_gate.dart';
import 'package:splitter/Screen/ProfileScreen/notifications_screen.dart';
import 'package:splitter/Screen/ProfileScreen/personal_details_screen.dart';
import 'package:splitter/Screen/ProfileScreen/premium_plan_screen.dart';
import 'package:splitter/Screen/ProfileScreen/request_feature_screen.dart';
import 'package:splitter/Services/biometric_auth_service.dart';
import 'package:splitter/Controllers/currency_controller.dart';
import 'package:splitter/Services/SupabaseServices/transaction_service.dart';
import 'package:splitter/Services/supabase_service.dart';
import 'package:splitter/Widgets/user_avatar.dart';

// ─── Light palette for this screen ───────────────────────────────────────────
const Color _bg = Color(0xFFF0F0F5);
const Color _cardBg = Colors.white;
const Color _sectionLabel = Color(0xFF9E9E9E);
const Color _titleColor = Color(0xFF1A1A1A);
const Color _subtitleColor = Color(0xFF9E9E9E);
const Color _dividerColor = Color(0xFFEEEEEE);
const Color _logoutRed = Color(0xFFE53935);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ─── Number formatter ───────────────────────────────────────────────────────
  String _formatAmount(double value) {
    String trimDecimal(double v) {
      // Show one decimal only when needed
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

  // ─── Logout dialog ──────────────────────────────────────────────────────────
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

  // ─── Data fetch ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> _fetchProfileData() async {
    final userId = SupabaseAuth().supabaseGetUserID();
    // Run profile + stats fetches in parallel
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
        backgroundColor: _bg,
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
                padding: const EdgeInsets.fromLTRB(20, 24, 20, bottomNavClearance),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GradientMeshBackground(
                      child: GlassCard(
                        margin: EdgeInsets.zero,
                        opacity: 0.14,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 24),
                        child: Column(
                          children: [
                            _buildAvatar(user),
                            const SizedBox(height: 16),
                            Text(
                              "${user.firstName ?? 'User'} ${user.lastName ?? ''}"
                                  .trim(),
                              style: const TextStyle(
                                fontFamily: 'Albra',
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: _titleColor,
                                height: 1.1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "JUST VIBING",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _subtitleColor,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildStatChips(stats),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── ACCOUNT INFO ──────────────────────────────────────────
                    _buildSectionHeader("ACCOUNT INFO"),
                    const SizedBox(height: 10),
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
                        icon: Icons.calendar_month_outlined,
                        title: "Monthly Recap",
                        subtitle: "Your spending summary",
                        onTap: () => Get.to(() => MonthlyRecapScreen()),
                      ),
                      _buildMenuTile(
                        icon: Icons.insights_outlined,
                        title: "Expense Insights",
                        subtitle: "Trends, unusual spends, settle-up health",
                        onTap: () async {
                          final ok = await requirePremium(
                            featureLabel: 'Advanced Analytics',
                          );
                          if (ok) {
                            Get.to(() => const ExpenseInsightsScreen());
                          }
                        },
                      ),
                      _buildMenuTile(
                        icon: Icons.diamond_outlined,
                        title: "Premium Plan",
                        subtitle: "Upgrade your experience",
                        onTap: () => Get.to(() => const PremiumPlanScreen()),
                        isLast: true,
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // ── APP SETTINGS ──────────────────────────────────────────
                    _buildSectionHeader("APP SETTINGS"),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 24),

                    // ── GENEROUS ──────────────────────────────────────────────
                    _buildSectionHeader("GENEROUS"),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 24),

                    // ── LOGOUT (separated tile) ───────────────────────────────
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
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Avatar: UserAvatar widget + soft diffused glow ──────────────────────
  Widget _buildAvatar(UserDetails user) {
    const double avatarRadius = 54;
    // White ring is slightly larger than avatar — creates visible white border
    const double ringRadius = avatarRadius + 6;

    return Stack(
      alignment: Alignment.center,
      children: [
        // White ring with soft two-tone diffused glow (shadow approach)
        // The BoxShadows diffuse INTO the background — no hard colored ring.
        Container(
          width: ringRadius * 2,
          height: ringRadius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              // Green glow — bleeds to the bottom-left into the background
              BoxShadow(
                color: const Color(0xFFB5F542).withOpacity(0.75),
                blurRadius: 32,
                spreadRadius: 4,
                offset: const Offset(-6, 6),
              ),
              // Purple glow — bleeds to the top-right into the background
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(0.75),
                blurRadius: 32,
                spreadRadius: 4,
                offset: const Offset(6, -6),
              ),
            ],
          ),
        ),
        // UserAvatar (DiceBear identicon, same as app bar)
        UserAvatar(
          userID: user.userID ?? '',
          userName: '${user.firstName ?? 'U'} ${user.lastName ?? ''}',
          imageUrl: user.profilePictureURL,
          radius: avatarRadius,
        ),
        // Edit badge
        Positioned(
          bottom: 6,
          right: 6,
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
    );
  }

  // ─── Stat chips ──────────────────────────────────────────────────────────
  Widget _buildStatChips(Map<String, double> stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildChip(
              label: "TOTAL SPENT",
              value: _formatAmount(stats['totalSpent'] ?? 0),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildChip(
              label: "TOTAL RECEIVED",
              value: _formatAmount(stats['totalReceived'] ?? 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _dividerColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _subtitleColor,
                letterSpacing: 0.8,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _titleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Section header ──────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _sectionLabel,
          letterSpacing: 1.8,
        ),
      ),
    );
  }

  // ─── Card wrapper — sharp rectangular, 0 rounded corners ─────────────────
  Widget _buildMenuCard(List<Widget> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.zero,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: tiles),
    );
  }

  // ─── Individual menu tile — rectangular, square icon box ─────────────────
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
    final effectiveIcon = iconColor ?? _titleColor;
    final effectiveTitle = titleColor ?? _titleColor;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Square icon box: black border, grey bg, black icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    border: Border.all(
                      color: const Color(0xFF1A1A1A),
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
                // Text
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
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: _subtitleColor,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showChevron)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: _subtitleColor,
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
            color: _dividerColor,
            indent: 70,
          ),
      ],
    );
  }

  // ─── Biometric tile (inline, with toggle) ────────────────────────────────
  Widget _buildBiometricTile() {
    return _BiometricMenuTile();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Biometric toggle tile (matches card tile style)
// ─────────────────────────────────────────────────────────────────────────────
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
              // Icon box
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.fingerprint_rounded,
                  size: 20,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(width: 14),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Biometric Lock",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _isSupported
                          ? "Require auth on app open"
                          : "Not supported on this device",
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Color(0xFF9E9E9E),
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
        // Divider leading into next tile
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
