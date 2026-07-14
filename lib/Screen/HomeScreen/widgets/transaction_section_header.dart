import 'package:flutter/material.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

class TransactionSectionHeader extends StatelessWidget {
  final String title;

  const TransactionSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: height_16, bottom: height_10),
      child: Text(
        title,
        style: body1_text.copyWith(
          color: neopopGrey,
          fontWeight: FontWeight.w600,
          fontSize: splitrFontBodySm,
        ),
      ),
    );
  }
}
