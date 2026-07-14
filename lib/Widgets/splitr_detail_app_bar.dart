import 'package:flutter/material.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

/// Transparent sub-screen app bar — matches home/group/lending root tabs.
class SplitrDetailAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;
  final bool automaticallyImplyLeading;

  const SplitrDetailAppBar({
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.bottom,
    this.automaticallyImplyLeading = true,
    super.key,
  }) : assert(title != null || titleWidget != null,
            'Provide title or titleWidget');

  static Widget iosBackLeading(
    BuildContext context, {
    VoidCallback? onPressed,
    Color color = groupOnSurface,
    double size = groupCarouselIconSm,
  }) {
    return IconButton(
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      icon: Icon(Icons.arrow_back_ios_new_rounded, size: size, color: color),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final titleContent = titleWidget ??
        Text(
          title!,
          style: headline3_text.copyWith(
            fontFamily: kFontAlbra,
            color: groupOnSurface,
            fontWeight: FontWeight.w600,
          ),
        );

    return AppBar(
      backgroundColor: groupTransparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: groupTransparent,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading ??
          (automaticallyImplyLeading ? iosBackLeading(context) : null),
      title: titleContent,
      centerTitle: centerTitle,
      actions: actions,
      bottom: bottom,
    );
  }
}
