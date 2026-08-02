import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:splitr/Services/monthly_recap_aggregator.dart';
import 'package:splitr/Services/recap_drop_service.dart';
import 'package:splitr/Services/recap_share_pack_exporter.dart';
import 'package:splitr/Widgets/recap_share_pack_card.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Services/public_share_link_service.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Controller/profile_controller.dart';
import 'package:splitr/Widgets/recap_badge_lottie.dart';
import 'package:splitr/Widgets/recap_glitch_reveal.dart';
import 'package:splitr/Widgets/recap_settlement_tick.dart';
import 'package:splitr/Widgets/recap_goal_confetti.dart';
import 'package:splitr/Widgets/recap_stagger_reveal.dart';
import 'package:splitr/Widgets/recap_lending_ledger.dart';
import 'package:splitr/Model/loan_payment_recap_row.dart';
import 'package:splitr/Widgets/recap_friend_avatar_stack.dart';
import 'package:splitr/Widgets/recap_pulse_cta.dart';
import 'package:splitr/Widgets/recap_share_card.dart';
import 'package:splitr/Widgets/recap_animated_goal_ring.dart';
import 'package:splitr/Widgets/recap_count_up_text.dart';
import 'package:splitr/Widgets/recap_flip_reveal.dart';
import 'package:splitr/Widgets/recap_intro_reveal.dart';
import 'package:splitr/Widgets/recap_sparkline.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Utils/num_parsing.dart';
import 'package:splitr/Utils/recap_chart_utils.dart';
import 'package:splitr/Utils/recap_month_nav.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';
import 'package:splitr/Screen/ProfileScreen/monthly_recap_story_host.dart';

class MonthlyRecapScreen extends StatefulWidget {
  const MonthlyRecapScreen({this.month, super.key});

  /// Recap month (normalized to first of month). Defaults to current month.
  final DateTime? month;

  @override
  State<MonthlyRecapScreen> createState() => _MonthlyRecapScreenState();
}

class _MonthlyRecapScreenState extends State<MonthlyRecapScreen> {
  final MonthlyRecapAggregator _recapAggregator = MonthlyRecapAggregator();
  final ScreenshotController _screenshotController = ScreenshotController();
  static const _storyNavigation = true;

  Map<String, dynamic>? _recapData;
  bool _isLoading = true;
  bool _shareFlash = false;
  bool _autoAdvanceIntro = false;
  late DateTime _selectedMonth;

  bool get _isInitialLoading => _isLoading && _recapData == null;

  double get _expenseTotal {
    if (_recapData == null) return 0;
    final raw = _recapData![RecapDataKeys.expenseTotal];
    if (raw is num) return raw.toDouble();
    return asDouble(_recapData![RecapDataKeys.totalSpent]);
  }

  @override
  void initState() {
    super.initState();
    _selectedMonth =
        RecapMonthNav.normalize(widget.month ?? DateTime.now());
    _loadRecap();
  }

  EdgeInsets _recapSlideInsets({
    double horizontal = groupGapLg,
    double vertical = groupGutter,
  }) {
    final padding = MediaQuery.paddingOf(context);
    const storyProgressReserve = 28.0;
    return EdgeInsets.fromLTRB(
      horizontal,
      vertical + padding.top + (_storyNavigation ? storyProgressReserve : 0),
      horizontal,
      vertical + padding.bottom,
    );
  }

  Future<void> _loadRecap() async {
    if (mounted) setState(() => _isLoading = true);
    final autoIntro = await RecapDropService().shouldAutoAdvanceIntro();
    final payload = await _recapAggregator.loadPayload(_selectedMonth);
    if (mounted) {
      setState(() {
        _recapData = payload.toMap();
        _autoAdvanceIntro = autoIntro;
        _isLoading = false;
      });
      await RecapDropService().markViewed(_selectedMonth);
    }
  }

  void _popRecap() {
    if (!mounted) return;
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop();
  }

  String _trendVsLastMonthLabel() {
    if (_recapData == null) return AppStrings.recap.unavailableTrend;
    final expenseTotal = _expenseTotal;
    final lastMonthTotal = asDouble(_recapData![RecapDataKeys.lastMonthTotal]);
    final month = _recapData![RecapDataKeys.month] as DateTime;
    if (lastMonthTotal <= 0) return AppStrings.recap.noPriorMonthData;
    final pct = ((expenseTotal - lastMonthTotal) / lastMonthTotal) * 100;
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
    final expenseTotal = _expenseTotal;
    final lastMonthTotal = asDouble(_recapData![RecapDataKeys.lastMonthTotal]);
    if (lastMonthTotal <= 0) return AppStrings.recap.unavailableTrend;
    final pct = ((expenseTotal - lastMonthTotal) / lastMonthTotal) * 100;
    final sign = pct > 0 ? '+' : '';
    return AppStringFormat.recapSignedPercent('$sign${pct.toStringAsFixed(0)}');
  }

  bool get _trendIsUp {
    if (_recapData == null) return false;
    return _expenseTotal > asDouble(_recapData![RecapDataKeys.lastMonthTotal]);
  }

  List<Map<String, dynamic>> get _spendingTrend {
    final raw = _recapData?[RecapDataKeys.spendingTrend];
    if (raw is List) {
      return raw.cast<Map<String, dynamic>>();
    }
    return const [];
  }

  String get _habitType =>
      _recapData?[RecapDataKeys.habitType] as String? ??
      RecapHabitTypes.quietMonth;

  ({String title, String description}) _habitCopy() {
    switch (_habitType) {
      case RecapHabitTypes.weekendSplurger:
        return (
          title: AppStrings.recap.weekendSplurger,
          description: AppStrings.recap.weekendSplurgerDesc,
        );
      case RecapHabitTypes.weekdayGrinder:
        return (
          title: AppStrings.recap.weekdayGrinder,
          description: AppStrings.recap.weekdayGrinderDesc,
        );
      case RecapHabitTypes.steadySpender:
        return (
          title: AppStrings.recap.steadySpender,
          description: AppStrings.recap.steadySpenderDesc,
        );
      default:
        return (
          title: AppStrings.recap.quietMonthHabit,
          description: AppStrings.recap.quietMonthHabitDesc,
        );
    }
  }

  int get _topCategoryRank {
    final rank = _recapData?[RecapDataKeys.topCategoryRank];
    if (rank is int && rank > 0) return rank;
    return 1;
  }

  int get _groupCount {
    final count = _recapData?[RecapDataKeys.groupCount];
    if (count is int) return count;
    if (count is num) return count.toInt();
    return 0;
  }

  String? get _topGroupName =>
      _recapData?[RecapDataKeys.topGroupName] as String?;

  double get _payerRatio =>
      asDouble(_recapData?[RecapDataKeys.payerRatio]);

  int get _settlementAvgDays {
    final days = _recapData?[RecapDataKeys.settlementAvgDays];
    if (days is int) return days;
    if (days is num) return days.toInt();
    return 0;
  }

  int get _settleUpHealthScore {
    final score = _recapData?[RecapDataKeys.settleUpHealthScore];
    if (score is int) return score;
    if (score is num) return score.toInt();
    return InsightsLimits.settleHealthDefault;
  }

  bool get _showGroupSlide =>
      _recapData?[RecapDataKeys.hasGroupActivity] == true ||
      _groupCount > 0 ||
      (_topGroupName != null && _topGroupName!.trim().isNotEmpty);

  String? get _topFriendName =>
      _recapData?[RecapDataKeys.topFriendName] as String?;

