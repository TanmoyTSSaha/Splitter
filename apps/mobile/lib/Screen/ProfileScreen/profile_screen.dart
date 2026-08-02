import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/theme_accent_colors.dart';
import 'package:splitr/Constants/glass_card.dart';
import 'package:splitr/Constants/gradient_mesh_background.dart';
import 'package:splitr/Constants/shared.dart';
import 'package:splitr/Model/user_details_model.dart';
import 'package:splitr/Screen/AuthScreens/login_screen.dart';
import 'package:splitr/Screen/FriendScreen/friends_screen.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Screen/ProfileScreen/badges_section_widget.dart';
import 'package:splitr/Screen/ProfileScreen/donate_screen.dart';
import 'package:splitr/Screen/ProfileScreen/change_password_screen.dart';
import 'package:splitr/Screen/ProfileScreen/sms_expense_drafts_screen.dart';
import 'package:splitr/Screen/ProfileScreen/splitwise_import_screen.dart';
import 'package:splitr/Controllers/theme_controller.dart';
import 'package:splitr/Screen/ProfileScreen/edit_currency_screen.dart';
import 'package:splitr/Screen/Insights/expense_insights_screen.dart';
import 'package:splitr/Widgets/animated_glass_bottom_nav_bar.dart';
import 'package:splitr/Screen/ProfileScreen/monthly_recap_screen.dart';
import 'package:splitr/Screen/ProfileScreen/personal_budgets_screen.dart';
import 'package:splitr/Screen/ProfileScreen/personal_details_screen.dart';
import 'package:splitr/Screen/ProfileScreen/premium_plan_screen.dart';
import 'package:splitr/Screen/SplashScreen/splash_preview_screen.dart';
import 'package:splitr/Screen/ProfileScreen/request_feature_screen.dart';
import 'package:splitr/Services/biometric_auth_service.dart';
import 'package:splitr/Controller/profile_controller.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Controllers/premium_subscription_controller.dart';
import 'package:splitr/Screen/ProfileScreen/notifications_screen.dart';
import 'package:splitr/Services/recap_drop_service.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Widgets/pulsing_badge_dot.dart';
import 'package:splitr/Widgets/user_avatar.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_keys.dart';

