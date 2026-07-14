import 'package:flutter/material.dart';
import 'package:splitr/Services/currency_service.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/glass_card.dart';
import 'package:splitr/Constants/shared.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Services/gamification_service.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Services/public_share_link_service.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Utils/num_parsing.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';

class MonthlyRecapScreen extends StatefulWidget {
  const MonthlyRecapScreen({super.key});

  @override
  State<MonthlyRecapScreen> createState() => _MonthlyRecapScreenState();
}

class _MonthlyRecapScreenState extends State<MonthlyRecapScreen> {
  final GamificationService _gamificationService = GamificationService();
  final PageController _pageController = PageController();
  final ScreenshotController _screenshotController = ScreenshotController();

  Map<String, dynamic>? _recapData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecap();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  EdgeInsets _recapSlideInsets({
    double horizontal = groupGapLg,
    double vertical = groupGutter,
  }) {
    final padding = MediaQuery.paddingOf(context);
    return EdgeInsets.fromLTRB(
      horizontal,
      vertical + padding.top,
      horizontal,
      vertical + padding.bottom,
    );
  }

  Future<void> _loadRecap() async {
    final now = DateTime.now();
    final data = await _gamificationService.generateRecap(now);
    if (mounted) {
      setState(() {
        _recapData = data;
        _isLoading = false;
      });
    }
  }

  String _trendVsLastMonthLabel() {
    if (_recapData == null) return AppStrings.recap.unavailableTrend;
    final totalSpent = asDouble(_recapData![RecapDataKeys.totalSpent]);
    final lastMonthTotal = asDouble(_recapData![RecapDataKeys.lastMonthTotal]);
    final month = _recapData![RecapDataKeys.month] as DateTime;
    if (lastMonthTotal <= 0) return AppStrings.recap.noPriorMonthData;
    final pct = ((totalSpent - lastMonthTotal) / lastMonthTotal) * 100;
    final prevMonth = DateFormat(AppDateFormats.monthAbbr)
        .format(DateTime(month.year, month.month - 1));
    final sign = pct > 0 ? '+' : '';
    return AppStringFormat.recapTrendVsMonth(
      '$sign${pct.toStringAsFixed(0)}',
      prevMonth,
    );
  }

  String _trendPercentLabel() {
    if (_recapData == null) return AppStrings.recap.unavailableTrend;
    final totalSpent = asDouble(_recapData![RecapDataKeys.totalSpent]);
    final lastMonthTotal = asDouble(_recapData![RecapDataKeys.lastMonthTotal]);
    if (lastMonthTotal <= 0) return AppStrings.recap.unavailableTrend;
    final pct = ((totalSpent - lastMonthTotal) / lastMonthTotal) * 100;
    final sign = pct > 0 ? '+' : '';
    return AppStringFormat.recapSignedPercent('$sign${pct.toStringAsFixed(0)}');
  }

  bool get _trendIsUp {
    if (_recapData == null) return false;
    final totalSpent = asDouble(_recapData![RecapDataKeys.totalSpent]);
    final lastMonthTotal = asDouble(_recapData![RecapDataKeys.lastMonthTotal]);
    return totalSpent > lastMonthTotal;
  }