  List<Map<String, dynamic>> get _groupFriendPeers {
    final raw = _recapData?[RecapDataKeys.groupFriendPeers];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  bool get _showLendingSlide =>
      _recapData?[RecapDataKeys.hasLendingActivity] == true;

  int get _activeLoanCount {
    final count = _recapData?[RecapDataKeys.activeLoanCount];
    if (count is int) return count;
    if (count is num) return count.toInt();
    return 0;
  }

  double get _totalLoanOutstanding =>
      asDouble(_recapData?[RecapDataKeys.totalLoanOutstanding]);

  double get _totalRepaidThisMonth =>
      asDouble(_recapData?[RecapDataKeys.totalRepaidThisMonth]);

  int get _loansWithPaymentThisMonth {
    final count = _recapData?[RecapDataKeys.loansWithPaymentThisMonth];
    if (count is int) return count;
    if (count is num) return count.toInt();
    return 0;
  }

  int get _loansCompletedThisMonth {
    final count = _recapData?[RecapDataKeys.loansCompletedThisMonth];
    if (count is int) return count;
    if (count is num) return count.toInt();
    return 0;
  }

  String get _topLoanTitle =>
      (_recapData?[RecapDataKeys.topLoanTitle] as String?) ??
      DisplayFallbacks.untitled;

  double get _topLoanProgress =>
      asDouble(_recapData?[RecapDataKeys.topLoanProgress]).clamp(0.0, 1.0);

  List<LoanPaymentRecapRow> get _lendingLedgerRows {
    final raw = _recapData?[RecapDataKeys.lendingLedgerRows];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => LoanPaymentRecapRow.fromLedgerMap(
              Map<String, dynamic>.from(e),
            ))
        .toList();
  }

  bool get _showGoalsSlide =>
      _recapData?[RecapDataKeys.hasGoalsActivity] == true;

  int get _activeGoalsCount {
    final count = _recapData?[RecapDataKeys.activeGoalsCount];
    if (count is int) return count;
    if (count is num) return count.toInt();
    return 0;
  }

  String get _bestGoalTitle =>
      (_recapData?[RecapDataKeys.bestGoalTitle] as String?) ??
      DisplayFallbacks.goal;

  double get _bestGoalProgress =>
      asDouble(_recapData?[RecapDataKeys.bestGoalProgress]).clamp(0.0, 1.0);

  double get _goalsContributedThisMonth =>
      asDouble(_recapData?[RecapDataKeys.goalsContributedThisMonth]);

  String get _goalsMotivationLine {
    final key = _recapData?[RecapDataKeys.goalsMotivationLine] as String?;
    if (_goalCompletedInMonth) return AppStrings.recap.goalTargetHit;
    if (key == RecapGoalMotivation.needsPush) {
      return AppStrings.recap.goalsNeedsPush;
    }
    return AppStrings.recap.goalsOnTrack;
  }

  bool get _goalCompletedInMonth =>
      _recapData?[RecapDataKeys.goalCompletedInMonth] == true;

  bool get _showPersonaSlide =>
      _recapData?[RecapDataKeys.hasPersonaSlide] == true;

  String get _personaType =>
      (_recapData?[RecapDataKeys.personaType] as String?) ??
      RecapPersonaTypes.steadySplitter;

  String get _personaTitle => switch (_personaType) {
        RecapPersonaTypes.settlementHero =>
          AppStrings.recap.personaSettlementHero,
        RecapPersonaTypes.goalGrinder => AppStrings.recap.personaGoalGrinder,
        RecapPersonaTypes.groupHost => AppStrings.recap.personaGroupHost,
        RecapPersonaTypes.quietMonth => AppStrings.recap.personaQuietMonth,
        RecapPersonaTypes.socialSplitter =>
          AppStrings.recap.personaSocialSplitter,
        _ => AppStrings.recap.personaSteadySplitter,
      };

  String get _personaSubtitle => switch (_personaType) {
        RecapPersonaTypes.settlementHero =>
          AppStrings.recap.personaSettlementHeroSub,
        RecapPersonaTypes.goalGrinder => AppStrings.recap.personaGoalGrinderSub,
        RecapPersonaTypes.groupHost => AppStrings.recap.personaGroupHostSub,
        RecapPersonaTypes.quietMonth => AppStrings.recap.personaQuietMonthSub,
        RecapPersonaTypes.socialSplitter =>
          AppStrings.recap.personaSocialSplitterSub,
        _ => AppStrings.recap.personaSteadySplitterSub,
      };

  String _personaStatLabel(String key) => switch (key) {
        RecapPersonaStatKeys.settlements => AppStrings.recap.statSettlements,
        RecapPersonaStatKeys.groups => AppStrings.recap.statGroups,
        RecapPersonaStatKeys.saved => AppStrings.recap.statSaved,
        RecapPersonaStatKeys.spendShare => AppStrings.recap.statSpendShare,
        RecapPersonaStatKeys.fronted => AppStrings.recap.statFronted,
        RecapPersonaStatKeys.spendChange => AppStrings.recap.statSpendChange,
        _ => AppStrings.recap.statSpent,
      };

  String get _personaStatOneLabel => _personaStatLabel(
        (_recapData?[RecapDataKeys.personaStatOneLabel] as String?) ??
            RecapPersonaStatKeys.spent,
      );

  String get _personaStatOneValue =>
      (_recapData?[RecapDataKeys.personaStatOneValue] as String?) ?? '0';

  String get _personaStatTwoLabel => _personaStatLabel(
        (_recapData?[RecapDataKeys.personaStatTwoLabel] as String?) ??
            RecapPersonaStatKeys.spendChange,
      );

  String get _personaStatTwoValue =>
      (_recapData?[RecapDataKeys.personaStatTwoValue] as String?) ?? '0';

  bool get _hasMonthlyBadge =>
      _recapData?[RecapDataKeys.hasMonthlyBadge] == true;

  String? get _monthlyBadgeName =>
      _recapData?[RecapDataKeys.monthlyBadgeName] as String?;

  String? get _monthlyBadgeDescription =>
      _recapData?[RecapDataKeys.monthlyBadgeDescription] as String?;

  Widget _recapAdvanceButton(Widget button) {
    if (_storyNavigation) return const SizedBox.shrink();
    return button;
  }

  String get _recapFirstName {
    if (Get.isRegistered<ProfileController>()) {
      final name =
          Get.find<ProfileController>().user.value?.firstName?.trim();
      if (name != null && name.isNotEmpty) return name;
    }
    return DisplayFallbacks.your;
  }