const Color _logoutRed = neopopError;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final RecapDropService _recapDropService = RecapDropService();
  bool _showRecapDot = false;

  @override
  void initState() {
    super.initState();
    _refreshRecapDot();
  }

  Future<void> _refreshRecapDot() async {
    final show = await _recapDropService.shouldShowProfileDot();
    if (mounted) setState(() => _showRecapDot = show);
  }

  String _formatAmount(double value) {
    return AppStringFormat.amountCompact(
      Get.find<CurrencyController>().symbol,
      value,
    );
  }

  Future<void> _showThemePicker() async {
    final theme = Get.find<ThemeController>();
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(AppStrings.profile.themeLight),
              onTap: () {
                theme.setMode(ThemeMode.light);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: Text(AppStrings.profile.themeDark),
              onTap: () {
                theme.setMode(ThemeMode.dark);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: Text(AppStrings.profile.themeSystem),
              onTap: () {
                theme.setMode(ThemeMode.system);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
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
          titlePadding: const EdgeInsets.all(groupGutter),
          actionsPadding: const EdgeInsets.all(groupGutter),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          title: Text(
            AppStrings.profile.logoutConfirmTitle,
            style: sub_headline5_text.copyWith(
              color: neopopBackground,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: Text(
            AppStrings.profile.logoutConfirmBody,
            style: caption_text.copyWith(
              color: neopopBackground,
            ),
          ),
          actions: [
            CustomSecondaryButton(
              buttonText: AppStrings.actions.yes,
              onPressed: () {
                SupabaseAuth().supabaseSignOut();
                setState(() {
                  Get.offAll(() => const LoginScreen());
                });
              },
              buttonHeight: 40,
              buttonWidth: devSysWidth * 0.26,
            ),
            CustomSecondaryButton(
              buttonText: AppStrings.actions.no,
              onPressed: () {
                Get.back();
              },
              buttonHeight: 40,
              buttonWidth: devSysWidth * 0.26,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = Get.find<ProfileController>();
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Obx(() {
          if (profile.isLoading.value && profile.user.value == null) {
            return const Center(child: LoadingWidget());
          }
          if (profile.errorMessage.value != null) {
            return Center(
              child: Text(
                profile.errorMessage.value!,
                style: body2_text.copyWith(color: neopopError),
                textAlign: TextAlign.center,
              ),
            );
          }

          final user = profile.user.value!;
          final stats = profile.stats;

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
                  _buildSectionHeader(AppStrings.profile.accountInfo),
                  const SizedBox(height: groupGapSm),
                  _buildMenuCard([
                    _buildMenuTile(
                      icon: Icons.person_outline_rounded,
                      title: AppStrings.profile.personalDetails,
                      subtitle: AppStrings.profile.personalDetailsSubtitle,
                      onTap: () => Get.to(
                        () => PersonalDetailsScreen(initialData: user),
                      ),
                    ),
                    _buildMenuTile(
                      icon: Icons.people_outline_rounded,
                      title: AppStrings.friends.tabFriends,
                      subtitle: AppStrings.profile.friendsSubtitle,
                      onTap: () => Get.to(() => const FriendsScreen()),
                    ),
                    _buildMenuTile(
                      icon: Icons.insights_outlined,
                      title: AppStrings.insights.title,
                      subtitle: AppStrings.profile.insightsSubtitle,
                      onTap: () => Get.to(() => const ExpenseInsightsScreen()),
                    ),
                    _buildMenuTile(
                      icon: Icons.calendar_month_outlined,
                      title: AppStrings.profile.monthlyRecap,
                      subtitle: AppStrings.profile.monthlyRecapSubtitle,
                      showBadgeDot: _showRecapDot,
                      onTap: () async {
                        await Get.to(() => const MonthlyRecapScreen());
                        _refreshRecapDot();
                      },
                    ),
                    _buildMenuTile(
                      icon: Icons.diamond_outlined,
                      title: AppStrings.profile.premiumPlan,
                      subtitle: AppStrings.profile.premiumPlanSubtitle,
                      onTap: () => Get.to(() => const PremiumPlanScreen()),
                      isLast: true,
                    ),
                  ]),
                  const SizedBox(height: groupGapLg),
                  _buildSectionHeader(AppStrings.profile.appSettings),
                  const SizedBox(height: groupGapSm),
                  _buildMenuCard([
                    _buildBiometricTile(),
                    _buildMenuTile(
                      icon: Icons.file_upload_outlined,
                      title: AppStrings.profile.importSplitwise,
                      subtitle: AppStrings.profile.importSplitwiseSubtitle,
                      onTap: () => Get.to(() => const SplitwiseImportScreen()),
                    ),
                    _buildMenuTile(
                      icon: Icons.sms_outlined,
                      title: AppStrings.profile.smsExpenseDraft,
                      subtitle: AppStrings.profile.smsExpenseDraftSubtitle,
                      onTap: () => Get.to(() => const SmsExpenseDraftsScreen()),
                    ),
                    _buildMenuTile(
                      icon: Icons.lock_outline_rounded,
                      title: AppStrings.profile.changePassword,
                      subtitle: AppStrings.profile.changePasswordSubtitle,
                      onTap: () => Get.to(() => const ChangePasswordScreen()),
                    ),
                    _buildMenuTile(
                      icon: Icons.dark_mode_outlined,
                      title: AppStrings.profile.appearance,
                      subtitle: AppStrings.profile.appearanceSubtitle,
                      onTap: _showThemePicker,
                    ),
                    _buildMenuTile(
                      icon: Icons.currency_rupee_rounded,
                      title: AppStrings.profile.editCurrency,
                      subtitle: AppStrings.profile.editCurrencySubtitle,
                      onTap: () => Get.to(() => const EditCurrencyScreen()),
                    ),
                    _buildMenuTile(
                      icon: Icons.pie_chart_outline_rounded,
                      title: AppStrings.profile.budgets,
                      subtitle: AppStrings.profile.budgetsSubtitle,
                      onTap: () => Get.to(() => const PersonalBudgetsScreen()),
                    ),
                    _buildMenuTile(
                      icon: Icons.notifications_outlined,
                      title: AppStrings.notifications.title,
                      subtitle: AppStrings.profile.notificationsSubtitle,
                      onTap: () =>
                          Get.to(() => const NotificationsScreen()),
                      isLast: true,
                    ),
                  ]),
                  const SizedBox(height: groupGapLg),
                  _buildSectionHeader(AppStrings.profile.generous),
                  const SizedBox(height: groupGapSm),
                  _buildMenuCard([
                    _buildMenuTile(
                      icon: Icons.volunteer_activism_outlined,
                      title: AppStrings.profile.donate,
                      subtitle: AppStrings.profile.donateSubtitle,
                      onTap: () => Get.to(() => const DonateScreen()),
                    ),
                    _buildMenuTile(
                      icon: Icons.edit_note_rounded,
                      title: AppStrings.profile.requestFeature,
                      subtitle: AppStrings.profile.requestFeatureSubtitle,
                      onTap: () =>
                          Get.to(() => RequestFeatureScreen(user: user)),
                      isLast: true,
                    ),
                  ]),
                  if (kDebugMode) ...[
                    const SizedBox(height: groupGapLg),
                    _buildSectionHeader('DEBUG'),
                    const SizedBox(height: groupGapSm),
                    _buildMenuCard([
                      _buildMenuTile(
                        icon: Icons.play_circle_outline,
                        title: AppStrings.profile.splashPreview,
                        subtitle: AppStrings.profile.splashPreviewSubtitle,
                        onTap: () => Get.to(() => const SplashPreviewScreen()),
                        isLast: true,
                      ),
                    ]),
                  ],
                  const SizedBox(height: groupGapLg),
                  _buildMenuCard([
                    _buildMenuTile(
                      icon: Icons.logout_rounded,
                      title: AppStrings.profile.logout,
                      subtitle: AppStrings.profile.logoutSubtitle,
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
        }),
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
                  "${user.firstName ?? AppStrings.profile.defaultUserName} ${user.lastName ?? ''}"
                      .trim(),
                  style: TextStyle(
                    fontFamily: kFontAlbra,
                    fontSize: splitrFontHeadline1Sm,
                    fontWeight: FontWeight.bold,
                    color: groupOnSurface,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Obx(() {
                  final isPro =
                      Get.find<PremiumSubscriptionController>().isPremium.value;
                  return Text(
                    isPro
                        ? AppStrings.profile.proMember
                        : AppStrings.profile.justVibing,
                    style: TextStyle(
                      fontFamily: kFontPoppins,
                      fontSize: splitrFontCaptionSm,
                      fontWeight: FontWeight.w600,
                      color: isPro
                          ? ThemeAccentColors.highlight(context)
                          : groupOnSurfaceMuted,
                      letterSpacing: 2.0,
                    ),
                  );
                }),
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
    final avatarRadius = AppDimensions.profileHeroAvatarRadius;
    final ringRadius = avatarRadius + AppDimensions.profileHeroAvatarRingOffset;
    final shadowBleed = AppDimensions.profileHeroAvatarShadowBleed;
    final ringSize = ringRadius * 2;
    final frameSize = ringSize + shadowBleed * 2;

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
                    color: AppPalette.avatarGlowGreen.withValues(alpha: 0.6),
                    blurRadius: 42,
                    spreadRadius: 0,
                    offset: const Offset(-10, 12),
                  ),
                  BoxShadow(
                    color: AppPalette.accentPurple.withValues(alpha: 0.55),
                    blurRadius: 42,
                    spreadRadius: 0,
                    offset: const Offset(10, -12),
                  ),
                  BoxShadow(
                    color: neopopAccentFillMuted,
                    blurRadius: 64,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
            UserAvatar(
              userID: user.userID ?? '',
              userName:
                  '${user.firstName ?? AppStrings.profile.defaultUserName[0]} ${user.lastName ?? ''}',
              imageUrl: user.profilePictureURL,
              radius: avatarRadius,
            ),
            Obx(() {
              if (!Get.find<PremiumSubscriptionController>().isPremium.value) {
                return const SizedBox.shrink();
              }
              return Positioned(
                top: shadowBleed + 4,
                left: shadowBleed + 4,
                child: Container(
                  padding: const EdgeInsets.all(groupGapXxs),
                  decoration: BoxDecoration(
                    color: neopopYellow,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    size: groupIconMd,
                    color: neopopBackground,
                  ),
                ),
              );
            }),
            Positioned(
              bottom: shadowBleed + 6,
              right: shadowBleed + 6,
              child: Container(
                width: AppDimensions.profileEditBadgeSize,
                height: AppDimensions.profileEditBadgeSize,
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
                  color: groupOnSurface,
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
            label: AppStrings.profile.totalSpent,
            value: _formatAmount(stats[ProfileStatsKeys.totalSpent] ?? 0),
          ),
        ),
        const SizedBox(width: groupCarouselGap),
        Expanded(
          child: _buildChip(
            label: AppStrings.profile.totalReceived,
            value: _formatAmount(stats[ProfileStatsKeys.totalReceived] ?? 0),
          ),
        ),
      ],
    );
  }

  Widget _buildChip({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: groupGap10, vertical: groupCarouselGap),
      decoration: BoxDecoration(
        color: groupCardFill,
        borderRadius: BorderRadius.circular(groupRadiusStat),
        border: Border.all(color: groupSurfaceBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: groupSurfaceFillWhisper,
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
                  fontFamily: kFontPoppins,
                  fontSize: splitrFontMicro,
                  fontWeight: FontWeight.w600,
                  color: groupOnSurfaceMuted,
                  letterSpacing: 0.8,
                ),
              ),
              TextSpan(
                text: value,
                style: TextStyle(
                  fontFamily: kFontPoppins,
                  fontSize: splitrFontMicro,
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
          fontFamily: kFontPoppins,
          fontSize: splitrFontCaptionSm,
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
    bool showBadgeDot = false,
    bool isLast = false,
  }) {
    final effectiveIcon = iconColor ?? groupOnSurface;
    final effectiveTitle = titleColor ?? groupOnSurface;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: groupGutter, vertical: groupCarouselGap),
            child: Row(
              children: [
                Container(
                  width: AppDimensions.profileMenuIconBox,
                  height: AppDimensions.profileMenuIconBox,
                  decoration: BoxDecoration(
                    color: AppPalette.surfaceMuted,
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
                          fontFamily: kFontAlbra,
                          fontSize: splitrFontBodyLg,
                          fontWeight: FontWeight.w600,
                          color: effectiveTitle,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: kFontPoppins,
                          fontSize: splitrFontCaptionSm,
                          color: groupOnSurfaceMuted,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showBadgeDot) const PulsingBadgeDot(),
                if (showChevron)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: groupOnSurfaceMuted,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            thickness: 1,
            color: AppPalette.surfaceMuted,
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
      return SizedBox(
        height: AppDimensions.profileLoadingHeight,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                strokeWidth: groupProgressStrokeWidth),
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: groupGutter, vertical: groupGap14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: groupSurfaceFillSoft,
                  borderRadius: BorderRadius.circular(groupRadiusMd),
                ),
                child: const Icon(
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
                      AppStrings.profile.biometricLock,
                      style: const TextStyle(
                        fontFamily: kFontPoppins,
                        fontSize: splitrFontBodyMd,
                        fontWeight: FontWeight.w600,
                        color: groupOnSurface,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _isSupported
                          ? AppStrings.profile.biometricEnabledSubtitle
                          : AppStrings.profile.biometricUnsupportedSubtitle,
                      style: TextStyle(
                        fontFamily: kFontPoppins,
                        fontSize: splitrFontCaptionSm,
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
                        ? neopopAccentBorderStrong
                        : groupChipTrackBg,
                  ),
                  onChanged: _isSupported
                      ? (value) async {
                          if (value) {
                            final result = await _bioService.authenticate(
                              reason: AppStrings.profile.verifyFingerprint,
                            );
                            if (!mounted) return;
                            if (!result.isSuccess) {
                              if (result.status !=
                                      BiometricAuthStatus.cancelled &&
                                  result.message != null) {
                                SplitrToast.showFromContext(
                                  context,
                                  AppStrings.errors.biometricFailed,
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
        const Padding(
          padding: EdgeInsets.only(left: groupGap68),
          child: Divider(
            height: 1,
            thickness: 1,
            color: groupSurfaceBorder,
          ),
        ),
      ],
    );
  }
}
