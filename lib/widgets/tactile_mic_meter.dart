import 'package:flutter/material.dart';

import '../theme/vani_colors.dart';

/// 3-bar tactile non-color status meter representing microphone input gain.
class TactileMicMeter extends StatelessWidget {
  final double level; // 0.0 to 1.0

  const TactileMicMeter({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark
        ? VaniColors.darkPrimary
        : VaniColors.lightPrimaryContainer;
    final inactiveColor =
        (isDark ? VaniColors.darkOutline : VaniColors.lightHairlineBorder)
            .withAlpha(120);

    final bar1Active = level > 0.05;
    final bar2Active = level > 0.35;
    final bar3Active = level > 0.70;

    String a11yLevel = 'Silent';
    if (bar3Active) {
      a11yLevel = 'Strong audio input';
    } else if (bar2Active) {
      a11yLevel = 'Optimal audio input';
    } else if (bar1Active) {
      a11yLevel = 'Low audio input';
    }

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: 'Microphone level: $a11yLevel',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark
              ? VaniColors.darkSurfaceContainerLow
              : VaniColors.lightContainerLowest,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isDark
                ? VaniColors.darkBorder
                : VaniColors.lightHairlineBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'MIC',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: isDark
                    ? VaniColors.darkTextSecondary
                    : VaniColors.lightTextSecondary,
              ),
            ),
            const SizedBox(width: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(4, bar1Active, activeColor, inactiveColor),
                const SizedBox(width: 2.5),
                _buildBar(8, bar2Active, activeColor, inactiveColor),
                const SizedBox(width: 2.5),
                _buildBar(12, bar3Active, activeColor, inactiveColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(
    double height,
    bool active,
    Color activeColor,
    Color inactiveColor,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: 3.5,
      height: height,
      decoration: BoxDecoration(
        color: active ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }
}
