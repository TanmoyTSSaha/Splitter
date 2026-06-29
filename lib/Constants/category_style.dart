import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:splitter/Constants/constants.dart';

Color categoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'shopping':
      return Colors.purpleAccent;
    case 'food':
      return neopopAccent;
    case 'travel':
      return Colors.blueAccent;
    case 'entertainment':
      return Colors.orangeAccent;
    case 'bills':
      return Colors.redAccent;
    case 'health':
      return Colors.greenAccent;
    case 'education':
      return Colors.yellowAccent;
    case 'groceries':
      return Colors.tealAccent;
    default:
      return Colors.grey;
  }
}

IconData categoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'shopping':
      return Icons.shopping_bag_outlined;
    case 'food':
      return Icons.restaurant;
    case 'transport':
      return Icons.directions_car_outlined;
    case 'travel':
      return Icons.flight;
    case 'entertainment':
      return Icons.movie_outlined;
    case 'bills':
      return Icons.receipt_long;
    case 'health':
      return Icons.medical_services_outlined;
    case 'education':
      return Icons.school_outlined;
    case 'groceries':
      return Icons.local_grocery_store_outlined;
    case 'rent':
      return Icons.home_outlined;
    case 'other':
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
  double size = 24,
}) {
  final logo = categoryLogo?.trim() ?? '';

  if (logo.startsWith('<svg')) {
    return SvgPicture.string(
      logo,
      width: size,
      height: size,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  if (logo.startsWith('http')) {
    return SvgPicture.network(
      logo,
      width: size,
      height: size,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  return Icon(categoryIcon(logo.isNotEmpty ? logo : category), color: color, size: size);
}
