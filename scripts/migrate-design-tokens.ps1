$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)

$skip = @('migrate-design-tokens.ps1')

# Order matters: longer / more specific patterns first.
$map = [ordered]@{}

# --- EdgeInsets (specific composites first) ---
@(
  @('EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0)', 'EdgeInsets.symmetric(horizontal: groupGapLg, vertical: groupGapLg)'),
  @('EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0)', 'EdgeInsets.symmetric(horizontal: groupGapLg, vertical: groupGutter)'),
  @('EdgeInsets.symmetric(horizontal: 24, vertical: 16)', 'EdgeInsets.symmetric(horizontal: groupGapLg, vertical: groupGutter)'),
  @('EdgeInsets.symmetric(horizontal: 16, vertical: 8)', 'EdgeInsets.symmetric(horizontal: groupGutter, vertical: groupGapSm)'),
  @('EdgeInsets.symmetric(horizontal: 16, vertical: 6)', 'EdgeInsets.symmetric(horizontal: groupGutter, vertical: groupGapXs)'),
  @('EdgeInsets.symmetric(vertical: 16, horizontal: 8)', 'EdgeInsets.symmetric(vertical: groupGutter, horizontal: groupGapSm)'),
  @('EdgeInsets.symmetric(horizontal: 8, vertical: 4)', 'EdgeInsets.symmetric(horizontal: groupGapSm, vertical: groupGapXxs)'),
  @('EdgeInsets.symmetric(horizontal: 8, vertical: 8)', 'EdgeInsets.symmetric(horizontal: groupGapSm, vertical: groupGapSm)'),
  @('EdgeInsets.symmetric(horizontal: 8, vertical: 2)', 'EdgeInsets.symmetric(horizontal: groupGapSm, vertical: groupGap2)'),
  @('EdgeInsets.symmetric(horizontal: 6, vertical: 2)', 'EdgeInsets.symmetric(horizontal: groupGapXs, vertical: groupGap2)'),
  @('EdgeInsets.symmetric(horizontal: 10, vertical: 4)', 'EdgeInsets.symmetric(horizontal: groupGap10, vertical: groupGapXxs)'),
  @('EdgeInsets.symmetric(horizontal: 12, vertical: 6)', 'EdgeInsets.symmetric(horizontal: groupCarouselGap, vertical: groupGapXs)'),
  @('EdgeInsets.symmetric(horizontal: 14, vertical: 14)', 'EdgeInsets.symmetric(horizontal: groupGap14, vertical: groupGap14)'),
  @('EdgeInsets.symmetric(horizontal: 14)', 'EdgeInsets.symmetric(horizontal: groupGap14)'),
  @('EdgeInsets.symmetric(horizontal: 24)', 'EdgeInsets.symmetric(horizontal: groupGapLg)'),
  @('EdgeInsets.symmetric(horizontal: 24.0)', 'EdgeInsets.symmetric(horizontal: groupGapLg)'),
  @('EdgeInsets.symmetric(horizontal: 16, vertical: 14)', 'EdgeInsets.symmetric(horizontal: groupGutter, vertical: groupGap14)'),
  @('EdgeInsets.symmetric(horizontal: 16, vertical: 8)', 'EdgeInsets.symmetric(horizontal: groupGutter, vertical: groupGapSm)'),
  @('EdgeInsets.symmetric(vertical: 16)', 'EdgeInsets.symmetric(vertical: groupGutter)'),
  @('EdgeInsets.symmetric(vertical: 8)', 'EdgeInsets.symmetric(vertical: groupGapSm)'),
  @('EdgeInsets.symmetric(vertical: 5)', 'EdgeInsets.symmetric(vertical: groupGap5)'),
  @('EdgeInsets.symmetric(vertical: 10)', 'EdgeInsets.symmetric(vertical: groupGap10)'),
  @('EdgeInsets.symmetric(horizontal: 16, vertical: 6)', 'EdgeInsets.symmetric(horizontal: groupGutter, vertical: groupGapXs)'),
  @('EdgeInsets.symmetric(horizontal: 10, vertical: 12)', 'EdgeInsets.symmetric(horizontal: groupGap10, vertical: groupCarouselGap)'),
  @('EdgeInsets.symmetric(horizontal: 16, vertical: 12)', 'EdgeInsets.symmetric(horizontal: groupGutter, vertical: groupCarouselGap)'),
  @('EdgeInsets.symmetric(horizontal: 12, vertical: 8)', 'EdgeInsets.symmetric(horizontal: groupCarouselGap, vertical: groupGapSm)'),
  @('EdgeInsets.symmetric(horizontal: 12, vertical: 4)', 'EdgeInsets.symmetric(horizontal: groupCarouselGap, vertical: groupGapXxs)'),
  @('EdgeInsets.symmetric(horizontal: 14, vertical: 10)', 'EdgeInsets.symmetric(horizontal: groupGap14, vertical: groupGap10)'),
  @('EdgeInsets.symmetric(horizontal: 18, vertical: 14)', 'EdgeInsets.symmetric(horizontal: groupGap18, vertical: groupGap14)'),
  @('EdgeInsets.symmetric(horizontal: 20, vertical: 14)', 'EdgeInsets.symmetric(horizontal: groupGap20, vertical: groupGap14)'),
  @('EdgeInsets.symmetric(horizontal: 10, vertical: 6)', 'EdgeInsets.symmetric(horizontal: groupGap10, vertical: groupGapXs)'),
  @('EdgeInsets.symmetric(horizontal: 10, vertical: 3)', 'EdgeInsets.symmetric(horizontal: groupGap10, vertical: groupGap3)'),
  @('EdgeInsets.symmetric(horizontal: 32)', 'EdgeInsets.symmetric(horizontal: groupGapXl)'),
  @('EdgeInsets.symmetric(horizontal: 8)', 'EdgeInsets.symmetric(horizontal: groupGapSm)'),
  @('EdgeInsets.symmetric(horizontal: 6)', 'EdgeInsets.symmetric(horizontal: groupGapXs)'),
  @('EdgeInsets.symmetric(vertical: 14)', 'EdgeInsets.symmetric(vertical: groupGap14)'),
  @('EdgeInsets.symmetric(vertical: 12)', 'EdgeInsets.symmetric(vertical: groupCarouselGap)'),
  @('EdgeInsets.symmetric(vertical: 6)', 'EdgeInsets.symmetric(vertical: groupGapXs)'),
  @('EdgeInsets.symmetric(vertical: 4)', 'EdgeInsets.symmetric(vertical: groupGapXxs)'),
  @('EdgeInsets.only(left: 68)', 'EdgeInsets.only(left: groupGap68)'),
  @('EdgeInsets.only(right: 16)', 'EdgeInsets.only(right: groupGutter)'),
  @('EdgeInsets.only(top: 8)', 'EdgeInsets.only(top: groupGapSm)'),
  @('EdgeInsets.only(top: 2)', 'EdgeInsets.only(top: groupGap2)'),
  @('EdgeInsets.only(bottom: 12)', 'EdgeInsets.only(bottom: groupCarouselGap)'),
  @('EdgeInsets.only(bottom: 6)', 'EdgeInsets.only(bottom: groupGapXs)'),
  @('EdgeInsets.only(bottom: 80)', 'EdgeInsets.only(bottom: groupGap80)'),
  @('EdgeInsets.fromLTRB(20, 8, 20, 32)', 'EdgeInsets.fromLTRB(groupGap20, groupGapSm, groupGap20, groupGapXl)'),
  @('EdgeInsets.fromLTRB(groupGutter, groupGapSm, groupGutter, 32)', 'EdgeInsets.fromLTRB(groupGutter, groupGapSm, groupGutter, groupGapXl)'),
  @('EdgeInsets.only(bottom: 16.0)', 'EdgeInsets.only(bottom: groupGutter)'),
  @('EdgeInsets.only(bottom: 16)', 'EdgeInsets.only(bottom: groupGutter)'),
  @('EdgeInsets.only(bottom: 10)', 'EdgeInsets.only(bottom: groupGap10)'),
  @('EdgeInsets.only(bottom: 8)', 'EdgeInsets.only(bottom: groupGapSm)'),
  @('EdgeInsets.only(top: 4)', 'EdgeInsets.only(top: groupGapXxs)'),
  @('EdgeInsets.only(right: 24)', 'EdgeInsets.only(right: groupGapLg)'),
  @('EdgeInsets.only(right: 8)', 'EdgeInsets.only(right: groupGapSm)'),
  @('EdgeInsets.only(left: 8)', 'EdgeInsets.only(left: groupGapSm)'),
  @('EdgeInsets.all(0)', 'EdgeInsets.zero'),
  @('EdgeInsets.all(28.0)', 'EdgeInsets.all(groupGap28)'),
  @('EdgeInsets.all(24)', 'EdgeInsets.all(groupGapLg)'),
  @('EdgeInsets.all(22)', 'EdgeInsets.all(groupGap22)'),
  @('EdgeInsets.all(14)', 'EdgeInsets.all(groupGap14)'),
  @('EdgeInsets.all(12)', 'EdgeInsets.all(groupCarouselGap)'),
  @('EdgeInsets.all(10)', 'EdgeInsets.all(groupGap10)'),
  @('EdgeInsets.all(8)', 'EdgeInsets.all(groupGapSm)'),
  @('EdgeInsets.all(4)', 'EdgeInsets.all(groupGapXxs)'),
  @('EdgeInsets.all(2)', 'EdgeInsets.all(groupGap2)'),
  @('const EdgeInsets.all(0)', 'EdgeInsets.zero'),
  @('indicatorPadding: const EdgeInsets.all(0)', 'indicatorPadding: EdgeInsets.zero')
) | ForEach-Object { $map[$_[0]] = $_[1] }

