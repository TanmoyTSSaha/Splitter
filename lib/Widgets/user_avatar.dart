import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:splitr/Constants/app_assets.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/constants.dart';

import 'package:splitr/Constants/domain_values.dart';

import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;

  final String userName;

  final String userID;

  final double radius;

  final double? fontSize;

  final BorderRadiusGeometry? customBorderRadius;

  final BoxShape shape;

  const UserAvatar({
    super.key,
    this.imageUrl,
    required this.userName,
    required this.userID,
    this.radius = groupCarouselIconLg,
    this.fontSize,
    this.customBorderRadius,
    this.shape = BoxShape.circle,
  });

  @override
  Widget build(BuildContext context) {
    // If a custom image URL is provided (e.g. from profile upload), use it.

    // Otherwise, use the DiceBear Identicon.

    // Note: We are prioritizing the Identicon for now as per the "Revamp" request,

    // unless imageUrl is explicitly non-null and valid (future proofing).

    // For this specific request: "Our current avatar system is colour based texts. I want to change."

    // So we will default to DiceBear.

    bool hasCustomImage = imageUrl != null &&
        imageUrl!.isNotEmpty &&
        imageUrl != AvatarSentinels.nullImageUrl;

    if (hasCustomImage) {
      // Keep existing logic for custom uploaded images if any

      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: shape,
          borderRadius: shape == BoxShape.rectangle ? customBorderRadius : null,
          image: DecorationImage(
            image: NetworkImage(
                imageUrl!), // Changed to NetworkImage for simplicity or keep Cached if needed, but for now standardizing.

            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return _buildDiceBearAvatar();
  }

  Widget _buildDiceBearAvatar() {
    // DiceBear Identicon API

    // Seed = userID to ensure consistency

    final String avatarUrl = AppUrls.dicebearIdenticon(userID);

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: neopopOnPrimary,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? customBorderRadius : null,
        border: Border.all(
          color: groupSurfaceFillSubtle,
          width: AppDimensions.borderWidthHairline,
        ),
      ),
      child: ClipRRect(
        borderRadius: shape == BoxShape.rectangle
            ? (customBorderRadius as BorderRadius? ?? BorderRadius.zero)
            : BorderRadius.circular(radius),
        child: SvgPicture.network(
          avatarUrl,
          fit: BoxFit.cover,
          placeholderBuilder: (BuildContext context) =>
              _buildInitialsFallback(),
        ),
      ),
    );
  }

  Widget _buildInitialsFallback() {
    final initials = _getInitials(userName);

    return Container(
      color: AppPalette.surfaceMuted,
      child: Center(
        child: Text(
          initials,
          style: body1_text.copyWith(
            color: groupMutedIconDim,
            fontWeight: FontWeight.bold,
            fontSize: fontSize ?? (radius * 0.6),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return DisplayFallbacks.questionMark;

    List<String> parts = name.trim().split(DisplaySeparators.nameWordSplit);

    if (parts.length > 1) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }

    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}
