import 'package:flutter/material.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// ########## THIS SECTION IS FOR FONT STYLE ##########

// GOOGLE FONT
// TextStyle headline1_text = GoogleFonts.lato(
//   fontSize: 36,
//   fontWeight: FontWeight.bold,
//   fontStyle: FontStyle.normal,
// );

// TextStyle headline2_text = GoogleFonts.lato(
//   fontSize: 32,
//   fontWeight: FontWeight.w600,
//   fontStyle: FontStyle.normal,
// );

// TextStyle headline3_text = GoogleFonts.lato(
//   fontSize: 28,
//   fontWeight: FontWeight.w500,
//   fontStyle: FontStyle.normal,
// );

// TextStyle sub_headline4_text = GoogleFonts.lato(
//   fontSize: 24,
//   fontWeight: FontWeight.w400,
//   fontStyle: FontStyle.normal,
// );

// TextStyle sub_headline5_text = GoogleFonts.lato(
//   fontSize: 20,
//   fontWeight: FontWeight.w400,
//   fontStyle: FontStyle.normal,
// );

// TextStyle body1_text = GoogleFonts.lato(
//   fontSize: 18,
//   fontWeight: FontWeight.normal,
//   fontStyle: FontStyle.normal,
// );

// TextStyle body2_text = GoogleFonts.lato(
//   fontSize: 16,
//   fontWeight: FontWeight.normal,
//   fontStyle: FontStyle.normal,
// );

// TextStyle caption_text = GoogleFonts.lato(
//   fontSize: 14,
//   fontWeight: FontWeight.normal,
//   fontStyle: FontStyle.italic,
// );

// TextStyle button_text = GoogleFonts.lato(
//   fontSize: 16,
//   fontWeight: FontWeight.w600,
//   fontStyle: FontStyle.normal,
// );

// LOCAL FONT — sizes in [splitrFontSizes]; use those tokens in copyWith / one-off TextStyles.

const double splitrFontNano = 8.0;
const double splitrFontNanoSm = 9.0;
const double splitrFontMicro = 10.0;
const double splitrFontCaptionSm = 11.0;
const double splitrFontCaption = 12.0;
const double splitrFontBodySm = 13.0;
const double splitrFontBody = 14.0;
const double splitrFontBodyMd = 15.0;
const double splitrFontBodyLg = 16.0;
const double splitrFontSubhead = 18.0;
const double splitrFontTitle = 20.0;
const double splitrFontSubheadLg = 22.0;
const double splitrFontHeadline3 = 24.0;
const double splitrFontHeadline2 = 28.0;
const double splitrFontHeadline1Sm = 30.0;
const double splitrFontHeadline1 = 32.0;
const double splitrFontDisplayLg = 38.0;
const double splitrFontHero = 42.0;
const double splitrFontSwipeHero = 56.0;

/// Monthly recap / share-card display sizes.
const double splitrFontRecapMd = 36.0;
const double splitrFontRecapLg = 40.0;
const double splitrFontRecapXl = 48.0;
const double splitrFontRecapHero = 52.0;
const double splitrFontRecapDisplay = 54.0;
const double splitrFontRecapWatermark = 80.0;

TextStyle headline1_text = const TextStyle(
  fontFamily: 'Poppins', // or Montserrat
  fontSize: splitrFontHeadline1,
  fontWeight: FontWeight.bold,
  fontStyle: FontStyle.normal,
);

TextStyle headline2_text = const TextStyle(
  fontFamily: 'Poppins', // or Montserrat
  fontSize: splitrFontHeadline2,
  fontWeight: FontWeight.w600,
  fontStyle: FontStyle.normal,
);

TextStyle headline3_text = const TextStyle(
  fontFamily: 'Poppins', // or Montserrat
  fontSize: splitrFontHeadline3,
  fontWeight: FontWeight.w500,
  fontStyle: FontStyle.normal,
);

TextStyle sub_headline4_text = const TextStyle(
  fontFamily: 'Poppins', // or Montserrat
  fontSize: splitrFontHeadline3,
  fontWeight: FontWeight.w400,
  fontStyle: FontStyle.normal,
);

