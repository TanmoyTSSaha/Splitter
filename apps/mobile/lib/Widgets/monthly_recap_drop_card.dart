import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/glass_card.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Screen/ProfileScreen/monthly_recap_screen.dart';
import 'package:splitr/Services/recap_drop_service.dart';
import 'package:splitr/Services/reminder_service.dart';

/// Home promo for monthly recap drop (first week of month).
class MonthlyRecapDropCard extends StatefulWidget {
  const MonthlyRecapDropCard({super.key});

  @override
  State<MonthlyRecapDropCard> createState() => _MonthlyRecapDropCardState();
}

class _MonthlyRecapDropCardState extends State<MonthlyRecapDropCard>
    with SingleTickerProviderStateMixin {
  final RecapDropService _dropService = RecapDropService();
  late final AnimationController _shimmerController;
  bool _loading = true;
  bool _visible = false;
  DateTime? _dropMonth;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _load();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final show = await _dropService.shouldShowHomePromo();
    if (!mounted) return;
    final dropMonth = show ? RecapDropService.dropMonth(DateTime.now()) : null;
    setState(() {
      _visible = show;
      _dropMonth = dropMonth;
      _loading = false;
    });

    if (show && dropMonth != null && Get.isRegistered<ReminderService>()) {
      final monthLabel =
          DateFormat(AppDateFormats.monthName).format(dropMonth);
      await _dropService.maybeNotifyDrop(
        reminders: Get.find<ReminderService>(),
        monthLabel: monthLabel,
      );
    }
  }

  void _openRecap() {
    final month = _dropMonth;
    if (month == null) return;
    Get.to(() => MonthlyRecapScreen(month: month));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || !_visible || _dropMonth == null) {
      return const SizedBox.shrink();
    }

    final monthLabel =
        DateFormat(AppDateFormats.monthName).format(_dropMonth!);

    return Padding(
      padding: const EdgeInsets.only(bottom: groupGapMd),
      child: GestureDetector(
        onTap: _openRecap,
        child: AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            return ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment(-1 + _shimmerController.value * 2, 0),
                  end: Alignment(_shimmerController.value * 2, 0),
                  colors: const [
                    AppPalette.recapOnSurfaceMuted,
                    AppPalette.mintAccent,
                    AppPalette.recapOnSurfaceMuted,
                  ],
                  stops: const [0.35, 0.5, 0.65],
                ).createShader(bounds);
              },
              child: child,
            );
          },
          child: GlassCard(
            margin: EdgeInsets.zero,
            opacity: 0.1,
            padding: const EdgeInsets.all(groupGapMd),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_stories_outlined,
                  color: AppPalette.mintAccent,
                  size: 24,
                ),
                const SizedBox(width: groupGapSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.home.recapDropTitle,
                        style: caption_text.copyWith(
                          color: groupOnSurfaceMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: groupGapXxs),
                      Text(
                        AppStringFormat.recapDropReady(monthLabel),
                        style: body2_text.copyWith(
                          color: groupOnSurface,
                          height: groupLineHeightRelaxed,
                        ),
                      ),
                      const SizedBox(height: groupGapXs),
                      Text(
                        AppStrings.home.viewRecap,
                        style: caption_text.copyWith(
                          color: neopopAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