  Future<void> _shareWebLink() async {
    if (_recapData == null) return;
    try {
      final month = _recapData![RecapDataKeys.month] as DateTime;
      final url = await PublicShareLinkService().createLink(
        type: ShareTypes.monthlyRecap,
        payload: {
          RecapSharePayloadKeys.totalSpent:
              _recapData![RecapDataKeys.totalSpent],
          RecapSharePayloadKeys.monthLabel:
              DateFormat(AppDateFormats.monthYear).format(month),
          RecapSharePayloadKeys.trendLabel: _trendVsLastMonthLabel(),
          RecapSharePayloadKeys.topCategory:
              _recapData![RecapDataKeys.topCategory],
        },
      );
      if (url == null) return;
      await Share.share(
        AppStringFormat.shareWebRecap(url),
      );
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        AppStrings.recap.errorSharingWeb,
        error: e,
        stack: stack,
      );
    }
  }

  void _shareSummary() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = await _screenshotController.captureAndSave(
        directory.path,
        fileName: AppStringFormat.recapFilename(
          DateTime.now().millisecondsSinceEpoch,
        ),
        pixelRatio: 2.0,
      );
      if (imagePath != null) {
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: AppStringFormat.shareImageRecap(),
        );
      }
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        AppStrings.recap.errorSharingImage,
        error: e,
        stack: stack,
      );
    } finally {
      // Don't resume automatically if user is still viewing options, but it's safe to resume here
      // or just leave paused since it's the last slide.
    }
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    if (_isLoading) {
      return Scaffold(
        backgroundColor: surface,
        appBar: SplitrDetailAppBar(
          title: AppStrings.profile.monthlyRecap,
        ),
        body: const Center(child: LoadingWidget()),
      );
    }

    if (_recapData == null ||
        (asDouble(_recapData![RecapDataKeys.totalSpent])) == 0.0) {
      return Scaffold(
        backgroundColor: surface,
        appBar: SplitrDetailAppBar(
          title: AppStrings.profile.monthlyRecap,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: groupOnSurfaceMuted,
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.recap.noSpendingData,
                style: body1_text.copyWith(color: groupOnSurfaceMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final totalSpent = asDouble(_recapData![RecapDataKeys.totalSpent]);
    final lastMonthTotal = asDouble(_recapData![RecapDataKeys.lastMonthTotal]);
    final topCategory = _recapData![RecapDataKeys.topCategory] as String;
    final topCategoryAmount =
        asDouble(_recapData![RecapDataKeys.topCategoryAmount]);
    final biggestExpenseAmount =
        asDouble(_recapData![RecapDataKeys.biggestExpenseAmount]);
    final biggestExpenseTitle =
        _recapData![RecapDataKeys.biggestExpenseTitle] as String;
    final biggestExpenseCategory =
        _recapData![RecapDataKeys.biggestExpenseCategory] as String? ??
            CategoryDefaults.dash;
    final biggestExpenseDate =
        _recapData![RecapDataKeys.biggestExpenseDate] as DateTime?;
    final month = _recapData![RecapDataKeys.month] as DateTime;

    double percentChange = 0.0;
    if (lastMonthTotal > 0) {
      percentChange = ((totalSpent - lastMonthTotal) / lastMonthTotal) * 100;
    }

    return Scaffold(
      backgroundColor: surface,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Slide 1: Custom Recap Card
          Container(
            color: AppPalette.recapLightBg,
            child: _buildNewFirstSlide(
              month: month,
              totalSpent: totalSpent,
              percentChange: percentChange,
              onNext: () => _pageController.nextPage(
                  duration: AppMotion.nav, curve: AppCurves.standard),
              onBack: () => Get.back(),
            ),
          ),

          // Slide 2: The Big Number
          Container(
            color: AppPalette.recapLightBg,
            child: _buildSecondSlide(
              month: month,
              totalSpent: totalSpent,
              lastMonthTotal: lastMonthTotal,
              categoryBreakdown: _recapData![RecapDataKeys.categoryBreakdown]
                  as Map<String, double>,
              onNext: () => _pageController.nextPage(
                  duration: AppMotion.nav, curve: AppCurves.standard),
              onBack: () => _pageController.previousPage(
                  duration: AppMotion.nav, curve: AppCurves.standard),
            ),
          ),

          // Slide 3: Category King
          Container(
            color: AppPalette.recapLightBg,
            child: _buildThirdSlide(
              month: month,
              topCategory: topCategory,
              topCategoryAmount: topCategoryAmount,
              totalSpent: totalSpent,
              onNext: () => _pageController.nextPage(
                  duration: AppMotion.nav, curve: AppCurves.standard),
              onBack: () => _pageController.previousPage(
                  duration: AppMotion.nav, curve: AppCurves.standard),
            ),
          ),

          // Slide 4: Spending Habit
          Container(
            color: AppPalette.recapLightBg,
            child: _buildFourthSlide(
              month: month,
              averageDailySpend:
                  asDouble(_recapData![RecapDataKeys.averageDailySpend]),
              onNext: () => _pageController.nextPage(
                  duration: AppMotion.nav, curve: AppCurves.standard),
              onBack: () => _pageController.previousPage(
                  duration: AppMotion.nav, curve: AppCurves.standard),
            ),
          ),

          // Slide 5: Biggest Payment
          Container(
            color: AppPalette.recapLightBg,
            child: _buildFifthSlide(
              month: month,
              biggestExpenseAmount: biggestExpenseAmount,
              biggestExpenseTitle: biggestExpenseTitle,
              biggestExpenseCategory: biggestExpenseCategory,
              biggestExpenseDate: biggestExpenseDate,
              onNext: () => _pageController.nextPage(
                  duration: AppMotion.nav, curve: AppCurves.standard),
              onBack: () => _pageController.previousPage(
                  duration: AppMotion.nav, curve: AppCurves.standard),
            ),
          ),

          // Slide 6: The Summary Card
          Container(
            color: AppPalette.recapLightBg,
            child: _buildFinalSlide(
              totalSpent: totalSpent,
              month: month,
              onNext: () =>
                  Get.back(), // Repurposing next as "close recap" for 6th slide
              onBack: () => _pageController.previousPage(
                  duration: AppMotion.nav, curve: AppCurves.standard),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalSlide({
    required double totalSpent,
    required DateTime month,
    required VoidCallback onNext,
    required VoidCallback onBack,
  }) {
    final curSymbol = Get.isRegistered<CurrencyController>()
        ? Get.find<CurrencyController>().symbol
        : CurrencyService.symbolFor(CurrencyDefaults.code);

    final formattedTotal =
        NumberFormat(AppDateFormats.numberGrouped).format(totalSpent);

    // Format Date Range
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final dateRangeStr = AppStringFormat.recapDateRange(
      DateFormat(AppDateFormats.monthAbbrDay).format(firstDay).toUpperCase(),
      DateFormat(AppDateFormats.monthAbbrDay).format(lastDay).toUpperCase(),
      month.year,
    );
    final monthNameTitle =
        DateFormat(AppDateFormats.monthName).format(month).toUpperCase();

    // Profile data fallback
    const firstName = DisplayFallbacks
        .your; // We can fetch actual first name if available in state, defaulting to YOUR for now

    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top,
        bottom: MediaQuery.paddingOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Top Area Outside Screenshot
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: groupGapLg, vertical: groupGutter),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Splitr text logo
                  Text(
                    AppBranding.brandLogo,
                    style: TextStyle(
                      fontFamily: kFontAlbra,
                      fontSize: splitrFontHeadline3,
                      fontWeight: FontWeight.w800,
                      color: groupOnSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(groupGapSm),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppPalette.recapLightBorder),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: groupOnSurface, size: 18),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Ready to Share Pill
            GlassCard(
              margin: EdgeInsets.zero,
              opacity: 0.09,
              padding: const EdgeInsets.symmetric(
                  horizontal: groupGutter, vertical: groupGapXs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: neopopAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.recap.readyToShare,
                    style: TextStyle(
                      fontFamily: kFontCourier,
                      fontSize: splitrFontMicro,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: groupOnSurface,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // The Shareable Card
            Screenshot(
              controller: _screenshotController,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: groupGapLg),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white, // Light theme card
                    borderRadius: BorderRadius.circular(groupCardRadiusXl),
                    border: Border.all(
                        color: AppPalette.recapLightBorder, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: groupSurfaceFillMedium,
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      )
                    ]),
                child: Stack(
                  children: [
                    // Subtle background gradient or glow
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppPalette.mintAccent.withOpacity(0.05),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(groupGap28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: groupSurfaceFillFaint,
                              borderRadius:
                                  BorderRadius.circular(groupRadiusSm),
                              border: Border.all(
                                color: groupMutedBorderStrong,
                              ),
                            ),
                            child: Text(
                              AppStringFormat.recapNameTitle(
                                  firstName, monthNameTitle),
                              style: TextStyle(
                                fontFamily: kFontCourier,
                                fontWeight: FontWeight.bold,
                                fontSize: splitrFontMicro,
                                letterSpacing: 1.5,
                                color: groupOnSurface,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Date Range
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  color: groupOnSurfaceMuted, size: 14),
                              const SizedBox(width: 8),
                              Text(
                                dateRangeStr,
                                style: TextStyle(
                                  fontFamily: kFontCourier,
                                  fontSize: splitrFontMicro,
                                  letterSpacing: 1.5,
                                  color: groupOnSurfaceMuted,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Main Text
                          Text(
                            AppStrings.recap.thisMonthISpent,
                            style: TextStyle(
                              fontFamily: kFontAlbra,
                              fontSize: splitrFontRecapMd,
                              color: groupOnSurface,
                              height: 1.1,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Giant Amount + Emoji
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                curSymbol,
                                style: TextStyle(
                                  fontFamily: kFontAlbra,
                                  fontSize: splitrFontRecapLg,
                                  color: groupOnSurfaceMuted,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(width: groupGapXxs),
                              Text(
                                formattedTotal,
                                style: TextStyle(
                                  fontFamily: kFontAlbra,
                                  fontSize: splitrFontSwipeHero,
                                  fontWeight: FontWeight.bold,
                                  color: groupOnSurface, // Dark text
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                AppStrings.recap.moneyEmoji,
                                style: TextStyle(fontSize: splitrFontHeadline1),
                              )
                            ],
                          ),

                          const SizedBox(height: groupCtaHeightCompact),

                          // Divider
                          Container(
                            height: 1,
                            color: groupMutedBorderStrong,
                          ),

                          const SizedBox(height: 24),

                          // Footer inside card
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.recap.poweredBy,
                                    style: TextStyle(
                                      fontFamily: kFontCourier,
                                      fontWeight: FontWeight.bold,
                                      fontSize: splitrFontNanoSm,
                                      letterSpacing: 2.0,
                                      color: groupOnSurfaceMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        AppBranding.brandName,
                                        style: TextStyle(
                                          fontFamily: kFontAlbra,
                                          fontSize: splitrFontHeadline3,
                                          fontWeight: FontWeight.bold,
                                          color: groupOnSurface,
                                        ),
                                      ),
                                      // Optionally a small dot colored mint
                                      const SizedBox(width: 2),
                                      Container(
                                        width: 4,
                                        height: 4,
                                        decoration: const BoxDecoration(
                                          color: AppPalette.mintAccent,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              // Mock QR Code Box
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: groupTransparent,
                                  border: Border.all(
                                      color: groupOnSurface, width: 2),
                                  borderRadius:
                                      BorderRadius.circular(groupRadiusSm),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.qr_code_2,
                                    color: groupOnSurface, size: 28),
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Quote Text
                          Text(
              AppStrings.recap.tagline,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kFontAlbra,
                fontSize: splitrFontBodyLg,
                fontStyle: FontStyle.italic,
                color: groupOnSurface,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 8),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                        color: groupOnSurfaceMuted, shape: BoxShape.circle)),
                const SizedBox(width: groupGapXxs),
                Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                        color: groupOnSurfaceMuted, shape: BoxShape.circle)),
                const SizedBox(width: groupGapXxs),
                Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                        color: groupOnSurfaceMuted, shape: BoxShape.circle)),
              ],
            ),

            const SizedBox(height: 32),

            // Share Recap Button Neopop
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: groupGutter),
              child: GestureDetector(
                onTap: _shareSummary,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Shadow layer
                    Positioned(
                      bottom: -4,
                      right: -4,
                      top: 4,
                      left: 4,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: groupOnSurface,
                        ),
                      ),
                    ),
                    // Button Top layer
                    Container(
                      width: double.infinity,
                      height: groupCtaHeight,
                      decoration: BoxDecoration(
                        color: AppPalette.mintAccent, // Mint green
                        border: Border.all(color: groupOnSurface, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.recap.shareRecap,
                            style: TextStyle(
                              fontFamily: kFontCourier,
                              fontSize: splitrFontBodyLg,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              color: groupOnSurface,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.ios_share,
                              color: groupOnSurface, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: groupGapSm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: groupGutter),
              child: TextButton.icon(
                onPressed: _shareWebLink,
                icon: const Icon(Icons.link_rounded, size: 18),
                label: Text(AppStrings.recap.shareWebLink),
              ),
            ),

            const SizedBox(height: 16),

            // Download Image Button Ghost
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: groupGapLg),
              child: GestureDetector(
                onTap: onNext,
                child: Container(
                  width: double.infinity,
                  height: groupCtaHeight,
                  decoration: BoxDecoration(
                    color: groupTransparent,
                    border: Border.all(color: groupOnSurface, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.recap.backToProfile,
                        style: TextStyle(
                          fontFamily: kFontCourier,
                          fontSize: splitrFontBody,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: groupOnSurface,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.arrow_forward,
                          color: groupOnSurface, size: 20),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNewFirstSlide({
    required DateTime month,
    required double totalSpent,
    required double percentChange,
    required VoidCallback onNext,
    required VoidCallback onBack,
  }) {
    final curSymbol = Get.isRegistered<CurrencyController>()
        ? Get.find<CurrencyController>().symbol
        : CurrencyService.symbolFor(CurrencyDefaults.code);
    final monthName = DateFormat(AppDateFormats.monthName).format(month);
    final year = month.year;
    final formattedTotal =
        NumberFormat(AppDateFormats.numberGrouped).format(totalSpent);

    return Padding(
      padding: _recapSlideInsets(vertical: groupGapLg),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo "Splitr." and Close Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                          Text(
                  AppBranding.brandLogo,
                  style: TextStyle(
                    fontFamily: kFontAlbra,
                    fontWeight: FontWeight.bold,
                    fontSize: splitrFontHeadline3,
                    color: groupOnSurface,
                    letterSpacing: 1.0,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(groupGapSm),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppPalette.recapLightBorder),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: groupOnSurface, size: 18),
                  ),
                ),
              ],
            ),

            const Spacer(flex: 2),

            // Big text
            Center(
              child: Column(
                children: [
                  Text(
                    AppStringFormat.yourMonthRecap(monthName),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: kFontAlbra,
                      fontSize: splitrFontRecapDisplay,
                      fontWeight: FontWeight.w800,
                      color: groupOnSurface,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    AppStrings.recap.moneyMovedSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: kFontCourier,
                      fontSize: splitrFontMicro,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.bold,
                      color: groupOnSurfaceMuted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 1,
                    width: 240,
                    color: AppPalette.recapLightBorder,
                  ),
                ],
              ),
            ),

            const SizedBox(height: groupCtaHeightCompact),

            // The main card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(groupGapLg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.zero,
                border:
                    Border.all(color: AppPalette.recapLightBorder, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: groupSurfaceFillWhisper,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Faded currency symbol
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Text(
                      curSymbol,
                      style: const TextStyle(
                        fontSize: splitrFontRecapWatermark,
                        color: AppPalette.recapMutedFill, // Very faint
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Month Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppPalette.recapLightBorder, width: 1.0),
                        ),
                        child: Text(
                          AppStringFormat.monthYearCaps(monthName, year),
                          style: TextStyle(
                            fontFamily: kFontCourier,
                            fontSize: splitrFontMicro,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: groupOnSurfaceMuted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      Text(
                        AppStrings.profile.totalSpent,
                        style: TextStyle(
                          fontFamily: kFontCourier,
                          fontSize: splitrFontMicro,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.bold,
                          color: groupOnSurfaceMuted,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            curSymbol,
                            style: TextStyle(
                              fontFamily: kFontAlbra,
                              fontSize: splitrFontRecapMd,
                              fontWeight: FontWeight.w600,
                              color: groupOnSurface,
                            ),
                          ),
                          const SizedBox(width: groupGapXxs),
                          Text(
                            formattedTotal,
                            style: TextStyle(
                              fontFamily: kFontAlbra,
                              fontSize: splitrFontRecapDisplay,
                              fontWeight: FontWeight.bold,
                              color: groupOnSurface,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Progress line / percent change
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 4,
                            color:
                                percentChange > 0 ? neopopError : neopopAccent,
                          ),
                          Container(
                            width: 40,
                            height: 4,
                            color: AppPalette.surfaceMuted,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            AppStringFormat.recapSignedPercentFromValue(
                              percentChange,
                            ),
                            style: TextStyle(
                              fontFamily: kFontPoppins,
                              fontSize: splitrFontCaption,
                              fontWeight: FontWeight.bold,
                              color: percentChange > 0
                                  ? neopopError
                                  : neopopAccent,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                      const Divider(
                          color: AppPalette.surfaceMuted, thickness: 1.5),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              AppStrings.recap.spendingPatterns,
                              style: TextStyle(
                                fontFamily: kFontCourier,
                                fontSize: splitrFontCaptionSm,
                                fontWeight: FontWeight.w600,
                                color: groupOnSurfaceMuted,
                                height: 1.4,
                              ),
                            ),
                          ),
                          // Arrow box
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: groupOnSurface, width: 1.5),
                            ),
                            child: const Icon(Icons.arrow_forward_rounded,
                                color: groupOnSurface, size: 18),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(flex: 3),

            // Bottom Button
            SizedBox(
              width: double.infinity,
              height: groupCtaHeight,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: neopopAccent,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.recap.viewFullRecap,
                      style: TextStyle(
                        fontFamily: kFontCourier,
                        fontSize: splitrFontBodySm,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: groupOnSurface,
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(Icons.arrow_forward_rounded,
                        color: groupOnSurface, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildSecondSlide({
    required DateTime month,
    required double totalSpent,
    required double lastMonthTotal,
    required Map<String, double> categoryBreakdown,
    required VoidCallback onNext,
    required VoidCallback onBack,
  }) {
    final curSymbol = Get.isRegistered<CurrencyController>()
        ? Get.find<CurrencyController>().symbol
        : CurrencyService.symbolFor(CurrencyDefaults.code);

    double percentChange = 0.0;
    if (lastMonthTotal > 0) {
      percentChange = ((totalSpent - lastMonthTotal) / lastMonthTotal) * 100;
    }

    final formattedTotal =
        NumberFormat(AppDateFormats.numberGrouped).format(totalSpent);
    final prevMonthName = DateFormat(AppDateFormats.monthName)
        .format(DateTime(month.year, month.month - 1));

    // Get Top 2 Categories
    final sortedCategories = categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top2 = sortedCategories.take(2).toList();

    final double maxCategoryAmount = top2.isNotEmpty ? top2.first.value : 1.0;

    return Padding(
      padding: _recapSlideInsets(),
      child: Column(
          children: [
            // Top App Bar Area
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                          Text(
                  AppBranding.brandLogo,
                  style: TextStyle(
                    fontFamily: kFontAlbra,
                    fontWeight: FontWeight.bold,
                    fontSize: splitrFontHeadline3,
                    color: groupOnSurface,
                    letterSpacing: 1.0,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(groupGapSm),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppPalette.recapLightBorder),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: groupOnSurface, size: 18),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Main summary card
            GlassCard(
              margin: EdgeInsets.zero,
              opacity: 0.06,
              padding: const EdgeInsets.all(groupGapMd),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(groupCarouselGap),
                    decoration: BoxDecoration(
                      color: groupSurfaceFillFaint,
                      borderRadius: BorderRadius.circular(groupCardRadius),
                      border: Border.all(
                        color: groupMutedBorderStrong,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(Icons.account_balance_wallet_outlined,
                        color: neopopAccent, size: 24),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        curSymbol,
                        style: TextStyle(
                          fontFamily: kFontAlbra,
                          fontSize: splitrFontHeadline2,
                          color: groupOnSurfaceMuted,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(width: groupGapXxs),
                      Text(
                        formattedTotal,
                        style: TextStyle(
                          fontFamily: kFontAlbra,
                          fontSize: splitrFontRecapHero,
                          fontWeight: FontWeight.bold,
                          color: neopopAccent,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.recap.totalSpentThisMonth,
                    style: TextStyle(
                      fontFamily: kFontCourier,
                      fontSize: splitrFontMicro,
                      letterSpacing: 1.5,
                      color: groupOnSurfaceMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  GlassCard(
                    margin: EdgeInsets.zero,
                    opacity: 0.06,
                    padding: const EdgeInsets.all(groupGapMd),
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.recap.spendingTrend,
                            style: TextStyle(
                              fontFamily: kFontCourier,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              fontSize: splitrFontMicro,
                              color: groupOnSurfaceMuted,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: percentChange > 0
                                  ? neopopError
                                  : neopopAccent,
                              borderRadius:
                                  BorderRadius.circular(groupRadiusSm),
                            ),
                            child: Text(
                              percentChange > 0
                                  ? AppStrings.recap.trendHigh
                                  : AppStrings.recap.trendLow,
                              style: TextStyle(
                                fontFamily: kFontCourier,
                                fontWeight: FontWeight.bold,
                                fontSize: splitrFontMicro,
                                color: groupOnSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(children: [
                        Icon(
                          percentChange > 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          color: percentChange > 0 ? neopopError : neopopAccent,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStringFormat.recapSignedPercentFromValue(
                                percentChange,
                              ),
                              style: TextStyle(
                                fontFamily: kFontPoppins,
                                fontWeight: FontWeight.bold,
                                fontSize: splitrFontTitle,
                                color: groupOnSurface,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppStringFormat.comparedToMonth(prevMonthName),
                              style: TextStyle(
                                fontFamily: kFontPoppins,
                                fontSize: splitrFontCaptionSm,
                                color: groupOnSurfaceMuted,
                              ),
                            ),
                          ],
                        ),
                      ]),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 6,
                        decoration: BoxDecoration(
                          color: groupMutedBorderHairline,
                          borderRadius: BorderRadius.circular(groupRadiusXs),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: (percentChange.abs() > 100
                                              ? 100
                                              : percentChange.abs())
                                          .toInt() ==
                                      0
                                  ? 1
                                  : (percentChange.abs() > 100
                                          ? 100
                                          : percentChange.abs())
                                      .toInt(),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: percentChange > 0
                                      ? neopopError
                                      : neopopAccent,
                                  borderRadius:
                                      BorderRadius.circular(groupRadiusXs),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 100 -
                                  ((percentChange.abs() > 100
                                                  ? 100
                                                  : percentChange.abs())
                                              .toInt() ==
                                          0
                                      ? 1
                                      : (percentChange.abs() > 100
                                              ? 100
                                              : percentChange.abs())
                                          .toInt()),
                              child: const SizedBox(),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Top Categories Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.recap.topCategories,
                  style: TextStyle(
                    fontFamily: kFontCourier,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: splitrFontCaption,
                    color: groupOnSurfaceMuted,
                  ),
                ),
                Text(AppStrings.recap.chartEllipsis,
                    style: TextStyle(
                        color: groupOnSurfaceMuted,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),

            // Top categories list
            if (top2.isNotEmpty)
              ...top2.map((cat) {
                final val = cat.value;
                final String shortLabel = val >= 1000
                    ? AppStringFormat.shortAmountK(val)
                    : val.toStringAsFixed(0);

                // Mapping category to icon
                IconData catIcon = Icons.category_outlined;
                if (cat.key.toLowerCase().contains(CategorySlugValues.food) ||
                    cat.key.toLowerCase().contains(CategorySlugValues.dining)) {
                  catIcon = Icons.restaurant;
                } else if (cat.key
                    .toLowerCase()
                    .contains(RecapCategoryKeywords.shop)) {
                  catIcon = Icons.shopping_bag_outlined;
                } else if (cat.key
                        .toLowerCase()
                        .contains(CategorySlugValues.travel) ||
                    cat.key
                        .toLowerCase()
                        .contains(CategorySlugValues.transport)) {
                  catIcon = Icons.directions_car_outlined;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: groupGutter),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(groupGap10),
                        decoration: BoxDecoration(
                          color: AppPalette.greyIcon.withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(groupControlRadiusSm),
                        ),
                        child: Icon(catIcon,
                            color: AppPalette.greyIconDark, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppPalette.recapLightBorder,
                            borderRadius: BorderRadius.circular(groupRadiusXs),
                          ),
                          alignment: Alignment.centerLeft,
                          child: LayoutBuilder(builder: (context, constraints) {
                            final double percentage = maxCategoryAmount > 0
                                ? (val / maxCategoryAmount)
                                : 0;
                            // Ensure percentage is valid between 0 and 1
                            final safePercentage = percentage.clamp(0.0, 1.0);
                            return Container(
                              width: constraints.maxWidth * safePercentage,
                              decoration: BoxDecoration(
                                color: AppPalette.greyIconDark,
                                borderRadius:
                                    BorderRadius.circular(groupRadiusXs),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 40,
                        child: Text(
                          "$curSymbol$shortLabel",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: kFontCourier,
                            fontSize: splitrFontCaption,
                            fontWeight: FontWeight.bold,
                            color: groupOnSurfaceMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              })
            else
              Padding(
                padding: EdgeInsets.only(bottom: groupGutter),
                child: Text(
                  AppStrings.recap.noCategoricalData,
                  style: TextStyle(
                    fontFamily: kFontCourier,
                    fontSize: splitrFontCaption,
                    color: groupOnSurfaceMuted,
                  ),
                ),
              ),

            const Spacer(),

            // Neopop Next Button (black shadow at bottom right)
            GestureDetector(
              onTap: onNext,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Shadow layer
                  Positioned(
                    bottom: -4,
                    right: -4,
                    top: 4,
                    left: 4,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: groupOnSurface,
                      ),
                    ),
                  ),
                  // Button Top layer
                  Container(
                    width: double.infinity,
                    height: groupCtaHeight,
                    decoration: BoxDecoration(
                      color: neopopAccent, // The light green
                      border: Border.all(color: groupOnSurface, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.recap.next,
                          style: TextStyle(
                            fontFamily: kFontCourier,
                            fontSize: splitrFontBodyLg,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: groupOnSurface,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward,
                            color: groupOnSurface, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Footer
                          Text(
              AppStrings.recap.securedByCredProtect,
              style: TextStyle(
                fontFamily: kFontCourier,
                fontSize: splitrFontMicro,
                color: groupOnSurfaceMuted,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildThirdSlide({
    required DateTime month,
    required String topCategory,
    required double topCategoryAmount,
    required double totalSpent,
    required VoidCallback onNext,
    required VoidCallback onBack,
  }) {
    // Unused variable removed

    // Calculate Impact
    final double impactPercentage =
        totalSpent > 0 ? (topCategoryAmount / totalSpent) * 100 : 0;
    final int impactInt = impactPercentage.round();

    // Map Category to icon and color
    IconData catIcon = Icons.category_outlined;
    Color accentC = AppPalette.categoryOrange; // Default Orange

    final lowerCat = topCategory.toLowerCase();
    if (lowerCat.contains(CategorySlugValues.food) ||
        lowerCat.contains(CategorySlugValues.dining)) {
      catIcon = Icons.restaurant;
      accentC = AppPalette.categoryOrange; // Orange
    } else if (lowerCat.contains(RecapCategoryKeywords.shop)) {
      catIcon = Icons.shopping_bag;
      accentC = AppPalette.categoryPink; // Pink
    } else if (lowerCat.contains(CategorySlugValues.travel) ||
        lowerCat.contains(CategorySlugValues.transport)) {
      catIcon = Icons.directions_car;
      accentC = AppPalette.categoryBlue; // Blue
    } else if (lowerCat.contains(RecapCategoryKeywords.grocery) ||
        lowerCat.contains(CategorySlugValues.groceries)) {
      catIcon = Icons.local_grocery_store;
      accentC = AppPalette.categoryGreen; // Green
    } else if (lowerCat.contains(RecapCategoryKeywords.bill) ||
        lowerCat.contains(RecapCategoryKeywords.utility)) {
      catIcon = Icons.receipt_long;
      accentC = AppPalette.categoryPurple; // Purple
    }

    return Padding(
      padding: _recapSlideInsets(),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar Area
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                          Text(
                  AppBranding.brandLogo,
                  style: TextStyle(
                    fontFamily: kFontAlbra,
                    fontWeight: FontWeight.bold,
                    fontSize: splitrFontHeadline3,
                    color: groupOnSurface,
                    letterSpacing: 1.0,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(groupGapSm),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppPalette.recapLightBorder),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: groupOnSurface, size: 18),
                  ),
                ),
              ],
            ),

            const Spacer(flex: 1),

            // Giant Title Area
                          Text(
              AppStrings.recap.your,
              style: TextStyle(
                fontFamily: kFontAlbra,
                fontSize: splitrFontRecapXl,
                fontWeight: FontWeight.w800,
                color: groupOnSurface,
                height: 1.1,
              ),
            ),
                          Text(
              AppStrings.recap.favourite,
              style: TextStyle(
                fontFamily: kFontAlbra,
                fontSize: splitrFontRecapXl,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: groupOnSurfaceMuted,
                height: 1.1,
              ),
            ),
            Text(
              AppStrings.groups.category,
              style: TextStyle(
                fontFamily: kFontAlbra,
                fontSize: splitrFontRecapHero,
                fontWeight: FontWeight.w800,
                color: groupOnSurface,
                height: 1.1,
              ),
            ),

            const SizedBox(height: 32),

            // Category summary card
            GlassCard(
              margin: EdgeInsets.zero,
              opacity: 0.06,
              padding: const EdgeInsets.all(groupGapMd),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppStrings.recap.chartEllipsis,
                          style: TextStyle(
                              color: groupOnSurfaceMuted,
                              fontWeight: FontWeight.bold,
                              fontSize: splitrFontBodyLg)),
                      Text(
                        AppStrings.recap.splitrId,
                        style: TextStyle(
                          fontFamily: kFontCourier,
                          color: groupOnSurfaceMuted,
                          fontSize: splitrFontMicro,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: groupSurfaceFillFaint,
                      borderRadius: BorderRadius.circular(groupCardRadiusLg),
                      border: Border.all(
                        color: groupMutedBorderStrong,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(catIcon, color: accentC, size: 40),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    AppStrings.recap.spentMostOn,
                    style: TextStyle(
                      fontFamily: kFontPoppins,
                      fontSize: splitrFontSubhead,
                      fontWeight: FontWeight.bold,
                      color: groupOnSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    topCategory,
                    style: TextStyle(
                      fontFamily: kFontAlbra,
                      fontSize: splitrFontHeadline2,
                      fontWeight: FontWeight.bold,
                      color: accentC,
                    ),
                  ),
                  const SizedBox(height: 40),
                  GlassCard(
                    margin: EdgeInsets.zero,
                    opacity: 0.06,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.recap.impact,
                              style: TextStyle(
                                fontFamily: kFontCourier,
                                fontSize: splitrFontMicro,
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.bold,
                                color: groupOnSurfaceMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppStringFormat.impactPercent(impactInt),
                              style: TextStyle(
                                fontFamily: kFontAlbra,
                                fontSize: splitrFontHeadline1,
                                fontWeight: FontWeight.bold,
                                color: groupOnSurface,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppStrings.recap.ofTotalSpend,
                              style: TextStyle(
                                fontFamily: kFontPoppins,
                                fontSize: splitrFontMicro,
                                color: groupOnSurfaceMuted,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 56,
                          height: groupCtaHeight,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: 1.0,
                                strokeWidth: 8,
                                color: groupMutedBorderHairline,
                              ),
                              CircularProgressIndicator(
                                value: impactPercentage / 100,
                                strokeWidth: 8,
                                color: accentC,
                                backgroundColor: groupTransparent,
                                strokeCap: StrokeCap.round,
                              ),
                              const Center(
                                child: Icon(Icons.flash_on,
                                    size: 14, color: groupOnSurfaceMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Witty remark
            Center(
              child: Text(
                AppStrings.recap.tasteTagline,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: kFontCourier,
                  fontSize: splitrFontCaptionSm,
                  color: groupOnSurfaceMuted,
                  height: 1.4,
                ),
              ),
            ),

            const Spacer(flex: 2),

            // Next button Neopop
            GestureDetector(
              onTap: onNext,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Shadow layer
                  Positioned(
                    bottom: -4,
                    right: -4,
                    top: 4,
                    left: 4,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: groupOnSurface,
                      ),
                    ),
                  ),
                  // Button Top layer
                  Container(
                    width: double.infinity,
                    height: groupCtaHeight,
                    decoration: BoxDecoration(
                      color: neopopAccent, // The light green
                      border: Border.all(color: groupOnSurface, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.recap.nextInsight,
                          style: TextStyle(
                            fontFamily: kFontCourier,
                            fontSize: splitrFontBodyLg,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: groupOnSurface,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward,
                            color: groupOnSurface, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildFourthSlide({
    required DateTime month,
    required double averageDailySpend,
    required VoidCallback onNext,
    required VoidCallback onBack,
  }) {
    final monthName = DateFormat(AppDateFormats.monthName).format(month);
    final curSymbol = Get.isRegistered<CurrencyController>()
        ? Get.find<CurrencyController>().symbol
        : CurrencyService.symbolFor(CurrencyDefaults.code);

    final formattedDaily =
        NumberFormat(AppDateFormats.numberGrouped).format(averageDailySpend);

    return Padding(
      padding: _recapSlideInsets(),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar Area
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Splitr text logo
                          Text(
                  AppBranding.brandLogo,
                  style: TextStyle(
                    fontFamily: kFontAlbra,
                    fontSize: splitrFontHeadline3,
                    fontWeight: FontWeight.w800,
                    color: groupOnSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(groupGapSm),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppPalette.recapLightBorder),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: groupOnSurface, size: 18),
                  ),
                ),
              ],
            ),

            const Spacer(flex: 1),

            // Giant Title Area
                          Text(
              AppStrings.recap.yourSpending,
              style: TextStyle(
                fontFamily: kFontAlbra,
                fontSize: splitrFontRecapXl,
                fontWeight: FontWeight.w800,
                color: groupOnSurface,
                height: 1.1,
                letterSpacing: -1.0,
              ),
            ),
                          Text(
              AppStrings.recap.habit,
              style: TextStyle(
                fontFamily: kFontAlbra,
                fontSize: splitrFontRecapHero,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
                color: AppPalette.mintAccent, // Mint green
                height: 1.1,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  color: AppPalette.mintAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  AppStringFormat.monthlyRecapLabel(monthName),
                  style: TextStyle(
                    fontFamily: kFontCourier,
                    fontSize: splitrFontMicro,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: groupOnSurfaceMuted,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Average Daily Spend Card
            GlassCard(
              margin: EdgeInsets.zero,
              opacity: 0.06,
              padding: const EdgeInsets.all(groupGapMd),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: neopopAccent, width: 2),
                          right: BorderSide(color: neopopAccent, width: 2),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: neopopAccent, width: 2),
                          left: BorderSide(color: neopopAccent, width: 2),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: neopopAccent,
                          boxShadow: [
                            BoxShadow(
                              color: neopopAccentBorderStrong,
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          curSymbol,
                          style: TextStyle(
                            fontFamily: kFontAlbra,
                            fontSize: splitrFontHeadline2,
                            fontWeight: FontWeight.bold,
                            color: groupOnSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$curSymbol$formattedDaily',
                            style: TextStyle(
                              fontFamily: kFontAlbra,
                              fontSize: splitrFontSwipeHero,
                              fontWeight: FontWeight.bold,
                              color: groupOnSurface,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: groupGapXxs),
                          Text(
                            AppStrings.recap.perDay,
                            style: TextStyle(
                              fontFamily: kFontAlbra,
                              fontSize: splitrFontTitle,
                              fontStyle: FontStyle.italic,
                              color: groupOnSurfaceMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.recap.averageDailySpend,
                        style: TextStyle(
                          fontFamily: kFontCourier,
                          fontSize: splitrFontMicro,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.bold,
                          color: groupOnSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Trend Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                          Text(
                  AppStrings.recap.trend,
                  style: TextStyle(
                    fontFamily: kFontCourier,
                    fontWeight: FontWeight.bold,
                    fontSize: splitrFontCaption,
                    letterSpacing: 1.5,
                    color: groupOnSurface,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: groupGapSm, vertical: groupGapXxs),
                  decoration: BoxDecoration(
                    color: neopopAccentFillLight,
                    borderRadius: BorderRadius.circular(groupRadiusSm),
                  ),
                  child: Text(
                    _trendVsLastMonthLabel(),
                    style: TextStyle(
                      fontFamily: kFontCourier,
                      fontSize: splitrFontMicro,
                      fontWeight: FontWeight.bold,
                      color: _trendIsUp ? neopopError : neopopAccent,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Mini Trend Chart Card
            GlassCard(
              margin: EdgeInsets.zero,
              opacity: 0.06,
              padding: const EdgeInsets.symmetric(
                  vertical: groupGutter, horizontal: groupGapSm),
              child: SizedBox(
                height: 100,
                width: double.infinity,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: 10,
                    minY: 0,
                    maxY: 10,
                    lineTouchData: const LineTouchData(enabled: false),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      drawHorizontalLine: true,
                      horizontalInterval: 5,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: groupMutedBorderHairline,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 2),
                          FlSpot(1, 3),
                          FlSpot(2, 2.5),
                          FlSpot(3, 5),
                          FlSpot(4, 4),
                          FlSpot(5, 8),
                          FlSpot(6, 7),
                          FlSpot(7, 9),
                          FlSpot(8, 8),
                          FlSpot(9, 10),
                          FlSpot(10, 8.5),
                        ],
                        isCurved: true,
                        color: neopopAccent,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: neopopAccentFillWhisper,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Insight Card
            GlassCard(
              margin: EdgeInsets.zero,
              opacity: 0.06,
              padding: const EdgeInsets.all(groupGapMd),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: neopopAccent, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.recap.weekendWarrior,
                          style: TextStyle(
                            fontFamily: kFontPoppins,
                            fontWeight: FontWeight.bold,
                            fontSize: splitrFontBody,
                            color: groupOnSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.recap.weekendWarriorDesc,
                          style: TextStyle(
                            fontFamily: kFontPoppins,
                            fontSize: splitrFontCaptionSm,
                            color: groupMutedTextFaint,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 2),

            // Next button Neopop
            GestureDetector(
              onTap: onNext,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Shadow layer
                  Positioned(
                    bottom: -4,
                    right: -4,
                    top: 4,
                    left: 4,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: groupOnSurface,
                      ),
                    ),
                  ),
                  // Button Top layer
                  Container(
                    width: double.infinity,
                    height: groupCtaHeight,
                    decoration: BoxDecoration(
                      color: AppPalette.mintAccent, // Mint green
                      border: Border.all(color: groupOnSurface, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.recap.nextInsight,
                          style: TextStyle(
                            fontFamily: kFontCourier,
                            fontSize: splitrFontBodyLg,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: groupOnSurface,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward,
                            color: groupOnSurface, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildFifthSlide({
    required DateTime month,
    required double biggestExpenseAmount,
    required String biggestExpenseTitle,
    required String biggestExpenseCategory,
    required DateTime? biggestExpenseDate,
    required VoidCallback onNext,
    required VoidCallback onBack,
  }) {
    final curSymbol = Get.isRegistered<CurrencyController>()
        ? Get.find<CurrencyController>().symbol
        : CurrencyService.symbolFor(CurrencyDefaults.code);

    final formattedAmount =
        NumberFormat(AppDateFormats.numberGrouped).format(biggestExpenseAmount);

    // Process Date string to extract 'FEB' and '12'
    String tMonth = DisplayFallbacks.na;
    String tDay = CategoryDefaults.dash;
    if (biggestExpenseDate != null) {
      tMonth = DateFormat(AppDateFormats.monthAbbr)
          .format(biggestExpenseDate)
          .toUpperCase();
      tDay = biggestExpenseDate.day.toString();
    }

    // Process Category to icon
    IconData catIcon = Icons.category;
    final lowerCat = biggestExpenseCategory.toLowerCase();
    if (lowerCat.contains(CategorySlugValues.food) ||
        lowerCat.contains(CategorySlugValues.dining)) {
      catIcon = Icons.restaurant;
    } else if (lowerCat.contains(RecapCategoryKeywords.shop)) {
      catIcon = Icons.shopping_bag;
    } else if (lowerCat.contains(CategorySlugValues.travel) ||
        lowerCat.contains(CategorySlugValues.transport) ||
        lowerCat.contains(RecapCategoryKeywords.flight)) {
      catIcon = Icons.flight_takeoff;
    } else if (lowerCat.contains(RecapCategoryKeywords.grocery) ||
        lowerCat.contains(CategorySlugValues.groceries)) {
      catIcon = Icons.local_grocery_store;
    } else if (lowerCat.contains(RecapCategoryKeywords.bill) ||
        lowerCat.contains(RecapCategoryKeywords.utility)) {
      catIcon = Icons.receipt_long;
    }

    return Padding(
      padding: _recapSlideInsets(),
      child: Column(
          children: [
            // Top App Bar Area
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                          Text(
                  AppBranding.brandLogo,
                  style: TextStyle(
                    fontFamily: kFontAlbra,
                    fontWeight: FontWeight.bold,
                    fontSize: splitrFontHeadline3,
                    color: groupOnSurface,
                    letterSpacing: 1.0,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(groupGapSm),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppPalette.recapLightBorder),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: groupOnSurface, size: 18),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Giant Title Area
                          Text(
              AppStrings.recap.biggest,
              style: TextStyle(
                fontFamily: kFontAlbra,
                fontSize: splitrFontRecapXl,
                fontWeight: FontWeight.w800,
                color: groupOnSurface,
                height: 1.1,
              ),
            ),
                          Text(
              AppStrings.recap.payment,
              style: TextStyle(
                fontFamily: kFontAlbra,
                fontSize: splitrFontRecapHero,
                fontWeight: FontWeight.w800,
                color: groupOnSurface,
                height: 1.1,
              ),
            ),

            const SizedBox(height: 32),

            // Main payment card
            GlassCard(
              margin: EdgeInsets.zero,
              opacity: 0.06,
              padding: const EdgeInsets.all(groupGapMd),
              child: Column(
                children: [
                  Text(
                    AppStrings.profile.totalSpent,
                    style: TextStyle(
                      fontFamily: kFontCourier,
                      fontSize: splitrFontMicro,
                      letterSpacing: 2.0,
                      color: groupOnSurfaceMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        curSymbol,
                        style: TextStyle(
                          fontFamily: kFontAlbra,
                          fontSize: splitrFontHeadline2,
                          color: groupOnSurfaceMuted,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(width: groupGapXxs),
                      Text(
                        formattedAmount,
                        style: TextStyle(
                          fontFamily: kFontAlbra,
                          fontSize: splitrFontSwipeHero,
                          fontWeight: FontWeight.bold,
                          color: groupOnSurface,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.recap.biggestPaymentMade,
                    style: TextStyle(
                      fontFamily: kFontPoppins,
                      fontSize: splitrFontBodySm,
                      color: groupOnSurfaceMuted,
                    ),
                  ),
                  const SizedBox(height: 32),
                  GlassCard(
                    margin: EdgeInsets.zero,
                    opacity: 0.06,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: groupCtaHeightCompact,
                          decoration: BoxDecoration(
                            color: groupSurfaceFillFaint,
                            borderRadius:
                                BorderRadius.circular(groupControlRadius),
                            border: Border.all(
                              color: groupMutedBorderStrong,
                              width: 1.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(catIcon, color: neopopAccent, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                biggestExpenseTitle,
                                style: TextStyle(
                                  fontFamily: kFontAlbra,
                                  fontWeight: FontWeight.w600,
                                  fontSize: splitrFontSubhead,
                                  color: groupOnSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppStringFormat.categoryWithBrand(
                                  biggestExpenseCategory,
                                ),
                                style: TextStyle(
                                  fontFamily: kFontCourier,
                                  fontSize: splitrFontMicro,
                                  color: groupOnSurfaceMuted,
                                  letterSpacing: 1.0,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: groupTransparent,
                            borderRadius:
                                BorderRadius.circular(groupControlRadiusSm),
                            border: Border.all(
                              color: groupMutedBorderStrong,
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                tMonth,
                                style: TextStyle(
                                  fontFamily: kFontCourier,
                                  fontSize: splitrFontNanoSm,
                                  color: groupOnSurfaceMuted,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tDay,
                                style: TextStyle(
                                  fontFamily: kFontAlbra,
                                  fontSize: splitrFontBodyLg,
                                  fontWeight: FontWeight.bold,
                                  color: groupOnSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Below Cards Row
            Row(
              children: [
                Expanded(
                  child: GlassCard(
                    margin: EdgeInsets.zero,
                    opacity: 0.06,
                    padding: const EdgeInsets.all(groupGapMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.recap.vsLastMonth,
                          style: TextStyle(
                            fontFamily: kFontPoppins,
                            fontSize: splitrFontCaption,
                            color: groupOnSurfaceMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              _trendIsUp
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              color: _trendIsUp ? neopopError : neopopAccent,
                              size: groupIconMd,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _trendPercentLabel(),
                              style: TextStyle(
                                fontFamily: kFontAlbra,
                                fontWeight: FontWeight.bold,
                                fontSize: splitrFontTitle,
                                color: _trendIsUp ? neopopError : neopopAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GlassCard(
                    margin: EdgeInsets.zero,
                    opacity: 0.06,
                    padding: EdgeInsets.all(groupGapMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.recap.categoryRank,
                          style: TextStyle(
                            fontFamily: kFontPoppins,
                            fontSize: splitrFontCaption,
                            color: groupOnSurfaceMuted,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.emoji_events,
                                color: Colors.amber, size: splitrFontBodyLg),
                            SizedBox(width: 8),
                            Text(
                              AppStrings.recap.rankFirst,
                              style: TextStyle(
                                fontFamily: kFontAlbra,
                                fontWeight: FontWeight.bold,
                                fontSize: splitrFontTitle,
                                color: groupOnSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // See Summary Button Neopop
            GestureDetector(
              onTap: onNext,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Shadow layer
                  Positioned(
                    bottom: -4,
                    right: -4,
                    top: 4,
                    left: 4,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: groupOnSurface,
                      ),
                    ),
                  ),
                  // Button Top layer
                  Container(
                    width: double.infinity,
                    height: groupCtaHeight,
                    decoration: BoxDecoration(
                      color: AppPalette.mintAccent, // Mint green
                      border: Border.all(color: groupOnSurface, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.recap.seeSummary,
                          style: TextStyle(
                            fontFamily: kFontCourier,
                            fontSize: splitrFontBodyLg,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: groupOnSurface,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward,
                            color: groupOnSurface, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}
