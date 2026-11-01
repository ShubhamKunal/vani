import 'package:flutter/material.dart';

import '../services/speech_service.dart';
import '../theme/vani_colors.dart';

class StatusPill extends StatefulWidget {
  final SpeechRecognitionState state;

  const StatusPill({super.key, required this.state});

  @override
  State<StatusPill> createState() => _StatusPillState();
}

class _StatusPillState extends State<StatusPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color containerBg;
    Color borderColor;
    Color textColor;
    IconData iconData;
    String labelText;
    bool showPulse = false;

    switch (widget.state) {
      case SpeechRecognitionState.listening:
        containerBg = isDark
            ? const Color(0xFF132038)
            : VaniColors.lightContainerLow;
        borderColor = isDark
            ? VaniColors.darkPrimary
            : VaniColors.lightPrimaryContainer;
        textColor = isDark
            ? VaniColors.darkSecondary
            : VaniColors.lightPrimaryContainer;
        iconData = Icons.hearing;
        labelText = 'LISTENING • HI/EN AUTO';
        showPulse = true;
        break;

      case SpeechRecognitionState.processing:
        containerBg = isDark
            ? const Color(0xFF1B221E)
            : VaniColors.lightSecondaryContainer.withAlpha(80);
        borderColor = isDark
            ? VaniColors.darkTertiary
            : VaniColors.lightSecondary;
        textColor = isDark
            ? VaniColors.darkTertiary
            : VaniColors.lightSecondary;
        iconData = Icons.autorenew;
        labelText = 'PROCESSING...';
        showPulse = true;
        break;

      case SpeechRecognitionState.paused:
        containerBg = isDark
            ? VaniColors.darkSurfaceContainer
            : VaniColors.lightContainer;
        borderColor = isDark
            ? VaniColors.darkOutline
            : VaniColors.lightTextSecondary;
        textColor = isDark
            ? VaniColors.darkTextSecondary
            : VaniColors.lightTextSecondary;
        iconData = Icons.pause_circle_outline;
        labelText = 'PAUSED';
        break;

      case SpeechRecognitionState.requestingPermission:
      case SpeechRecognitionState.initializing:
        containerBg = isDark
            ? VaniColors.darkSurfaceContainerLow
            : VaniColors.lightContainer;
        borderColor = isDark
            ? VaniColors.darkOutline
            : VaniColors.lightHairlineBorder;
        textColor = isDark
            ? VaniColors.darkTextSecondary
            : VaniColors.lightTextSecondary;
        iconData = Icons.hourglass_top;
        labelText = 'INITIALIZING...';
        break;

      case SpeechRecognitionState.unavailable:
      case SpeechRecognitionState.error:
        containerBg = isDark
            ? const Color(0xFF3B1515)
            : const Color(0xFFFFDAD6);
        borderColor = const Color(0xFFBA1A1A);
        textColor = const Color(0xFFBA1A1A);
        iconData = Icons.error_outline;
        labelText = widget.state == SpeechRecognitionState.unavailable
            ? 'MIC UNAVAILABLE'
            : 'ENGINE ERROR';
        break;

      case SpeechRecognitionState.idle:
      case SpeechRecognitionState.disposed:
        containerBg = isDark
            ? VaniColors.darkSurfaceContainer
            : VaniColors.lightContainerLow;
        borderColor = isDark
            ? VaniColors.darkOutline
            : VaniColors.lightHairlineBorder;
        textColor = isDark
            ? VaniColors.darkTextSecondary
            : VaniColors.lightTextSecondary;
        iconData = Icons.mic_none;
        labelText = 'READY TO LISTEN';
        break;
    }

    return Semantics(
      label: 'Transcription status: $labelText',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: containerBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showPulse)
              FadeTransition(
                opacity: _pulseAnimation,
                child: Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: textColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            Icon(iconData, size: 14, color: textColor),
            const SizedBox(width: 5),
            Text(
              labelText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
