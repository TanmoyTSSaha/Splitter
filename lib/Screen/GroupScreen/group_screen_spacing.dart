import 'package:flutter/material.dart';
import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/constants.dart';

/// Shared spacing scale for the Groups list screen and related empty states.
const double groupGapNone = 0.0;
const double groupGap2 = 2.0;
const double groupGutter = 16.0;
const double groupGapSm = 8.0;
const double groupGapMd = 16.0;
const double groupGapLg = 24.0;
const double groupGapXl = 32.0;
const double groupCarouselGap = 12.0;
const double groupGapXxs = 4.0;
const double groupGapXs = 6.0;
const double groupGap3 = 3.0;
const double groupGap5 = 5.0;
const double groupGap10 = 10.0;
const double groupGap14 = 14.0;
const double groupGap20 = 20.0;
const double groupGap18 = 18.0;
const double groupGap22 = 22.0;
const double groupGap28 = 28.0;
const double groupGap68 = 68.0;
const double groupGap80 = 80.0;

/// Vertical clearance reserved above the floating bottom nav bar.
const double bottomNavClearance = groupGap80;

const double groupFabClearance = bottomNavClearance + groupGutter;

/// Carousel / card layout on group screens.
const double groupCardRadius = 16.0;
const double groupAccentBorderWidth = 1.5;
const double groupCarouselCardWidth = 150.0;
const double groupCarouselCardHeight = 160.0;
const double groupCarouselIconLg = 24.0;
const double groupCarouselIconSm = 18.0;

/// Corner radii not covered by card/control tokens.
const double groupRadiusHairline = 2.0;
const double groupRadiusXs = 3.0;
const double groupRadiusSm = 4.0;
const double groupRadiusMdSm = 6.0;
const double groupRadiusMd = 10.0;
const double groupRadiusLgSm = 14.0;
const double groupPillRadius = 32.0;
const double groupRadiusHero = 70.0;
const double groupRadiusFull = 56.0;
const double groupRadiusChip = 9.0;
const double groupRadiusStat = 30.0;
const double groupRadiusBadge = 35.0;

/// Standard icon size on list rows and chips.
const double groupIconMd = 16.0;
const double groupIconSm = 12.0;

/// Share-distribution tab layout.
const double groupShareSummaryWidthFactor = 0.7;
const double groupShareControlsWidthFactor = 0.3;
const double groupShareInputWidth = 80.0;

/// Emoji picker sheet height.
const double groupEmojiPickerHeight = 120.0;

/// Larger card radii used on home charts and hero cards.
const double groupCardRadiusLg = 20.0;
const double groupCardRadiusXl = 24.0;

/// Controls: buttons, inputs, chips.
const double groupControlRadiusSm = 8.0;
const double groupControlRadius = 12.0;

/// Primary full-width CTA height.
const double groupCtaHeight = 56.0;
const double groupCtaHeightCompact = 48.0;

/// Inline progress indicator on buttons and forms.
const double groupProgressIndicatorSize = 24.0;
const double groupProgressStrokeWidth = 2.0;
const double groupProgressStrokeWidthMedium = 2.5;

/// Bottom sheet / modal top corners.
const BorderRadius groupSheetTopBorderRadius = BorderRadius.vertical(
  top: Radius.circular(groupCardRadius),
);
const BorderRadius groupSheetTopBorderRadiusXl = BorderRadius.vertical(
  top: Radius.circular(groupCardRadiusXl),
);
const BorderRadius groupSheetTopBorderRadiusLg = BorderRadius.vertical(
  top: Radius.circular(groupCardRadiusLg),
);
const BorderRadius groupSheetBottomBorderRadius = BorderRadius.vertical(
  bottom: Radius.circular(groupCardRadius),
);

/// Micro type size (chart axis labels, badges).
const double groupFontMicro = splitrFontMicro;

/// Standard line-height multipliers for compact UI copy.
const double groupLineHeightTight = 1.3;
const double groupLineHeightRelaxed = 1.35;

/// Fully transparent — prefer over raw [Colors.transparent].
const Color groupTransparent = Colors.transparent;

/// Home spend bar chart layout.
const double homeSpendChartEmptyHeight = 200.0;
const double homeSpendChartHeight = 220.0;
const double homeSpendChartBarWidth = 8.0;
const double homeSpendChartBarRadius = 4.0;
const double homeSpendChartAxisReservedSize = groupGapLg;
const double homeSpendChartMaxYFallback = 100.0;
const double homeSpendChartMaxYPaddingFactor = 1.2;
const double homeSpendChartShadowBlur = 12.0;
const Offset homeSpendChartShadowOffset = Offset(0, 4);