TextStyle sub_headline5_text = const TextStyle(
  fontFamily: 'Poppins', // or Montserrat
  fontSize: splitrFontSubhead,
  fontWeight: FontWeight.w400,
  fontStyle: FontStyle.normal,
);

TextStyle body1_text = const TextStyle(
  fontFamily: 'Poppins', // or Montserrat
  fontSize: splitrFontBodyLg,
  fontWeight: FontWeight.normal,
  fontStyle: FontStyle.normal,
);

TextStyle body2_text = const TextStyle(
  fontFamily: 'Poppins', // or Montserrat
  fontSize: splitrFontBody,
  fontWeight: FontWeight.normal,
  fontStyle: FontStyle.normal,
);

TextStyle caption_text = const TextStyle(
  fontFamily: 'Poppins', // or Montserrat
  fontSize: splitrFontCaption,
  fontWeight: FontWeight.normal,
  fontStyle: FontStyle.italic,
);

TextStyle button_text = const TextStyle(
  fontFamily: 'Poppins', // or Montserrat
  fontSize: splitrFontBodyLg,
  fontWeight: FontWeight.w600,
  fontStyle: FontStyle.normal,
);

TextStyle headline4_text = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: splitrFontBodyLg,
  fontWeight: FontWeight.w600,
  fontStyle: FontStyle.normal,
);

TextStyle subtitle1_text = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: splitrFontBody,
  fontWeight: FontWeight.w400,
  fontStyle: FontStyle.normal,
  color: neopopGrey,
);

final TextTheme splitter_custom_text_theme = TextTheme(
  displayLarge: headline1_text,
  displayMedium: headline2_text,
  displaySmall: headline3_text,
  headlineLarge: sub_headline4_text,
  headlineMedium: sub_headline5_text,
  titleLarge: body1_text,
  titleMedium: body2_text,
  titleSmall: caption_text,
  bodyLarge:
      GoogleFonts.lato(fontSize: splitrFontBodyLg, fontWeight: FontWeight.w600),
  bodyMedium: GoogleFonts.lato(
      fontSize: splitrFontBodyLg, fontWeight: FontWeight.normal),
  bodySmall:
      GoogleFonts.lato(fontSize: splitrFontBody, fontWeight: FontWeight.normal),
  labelLarge:
      GoogleFonts.lato(fontSize: splitrFontBody, fontWeight: FontWeight.bold),
  labelMedium: GoogleFonts.lato(
      fontSize: splitrFontCaption, fontWeight: FontWeight.normal),
  labelSmall: GoogleFonts.lato(
      fontSize: splitrFontMicro, fontWeight: FontWeight.normal),
);

// ########## THIS SECTION IS FOR COLORS ##########

const Color neopopPrimary = Color(0xFFFE885D); // Neon Pink
const Color neopopAccent = Color(0xFF18C595); // Neon Cyan
const Color neopopBackground = Color(0xFF0D0D0D); // Dark Background
const Color neopopSurface = Color(0xFF333333); // Darker Surface
const Color neopopError = Color(0xFFC62828); // Red Error
const Color neopopOnPrimary = Color(0xFFFFFFFF); // White text on Neon Pink
const Color neopopOnAccent = Color(0xFF000000); // Black text on Neon Cyan
const Color neopopOnBackground =
    Color(0xFFFFFFFF); // White text on Dark Background
const Color neopopOnSurface = Color(0xFFFFFFFF); // White text on Darker Surface
const Color neopopOnError = Color(0xFFFFFFFF); // White text on Red Error
const Color neopopGrey = Color(0xFF8A8D8E); // White text on Red Error
const Color neopopSecondaryGrey = Color(0xFF323232); // White text on Red Error
const Color neopopYellow = Color(0xFFF9FE8A); // White text on Red Error

/// Positive metrics: promptness, settlement speed, gains.
const Color neopopSuccess = Color(0xFF2E7D32);

/// Inline validation errors and poor scores (toast/snackbars use [neopopError]).
const Color neopopAlert = Color(0xFFE53935);

/// Bright success indicators (checkmarks, valid field state).
const Color neopopSuccessBright = Color(0xFF4CAF50);

/// "You owe" balance highlight in friend lists.
const Color neopopOwe = Color(0xFFE6A800);