  Future<void> _shareWebLink() async {
    if (_recapData == null) return;
    try {
      final month = _recapData![RecapDataKeys.month] as DateTime;
      final payload = <String, dynamic>{
        RecapSharePayloadKeys.monthLabel:
            DateFormat(AppDateFormats.monthYear).format(month),
        RecapSharePayloadKeys.persona: _personaTitle,
        RecapSharePayloadKeys.topCategory:
            _recapData![RecapDataKeys.topCategory],
      };
      if (_showGroupSlide && _topGroupName != null) {
        payload[RecapSharePayloadKeys.groupHighlight] = _topGroupName;
      }
      if (_showGoalsSlide) {
        payload[RecapSharePayloadKeys.goalHighlight] = _bestGoalTitle;
      }
      final url = await PublicShareLinkService().createLink(
        type: ShareTypes.monthlyRecap,
        payload: payload,
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

  List<RecapSharePackCardData> _sharePackCards() {
    final month = _recapData![RecapDataKeys.month] as DateTime;
    final cards = <RecapSharePackCardData>[
      RecapSharePackCardData(
        kind: RecapSharePackKind.persona,
        month: month,
        firstName: _recapFirstName,
        personaTitle: _personaTitle,
        personaType: _personaType,
        badgeName: _hasMonthlyBadge ? _monthlyBadgeName : null,
      ),
    ];

    final settlementsRaw = _recapData?[RecapDataKeys.settlementsClosedCount];
    final settlementsClosed = settlementsRaw is int
        ? settlementsRaw
        : (settlementsRaw as num?)?.toInt() ?? 0;
    if (settlementsClosed > 0) {
      cards.add(
        RecapSharePackCardData(
          kind: RecapSharePackKind.settlementsClosed,
          month: month,
          firstName: _recapFirstName,
          personaTitle: _personaTitle,
          personaType: _personaType,
          settlementsClosed: settlementsClosed,
        ),
      );
    }

    final topCategory = _recapData![RecapDataKeys.topCategory] as String;
    if (topCategory != DisplayFallbacks.none &&
        _expenseTotal > 0) {
      cards.add(
        RecapSharePackCardData(
          kind: RecapSharePackKind.spendPersonality,
          month: month,
          firstName: _recapFirstName,
          personaTitle: _personaTitle,
          personaType: _personaType,
          topSpendCategory: topCategory,
          habitLabel: _habitCopy().title,
        ),
      );
    }

    if (_showGoalsSlide) {
      cards.add(
        RecapSharePackCardData(
          kind: RecapSharePackKind.goalMomentum,
          month: month,
          firstName: _recapFirstName,
          personaTitle: _personaTitle,
          personaType: _personaType,
          goalName: _bestGoalTitle,
          goalProgressPercent: _bestGoalProgress * 100,
          goalHit: _bestGoalProgress >= 1,
        ),
      );
    }

    return cards;
  }

  Future<String?> _captureStoryImage(RecapSharePackCardData card) {
    return RecapSharePackExporter.captureStoryPng(
      context: context,
      data: card,
      filenameMillis: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<String?> _captureSquareImage(RecapSharePackCardData card) {
    return RecapSharePackExporter.captureSquarePng(
      context: context,
      data: card,
      filenameMillis: DateTime.now().millisecondsSinceEpoch,
    );
  }

  String _shareImageCaption({required bool includeSpend}) {
    var text = AppStringFormat.shareImageRecap();
    if (!includeSpend || _expenseTotal <= 0) return text;
    final curSymbol = Get.isRegistered<CurrencyController>()
        ? Get.find<CurrencyController>().symbol
        : CurrencyService.symbolFor(CurrencyDefaults.code);
    final formatted =
        NumberFormat(AppDateFormats.numberGrouped).format(_expenseTotal);
    return '$text $curSymbol$formatted ${AppStrings.recap.totalSpentThisMonth.toLowerCase()}.';
  }

  void _showSharePackPreview() {
    final cards = _sharePackCards();
    if (cards.isEmpty) return;
    final pageController = PageController();
    var includeSpend = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: neopopBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(groupCardRadiusXl)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: groupGapMd),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.recap.sharePackPreviewTitle,
                      style:
                          body1_text.copyWith(color: AppPalette.recapOnSurface),
                    ),
                    const SizedBox(height: groupGapMd),
                    SizedBox(
                      height: RecapSharePackCard.storyHeight * 0.55,
                      child: PageView.builder(
                        controller: pageController,
                        itemCount: cards.length,
                        itemBuilder: (_, index) {
                          return Center(
                            child: FittedBox(
                              child: RecapSharePackCard(data: cards[index]),
                            ),
                          );
                        },
                      ),
                    ),
                    SwitchListTile(
                      value: includeSpend,
                      activeThumbColor: AppPalette.mintAccent,
                      title: Text(
                        AppStrings.recap.includeMySpendInShare,
                        style: body2_text.copyWith(
                          color: AppPalette.recapOnSurface,
                        ),
                      ),
                      onChanged: (value) =>
                          setSheetState(() => includeSpend = value),
                    ),
                    ListTile(
                      leading: const Icon(Icons.auto_stories_outlined,
                          color: AppPalette.mintAccent),
                      title: Text(
                        AppStrings.recap.shareToStory,
                        style:
                            body1_text.copyWith(color: AppPalette.recapOnSurface),
                      ),
                      onTap: () async {
                        final index = pageController.page?.round() ?? 0;
                        Navigator.pop(sheetContext);
                        await _shareStoryImage(
                          cards[index.clamp(0, cards.length - 1)],
                          includeSpend: includeSpend,
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.crop_square_outlined,
                          color: AppPalette.mintAccent),
                      title: Text(
                        AppStrings.recap.shareToFeed,
                        style:
                            body1_text.copyWith(color: AppPalette.recapOnSurface),
                      ),
                      onTap: () async {
                        final index = pageController.page?.round() ?? 0;
                        Navigator.pop(sheetContext);
                        await _shareSquareImage(
                          cards[index.clamp(0, cards.length - 1)],
                          includeSpend: includeSpend,
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.download_outlined,
                          color: AppPalette.mintAccent),
                      title: Text(
                        AppStrings.recap.saveImage,
                        style:
                            body1_text.copyWith(color: AppPalette.recapOnSurface),
                      ),
                      onTap: () async {
                        final index = pageController.page?.round() ?? 0;
                        Navigator.pop(sheetContext);
                        await _saveStoryImage(
                          cards[index.clamp(0, cards.length - 1)],
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.link, color: AppPalette.mintAccent),
                      title: Text(
                        AppStrings.recap.shareWebLink,
                        style:
                            body1_text.copyWith(color: AppPalette.recapOnSurface),
                      ),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _shareWebLink();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showShareSheet() {
    _showSharePackPreview();
  }

  Future<void> _flashShareSuccess() async {
    setState(() => _shareFlash = true);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (mounted) setState(() => _shareFlash = false);
  }

  Future<void> _shareStoryImage(
    RecapSharePackCardData card, {
    bool includeSpend = false,
  }) async {
    try {
      final imagePath = await _captureStoryImage(card);
      if (imagePath == null) {
        Get.snackbar(
          AppStrings.errors.actionHumorous,
          AppStrings.recap.shareImageFailed,
        );
        return;
      }
      await HapticFeedback.lightImpact();
      await _flashShareSuccess();
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: _shareImageCaption(includeSpend: includeSpend),
      );
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        AppStrings.recap.errorSharingImage,
        error: e,
        stack: stack,
      );
    }
  }

  Future<void> _saveStoryImage(RecapSharePackCardData card) async {
    try {
      final imagePath = await _captureStoryImage(card);
      if (imagePath == null) {
        Get.snackbar(
          AppStrings.errors.actionHumorous,
          AppStrings.recap.shareImageFailed,
        );
        return;
      }
      await HapticFeedback.lightImpact();
      await _flashShareSuccess();
      await Share.shareXFiles([XFile(imagePath)]);
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        AppStrings.recap.errorSharingImage,
        error: e,
        stack: stack,
      );
    }
  }

  Future<void> _shareSquareImage(
    RecapSharePackCardData card, {
    bool includeSpend = false,
  }) async {
    try {
      final imagePath = await _captureSquareImage(card);
      if (imagePath == null) {
        Get.snackbar(
          AppStrings.errors.actionHumorous,
          AppStrings.recap.shareImageFailed,
        );
        return;
      }
      await HapticFeedback.lightImpact();
      await _flashShareSuccess();
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: _shareImageCaption(includeSpend: includeSpend),
      );
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        AppStrings.recap.errorSharingImage,
        error: e,
        stack: stack,
      );
    }
  }

  Future<void> _saveSquareImage(RecapSharePackCardData card) async {
    try {
      final imagePath = await _captureSquareImage(card);
      if (imagePath == null) {
        Get.snackbar(
          AppStrings.errors.actionHumorous,
          AppStrings.recap.shareImageFailed,
        );
        return;
      }
      await HapticFeedback.lightImpact();
      await _flashShareSuccess();
      await Share.shareXFiles([XFile(imagePath)]);
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        AppStrings.recap.errorSharingImage,
        error: e,
        stack: stack,
      );
    }
  }

  void _shareSummary() {
    _showShareSheet();
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    if (_isInitialLoading) {
      return Scaffold(
        backgroundColor: surface,
        appBar: SplitrDetailAppBar(
          title: AppStrings.profile.monthlyRecap,
        ),
        body: const Center(child: LoadingWidget()),
      );
    }

    if (_recapData == null) {
      return Scaffold(
        backgroundColor: surface,
        appBar: SplitrDetailAppBar(
          title: AppStrings.profile.monthlyRecap,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              const Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: AppPalette.recapOnSurfaceMuted,
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.recap.noSpendingData,
                style: body1_text.copyWith(color: AppPalette.recapOnSurfaceMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final expenseTotal = _expenseTotal;
    final lastMonthTotal = asDouble(_recapData![RecapDataKeys.lastMonthTotal]);
    final topCategory = _recapData![RecapDataKeys.topCategory] as String;
    final topCategoryAmount =
        asDouble(_recapData![RecapDataKeys.topCategoryAmount]);
    final month = _recapData![RecapDataKeys.month] as DateTime;
    final habitTxnCount =
        _recapData?[RecapDataKeys.habitTransactionCount] as int? ?? 0;
    final showHabitSlide =
        habitTxnCount >= InsightsLimits.minTxnsForHabit;

    return Scaffold(
      backgroundColor: neopopBackground,
      body: Stack(
        children: [
          MonthlyRecapStoryHost(
        autoAdvanceIntro: _autoAdvanceIntro,
        onIntroAutoAdvanced: () => RecapDropService().markIntroAutoPlayed(),
        onComplete: () => _popRecap(),
        slides: [
          _buildNewFirstSlide(
            month: month,
            onNext: () {},
            onBack: () => _popRecap(),
          ),
          if (expenseTotal > 0)
            _buildSecondSlide(
              month: month,
              totalSpent: expenseTotal,
              lastMonthTotal: lastMonthTotal,
              spendingTrend: _spendingTrend,
              onNext: () {},
              onBack: () {},
            ),
          if (topCategory != DisplayFallbacks.none && expenseTotal > 0)
            _buildThirdSlide(
              month: month,
              topCategory: topCategory,
              topCategoryAmount: topCategoryAmount,
              totalSpent: expenseTotal,
              onNext: () {},
              onBack: () {},
            ),
          if (showHabitSlide)
            _buildFourthSlide(
              month: month,
              habitTitle: _habitCopy().title,
              habitDescription: _habitCopy().description,
              onNext: () {},
              onBack: () {},
            ),
          if (_showGroupSlide)
            _buildGroupSlide(
              month: month,
              groupCount: _groupCount,
              topGroupName: _topGroupName ?? DisplayFallbacks.aGroup,
              topFriendName: _topFriendName,
              groupFriendPeers: _groupFriendPeers,
              payerRatio: _payerRatio,
              settlementAvgDays: _settlementAvgDays,
              settleUpHealthScore: _settleUpHealthScore,
              onNext: () {},
              onBack: () {},
            ),
          if (_showGoalsSlide)
            _buildGoalsSlide(
              month: month,
              activeGoalsCount: _activeGoalsCount,
              bestGoalTitle: _bestGoalTitle,
              bestGoalProgress: _bestGoalProgress,
              contributedThisMonth: _goalsContributedThisMonth,
              motivationLine: _goalsMotivationLine,
              goalCompletedInMonth: _goalCompletedInMonth,
              onNext: () {},
              onBack: () {},
            ),
          if (_showPersonaSlide)
            _buildPersonaSlide(
              month: month,
              statOneLabel: _personaStatOneLabel,
              statOneValue: _personaStatOneValue,
              statTwoLabel: _personaStatTwoLabel,
              statTwoValue: _personaStatTwoValue,
              badgeName: _monthlyBadgeName,
              badgeDescription: _monthlyBadgeDescription,
              showBadge: _hasMonthlyBadge,
              onNext: () {},
              onBack: () {},
            ),
          _buildFinalSlide(
            month: month,
            onNext: () => _popRecap(),
            onBack: () {},
          ),
        ],
          ),
          if (_shareFlash)
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
            ),
          if (_isLoading)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.45),
                child: const Center(child: LoadingWidget()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFinalSlide({
    required DateTime month,
    required VoidCallback onNext,
    required VoidCallback onBack,
  }) {
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

    // Profile data
    final firstName = _recapFirstName;

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
                      color: AppPalette.recapOnSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _popRecap(),
                    child: Container(
                      padding: const EdgeInsets.all(groupGapSm),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppPalette.recapBorder),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppPalette.recapOnSurface, size: 18),
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
                      color: AppPalette.recapOnSurface,
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
                    color: AppPalette.recapCardFill, // Light theme card
                    borderRadius: BorderRadius.circular(groupCardRadiusXl),
                    border: Border.all(
                        color: AppPalette.recapBorder, width: 1.5),
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
                                color: AppPalette.recapOnSurface,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Date Range
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  color: AppPalette.recapOnSurfaceMuted, size: 14),
                              const SizedBox(width: 8),
                              Text(
                                dateRangeStr,
                                style: TextStyle(
                                  fontFamily: kFontCourier,
                                  fontSize: splitrFontMicro,
                                  letterSpacing: 1.5,
                                  color: AppPalette.recapOnSurfaceMuted,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          Text(
                            _personaTitle.toUpperCase(),
                            style: TextStyle(
                              fontFamily: kFontAlbra,
                              fontSize: splitrFontRecapMd,
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.italic,
                              color: AppPalette.mintAccent,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppStrings.recap.sharePackPersonaPraise,
                            style: TextStyle(
                              fontFamily: kFontCourier,
                              fontSize: splitrFontCaption,
                              color: AppPalette.recapOnSurfaceMuted,
                            ),
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
                                      color: AppPalette.recapOnSurfaceMuted,
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
                                          color: AppPalette.recapOnSurface,
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
                                      color: AppPalette.recapOnSurface, width: 2),
                                  borderRadius:
                                      BorderRadius.circular(groupRadiusSm),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.qr_code_2,
                                    color: AppPalette.recapOnSurface, size: 28),
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

            Text(
              AppStrings.recap.securedBySplitr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kFontAlbra,
                fontSize: splitrFontBodyLg,
                fontStyle: FontStyle.italic,
                color: AppPalette.recapOnSurface,
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
                        color: AppPalette.recapOnSurfaceMuted, shape: BoxShape.circle)),
                const SizedBox(width: groupGapXxs),
                Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                        color: AppPalette.recapOnSurfaceMuted, shape: BoxShape.circle)),
                const SizedBox(width: groupGapXxs),
                Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                        color: AppPalette.recapOnSurfaceMuted, shape: BoxShape.circle)),
              ],
            ),

            const SizedBox(height: 32),

            // Share Recap Button Neopop
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: groupGutter),
              child: RecapPulseCta(
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
                          color: AppPalette.recapOnSurface,
                        ),
                      ),
                    ),
                    // Button Top layer
                    Container(
                      width: double.infinity,
                      height: groupCtaHeight,
                      decoration: BoxDecoration(
                        color: AppPalette.mintAccent, // Mint green
                        border: Border.all(color: AppPalette.recapOnSurface, width: 2),
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
                              color: AppPalette.recapOnSurface,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.ios_share,
                              color: AppPalette.recapOnSurface, size: 20),
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
                    border: Border.all(color: AppPalette.recapOnSurface, width: 1.5),
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
                          color: AppPalette.recapOnSurface,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.arrow_forward,
                          color: AppPalette.recapOnSurface, size: 20),
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
    required VoidCallback onNext,
    required VoidCallback onBack,
  }) {
    final monthName = DateFormat(AppDateFormats.monthName).format(month);

    return Padding(
      padding: _recapSlideInsets(vertical: groupGapLg),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                          Text(
                  AppBranding.brandLogo,
                  style: TextStyle(
                    fontFamily: kFontAlbra,
                    fontWeight: FontWeight.bold,
                    fontSize: splitrFontHeadline3,
                    color: AppPalette.recapOnSurface,
                    letterSpacing: 1.0,
                  ),
                ),
                if (!_storyNavigation)
                  GestureDetector(
                    onTap: () => _popRecap(),
                    child: Container(
                      padding: const EdgeInsets.all(groupGapSm),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppPalette.recapBorder),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppPalette.recapOnSurface, size: 18),
                    ),
                  )
                else
                  const SizedBox(width: 40, height: 40),
              ],
            ),

            const Spacer(),

            RecapIntroReveal(
              firstName: _recapFirstName,
              monthName: monthName,
              subtitle: AppStrings.recap.moneyMovedSubtitle,
            ),

            const Spacer(),
          ],
        ),
    );
  }

  Widget _buildSecondSlide({
    required DateTime month,
    required double totalSpent,
    required double lastMonthTotal,
    required List<Map<String, dynamic>> spendingTrend,
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

    final prevMonthName = DateFormat(AppDateFormats.monthName)
        .format(DateTime(month.year, month.month - 1));

    return Padding(
      padding: _recapSlideInsets(),
      child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                          Text(
                  AppBranding.brandLogo,
                  style: TextStyle(
                    fontFamily: kFontAlbra,
                    fontWeight: FontWeight.bold,
                    fontSize: splitrFontHeadline3,
                    color: AppPalette.recapOnSurface,
                    letterSpacing: 1.0,
                  ),
                ),
                if (!_storyNavigation)
                  GestureDetector(
                    onTap: () => _popRecap(),
                    child: Container(
                      padding: const EdgeInsets.all(groupGapSm),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppPalette.recapBorder),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppPalette.recapOnSurface, size: 18),
                    ),
                  )
                else
                  const SizedBox(width: 40, height: 40),
              ],
            ),

            const SizedBox(height: 32),

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
                          color: AppPalette.recapOnSurfaceMuted,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(width: groupGapXxs),
                      RecapCountUpText(
                        value: totalSpent,
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
                      fontFamily: kFontPoppins,
                      fontSize: splitrFontCaption,
                      letterSpacing: 1.2,
                      color: AppPalette.recapOnSurfaceMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(
                        percentChange > 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                        color: percentChange > 0 ? neopopError : neopopAccent,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: percentChange > 0
                                    ? neopopError
                                    : neopopAccent,
                                borderRadius:
                                    BorderRadius.circular(groupRadiusSm),
                              ),
                              child: Text(
                                AppStringFormat.recapSignedPercentFromValue(
                                  percentChange,
                                ),
                                style: TextStyle(
                                  fontFamily: kFontPoppins,
                                  fontWeight: FontWeight.bold,
                                  fontSize: splitrFontCaption,
                                  color: AppPalette.recapOnSurface,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppStringFormat.comparedToMonth(prevMonthName),
                              style: TextStyle(
                                fontFamily: kFontPoppins,
                                fontSize: splitrFontCaptionSm,
                                color: AppPalette.recapOnSurfaceMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (spendingTrend.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    RecapSparkline(trend: spendingTrend),
                  ],
                ],
              ),
            ),

            const Spacer(),

            _recapAdvanceButton(
              GestureDetector(
                onTap: onNext,
                child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: -4,
                    right: -4,
                    top: 4,
                    left: 4,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppPalette.recapOnSurface,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: groupCtaHeight,
                    decoration: BoxDecoration(
                      color: neopopAccent,
                      border: Border.all(color: AppPalette.recapOnSurface, width: 2),
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
                            color: AppPalette.recapOnSurface,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward,
                            color: AppPalette.recapOnSurface, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ),

            const SizedBox(height: 32),

                          Text(
              AppStrings.recap.securedBySplitr,
              style: TextStyle(
                fontFamily: kFontPoppins,
                fontSize: splitrFontCaptionSm,
                color: AppPalette.recapOnSurfaceMuted,
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
                    color: AppPalette.recapOnSurface,
                    letterSpacing: 1.0,
                  ),
                ),
                GestureDetector(
                  onTap: () => _popRecap(),
                  child: Container(
                    padding: const EdgeInsets.all(groupGapSm),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppPalette.recapBorder),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppPalette.recapOnSurface, size: 18),
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
                color: AppPalette.recapOnSurface,
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
                color: AppPalette.recapOnSurfaceMuted,
                height: 1.1,
              ),
            ),
            Text(
              AppStrings.groups.category,
              style: TextStyle(
                fontFamily: kFontAlbra,
                fontSize: splitrFontRecapHero,
                fontWeight: FontWeight.w800,
                color: AppPalette.recapOnSurface,
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
                              color: AppPalette.recapOnSurfaceMuted,
                              fontWeight: FontWeight.bold,
                              fontSize: splitrFontBodyLg)),
                      Text(
                        AppStrings.recap.splitrId,
                        style: TextStyle(
                          fontFamily: kFontCourier,
                          color: AppPalette.recapOnSurfaceMuted,
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
                      color: AppPalette.recapOnSurface,
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
                                color: AppPalette.recapOnSurfaceMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppStringFormat.impactPercent(impactInt),
                              style: TextStyle(
                                fontFamily: kFontAlbra,
                                fontSize: splitrFontHeadline1,
                                fontWeight: FontWeight.bold,
                                color: AppPalette.recapOnSurface,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppStrings.recap.ofTotalSpend,
                              style: TextStyle(
                                fontFamily: kFontPoppins,
                                fontSize: splitrFontMicro,
                                color: AppPalette.recapOnSurfaceMuted,
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
                                    size: 14, color: AppPalette.recapOnSurfaceMuted),
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
                '$topCategory ${AppStrings.recap.categoryDominatedQuip}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: kFontCourier,
                  fontSize: splitrFontCaptionSm,
                  color: AppPalette.recapOnSurfaceMuted,
                  height: 1.4,
                ),
              ),
            ),

            const Spacer(flex: 2),

            // Next button Neopop
            _recapAdvanceButton(
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
                          color: AppPalette.recapOnSurface,
                        ),
                      ),
                    ),
                    // Button Top layer
                    Container(
                      width: double.infinity,
                      height: groupCtaHeight,
                      decoration: BoxDecoration(
                        color: neopopAccent, // The light green
                        border: Border.all(color: AppPalette.recapOnSurface, width: 2),
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
                              color: AppPalette.recapOnSurface,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward,
                              color: AppPalette.recapOnSurface, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildFourthSlide({
    required DateTime month,
    required String habitTitle,
    required String habitDescription,
    required VoidCallback onNext,
    required VoidCallback onBack,
  }) {
    final monthName = DateFormat(AppDateFormats.monthName).format(month);

    return Padding(
      padding: _recapSlideInsets(),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                          Text(
                  AppBranding.brandLogo,
                  style: TextStyle(
                    fontFamily: kFontAlbra,
                    fontSize: splitrFontHeadline3,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.recapOnSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                GestureDetector(
                  onTap: () => _popRecap(),
                  child: Container(
                    padding: const EdgeInsets.all(groupGapSm),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppPalette.recapBorder),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppPalette.recapOnSurface, size: 18),
                  ),
                ),
              ],
            ),

            const Spacer(flex: 1),

                          Text(
              AppStrings.recap.yourSpending,
              style: TextStyle(
                fontFamily: kFontAlbra,
                fontSize: splitrFontRecapXl,
                fontWeight: FontWeight.w800,
                color: AppPalette.recapOnSurface,
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
                color: AppPalette.mintAccent,
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
                    fontFamily: kFontPoppins,
                    fontSize: splitrFontCaptionSm,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.recapOnSurfaceMuted,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            GlassCard(
              margin: EdgeInsets.zero,
              opacity: 0.06,
              padding: const EdgeInsets.all(groupGapLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habitTitle,
                    style: TextStyle(
                      fontFamily: kFontAlbra,
                      fontWeight: FontWeight.bold,
                      fontSize: splitrFontHeadline2,
                      color: AppPalette.mintAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    habitDescription,
                    style: TextStyle(
                      fontFamily: kFontPoppins,
                      fontSize: splitrFontBody,
                      color: AppPalette.recapOnSurface,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 2),

            _recapAdvanceButton(
              GestureDetector(
                onTap: onNext,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      bottom: -4,
                      right: -4,
                      top: 4,
                      left: 4,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppPalette.recapOnSurface,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: groupCtaHeight,
                      decoration: BoxDecoration(
                        color: AppPalette.mintAccent,
                        border: Border.all(color: AppPalette.recapOnSurface, width: 2),
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
                              color: AppPalette.recapOnSurface,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward,
                              color: AppPalette.recapOnSurface, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
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
                    color: AppPalette.recapOnSurface,
                    letterSpacing: 1.0,
                  ),
                ),
                GestureDetector(
                  onTap: () => _popRecap(),
                  child: Container(
                    padding: const EdgeInsets.all(groupGapSm),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppPalette.recapBorder),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppPalette.recapOnSurface, size: 18),
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
                color: AppPalette.recapOnSurface,
                height: 1.1,
              ),
            ),
                          Text(
              AppStrings.recap.payment,
              style: TextStyle(
                fontFamily: kFontAlbra,
                fontSize: splitrFontRecapHero,
                fontWeight: FontWeight.w800,
                color: AppPalette.recapOnSurface,
                height: 1.1,
              ),
            ),

            const SizedBox(height: 32),

            // Main payment card
            RecapFlipReveal(
              child: GlassCard(
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
                      color: AppPalette.recapOnSurfaceMuted,
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
                          color: AppPalette.recapOnSurfaceMuted,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(width: groupGapXxs),
                      RecapCountUpText(
                        value: biggestExpenseAmount,
                        style: TextStyle(
                          fontFamily: kFontAlbra,
                          fontSize: splitrFontSwipeHero,
                          fontWeight: FontWeight.bold,
                          color: AppPalette.recapOnSurface,
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
                      color: AppPalette.recapOnSurfaceMuted,
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
                                  color: AppPalette.recapOnSurface,
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
                                  color: AppPalette.recapOnSurfaceMuted,
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
                                  color: AppPalette.recapOnSurfaceMuted,
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
                                  color: AppPalette.recapOnSurface,
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
                            color: AppPalette.recapOnSurfaceMuted,
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
                            color: AppPalette.recapOnSurfaceMuted,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.emoji_events,
                                color: Colors.amber, size: splitrFontBodyLg),
                            SizedBox(width: 8),
                            Text(
                              '#$_topCategoryRank',
                              style: TextStyle(
                                fontFamily: kFontAlbra,
                                fontWeight: FontWeight.bold,
                                fontSize: splitrFontTitle,
                                color: AppPalette.recapOnSurface,
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
            _recapAdvanceButton(
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
                          color: AppPalette.recapOnSurface,
                        ),
                      ),
                    ),
                    // Button Top layer
                    Container(
                      width: double.infinity,
                      height: groupCtaHeight,
                      decoration: BoxDecoration(
                        color: AppPalette.mintAccent, // Mint green
                        border: Border.all(color: AppPalette.recapOnSurface, width: 2),
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
                              color: AppPalette.recapOnSurface,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward,
                              color: AppPalette.recapOnSurface, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildGroupSlide({
    required DateTime month,
    required int groupCount,
    required String topGroupName,
    required String? topFriendName,
    required List<Map<String, dynamic>> groupFriendPeers,
    required double payerRatio,
    required int settlementAvgDays,
    required int settleUpHealthScore,
    required VoidCallback onNext,
    required VoidCallback onBack,
  }) {
    final monthName = DateFormat(AppDateFormats.monthName).format(month);
    final payerFraction = (payerRatio / 100).clamp(0.0, 1.0);
    final payerPct = payerRatio.round();

    return Padding(
      padding: _recapSlideInsets(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppBranding.brandLogo,
                style: TextStyle(
                  fontFamily: kFontAlbra,
                  fontSize: splitrFontHeadline3,
                  fontWeight: FontWeight.w800,
                  color: AppPalette.recapOnSurface,
                  letterSpacing: -0.5,
                ),
              ),
              GestureDetector(
                onTap: () => _popRecap(),
                child: Container(
                  padding: const EdgeInsets.all(groupGapSm),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppPalette.recapBorder),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppPalette.recapOnSurface, size: 18),
                ),
              ),
            ],
          ),
          const Spacer(flex: 1),
          Text(
            AppStrings.recap.splitSquad,
            style: TextStyle(
              fontFamily: kFontAlbra,
              fontSize: splitrFontRecapXl,
              fontWeight: FontWeight.w800,
              color: AppPalette.recapOnSurface,
              height: 1.1,
              letterSpacing: -1.0,
            ),
          ),
          Text(
            AppStrings.recap.squad,
            style: TextStyle(
              fontFamily: kFontAlbra,
              fontSize: splitrFontRecapHero,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              color: AppPalette.mintAccent,
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
                  color: AppPalette.recapOnSurfaceMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          GlassCard(
            margin: EdgeInsets.zero,
            opacity: 0.06,
            padding: const EdgeInsets.all(groupGapLg),
            child: Column(
              children: [
                Text(
                  AppStrings.recap.splitWithGroups,
                  style: TextStyle(
                    fontFamily: kFontPoppins,
                    fontSize: splitrFontCaption,
                    color: AppPalette.recapOnSurfaceMuted,
                  ),
                ),
                const SizedBox(height: 8),
                RecapCountUpText(
                  value: groupCount.toDouble(),
                  style: TextStyle(
                    fontFamily: kFontAlbra,
                    fontSize: splitrFontRecapHero,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.recapOnSurface,
                  ),
                ),
                Text(
                  AppStrings.recap.groupsThisMonth,
                  style: TextStyle(
                    fontFamily: kFontCourier,
                    fontSize: splitrFontMicro,
                    letterSpacing: 1.2,
                    color: AppPalette.recapOnSurfaceMuted,
                  ),
                ),
                if (topGroupName.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.recap.topGroupLabel,
                    style: TextStyle(
                      fontFamily: kFontPoppins,
                      fontSize: splitrFontCaption,
                      color: AppPalette.recapOnSurfaceMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    topGroupName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: kFontAlbra,
                      fontSize: splitrFontTitle,
                      fontWeight: FontWeight.bold,
                      color: AppPalette.mintAccent,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (groupFriendPeers.isNotEmpty || topFriendName != null) ...[
            const SizedBox(height: 24),
            if (groupFriendPeers.isNotEmpty)
              Center(child: RecapFriendAvatarStack(peers: groupFriendPeers)),
            if (topFriendName != null && topFriendName.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                AppStrings.recap.topSplitBuddy,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: kFontPoppins,
                  fontSize: splitrFontCaption,
                  color: AppPalette.recapOnSurfaceMuted,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                topFriendName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: kFontAlbra,
                  fontSize: splitrFontTitle,
                  fontWeight: FontWeight.bold,
                  color: AppPalette.recapOnSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
          const SizedBox(height: 16),
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
                        AppStrings.recap.youFronted,
                        style: TextStyle(
                          fontFamily: kFontPoppins,
                          fontSize: splitrFontCaption,
                          color: AppPalette.recapOnSurfaceMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RecapAnimatedCategoryBar(
                        fraction: payerFraction,
                        color: AppPalette.mintAccent,
                        delay: AppMotion.staggerItemDelay,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$payerPct${AppDisplaySymbols.percent} ${AppStrings.recap.ofGroupSpend}',
                        style: TextStyle(
                          fontFamily: kFontCourier,
                          fontSize: splitrFontMicro,
                          fontWeight: FontWeight.bold,
                          color: AppPalette.recapOnSurface,
                        ),
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
                  padding: const EdgeInsets.all(groupGapMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.recap.avgSettlement,
                        style: TextStyle(
                          fontFamily: kFontPoppins,
                          fontSize: splitrFontCaption,
                          color: AppPalette.recapOnSurfaceMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                RecapCountUpText(
                                  value: settlementAvgDays.toDouble(),
                                  style: TextStyle(
                                    fontFamily: kFontAlbra,
                                    fontWeight: FontWeight.bold,
                                    fontSize: splitrFontTitle,
                                    color: AppPalette.recapOnSurface,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  AppStrings.recap.daysUnit,
                                  style: TextStyle(
                                    fontFamily: kFontCourier,
                                    fontSize: splitrFontCaption,
                                    color: AppPalette.recapOnSurfaceMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          RecapSettlementTick(
                            settleUpHealthScore: settleUpHealthScore,
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
          _recapAdvanceButton(
            GestureDetector(
              onTap: onNext,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: -4,
                    right: -4,
                    top: 4,
                    left: 4,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppPalette.recapOnSurface,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: groupCtaHeight,
                    decoration: BoxDecoration(
                      color: AppPalette.mintAccent,
                      border: Border.all(
                          color: AppPalette.recapOnSurface, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.recap.seeSummary,
                          style: TextStyle(
                            fontFamily: kFontCourier,
                            fontWeight: FontWeight.bold,
                            fontSize: splitrFontMicro,
                            letterSpacing: 2.0,
                            color: AppPalette.recapOnSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward,
                            color: AppPalette.recapOnSurface, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLendingSlide({
    required DateTime month,
    required int activeLoanCount,
    required double totalOutstanding,
    required double totalRepaidThisMonth,
    required int loansWithPaymentThisMonth,
    required int loansCompletedThisMonth,
    required String topLoanTitle,
    required double topLoanProgress,
    required List<LoanPaymentRecapRow> lendingLedgerRows,
    required VoidCallback onNext,
    required VoidCallback onBack,
  }) {
    final monthName = DateFormat(AppDateFormats.monthName).format(month);
    final curSymbol = Get.isRegistered<CurrencyController>()
        ? Get.find<CurrencyController>().symbol
        : CurrencyService.symbolFor(CurrencyDefaults.code);
    final outstandingLabel =
        NumberFormat(AppDateFormats.numberGrouped).format(totalOutstanding);
    final repaidLabel =
        NumberFormat(AppDateFormats.numberGrouped).format(totalRepaidThisMonth);

    final slide = Padding(
      padding: _recapSlideInsets(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppBranding.brandLogo,
                style: TextStyle(
                  fontFamily: kFontAlbra,
                  fontSize: splitrFontHeadline3,
                  fontWeight: FontWeight.w800,
                  color: AppPalette.recapOnSurface,
                  letterSpacing: -0.5,
                ),
              ),
              GestureDetector(
                onTap: () => _popRecap(),
                child: Container(
                  padding: const EdgeInsets.all(groupGapSm),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppPalette.recapBorder),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppPalette.recapOnSurface, size: 18),
                ),
              ),
            ],
          ),
          const Spacer(flex: 1),
          Text(
            AppStrings.recap.loansAnd,
            style: TextStyle(
              fontFamily: kFontAlbra,
              fontSize: splitrFontRecapXl,
              fontWeight: FontWeight.w800,
              color: AppPalette.recapOnSurface,
              height: 1.1,
              letterSpacing: -1.0,
            ),
          ),
          Text(
            AppStrings.recap.repayments,
            style: TextStyle(
              fontFamily: kFontAlbra,
              fontSize: splitrFontRecapHero,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              color: AppPalette.mintAccent,
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
                  color: AppPalette.recapOnSurfaceMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: RecapStaggerReveal(
                  index: 0,
                  child: GlassCard(
                  margin: EdgeInsets.zero,
                  opacity: 0.06,
                  padding: const EdgeInsets.all(groupGapMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.recap.activeLoans,
                        style: TextStyle(
                          fontFamily: kFontPoppins,
                          fontSize: splitrFontCaption,
                          color: AppPalette.recapOnSurfaceMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RecapCountUpText(
                        value: activeLoanCount.toDouble(),
                        style: TextStyle(
                          fontFamily: kFontAlbra,
                          fontWeight: FontWeight.bold,
                          fontSize: splitrFontTitle,
                          color: AppPalette.recapOnSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: RecapStaggerReveal(
                  index: 1,
                  child: GlassCard(
                  margin: EdgeInsets.zero,
                  opacity: 0.06,
                  padding: const EdgeInsets.all(groupGapMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.recap.outstanding,
                        style: TextStyle(
                          fontFamily: kFontPoppins,
                          fontSize: splitrFontCaption,
                          color: AppPalette.recapOnSurfaceMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$curSymbol$outstandingLabel',
                        style: TextStyle(
                          fontFamily: kFontCourier,
                          fontWeight: FontWeight.bold,
                          fontSize: splitrFontSubhead,
                          color: AppPalette.recapOnSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RecapStaggerReveal(
            index: 2,
            child: GlassCard(
            margin: EdgeInsets.zero,
            opacity: 0.06,
            padding: const EdgeInsets.all(groupGapLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.recap.topLoan,
                  style: TextStyle(
                    fontFamily: kFontCourier,
                    fontSize: splitrFontMicro,
                    letterSpacing: 1.2,
                    color: AppPalette.recapOnSurfaceMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  topLoanTitle,
                  style: TextStyle(
                    fontFamily: kFontAlbra,
                    fontSize: splitrFontTitle,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.mintAccent,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                RecapAnimatedCategoryBar(
                  fraction: topLoanProgress,
                  color: AppPalette.mintAccent,
                  delay: AppMotion.staggerItemDelay,
                ),
              ],
            ),
          ),
          ),
          if (lendingLedgerRows.isNotEmpty) ...[
            const SizedBox(height: 16),
            RecapLendingLedger(
              rows: lendingLedgerRows,
              currencySymbol: curSymbol,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: RecapStaggerReveal(
                  index: 3,
                  child: GlassCard(
                  margin: EdgeInsets.zero,
                  opacity: 0.06,
                  padding: const EdgeInsets.all(groupGapMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.recap.repaidThisMonth,
                        style: TextStyle(
                          fontFamily: kFontPoppins,
                          fontSize: splitrFontCaption,
                          color: AppPalette.recapOnSurfaceMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$curSymbol$repaidLabel',
                        style: TextStyle(
                          fontFamily: kFontCourier,
                          fontWeight: FontWeight.bold,
                          fontSize: splitrFontSubhead,
                          color: AppPalette.recapOnSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: RecapStaggerReveal(
                  index: 4,
                  child: GlassCard(
                  margin: EdgeInsets.zero,
                  opacity: 0.06,
                  padding: const EdgeInsets.all(groupGapMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.recap.loanPayments,
                        style: TextStyle(
                          fontFamily: kFontPoppins,
                          fontSize: splitrFontCaption,
                          color: AppPalette.recapOnSurfaceMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RecapCountUpText(
                        value: loansWithPaymentThisMonth.toDouble(),
                        style: TextStyle(
                          fontFamily: kFontAlbra,
                          fontWeight: FontWeight.bold,
                          fontSize: splitrFontTitle,
                          color: AppPalette.recapOnSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              ),
            ],
          ),
          if (totalRepaidThisMonth > 0) ...[
            const SizedBox(height: 16),
            Text(
              AppStrings.recap.disciplineLine,
              style: TextStyle(
                fontFamily: kFontCourier,
                fontSize: splitrFontCaption,
                color: AppPalette.recapOnSurfaceMuted,
              ),
            ),
          ],
          const Spacer(),
          _recapAdvanceButton(
            GestureDetector(
              onTap: onNext,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: -4,
                    right: -4,
                    top: 4,
                    left: 4,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppPalette.recapOnSurface,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: groupCtaHeight,
                    decoration: BoxDecoration(
                      color: AppPalette.mintAccent,
                      border: Border.all(
                          color: AppPalette.recapOnSurface, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.recap.seeSummary,
                          style: TextStyle(
                            fontFamily: kFontCourier,
                            fontWeight: FontWeight.bold,
                            fontSize: splitrFontMicro,
                            letterSpacing: 2.0,
                            color: AppPalette.recapOnSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward,
                            color: AppPalette.recapOnSurface, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (loansCompletedThisMonth > 0) {
      return RecapGreenFlash(child: slide);
    }
    return slide;
  }

  Widget _buildGoalsSlide({
    required DateTime month,
    required int activeGoalsCount,
    required String bestGoalTitle,
    required double bestGoalProgress,
    required double contributedThisMonth,
    required String motivationLine,
    required bool goalCompletedInMonth,
    required VoidCallback onNext,
    required VoidCallback onBack,
  }) {
    final monthName = DateFormat(AppDateFormats.monthName).format(month);
    final curSymbol = Get.isRegistered<CurrencyController>()
        ? Get.find<CurrencyController>().symbol
        : CurrencyService.symbolFor(CurrencyDefaults.code);
    final contributedLabel =
        NumberFormat(AppDateFormats.numberGrouped).format(contributedThisMonth);

    final slide = Padding(
      padding: _recapSlideInsets(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppBranding.brandLogo,
                style: TextStyle(
                  fontFamily: kFontAlbra,
                  fontSize: splitrFontHeadline3,
                  fontWeight: FontWeight.w800,
                  color: AppPalette.recapOnSurface,
                  letterSpacing: -0.5,
                ),
              ),
              GestureDetector(
                onTap: () => _popRecap(),
                child: Container(
                  padding: const EdgeInsets.all(groupGapSm),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppPalette.recapBorder),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppPalette.recapOnSurface, size: 18),
                ),
              ),
            ],
          ),
          const Spacer(flex: 1),
          Text(
            AppStrings.recap.goalsAnd,
            style: TextStyle(
              fontFamily: kFontAlbra,
              fontSize: splitrFontRecapXl,
              fontWeight: FontWeight.w800,
              color: AppPalette.recapOnSurface,
              height: 1.1,
              letterSpacing: -1.0,
            ),
          ),
          Text(
            AppStrings.recap.momentum,
            style: TextStyle(
              fontFamily: kFontAlbra,
              fontSize: splitrFontRecapHero,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              color: AppPalette.mintAccent,
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
                  color: AppPalette.recapOnSurfaceMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: RecapAnimatedGoalRing(
              progress: bestGoalProgress,
              label: bestGoalTitle,
            ),
          ),
          const SizedBox(height: 24),
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
                        AppStrings.recap.addedThisMonth,
                        style: TextStyle(
                          fontFamily: kFontPoppins,
                          fontSize: splitrFontCaption,
                          color: AppPalette.recapOnSurfaceMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '+$curSymbol$contributedLabel',
                        style: TextStyle(
                          fontFamily: kFontCourier,
                          fontWeight: FontWeight.bold,
                          fontSize: splitrFontSubhead,
                          color: AppPalette.mintAccent,
                        ),
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
                  padding: const EdgeInsets.all(groupGapMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.recap.activeGoals,
                        style: TextStyle(
                          fontFamily: kFontPoppins,
                          fontSize: splitrFontCaption,
                          color: AppPalette.recapOnSurfaceMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RecapCountUpText(
                        value: activeGoalsCount.toDouble(),
                        style: TextStyle(
                          fontFamily: kFontAlbra,
                          fontWeight: FontWeight.bold,
                          fontSize: splitrFontTitle,
                          color: AppPalette.recapOnSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            motivationLine,
            style: TextStyle(
              fontFamily: kFontCourier,
              fontSize: splitrFontCaption,
              color: AppPalette.recapOnSurfaceMuted,
            ),
          ),
          const Spacer(),
          _recapAdvanceButton(
            GestureDetector(
              onTap: onNext,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: -4,
                    right: -4,
                    top: 4,
                    left: 4,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppPalette.recapOnSurface,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: groupCtaHeight,
                    decoration: BoxDecoration(
                      color: AppPalette.mintAccent,
                      border: Border.all(
                          color: AppPalette.recapOnSurface, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.recap.seeSummary,
                          style: TextStyle(
                            fontFamily: kFontCourier,
                            fontWeight: FontWeight.bold,
                            fontSize: splitrFontMicro,
                            letterSpacing: 2.0,
                            color: AppPalette.recapOnSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward,
                            color: AppPalette.recapOnSurface, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return RecapGoalConfetti(
      active: goalCompletedInMonth,
      child: slide,
    );
  }

  Widget _buildPersonaSlide({
    required DateTime month,
    required String statOneLabel,
    required String statOneValue,
    required String statTwoLabel,
    required String statTwoValue,
    required String? badgeName,
    required String? badgeDescription,
    required bool showBadge,
    required VoidCallback onNext,
    required VoidCallback onBack,
  }) {
    final monthName = DateFormat(AppDateFormats.monthName).format(month);

    return Padding(
      padding: _recapSlideInsets(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppBranding.brandLogo,
                style: TextStyle(
                  fontFamily: kFontAlbra,
                  fontSize: splitrFontHeadline3,
                  fontWeight: FontWeight.w800,
                  color: AppPalette.recapOnSurface,
                  letterSpacing: -0.5,
                ),
              ),
              GestureDetector(
                onTap: () => _popRecap(),
                child: Container(
                  padding: const EdgeInsets.all(groupGapSm),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppPalette.recapBorder),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppPalette.recapOnSurface, size: 18),
                ),
              ),
            ],
          ),
          const Spacer(flex: 1),
          Text(
            AppStrings.recap.yourPersona,
            style: TextStyle(
              fontFamily: kFontAlbra,
              fontSize: splitrFontRecapXl,
              fontWeight: FontWeight.w800,
              color: AppPalette.recapOnSurface,
              height: 1.1,
            ),
          ),
          Text(
            AppStrings.recap.persona,
            style: TextStyle(
              fontFamily: kFontAlbra,
              fontSize: splitrFontRecapHero,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              color: AppPalette.mintAccent,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(width: 3, height: 14, color: AppPalette.mintAccent),
              const SizedBox(width: 8),
              Text(
                AppStringFormat.monthlyRecapLabel(monthName),
                style: TextStyle(
                  fontFamily: kFontCourier,
                  fontSize: splitrFontMicro,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                  color: AppPalette.recapOnSurfaceMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          GlassCard(
            margin: EdgeInsets.zero,
            opacity: 0.06,
            padding: const EdgeInsets.all(groupGapLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RecapGlitchReveal(
                  text: _personaTitle,
                  style: TextStyle(
                    fontFamily: kFontAlbra,
                    fontSize: splitrFontTitle,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.mintAccent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _personaSubtitle,
                  style: TextStyle(
                    fontFamily: kFontPoppins,
                    fontSize: splitrFontCaption,
                    color: AppPalette.recapOnSurfaceMuted,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statOneLabel,
                            style: TextStyle(
                              fontFamily: kFontCourier,
                              fontSize: splitrFontMicro,
                              color: AppPalette.recapOnSurfaceMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            statOneValue,
                            style: TextStyle(
                              fontFamily: kFontAlbra,
                              fontWeight: FontWeight.bold,
                              fontSize: splitrFontSubhead,
                              color: AppPalette.recapOnSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statTwoLabel,
                            style: TextStyle(
                              fontFamily: kFontCourier,
                              fontSize: splitrFontMicro,
                              color: AppPalette.recapOnSurfaceMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            statTwoValue,
                            style: TextStyle(
                              fontFamily: kFontAlbra,
                              fontWeight: FontWeight.bold,
                              fontSize: splitrFontSubhead,
                              color: AppPalette.recapOnSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (showBadge && badgeName != null) ...[
            const SizedBox(height: 16),
            GlassCard(
              margin: EdgeInsets.zero,
              opacity: 0.09,
              padding: const EdgeInsets.all(groupGapMd),
              child: Row(
                children: [
                  const RecapBadgeLottie(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.recap.badgeUnlocked,
                          style: TextStyle(
                            fontFamily: kFontCourier,
                            fontSize: splitrFontMicro,
                            letterSpacing: 1.2,
                            color: AppPalette.recapOnSurfaceMuted,
                          ),
                        ),
                        Text(
                          badgeName,
                          style: TextStyle(
                            fontFamily: kFontAlbra,
                            fontWeight: FontWeight.bold,
                            fontSize: splitrFontSubhead,
                            color: AppPalette.recapOnSurface,
                          ),
                        ),
                        if (badgeDescription != null &&
                            badgeDescription.isNotEmpty)
                          Text(
                            badgeDescription,
                            style: TextStyle(
                              fontFamily: kFontPoppins,
                              fontSize: splitrFontCaption,
                              color: AppPalette.recapOnSurfaceMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          _recapAdvanceButton(
            GestureDetector(
              onTap: onNext,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: -4,
                    right: -4,
                    top: 4,
                    left: 4,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppPalette.recapOnSurface,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: groupCtaHeight,
                    decoration: BoxDecoration(
                      color: AppPalette.mintAccent,
                      border: Border.all(
                          color: AppPalette.recapOnSurface, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.recap.seeSummary,
                          style: TextStyle(
                            fontFamily: kFontCourier,
                            fontWeight: FontWeight.bold,
                            fontSize: splitrFontMicro,
                            letterSpacing: 2.0,
                            color: AppPalette.recapOnSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward,
                            color: AppPalette.recapOnSurface, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
