import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Screen/AuthScreens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      title: AppStrings.onboarding.page1Title,
      description: AppStrings.onboarding.page1Desc,
      icon: Icons.group,
      gradient: [neopopAccent, AppPalette.onboardingTeal],
    ),
    _OnboardingPage(
      title: AppStrings.onboarding.page2Title,
      description: AppStrings.onboarding.page2Desc,
      icon: Icons.insights,
      gradient: [
        AppPalette.onboardingPurpleStart,
        AppPalette.onboardingPurpleEnd,
      ],
    ),
    _OnboardingPage(
      title: AppStrings.onboarding.page3Title,
      description: AppStrings.onboarding.page3Desc,
      icon: Icons.handshake,
      gradient: [
        AppPalette.onboardingPinkStart,
        AppPalette.onboardingPinkEnd,
      ],
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefKeys.hasSeenOnboarding, true);
    Get.offAll(() => const LoginScreen());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: surface,
      body: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.paddingOf(context).top,
          bottom: MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  AppStrings.actions.skip,
                  style: body1_text.copyWith(color: groupOnSurfaceMuted),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: AppMotion.nav,
                  margin: const EdgeInsets.symmetric(horizontal: groupGapXxs),
                  height: AppDimensions.onboardingDotHeight,
                  width: _currentPage == index
                      ? AppDimensions.onboardingDotActiveWidth
                      : AppDimensions.onboardingDotHeight,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? neopopAccent
                        : AppPalette.greyIcon.withOpacity(
                            AppDimensions.inactiveDotOpacity,
                          ),
                    borderRadius: BorderRadius.circular(groupRadiusSm),
                  ),
                ),
              ),
            ),
            const SizedBox(height: groupGapXl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: groupGapXl),
              child: SizedBox(
                width: double.infinity,
                height: groupCtaHeight,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _pages.length - 1) {
                      _completeOnboarding();
                    } else {
                      _pageController.nextPage(
                        duration: AppMotion.slide,
                        curve: AppCurves.standard,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neopopAccent,
                    foregroundColor: groupOnSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(groupCardRadius),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? AppStrings.actions.getStarted
                        : AppStrings.actions.next,
                    style: sub_headline5_text.copyWith(
                      color: groupOnSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: groupGapXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: AppDimensions.onboardingIconContainer,
            width: AppDimensions.onboardingIconContainer,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: page.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(groupRadiusHero),
              boxShadow: [
                BoxShadow(
                  color: page.gradient.first.withOpacity(0.4),
                  blurRadius: AppDimensions.onboardingShadowBlur,
                  offset: AppAnimationOffsets.meshShadow,
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: AppDimensions.onboardingIconSize,
              color: neopopOnPrimary,
            ),
          ),
          const SizedBox(height: groupCtaHeightCompact),
          Text(
            page.title,
            style: headline2_text.copyWith(
              color: groupOnSurface,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: groupGutter),
          Text(
            page.description,
            style: body1_text.copyWith(
              color: groupOnSurfaceMuted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;

  _OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}