/// Disabled control chrome.
const Color neopopDisabledBg = Color(0xFFDDDDDD);
const Color neopopDisabledFg = Color(0xFF9E9E9E);
const Color neopopDisabledMuted = Color(0xFFCCCCCC);

/// Chart color for positive / is-owed balances.
const Color neopopIsOwed = Color(0xFF22C55E);

/// Accent tint scale — prefer over inline `neopopAccent.withOpacity` / `withValues`.
Color get neopopAccentFillWhisper => neopopAccent.withValues(alpha: 0.05);
Color get neopopAccentFillSubtle => neopopAccent.withValues(alpha: 0.06);
Color get neopopAccentFillFaint => neopopAccent.withValues(alpha: 0.08);
Color get neopopAccentFillSoft => neopopAccent.withValues(alpha: 0.10);
Color get neopopAccentFillLight => neopopAccent.withValues(alpha: 0.12);
Color get neopopAccentFillMuted => neopopAccent.withValues(alpha: 0.14);
Color get neopopAccentFillMedium => neopopAccent.withValues(alpha: 0.15);
Color get neopopAccentFillStrong => neopopAccent.withValues(alpha: 0.20);
Color get neopopAccentBorderHairline => neopopAccent.withValues(alpha: 0.25);
Color get neopopAccentBorderSoft => neopopAccent.withValues(alpha: 0.30);
Color get neopopAccentBorder => neopopAccent.withValues(alpha: 0.35);
Color get neopopAccentBorderStrong => neopopAccent.withValues(alpha: 0.40);
Color get neopopAccentSelected => neopopAccent.withValues(alpha: 0.45);
Color get neopopAccentIconMuted => neopopAccent.withValues(alpha: 0.50);
Color get neopopAccentIconDim => neopopAccent.withValues(alpha: 0.60);
Color get neopopAccentIconMedium => neopopAccent.withValues(alpha: 0.70);
Color get neopopAccentScrim => neopopAccent.withValues(alpha: 0.80);
Color get neopopAccentIconStrong => neopopAccent.withValues(alpha: 0.90);
Color get neopopAccentOverlay => neopopAccent.withValues(alpha: 0.95);

/// Grey tint scale ([groupOnSurfaceMuted] aliases [neopopGrey]).
Color get neopopGreyFillMedium => neopopGrey.withValues(alpha: 0.15);
Color get neopopGreyBorder => neopopGrey.withValues(alpha: 0.20);
Color get neopopGreyBorderMedium => neopopGrey.withValues(alpha: 0.35);
Color get neopopGreyBorderSoft => neopopGrey.withValues(alpha: 0.30);
Color get neopopGreyIconMuted => neopopGrey.withValues(alpha: 0.50);
Color get neopopGreyIconDim => neopopGrey.withValues(alpha: 0.60);

/// Background tint scale.
Color get neopopBackgroundFillWhisper =>
    neopopBackground.withValues(alpha: 0.03);
Color get neopopBackgroundFillSoft => neopopBackground.withValues(alpha: 0.30);
Color get neopopBackgroundFillMedium =>
    neopopBackground.withValues(alpha: 0.50);
Color get neopopBackgroundOverlay => neopopBackground.withValues(alpha: 0.90);

/// On-background tint scale.
Color get neopopOnBackgroundBorderSoft =>
    neopopOnBackground.withValues(alpha: 0.12);

/// On-primary tint scale.
Color get neopopOnPrimaryFillWhisper => neopopOnPrimary.withValues(alpha: 0.05);
Color get neopopOnPrimaryFillFaint => neopopOnPrimary.withValues(alpha: 0.08);
Color get neopopOnPrimaryIconDim => neopopOnPrimary.withValues(alpha: 0.60);

/// Error tint scale.
Color get neopopErrorFillSoft => neopopError.withValues(alpha: 0.10);
Color get neopopErrorFillMedium => neopopError.withValues(alpha: 0.12);
Color get neopopErrorOverlay => neopopError.withValues(alpha: 0.90);