/// Text/icons on dark gradient share/export cards.
const Color shareCardOnSurface = Colors.white;
Color get shareCardFillWhisper => shareCardOnSurface.withValues(alpha: 0.04);
Color get shareCardFillSubtle => shareCardOnSurface.withValues(alpha: 0.05);
Color get shareCardFillFaint => shareCardOnSurface.withValues(alpha: 0.06);
Color get shareCardFillSoft => shareCardOnSurface.withValues(alpha: 0.08);
Color get shareCardFillMedium => shareCardOnSurface.withValues(alpha: 0.20);
Color get shareCardBorderHairline => shareCardOnSurface.withValues(alpha: 0.08);
Color get shareCardBorderSoft => shareCardOnSurface.withValues(alpha: 0.35);
Color get shareCardBorderStrong => shareCardOnSurface.withValues(alpha: 0.40);
Color get shareCardIconMuted => shareCardOnSurface.withValues(alpha: 0.38);
Color get shareCardIconDim => shareCardOnSurface.withValues(alpha: 0.50);
Color get shareCardTextMuted => shareCardOnSurface.withValues(alpha: 0.50);
Color get shareCardTextFaint => shareCardOnSurface.withValues(alpha: 0.70);

/// Primary text on white/light group-details surfaces.
const Color groupOnSurface = neopopBackground;

/// Muted/secondary text on white/light group-details surfaces.
const Color groupOnSurfaceMuted = neopopGrey;

/// Card/surface fill on light shells (replaces raw `Colors.white`).
const Color groupCardFill = Colors.white;

/// Hairline borders on light cards and chips.
const Color groupSurfaceBorder = AppPalette.surfaceMuted;

/// Unselected chip/toggle track background.
const Color groupChipTrackBg = AppPalette.chipTrackBg;

/// Muted fill for locked/read-only fields on light surfaces.
const Color groupSurfaceMutedFill = AppPalette.surfaceMutedFill;

/// Selected chip text on dark fill.
const Color groupChipSelectedFg = Colors.white;

/// Unselected chip/toggle label.
const Color groupChipUnselectedFg = neopopGrey;

/// Light chip fill for profile stat pills.
Color get groupMutedFillSubtle => groupOnSurfaceMuted.withValues(alpha: 0.06);
Color get groupChipFillLight => groupMutedFillSubtle;

/// Muted surface tint scale — prefer over inline `groupOnSurfaceMuted.withValues`.
Color get groupMutedFillWhisper => groupOnSurfaceMuted.withValues(alpha: 0.05);
Color get groupMutedFillFaint => groupOnSurfaceMuted.withValues(alpha: 0.08);
Color get groupMutedFillSoft => groupOnSurfaceMuted.withValues(alpha: 0.10);
Color get groupMutedFillLight => groupOnSurfaceMuted.withValues(alpha: 0.12);
Color get groupMutedFillMedium => groupOnSurfaceMuted.withValues(alpha: 0.15);
Color get groupMutedBorder => groupOnSurfaceMuted.withValues(alpha: 0.20);
Color get groupMutedBorderHairline =>
    groupOnSurfaceMuted.withValues(alpha: 0.25);
Color get groupMutedBorderSoft => groupOnSurfaceMuted.withValues(alpha: 0.30);
Color get groupMutedBorderStrong => groupOnSurfaceMuted.withValues(alpha: 0.35);
Color get groupMutedBorderHeavy => groupOnSurfaceMuted.withValues(alpha: 0.40);
Color get groupMutedIconMuted => groupOnSurfaceMuted.withValues(alpha: 0.50);
Color get groupMutedIconDim => groupOnSurfaceMuted.withValues(alpha: 0.60);
Color get groupMutedTextSecondary =>
    groupOnSurfaceMuted.withValues(alpha: 0.70);
Color get groupMutedTextFaint => groupOnSurfaceMuted.withValues(alpha: 0.80);

/// On-surface tint scale for light card shells.
Color get groupSurfaceFillWhisper => groupOnSurface.withValues(alpha: 0.04);
Color get groupSurfaceFillSubtle => groupOnSurface.withValues(alpha: 0.05);
Color get groupSurfaceFillFaint => groupOnSurface.withValues(alpha: 0.06);
Color get groupSurfaceFillSoft => groupOnSurface.withValues(alpha: 0.08);
Color get groupSurfaceFillMedium => groupOnSurface.withValues(alpha: 0.15);
