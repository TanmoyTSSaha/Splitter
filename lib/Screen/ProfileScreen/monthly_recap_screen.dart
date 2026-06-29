import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Services/gamification_service.dart';
import 'package:splitter/Controllers/currency_controller.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart'; // Add fl_chart

class MonthlyRecapScreen extends StatefulWidget {
  const MonthlyRecapScreen({Key? key}) : super(key: key);

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

  void _shareSummary() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = await _screenshotController.captureAndSave(
        directory.path,
        fileName: "monthly_recap_${DateTime.now().millisecondsSinceEpoch}.png",
        pixelRatio: 2.0,
      );
      if (imagePath != null) {
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: "Here's my spending wrap-up for this month! 🚀 #SplitterApp",
        );
      }
    } catch (e) {
      debugPrint("Error sharing recap: $e");
    } finally {
      // Don't resume automatically if user is still viewing options, but it's safe to resume here
      // or just leave paused since it's the last slide.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: neopopBackground,
        body:
            const Center(child: CircularProgressIndicator(color: neopopAccent)),
      );
    }

    if (_recapData == null || (_recapData!['totalSpent'] as double) == 0.0) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0F0F5),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF1A1A1A)),
            onPressed: () => Get.back(),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: Color(0xFF9E9E9E),
              ),
              SizedBox(height: 16),
              Text(
                "No spending data found for this month.",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFF9E9E9E),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final totalSpent = _recapData!['totalSpent'] as double;
    final lastMonthTotal = _recapData!['lastMonthTotal'] as double;
    final topCategory = _recapData!['topCategory'] as String;
    final topCategoryAmount = _recapData!['topCategoryAmount'] as double;
    final biggestExpenseAmount = _recapData!['biggestExpenseAmount'] as double;
    final biggestExpenseTitle = _recapData!['biggestExpenseTitle'] as String;
    final biggestExpenseCategory =
        _recapData!['biggestExpenseCategory'] as String? ?? '-';
    final biggestExpenseDate = _recapData!['biggestExpenseDate'] as DateTime?;
    final month = _recapData!['month'] as DateTime;

    double percentChange = 0.0;
    if (lastMonthTotal > 0) {
      percentChange = ((totalSpent - lastMonthTotal) / lastMonthTotal) * 100;
    }

    return Scaffold(
      backgroundColor: neopopBackground,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Slide 1: Custom Recap Card
          Container(
            color: const Color(0xFFF0F0F5),
            child: _buildNewFirstSlide(
              month: month,
              totalSpent: totalSpent,
              percentChange: percentChange,
              onNext: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut),
              onBack: () => Get.back(),
            ),
          ),

          // Slide 2: The Big Number
          Container(
            color: const Color(0xFFF0F0F5),
            child: _buildSecondSlide(
              month: month,
              totalSpent: totalSpent,
              lastMonthTotal: lastMonthTotal,
              categoryBreakdown:
                  _recapData!['categoryBreakdown'] as Map<String, double>,
              onNext: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut),
              onBack: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut),
            ),
          ),

          // Slide 3: Category King
          Container(
            color: const Color(0xFFF0F0F5),
            child: _buildThirdSlide(
              month: month,
              topCategory: topCategory,
              topCategoryAmount: topCategoryAmount,
              totalSpent: totalSpent,
              onNext: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut),
              onBack: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut),
            ),
          ),

          // Slide 4: Spending Habit
          Container(
            color: const Color(0xFFF0F0F5),
            child: _buildFourthSlide(
              month: month,
              averageDailySpend: _recapData!['averageDailySpend'] as double,
              onNext: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut),
              onBack: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut),
            ),
          ),

          // Slide 5: Biggest Payment
          Container(
            color: const Color(0xFFF0F0F5),
            child: _buildFifthSlide(
              month: month,
              biggestExpenseAmount: biggestExpenseAmount,
              biggestExpenseTitle: biggestExpenseTitle,
              biggestExpenseCategory: biggestExpenseCategory,
              biggestExpenseDate: biggestExpenseDate,
              onNext: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut),
              onBack: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut),
            ),
          ),

          // Slide 6: The Summary Card
          Container(
            color: neopopBackground,
            child: _buildFinalSlide(
              totalSpent: totalSpent,
              month: month,
              onNext: () =>
                  Get.back(), // Repurposing next as "close recap" for 6th slide
              onBack: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut),
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
        : '₹';

    final formattedTotal = NumberFormat('#,##0').format(totalSpent);

    // Format Date Range
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final dateRangeStr =
        "${DateFormat('MMM dd').format(firstDay).toUpperCase()} - ${DateFormat('MMM dd').format(lastDay).toUpperCase()}, ${month.year}";
    final monthNameTitle = DateFormat('MMMM').format(month).toUpperCase();

    // Profile data fallback
    final firstName =
        "YOUR"; // We can fetch actual first name if available in state, defaulting to YOUR for now

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Top Area Outside Screenshot
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Splitr text logo
                  const Text(
                    'Splitr.',
                    style: TextStyle(
                      fontFamily: 'Albra',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: const Icon(Icons.close,
                          color: Color(0xFF1A1A1A), size: 18),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Ready to Share Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF16161A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1DE9B6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "READY TO SHARE",
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

            // The Shareable Card
            Screenshot(
              controller: _screenshotController,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white, // Light theme card
                    borderRadius: BorderRadius.circular(24),
                    border:
                        Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
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
                          color: const Color(0xFF1DE9B6).withOpacity(0.05),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16161A), // Dark Background
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "$firstName $monthNameTitle RECAP",
                              style: const TextStyle(
                                fontFamily: 'Courier',
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                letterSpacing: 1.5,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Date Range
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  color: Color(0xFF757575), size: 14),
                              const SizedBox(width: 8),
                              Text(
                                dateRangeStr,
                                style: const TextStyle(
                                  fontFamily: 'Courier',
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                  color: Color(0xFF757575),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Main Text
                          const Text(
                            "This month\nI spent",
                            style: TextStyle(
                              fontFamily: 'Albra',
                              fontSize: 36,
                              color: Color(
                                  0xFF1A1A1A), // Dark text on light background
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
                                style: const TextStyle(
                                  fontFamily: 'Albra',
                                  fontSize: 40,
                                  color: Color(0xFF9E9E9E),
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formattedTotal,
                                style: const TextStyle(
                                  fontFamily: 'Albra',
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A), // Dark text
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "💸",
                                style: TextStyle(fontSize: 32),
                              )
                            ],
                          ),

                          const SizedBox(height: 48),

                          // Divider
                          Container(
                            height: 1,
                            color: const Color(0xFF2A2A2A),
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
                                  const Text(
                                    "POWERED BY",
                                    style: TextStyle(
                                      fontFamily: 'Courier',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9,
                                      letterSpacing: 2.0,
                                      color: Color(0xFF757575),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Text(
                                        "Splitr",
                                        style: TextStyle(
                                          fontFamily: 'Albra',
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1A1A1A),
                                        ),
                                      ),
                                      // Optionally a small dot colored mint
                                      const SizedBox(width: 2),
                                      Container(
                                        width: 4,
                                        height: 4,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF1DE9B6),
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
                                  color: Colors.transparent,
                                  border: Border.all(
                                      color: const Color(0xFF1A1A1A), width: 2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.qr_code_2,
                                    color: Color(0xFF1A1A1A), size: 28),
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
              "\"Better experiences, better\nrewards, better rules.\"",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Albra',
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF1A1A1A).withOpacity(0.8),
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
                        color: Color(0xFF9E9E9E), shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                        color: Color(0xFF9E9E9E), shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                        color: Color(0xFF9E9E9E), shape: BoxShape.circle)),
              ],
            ),

            const SizedBox(height: 32),

            // Share Recap Button Neopop
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
                          color: Colors.black,
                        ),
                      ),
                    ),
                    // Button Top layer
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1DE9B6), // Mint green
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "SHARE RECAP",
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.ios_share, color: Colors.black, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Download Image Button Ghost
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: onNext,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border:
                        Border.all(color: const Color(0xFF1A1A1A), width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "BACK TO PROFILE",
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.arrow_forward,
                          color: Color(0xFF1A1A1A), size: 20),
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
        : '₹';
    final monthName = DateFormat('MMMM').format(month);
    final year = month.year;
    final formattedTotal = NumberFormat('#,##0').format(totalSpent);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo "Splitr." and Close Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Splitr.",
                  style: TextStyle(
                    fontFamily: 'Albra',
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black,
                    letterSpacing: 1.0,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: const Icon(Icons.close,
                        color: Color(0xFF1A1A1A), size: 18),
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
                    "Your\n$monthName\nRecap",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Albra',
                      fontSize: 54,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "HERE'S HOW YOUR MONEY MOVED THIS MONTH",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 10,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 1,
                    width: 240,
                    color: const Color(0xFFE0E0E0),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // The main card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.zero,
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
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
                        fontSize: 80,
                        color: Color(0xFFF5F5F7), // Very faint
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
                              color: const Color(0xFFE0E0E0), width: 1.0),
                        ),
                        child: Text(
                          "${monthName.toUpperCase()} $year",
                          style: const TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      const Text(
                        "TOTAL SPENT",
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 10,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            curSymbol,
                            style: const TextStyle(
                              fontFamily: 'Albra',
                              fontSize: 36,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedTotal,
                            style: const TextStyle(
                              fontFamily: 'Albra',
                              fontSize: 54,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
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
                            color: const Color(0xFFEEEEEE),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "${percentChange > 0 ? '+' : ''}${percentChange.toStringAsFixed(1)}%",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: percentChange > 0
                                  ? neopopError
                                  : neopopAccent,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                      const Divider(color: Color(0xFFEEEEEE), thickness: 1.5),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(
                            child: Text(
                              "Your spending patterns\nacross categories.",
                              style: TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF9E9E9E),
                                height: 1.4,
                              ),
                            ),
                          ),
                          // Arrow box
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFF1A1A1A), width: 1.5),
                            ),
                            child: const Icon(Icons.arrow_forward_rounded,
                                color: Color(0xFF1A1A1A), size: 18),
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
              height: 56,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: neopopAccent,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "VIEW FULL RECAP",
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(Icons.arrow_forward_rounded,
                        color: Colors.black, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
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
        : '₹';

    double percentChange = 0.0;
    if (lastMonthTotal > 0) {
      percentChange = ((totalSpent - lastMonthTotal) / lastMonthTotal) * 100;
    }

    final formattedTotal = NumberFormat('#,##0').format(totalSpent);
    final prevMonthName =
        DateFormat('MMMM').format(DateTime(month.year, month.month - 1));

    // Get Top 2 Categories
    final sortedCategories = categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top2 = sortedCategories.take(2).toList();

    final double maxCategoryAmount = top2.isNotEmpty ? top2.first.value : 1.0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            // Top App Bar Area
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Splitr.",
                  style: TextStyle(
                    fontFamily: 'Albra',
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black,
                    letterSpacing: 1.0,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: const Icon(Icons.close,
                        color: Color(0xFF1A1A1A), size: 18),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Main Dark Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF121215), // Very dark grey/black
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Wallet Icon box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFF2A2A2A), width: 1.5),
                    ),
                    child: const Icon(Icons.account_balance_wallet_outlined,
                        color: neopopAccent, size: 24),
                  ),
                  const SizedBox(height: 24),

                  // Giant Number
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        curSymbol,
                        style: const TextStyle(
                          fontFamily: 'Albra',
                          fontSize: 28,
                          color: Color(0xFF757575),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedTotal,
                        style: const TextStyle(
                          fontFamily: 'Albra',
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: neopopAccent, // Highly visible vivid color
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "TOTAL SPENT THIS MONTH",
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 10,
                      letterSpacing: 1.5,
                      color: Color(0xFF757575),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Spending Trend Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161619),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFF2A2A2A), width: 1.5),
                    ),
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "SPENDING TREND",
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              fontSize: 10,
                              color: Color(0xFF757575),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: percentChange > 0
                                  ? neopopError
                                  : neopopAccent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              percentChange > 0 ? "HIGH" : "LOW",
                              style: const TextStyle(
                                fontFamily: 'Courier',
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color:
                                    Colors.black, // Dark text on bright badge
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
                              "${percentChange > 0 ? '+' : ''}${percentChange.toStringAsFixed(1)}%",
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "compared to $prevMonthName",
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: Color(0xFF757575),
                              ),
                            )
                          ],
                        ),
                      ]),
                      const SizedBox(height: 16),
                      // Progress Bar
                      Container(
                        width: double.infinity,
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(3),
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
                                  borderRadius: BorderRadius.circular(3),
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
                      )
                    ]),
                  )
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Top Categories Header
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "TOP CATEGORIES",
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
                Text("...",
                    style: TextStyle(
                        color: Color(0xFF9E9E9E), fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),

            // Top categories list
            if (top2.isNotEmpty)
              ...top2.map((cat) {
                final val = cat.value;
                final String shortLabel = val >= 1000
                    ? '${(val / 1000).toStringAsFixed(1)}k'
                    : val.toStringAsFixed(0);

                // Mapping category to icon
                IconData catIcon = Icons.category_outlined;
                if (cat.key.toLowerCase().contains('food') ||
                    cat.key.toLowerCase().contains('dining')) {
                  catIcon = Icons.restaurant;
                } else if (cat.key.toLowerCase().contains('shop')) {
                  catIcon = Icons.shopping_bag_outlined;
                } else if (cat.key.toLowerCase().contains('travel') ||
                    cat.key.toLowerCase().contains('transport')) {
                  catIcon = Icons.directions_car_outlined;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9E9E9E).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(catIcon,
                            color: const Color(0xFF757575), size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(3),
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
                                color: const Color(0xFF757575),
                                borderRadius: BorderRadius.circular(3),
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
                          style: const TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList()
            else
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "No categorical data available",
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
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
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // Button Top layer
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: neopopAccent, // The light green
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "NEXT",
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward,
                            color: Colors.black, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Footer
            const Text(
              "SECURED BY CRED PROTECT",
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 10,
                color: Color(0xFF9E9E9E),
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
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
    Color accentC = const Color(0xFFFF9800); // Default Orange

    final lowerCat = topCategory.toLowerCase();
    if (lowerCat.contains('food') || lowerCat.contains('dining')) {
      catIcon = Icons.restaurant;
      accentC = const Color(0xFFFF9800); // Orange
    } else if (lowerCat.contains('shop')) {
      catIcon = Icons.shopping_bag;
      accentC = const Color(0xFFE91E63); // Pink
    } else if (lowerCat.contains('travel') || lowerCat.contains('transport')) {
      catIcon = Icons.directions_car;
      accentC = const Color(0xFF2196F3); // Blue
    } else if (lowerCat.contains('grocery') || lowerCat.contains('groceries')) {
      catIcon = Icons.local_grocery_store;
      accentC = const Color(0xFF4CAF50); // Green
    } else if (lowerCat.contains('bill') || lowerCat.contains('utilit')) {
      catIcon = Icons.receipt_long;
      accentC = const Color(0xFF9C27B0); // Purple
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar Area
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Splitr.",
                  style: TextStyle(
                    fontFamily: 'Albra',
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black,
                    letterSpacing: 1.0,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: const Icon(Icons.close,
                        color: Color(0xFF1A1A1A), size: 18),
                  ),
                ),
              ],
            ),

            const Spacer(flex: 1),

            // Giant Title Area
            const Text(
              "Your",
              style: TextStyle(
                fontFamily: 'Albra',
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
                height: 1.1,
              ),
            ),
            const Text(
              "favourite",
              style: TextStyle(
                fontFamily: 'Albra',
                fontSize: 48,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: Color(0xFF555555),
                height: 1.1,
              ),
            ),
            const Text(
              "Category",
              style: TextStyle(
                fontFamily: 'Albra',
                fontSize: 52,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
                height: 1.1,
              ),
            ),

            const SizedBox(height: 32),

            // The main dark card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF121215),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Inner header
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("...",
                          style: TextStyle(
                              color: Color(0xFF757575),
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      Text(
                        "SPLITR • ID 8821",
                        style: TextStyle(
                          fontFamily: 'Courier',
                          color: Color(0xFF757575),
                          fontSize: 10,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Category Icon Box
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1B20),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFF2A2A2A), width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Icon(catIcon, color: accentC, size: 40),
                  ),
                  const SizedBox(height: 32),

                  // "You spent the most on"
                  const Text(
                    "You spent the most on",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    topCategory,
                    style: TextStyle(
                      fontFamily: 'Albra',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: accentC,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Impact Sub-card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161619),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFF2A2A2A), width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "IMPACT",
                              style: TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 10,
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF757575),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "$impactInt%",
                              style: const TextStyle(
                                fontFamily: 'Albra',
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "of your total spend",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                color: Color(0xFF757575),
                              ),
                            )
                          ],
                        ),

                        // Circular Chart
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: 1.0,
                                strokeWidth: 8,
                                color: const Color(0xFF2A2A2A),
                              ),
                              CircularProgressIndicator(
                                value: impactPercentage / 100,
                                strokeWidth: 8,
                                color: accentC,
                                backgroundColor: Colors.transparent,
                                strokeCap: StrokeCap.round,
                              ),
                              const Center(
                                child: Icon(Icons.flash_on,
                                    size: 14, color: Color(0xFF757575)),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Witty remark
            const Center(
              child: Text(
                "Your taste is impeccable, just like your credit\nscore.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 11,
                  color: Color(0xFF757575),
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
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // Button Top layer
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: neopopAccent, // The light green
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "NEXT INSIGHT",
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward,
                            color: Colors.black, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFourthSlide({
    required DateTime month,
    required double averageDailySpend,
    required VoidCallback onNext,
    required VoidCallback onBack,
  }) {
    final monthName = DateFormat('MMMM').format(month);
    final curSymbol = Get.isRegistered<CurrencyController>()
        ? Get.find<CurrencyController>().symbol
        : '₹';

    final formattedDaily = NumberFormat('#,##0').format(averageDailySpend);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar Area
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Splitr text logo
                const Text(
                  'Splitr.',
                  style: TextStyle(
                    fontFamily: 'Albra',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: const Icon(Icons.close,
                        color: Color(0xFF1A1A1A), size: 18),
                  ),
                ),
              ],
            ),

            const Spacer(flex: 1),

            // Giant Title Area
            const Text(
              "your spending",
              style: TextStyle(
                fontFamily: 'Albra',
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
                height: 1.1,
                letterSpacing: -1.0,
              ),
            ),
            const Text(
              "habit.",
              style: TextStyle(
                fontFamily: 'Albra',
                fontSize: 52,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
                color: Color(0xFF1DE9B6), // Mint green
                height: 1.1,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  color: const Color(0xFF1DE9B6),
                ),
                const SizedBox(width: 8),
                Text(
                  "MONTHLY RECAP • ${monthName.toUpperCase()}",
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Average Daily Spend Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF121215),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative top right lines
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                          border: Border(
                        top: BorderSide(color: Color(0xFF1DE9B6), width: 2),
                        right: BorderSide(color: Color(0xFF1DE9B6), width: 2),
                      )),
                    ),
                  ),
                  // Decorative bottom left lines
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                          border: Border(
                        bottom: BorderSide(color: Color(0xFF1DE9B6), width: 2),
                        left: BorderSide(color: Color(0xFF1DE9B6), width: 2),
                      )),
                    ),
                  ),
                  Column(
                    children: [
                      // Currency Bubble
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1DE9B6),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1DE9B6).withOpacity(0.4),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          curSymbol,
                          style: const TextStyle(
                            fontFamily: 'Albra',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
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
                            "$curSymbol$formattedDaily",
                            style: const TextStyle(
                              fontFamily: 'Albra',
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            "/day",
                            style: TextStyle(
                              fontFamily: 'Albra',
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF9E9E9E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "AVERAGE DAILY SPEND",
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 10,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF757575),
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
                const Text(
                  "TREND",
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.5,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF162521), // Darkened mint backing
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "+12% vs Sep",
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1DE9B6),
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 12),

            // Mini Trend Chart Card
            Container(
              height: 100,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF121215),
                borderRadius: BorderRadius.circular(16),
              ),
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
                        color: const Color(0xFF2A2A2A),
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
                      color: const Color(0xFF1DE9B6),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF1DE9B6).withOpacity(0.05),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Insight Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: const Color(0xFF121215),
                  borderRadius: BorderRadius.circular(8),
                  border: const Border(
                    left: BorderSide(color: Color(0xFF1DE9B6), width: 4),
                  )),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome,
                      color: Color(0xFF1DE9B6), size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Weekend Warrior",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Most of your high-value transactions happened on Saturdays and Sundays.",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: const Color(0xFF9E9E9E).withOpacity(0.8),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  )
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
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // Button Top layer
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1DE9B6), // Mint green
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "NEXT INSIGHT",
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward,
                            color: Colors.black, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        : '₹';

    final formattedAmount = NumberFormat('#,##0').format(biggestExpenseAmount);

    // Process Date string to extract 'FEB' and '12'
    String tMonth = "N/A";
    String tDay = "-";
    if (biggestExpenseDate != null) {
      tMonth = DateFormat('MMM').format(biggestExpenseDate).toUpperCase();
      tDay = biggestExpenseDate.day.toString();
    }

    // Process Category to icon
    IconData catIcon = Icons.category;
    final lowerCat = biggestExpenseCategory.toLowerCase();
    if (lowerCat.contains('food') || lowerCat.contains('dining')) {
      catIcon = Icons.restaurant;
    } else if (lowerCat.contains('shop')) {
      catIcon = Icons.shopping_bag;
    } else if (lowerCat.contains('travel') ||
        lowerCat.contains('transport') ||
        lowerCat.contains('flight')) {
      catIcon = Icons.flight_takeoff;
    } else if (lowerCat.contains('grocery') || lowerCat.contains('groceries')) {
      catIcon = Icons.local_grocery_store;
    } else if (lowerCat.contains('bill') || lowerCat.contains('utilit')) {
      catIcon = Icons.receipt_long;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            // Top App Bar Area
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Splitr.",
                  style: TextStyle(
                    fontFamily: 'Albra',
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black,
                    letterSpacing: 1.0,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: const Icon(Icons.close,
                        color: Color(0xFF1A1A1A), size: 18),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Giant Title Area
            const Text(
              "Biggest",
              style: TextStyle(
                fontFamily: 'Albra',
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
                height: 1.1,
              ),
            ),
            const Text(
              "Payment",
              style: TextStyle(
                fontFamily: 'Albra',
                fontSize: 52,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
                height: 1.1,
              ),
            ),

            const SizedBox(height: 32),

            // Main Dark Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF121215), // Very dark grey/black
                borderRadius: BorderRadius.circular(24),
                border: const Border(
                  left: BorderSide(
                      color: Color(0xFF1DE9B6), width: 4), // Mint accent
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "TOTAL SPENT",
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 10,
                      letterSpacing: 2.0,
                      color: Color(0xFF757575),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Giant Number
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        curSymbol,
                        style: const TextStyle(
                          fontFamily: 'Albra',
                          fontSize: 28,
                          color: Color(0xFF9E9E9E),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedAmount,
                        style: const TextStyle(
                          fontFamily: 'Albra',
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  const Text(
                    "Biggest payment you made",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // The Transaction Block
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0D0F),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFF1A1A1A), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        // Icon Square
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(
                                0xFF232336), // Deep purple tone from image
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFF33334D), width: 1.0),
                          ),
                          alignment: Alignment.center,
                          child: Icon(catIcon,
                              color: const Color(0xFF8B9FFF), size: 24),
                        ),
                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                biggestExpenseTitle,
                                style: const TextStyle(
                                  fontFamily: 'Albra',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "$biggestExpenseCategory • SPLITR",
                                style: const TextStyle(
                                  fontFamily: 'Courier',
                                  fontSize: 10,
                                  color: Color(0xFF757575),
                                  letterSpacing: 1.0,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Date Box
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color(0xFF2A2A2A), width: 1.0),
                          ),
                          child: Column(
                            children: [
                              Text(
                                tMonth,
                                style: const TextStyle(
                                  fontFamily: 'Courier',
                                  fontSize: 9,
                                  color: Color(0xFF9E9E9E),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tDay,
                                style: const TextStyle(
                                  fontFamily: 'Albra',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Below Cards Row
            Row(
              children: [
                // vs Last Month (Mock)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121215),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "vs Last Month",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Color(0xFF757575),
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.trending_up,
                                color: Color(0xFF1DE9B6), size: 16),
                            SizedBox(width: 8),
                            Text(
                              "+12%",
                              style: TextStyle(
                                fontFamily: 'Albra',
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFF1DE9B6),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Category Rank (Mock)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121215),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Category Rank",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Color(0xFF757575),
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.emoji_events,
                                color: Colors.amber, size: 16),
                            SizedBox(width: 8),
                            Text(
                              "#1",
                              style: TextStyle(
                                fontFamily: 'Albra',
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            )
                          ],
                        )
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
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // Button Top layer
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1DE9B6), // Mint green
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "SEE SUMMARY",
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward,
                            color: Colors.black, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