/// Yellow tint scale.
Color get neopopYellowFillSoft => neopopYellow.withValues(alpha: 0.10);
Color get neopopYellowFillMedium => neopopYellow.withValues(alpha: 0.15);
Color get neopopYellowFillStrong => neopopYellow.withValues(alpha: 0.20);
Color get neopopYellowIconMuted => neopopYellow.withValues(alpha: 0.60);
Color get neopopYellowScrim => neopopYellow.withValues(alpha: 0.15);
Color get neopopYellowBorderStrong => neopopYellow.withValues(alpha: 0.40);

/// Primary tint scale.
Color get neopopPrimaryFillSubtle => neopopPrimary.withValues(alpha: 0.06);
Color get neopopPrimaryFillLight => neopopPrimary.withValues(alpha: 0.12);

const ColorScheme neopopColorScheme = ColorScheme(
  primary: neopopPrimary,
  primaryContainer: neopopPrimary,
  secondary: neopopAccent,
  secondaryContainer: neopopAccent,
  surface: neopopSurface,
  error: neopopError,
  onPrimary: neopopOnPrimary,
  onSecondary: neopopOnAccent,
  onSurface: neopopOnSurface,
  onError: neopopOnError,
  brightness: Brightness.dark,
);

// ########## THIS SECTION IS FOR SIZES ##########
double devSysHeight = Get.context!.height;
double devSysWidth = Get.context!.width;
double height_8 = (Get.height / devSysHeight).toInt() * 8;
double width_8 = (Get.width / devSysWidth).toInt() * 8;
double height_10 = (Get.height / devSysHeight).toInt() * 10;
double width_10 = (Get.width / devSysWidth).toInt() * 10;
double height_16 = (Get.height / devSysHeight).toInt() * 16;
double width_16 = (Get.width / devSysWidth).toInt() * 16;

/// Personal expense payment methods (free-text in DB; keep in sync with pickers).
const kPersonalPaymentMethods = [
  'Cash',
  'Online',
  'UPI',
  'Debit card',
  'Credit card',
  'Fastag',
  'Wallet',
];

const kPersonalIncomeCategories = {
  'income',
  'salary',
  'refund',
  'cashback',
  'reimbursement',
};

enum SharingMode {
  byEvenly,
  byUnevenly,
  byPercentage,
  byShares,
  byItem,
}

/// DB string + UI label for [SharingMode].
extension SharingModeValues on SharingMode {
  String get dbValue => switch (this) {
        SharingMode.byEvenly => SharingTypeValues.evenly,
        SharingMode.byUnevenly => SharingTypeValues.unevenly,
        SharingMode.byPercentage => SharingTypeValues.percentage,
        SharingMode.byShares => SharingTypeValues.shares,
        SharingMode.byItem => SharingTypeValues.byItem,
      };

  String get label => switch (this) {
        SharingMode.byEvenly => 'Evenly',
        SharingMode.byUnevenly => 'Unevenly',
        SharingMode.byPercentage => 'Percentage',
        SharingMode.byShares => 'Shares',
        SharingMode.byItem => 'By Item',
      };

  String get tabTitle => switch (this) {
        SharingMode.byEvenly => 'Split evenly',
        SharingMode.byUnevenly => 'Split Unevenly',
        SharingMode.byPercentage => 'Split by Percentage',
        SharingMode.byShares => 'Split by Shares',
        SharingMode.byItem => 'Split by items',
      };

  String get tabSubtitle => switch (this) {
        SharingMode.byEvenly => 'Select who owns the even share in the split',
        SharingMode.byUnevenly => 'Split exactly how much each person owes',
        SharingMode.byPercentage => 'Specify the percentage each person owes',
        SharingMode.byShares => 'Assign shares to each person',
        SharingMode.byItem => 'Add items and assign who shares each',
      };

  static SharingMode? fromDbValue(String? value) => switch (value) {
        SharingTypeValues.evenly => SharingMode.byEvenly,
        SharingTypeValues.unevenly => SharingMode.byUnevenly,
        SharingTypeValues.percentage => SharingMode.byPercentage,
        SharingTypeValues.shares => SharingMode.byShares,
        SharingTypeValues.byItem => SharingMode.byItem,
        _ => null,
      };
}

/// Primary UI font families.
const String kFontPoppins = 'Poppins';
const String kFontAlbra = 'Albra';
const String kFontCourier = 'Courier';
