import 'package:flutter/material.dart';
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

// LOCAL FONT
TextStyle headline1_text = const TextStyle(
  fontFamily: 'Albra',
  fontSize: 36,
  fontWeight: FontWeight.bold,
  fontStyle: FontStyle.normal,
);

TextStyle headline2_text = const TextStyle(
  fontFamily: 'Albra',
  fontSize: 32,
  fontWeight: FontWeight.w600,
  fontStyle: FontStyle.normal,
);

TextStyle headline3_text = const TextStyle(
  fontFamily: 'Albra',
  fontSize: 28,
  fontWeight: FontWeight.w500,
  fontStyle: FontStyle.normal,
);

TextStyle sub_headline4_text = const TextStyle(
  fontFamily: 'Albra',
  fontSize: 24,
  fontWeight: FontWeight.w400,
  fontStyle: FontStyle.normal,
);

TextStyle sub_headline5_text = const TextStyle(
  fontFamily: 'Albra',
  fontSize: 20,
  fontWeight: FontWeight.w400,
  fontStyle: FontStyle.normal,
);

TextStyle body1_text = const TextStyle(
  fontFamily: 'Albra',
  fontSize: 18,
  fontWeight: FontWeight.normal,
  fontStyle: FontStyle.normal,
);

TextStyle body2_text = const TextStyle(
  fontFamily: 'Albra',
  fontSize: 16,
  fontWeight: FontWeight.normal,
  fontStyle: FontStyle.normal,
);

TextStyle caption_text = const TextStyle(
  fontFamily: 'Albra',
  fontSize: 14,
  fontWeight: FontWeight.normal,
  fontStyle: FontStyle.italic,
);

TextStyle button_text = const TextStyle(
  fontFamily: 'Albra',
  fontSize: 16,
  fontWeight: FontWeight.w600,
  fontStyle: FontStyle.normal,
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
  bodyLarge: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
  bodyMedium: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.normal),
  bodySmall: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.normal),
  labelLarge: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold),
  labelMedium: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.normal),
  labelSmall: GoogleFonts.lato(fontSize: 10, fontWeight: FontWeight.normal),
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

const ColorScheme neopopColorScheme = ColorScheme(
  primary: neopopPrimary,
  primaryContainer: neopopPrimary,
  secondary: neopopAccent,
  secondaryContainer: neopopAccent,
  surface: neopopSurface,
  background: neopopBackground,
  error: neopopError,
  onPrimary: neopopOnPrimary,
  onSecondary: neopopOnAccent,
  onSurface: neopopOnSurface,
  onBackground: neopopOnBackground,
  onError: neopopOnError,
  brightness: Brightness.dark,
);


// ########## THIS SECTION IS FOR SIZES ##########
double devSysHeight = Get.context!.height;
double devSysWidth = Get.context!.width;
double height_10 = (Get.height / devSysHeight).toInt() * 10;
double width_10 = (Get.width / devSysWidth).toInt() * 10;
double height_16 = (Get.height / devSysHeight).toInt() * 16;
double width_16 = (Get.width / devSysWidth).toInt() * 16;