import 'package:flutter/material.dart';

import '../models/transcript_segment.dart';
import '../theme/vani_colors.dart';
import '../theme/vani_typography.dart';

class TranscriptTurnCard extends StatelessWidget {
  final TranscriptSegment segment;
  final double textScale;
  final bool showTimestamps;
  final bool showSpeakerLabels;
  final bool isInterim;

  const TranscriptTurnCard({
    super.key,
    required this.segment,
    this.textScale = 1.0,
    this.showTimestamps = true,
    this.showSpeakerLabels = true,
    this.isInterim = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Acoustic sound events (non-speech tags like [Door opens] or [Applause])
    if (segment.isSoundEvent) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? VaniColors.darkSurfaceContainerLow
                  : VaniColors.lightContainer,
              borderRadius: BorderRadius.circular(16),
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
                  Icons.hearing_outlined,
                  size: 15,
                  color: isDark
                      ? VaniColors.darkSecondary
                      : VaniColors.lightSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  segment.text,
                  style: TextStyle(
                    fontSize: 12 * textScale,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? VaniColors.darkSecondary
                        : VaniColors.lightSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isSpeaker1 = segment.speakerId == 'S1';
    final speakerBadgeColor = isSpeaker1
        ? (isDark ? VaniColors.darkPrimary : VaniColors.lightPrimaryContainer)
        : (isDark ? VaniColors.darkSecondary : VaniColors.lightSecondary);
    final speakerBadgeTextColor = isSpeaker1
        ? Colors.white
        : (isDark ? Colors.black : Colors.white);

    final borderLeftColor = speakerBadgeColor;
    final textColor = isDark
        ? VaniColors.darkTextPrimary
        : VaniColors.lightTextPrimary;

    final timeStr =
        '${segment.timestamp.hour.toString().padLeft(2, '0')}:${segment.timestamp.minute.toString().padLeft(2, '0')}:${segment.timestamp.second.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.only(
        left: 12,
        top: isInterim ? 8 : 4,
        bottom: isInterim ? 8 : 4,
        right: isInterim ? 8 : 0,
      ),
      decoration: BoxDecoration(
        color: isInterim
            ? (isDark
                  ? VaniColors.darkSurfaceContainerLow.withAlpha(180)
                  : VaniColors.lightContainerLow.withAlpha(180))
            : Colors.transparent,
        borderRadius: isInterim ? BorderRadius.circular(8) : null,
        border: Border(left: BorderSide(color: borderLeftColor, width: 3.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Speaker header strip
          if (showSpeakerLabels || showTimestamps)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (showSpeakerLabels) ...[
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: speakerBadgeColor,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            segment.speakerId,
                            style: TextStyle(
                              color: speakerBadgeTextColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          segment.speakerName,
                          style: VaniTypography.speakerLabel(speakerBadgeColor),
                        ),
                      ],
                      if (isInterim) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? VaniColors.darkPrimary.withAlpha(40)
                                : VaniColors.lightSecondaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: speakerBadgeColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'LIVE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: speakerBadgeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (showTimestamps)
                    Text(
                      isInterim ? 'Now' : timeStr,
                      style: VaniTypography.caption(
                        isDark
                            ? VaniColors.darkOutline
                            : VaniColors.lightTextSecondary,
                      ),
                    ),
                ],
              ),
            ),

          // Utterance text
          SelectableText.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: segment.text,
                  style: isInterim
                      ? VaniTypography.transcriptInterim(
                          textColor,
                          textScale,
                        ).copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor: speakerBadgeColor.withAlpha(160),
                          decorationStyle: TextDecorationStyle.solid,
                          decorationThickness: 1.8,
                        )
                      : VaniTypography.transcriptFocus(textColor, textScale),
                ),
                if (isInterim)
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(
                      width: 3.5,
                      height: 18 * textScale,
                      margin: const EdgeInsets.only(left: 4),
                      color: speakerBadgeColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
