import 'package:flutter/material.dart';

import '../theme/vani_colors.dart';
import '../theme/vani_typography.dart';

class JumpToLatestButton extends StatelessWidget {
  final VoidCallback onPressed;

  const JumpToLatestButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: 'Jump to latest speech transcript',
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(24),
        color: isDark
            ? VaniColors.darkSurfaceContainerHigh
            : VaniColors.lightContainerLowest,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? VaniColors.darkBorder
                    : VaniColors.lightHairlineBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_downward,
                  size: 18,
                  color: isDark
                      ? VaniColors.darkPrimary
                      : VaniColors.lightPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Jump to latest speech',
                  style: VaniTypography.labelMd(
                    isDark
                        ? VaniColors.darkTextPrimary
                        : VaniColors.lightPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