# --- BorderRadius ---
@(
  @('BorderRadius.vertical(top: Radius.circular(24))', 'groupSheetTopBorderRadiusXl'),
  @('const BorderRadius.vertical(top: Radius.circular(24))', 'groupSheetTopBorderRadiusXl'),
  @('BorderRadius.vertical(top: Radius.circular(20))', 'groupSheetTopBorderRadiusLg'),
  @('const BorderRadius.vertical(top: Radius.circular(20))', 'groupSheetTopBorderRadiusLg'),
  @('const BorderRadius.vertical(bottom: Radius.circular(16))', 'groupSheetBottomBorderRadius'),
  @('BorderRadius.vertical(bottom: Radius.circular(16))', 'groupSheetBottomBorderRadius'),
  @('BorderRadius.all(Radius.circular(8))', 'BorderRadius.all(Radius.circular(groupControlRadiusSm))'),
  @('BorderRadius.circular(0)', 'BorderRadius.zero'),
  @('BorderRadius.circular(70)', 'BorderRadius.circular(groupRadiusHero)'),
  @('BorderRadius.circular(56)', 'BorderRadius.circular(groupRadiusFull)'),
  @('BorderRadius.circular(32)', 'BorderRadius.circular(groupPillRadius)'),
  @('BorderRadius.circular(14)', 'BorderRadius.circular(groupRadiusLgSm)'),
  @('BorderRadius.circular(10)', 'BorderRadius.circular(groupRadiusMd)'),
  @('BorderRadius.circular(6)', 'BorderRadius.circular(groupRadiusMdSm)'),
  @('BorderRadius.circular(4)', 'BorderRadius.circular(groupRadiusSm)'),
  @('BorderRadius.circular(3)', 'BorderRadius.circular(groupRadiusXs)'),
  @('BorderRadius.circular(2)', 'BorderRadius.circular(groupRadiusHairline)')
) | ForEach-Object { $map[$_[0]] = $_[1] }

