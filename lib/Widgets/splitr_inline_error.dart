import 'package:flutter/material.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

/// Inline error block for screens, tabs, and [FutureBuilder.hasError] branches.
///
/// [message] must already be user-safe (use [AppErrorReporter.inlineMessage]).
class SplitrInlineError extends StatelessWidget {
  const SplitrInlineError({
    required this.message,
    this.onRetry,
    this.padding = const EdgeInsets.symmetric(vertical: groupGapXl),
    this.centered = true,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;
  final EdgeInsetsGeometry padding;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          style: body2_text.copyWith(color: groupOnSurfaceMuted),
          textAlign: TextAlign.center,
        ),
        if (onRetry != null) ...[
          const SizedBox(height: groupGapSm),
          TextButton(
            onPressed: onRetry,
            child: Text(
              AppStrings.actions.tryAgain,
              style: body2_text.copyWith(color: neopopAccent),
            ),
          ),
        ],
      ],
    );

    return Padding(
      padding: padding,
      child: centered
          ? Center(child: content)
          : Align(alignment: Alignment.center, child: content),
    );
  }
}
