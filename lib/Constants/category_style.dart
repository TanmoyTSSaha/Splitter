import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/domain_values.dart';

Color categoryColor(String category) {
  switch (category.toLowerCase()) {
    case CategorySlugValues.shopping:
      return CategoryMaterialColors.purple;
    case CategorySlugValues.food:
      return neopopAccent;
    case CategorySlugValues.travel:
      return CategoryMaterialColors.blue;
    case CategorySlugValues.entertainment:
      return CategoryMaterialColors.orange;
    case CategorySlugValues.bills:
      return neopopError;
    case CategorySlugValues.health:
      return CategoryMaterialColors.green;
    case CategorySlugValues.education:
      return CategoryMaterialColors.yellow;
    case CategorySlugValues.groceries:
      return CategoryMaterialColors.teal;
    default:
      return CategoryMaterialColors.grey;
  }
}

IconData categoryIcon(String category) {
  switch (category.toLowerCase()) {
    case CategorySlugValues.shopping:
      return Icons.shopping_bag_outlined;
    case CategorySlugValues.food:
      return Icons.restaurant;
    case CategorySlugValues.transport:
      return Icons.directions_car_outlined;
    case CategorySlugValues.travel:
      return Icons.flight;
    case CategorySlugValues.entertainment:
      return Icons.movie_outlined;
    case CategorySlugValues.bills:
      return Icons.receipt_long;
    case CategorySlugValues.health:
      return Icons.medical_services_outlined;
    case CategorySlugValues.education:
      return Icons.school_outlined;
    case CategorySlugValues.groceries:
      return Icons.local_grocery_store_outlined;
    case CategorySlugValues.rent:
      return Icons.home_outlined;
    case CategorySlugValues.other:
      return Icons.more_horiz;
    default:
      return Icons.category_outlined;
  }
}

/// Renders a category logo from DB values (icon key, inline SVG, or URL).
Widget buildCategoryLogo({
  required String? categoryLogo,
  required String category,
  required Color color,
  double size = AppDimensions.groupIconLg,
}) {
  final logo = categoryLogo?.trim() ?? '';

  if (logo.startsWith(LogoUrlPrefixes.svg)) {
    return SvgPicture.string(
      logo,
      width: size,
      height: size,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  if (logo.startsWith(LogoUrlPrefixes.http)) {
    return SvgPicture.network(
      logo,
      width: size,
      height: size,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  return Icon(categoryIcon(logo.isNotEmpty ? logo : category),
      color: color, size: size);
}