# --- fontSize (largest first); skip constants.dart ---
@(
  @('fontSize: 80', 'fontSize: splitrFontRecapWatermark'),
  @('fontSize: 56', 'fontSize: splitrFontSwipeHero'),
  @('fontSize: 48', 'fontSize: splitrFontRecapXl'),
  @('fontSize: 42', 'fontSize: splitrFontHero'),
  @('fontSize: 40', 'fontSize: splitrFontRecapLg'),
  @('fontSize: 38', 'fontSize: splitrFontDisplayLg'),
  @('fontSize: 36', 'fontSize: splitrFontRecapMd'),
  @('fontSize: 32', 'fontSize: splitrFontHeadline1'),
  @('fontSize: 30', 'fontSize: splitrFontHeadline1Sm'),
  @('fontSize: 28', 'fontSize: splitrFontHeadline2'),
  @('fontSize: 24', 'fontSize: splitrFontHeadline3'),
  @('fontSize: 22', 'fontSize: splitrFontSubheadLg'),
  @('fontSize: 20', 'fontSize: splitrFontTitle'),
  @('fontSize: 18', 'fontSize: splitrFontSubhead'),
  @('fontSize: 16', 'fontSize: splitrFontBodyLg'),
  @('fontSize: 15', 'fontSize: splitrFontBodyMd'),
  @('fontSize: 14', 'fontSize: splitrFontBody'),
  @('fontSize: 13', 'fontSize: splitrFontBodySm'),
  @('fontSize: 12', 'fontSize: splitrFontCaption'),
  @('fontSize: 11', 'fontSize: splitrFontCaptionSm'),
  @('fontSize: 10', 'fontSize: splitrFontMicro'),
  @('fontSize: 9', 'fontSize: splitrFontNanoSm'),
  @('fontSize: 8', 'fontSize: splitrFontNano')
) | ForEach-Object { $map[$_[0]] = $_[1] }

