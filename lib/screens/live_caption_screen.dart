import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/caption_controller.dart';
import '../controllers/quick_responses_controller.dart';
import '../models/app_settings.dart';
import '../services/settings_service.dart';
import '../theme/vani_colors.dart';
import '../theme/vani_typography.dart';
import '../widgets/jump_to_latest_button.dart';
import '../widgets/status_pill.dart';
import '../widgets/tactile_mic_meter.dart';
import '../widgets/transcript_turn_card.dart';
import 'quick_responses_screen.dart';
import 'settings_screen.dart';

class LiveCaptionScreen extends StatefulWidget {
  final CaptionController captionController;
  final QuickResponsesController quickResponsesController;
  final SettingsService settingsService;
  final AppSettings appSettings;
  final ValueChanged<AppSettings> onSettingsChanged;

  const LiveCaptionScreen({
    super.key,
    required this.captionController,
    required this.quickResponsesController,
    required this.settingsService,
    required this.appSettings,
    required this.onSettingsChanged,
  });

  @override
  State<LiveCaptionScreen> createState() => _LiveCaptionScreenState();
}

class _LiveCaptionScreenState extends State<LiveCaptionScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showJumpToLatest = false;
  bool _showTextScaleDrawer = false;
  bool _savedFeedback = false;
  late double _activeTextScale;

  @override
  void initState() {
    super.initState();
    _activeTextScale = widget.appSettings.textScale;
    widget.captionController.addListener(_onCaptionControllerUpdated);
    _scrollController.addListener(_onScroll);

    // Auto-start listening on launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.captionController.start();
    });
  }

  @override
  void didUpdateWidget(covariant LiveCaptionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appSettings.textScale != widget.appSettings.textScale) {
      _activeTextScale = widget.appSettings.textScale;
    }
  }

  @override
  void dispose() {
    widget.captionController.removeListener(_onCaptionControllerUpdated);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final isNearBottom = (maxScroll - currentScroll) < 80.0;

    if (isNearBottom && _showJumpToLatest) {
      setState(() => _showJumpToLatest = false);
      widget.captionController.setAutoScroll(true);
    } else if (!isNearBottom && !_showJumpToLatest) {
      setState(() => _showJumpToLatest = true);
      widget.captionController.setAutoScroll(false);
    }
  }

  void _onCaptionControllerUpdated() {
    if (!mounted) return;
    setState(() {});

    // High performance instant lock to newest token without animation stutter
    if (widget.captionController.isAutoScrollEnabled &&
        _scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    setState(() => _showJumpToLatest = false);
    widget.captionController.setAutoScroll(true);
  }

  void _copyAndSaveTranscript() {
    if (widget.captionController.segments.isEmpty &&
        widget.captionController.interimSegment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No captions to save yet. Speak near the microphone to transcribe.',
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final text = widget.captionController.exportFormattedTranscript();
    Clipboard.setData(ClipboardData(text: text));

    if (widget.appSettings.hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }

    setState(() => _savedFeedback = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _savedFeedback = false);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transcript copied to clipboard! (Long-press to clear)'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearSession() {
    if (widget.captionController.segments.isEmpty &&
        widget.captionController.interimSegment == null) {
      return;
    }

    if (widget.appSettings.hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }

    widget.captionController.clearSession();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Caption session cleared.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          settingsService: widget.settingsService,
          currentSettings: widget.appSettings,
          onSettingsChanged: (newSettings) {
            widget.onSettingsChanged(newSettings);
            setState(() {
              _activeTextScale = newSettings.textScale;
            });
          },
        ),
      ),
    );
  }

  void _openQuickResponses() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuickResponsesScreen(
          controller: widget.quickResponsesController,
          onReturnToCaptions: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final primaryContainer = theme.colorScheme.primaryContainer;
    final segments = widget.captionController.segments;
    final interim = widget.captionController.interimSegment;
    final isPaused = widget.captionController.isPaused;
    final errorMessage = widget.captionController.errorMessage;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP APP BAR
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? VaniColors.darkBorder
                        : VaniColors.lightHairlineBorder,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Brand Logo & Acoustic Symbol
                  Row(
                    children: [
                      Icon(Icons.graphic_eq, color: primaryColor, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Vani',
                        style: VaniTypography.headlineMd(primaryColor),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? VaniColors.darkPrimary.withAlpha(40)
                              : VaniColors.lightSecondaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'LIVE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Direct Accessibility Touch Targets (min 48x48)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.format_size, size: 22),
                        tooltip: 'Adjust font size and reading comfort',
                        onPressed: () {
                          setState(() {
                            _showTextScaleDrawer = !_showTextScaleDrawer;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, size: 22),
                        tooltip: 'Accessibility settings',
                        onPressed: _openSettings,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. SUB-HEADER: DUAL-CODED STATUS & MIC METER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? VaniColors.darkSurface
                    : VaniColors.lightBaseCanvas,
                border: Border(
                  bottom: BorderSide(
                    color:
                        (isDark
                                ? VaniColors.darkBorder
                                : VaniColors.lightHairlineBorder)
                            .withAlpha(120),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusPill(state: widget.captionController.engineState),
                  ValueListenableBuilder<double>(
                    valueListenable: widget.captionController.micLevelNotifier,
                    builder: (context, level, child) {
                      return TactileMicMeter(level: level);
                    },
                  ),
                ],
              ),
            ),

            // 3. TEXT SIZE QUICK SLIDER DRAWER (Animated Expand/Collapse)
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: _showTextScaleDrawer
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? VaniColors.darkSurfaceContainerLow
                            : VaniColors.lightContainerLowest,
                        border: Border(
                          bottom: BorderSide(
                            color: isDark
                                ? VaniColors.darkBorder
                                : VaniColors.lightHairlineBorder,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Text Scale (Reading Comfort)',
                                style: VaniTypography.speakerLabel(
                                  primaryColor,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                tooltip: 'Close text scaler',
                                onPressed: () {
                                  setState(() => _showTextScaleDrawer = false);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                'Aa (100%)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Slider(
                                  value: _activeTextScale,
                                  min: 1.0,
                                  max: 1.6,
                                  divisions: 6,
                                  activeColor: primaryColor,
                                  onChanged: (val) {
                                    setState(() => _activeTextScale = val);
                                    final updated = widget.appSettings.copyWith(
                                      textScale: val,
                                    );
                                    widget.onSettingsChanged(updated);
                                    widget.settingsService.saveSettings(
                                      updated,
                                    );
                                  },
                                ),
                              ),
                              const Text(
                                'Aa (160%)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // ERROR / PERMISSION RECOVERY BANNER
            if (errorMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF3B1515)
                      : const Color(0xFFFFDAD6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBA1A1A)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFBA1A1A),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style: const TextStyle(
                          color: Color(0xFF93000A),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => widget.captionController.start(),
                      child: const Text(
                        'RETRY',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

            // 4. MAIN LIVE TRANSCRIPT SURFACE
            Expanded(
              child: Stack(
                children: [
                  if (segments.isEmpty && interim == null)
                    // Empty State: Reassuring accessibility message
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isPaused
                                  ? Icons.pause_circle_outline
                                  : Icons.hearing,
                              size: 48,
                              color:
                                  (isDark
                                          ? VaniColors.darkOutline
                                          : VaniColors.lightTextSecondary)
                                      .withAlpha(140),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isPaused
                                  ? 'Transcription is paused.\nTap "RESUME" below to continue.'
                                  : 'Listening for speech...\nSpeak naturally near the microphone.\nEnglish and Hindi are supported.',
                              textAlign: TextAlign.center,
                              style: VaniTypography.bodyMd(
                                isDark
                                    ? VaniColors.darkTextSecondary
                                    : VaniColors.lightTextSecondary,
                                _activeTextScale,
                              ).copyWith(height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                      itemCount: segments.length + (interim != null ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < segments.length) {
                          return TranscriptTurnCard(
                            segment: segments[index],
                            textScale: _activeTextScale,
                            showTimestamps: widget.appSettings.showTimestamps,
                            showSpeakerLabels:
                                widget.appSettings.showSpeakerLabels,
                            isInterim: false,
                          );
                        } else {
                          return TranscriptTurnCard(
                            segment: interim!,
                            textScale: _activeTextScale,
                            showTimestamps: widget.appSettings.showTimestamps,
                            showSpeakerLabels:
                                widget.appSettings.showSpeakerLabels,
                            isInterim: true,
                          );
                        }
                      },
                    ),

                  // Floating "Jump to latest" Indicator Pill
                  if (_showJumpToLatest)
                    Positioned(
                      bottom: 84,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: JumpToLatestButton(onPressed: _scrollToBottom),
                      ),
                    ),

                  // 5. FLOATING ERGONOMIC CONTROL BAR (One-handed Accessibility Bar)
                  Positioned(
                    bottom: 12,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? VaniColors.darkSurfaceContainer
                            : VaniColors.lightContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? VaniColors.darkBorder
                              : VaniColors.lightHairlineBorder,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(isDark ? 80 : 25),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Action 1: Save / Copy session (Long press to clear)
                          InkWell(
                            onTap: _copyAndSaveTranscript,
                            onLongPress: _clearSession,
                            borderRadius: BorderRadius.circular(10),
                            child: Tooltip(
                              message:
                                  'Tap to copy transcript, Long-press to clear',
                              child: Container(
                                width: 56,
                                height: 52,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _savedFeedback
                                          ? Icons.check_circle
                                          : Icons.save_outlined,
                                      size: 20,
                                      color: _savedFeedback
                                          ? primaryColor
                                          : (isDark
                                                ? VaniColors.darkTextSecondary
                                                : VaniColors
                                                      .lightTextSecondary),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _savedFeedback ? 'Saved' : 'Save',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: _savedFeedback
                                            ? primaryColor
                                            : (isDark
                                                  ? VaniColors.darkTextSecondary
                                                  : VaniColors
                                                        .lightTextSecondary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Action 2: Central Primary PAUSE / RESUME TOGGLE BUTTON (Minimum 52-56px Touch Target, WCAG AAA)
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isPaused
                                      ? Colors.grey[700]
                                      : primaryContainer,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                onPressed: () {
                                  if (widget.appSettings.hapticsEnabled) {
                                    HapticFeedback.lightImpact();
                                  }
                                  widget.captionController.togglePauseResume();
                                },
                                icon: Icon(
                                  isPaused ? Icons.play_arrow : Icons.pause,
                                  size: 24,
                                ),
                                label: Text(
                                  isPaused ? 'RESUME' : 'PAUSE',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Action 3: Quick Phrases Trigger
                          InkWell(
                            onTap: _openQuickResponses,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 56,
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.quickreply_outlined,
                                    size: 20,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Phrases',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // 6. BOTTOM NAVIGATION BAR
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        height: 60,
        backgroundColor: isDark
            ? VaniColors.darkSurface
            : VaniColors.lightContainerLowest,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.mic), label: 'Listen'),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Quick Phrases',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
        onDestinationSelected: (idx) {
          if (idx == 1) {
            _openQuickResponses();
          } else if (idx == 2) {
            _openSettings();
          }
        },
      ),
    );
  }
}