# --- misc layout ---
$map['SizedBox(width: 4)'] = 'SizedBox(width: groupGapXxs)'
$map['height: 120'] = 'height: groupEmojiPickerHeight'
$map['size: 16'] = 'size: splitrFontBodyLg'

$tokenPattern = 'groupGap|groupGutter|groupCarousel|groupRadius|groupSheet|groupControl|groupPill|groupEmoji|splitrFont|BorderRadius\.zero|EdgeInsets\.zero'

Get-ChildItem -Path lib -Recurse -Filter *.dart | ForEach-Object {
  if ($_.Name -eq 'group_screen_spacing.dart' -or $_.Name -eq 'constants.dart') { return }
  $c = Get-Content $_.FullName -Raw
  $orig = $c
  foreach ($k in $map.Keys) { $c = $c.Replace($k, $map[$k]) }
  if ($c -eq $orig) { return }

  $needsSpacing = ($c -match $tokenPattern) -and ($c -notmatch 'group_screen_spacing')
  if ($needsSpacing) {
    if ($c -match "import 'package:splitr/Constants/constants.dart';") {
      if ($c -notmatch 'group_screen_spacing') {
        $c = $c.Replace(
          "import 'package:splitr/Constants/constants.dart';",
          "import 'package:splitr/Constants/constants.dart';`nimport 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';"
        )
      }
    } elseif ($c -notmatch 'group_screen_spacing') {
      $m = [regex]::Match($c, "import 'package:[^']+';")
      if ($m.Success) {
        $c = $c.Insert($m.Index + $m.Length, "`nimport 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';")
      }
    }
  }

  $needsConstants = ($c -match 'splitrFont') -and ($c -notmatch "import 'package:splitr/Constants/constants.dart';")
  if ($needsConstants) {
    $m = [regex]::Match($c, "import 'package:flutter/material.dart';")
    if ($m.Success) {
      $c = $c.Insert($m.Index + $m.Length, "`nimport 'package:splitr/Constants/constants.dart';")
    }
  }

  Set-Content -Path $_.FullName -Value $c -NoNewline
  Write-Output $_.FullName
}
