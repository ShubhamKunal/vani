import 'dart:async';

import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../services/settings_service.dart';
import '../services/speech_service.dart';
import '../theme/vani_colors.dart';

/// Production Splash Screen faithful to Stitch design:
/// "Vani — Splash Screen (Goddess Vani Edition)"
/// (Stitch Screen: projects/17288222240461821434/screens/e7affd37c07844399453ba9c1ef1684c)
class SplashScreen extends StatefulWidget {
  final SpeechRecognitionService speechService;
  final SettingsService settingsService;
  final AppSettings appSettings;
  final VoidCallback onInitializationComplete;

  const SplashScreen({
    super.key,
    required this.speechService,
    required this.settingsService,
    required this.appSettings,
    required this.onInitializationComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _progressAnimation;

  String _statusText = 'Calibrating acoustic model...';
  bool _isFinished = false;
  Timer? _transitionTimer;

  @override
  void initState() {
    super.initState();

    // 1. Concentric acoustic sound wave pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 2. Harmonic floating emblem animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0.0, end: -6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // 3. Calibration progress bar (smooth 0% -> 100%)
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    _progressAnimation.addListener(() {
      setState(() {});
      if (_progressAnimation.value >= 0.75 &&
          _statusText != 'Initializing speech engine...') {
        setState(() {
          _statusText = 'Initializing speech engine...';
        });
      }
      if (_progressAnimation.value >= 0.98 &&
          _statusText != 'Speech engine ready') {
        setState(() {
          _statusText = 'Speech engine ready';
        });
      }
    });

    _startWarmupAndTransition();
  }

  Future<void> _startWarmupAndTransition() async {
    _progressController.forward();

    // Initialize speech engine and settings in parallel
    try {
      await widget.speechService.initialize().timeout(
        const Duration(milliseconds: 1200),
        onTimeout: () => true,
      );
    } catch (_) {
      // Graceful fallback to avoid launch blocking
    }

    // Ensure progress bar completes smoothly and transition without leak
    _transitionTimer?.cancel();
    _transitionTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted && !_isFinished) {
        _completeTransition();
      }
    });
  }

  void _completeTransition() {
    if (_isFinished) return;
    _isFinished = true;
    _transitionTimer?.cancel();
    widget.onInitializationComplete();
  }

  @override
  void dispose() {
    _transitionTimer?.cancel();
    _pulseController.dispose();
    _floatController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Stitch Design Tokens:
    // Background gradient: #FAF8FF via #FFFFFF to #F1F3FE (or dark obsidian slate)
    final bgGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F1016), Color(0xFF14161F), Color(0xFF0D0E13)],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFAF8FF), Color(0xFFFFFFFF), Color(0xFFF1F3FE)],
          );

    final brandPrimary = isDark
        ? VaniColors.darkPrimary
        : const Color(0xFF4F46E5); // Royal Electric Indigo from Stitch
    final brandText = isDark
        ? VaniColors.darkTextPrimary
        : const Color(0xFF0F172A); // Deep Charcoal Slate

    final percent = (_progressAnimation.value * 100).toInt().clamp(0, 100);

    return Scaffold(
      body: GestureDetector(
        onTap: _completeTransition, // Instant bypass principle: tap to jump straight to live captions
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(gradient: bgGradient),
          child: SafeArea(
            child: Stack(
              children: [
                // 1. Acoustic Atmosphere: Sacred Concentric Sound Waves (Vāc / Nāda Brahma)
                Positioned.fill(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        final scale = _pulseAnimation.value;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer wave ring (520px)
                            Container(
                              width: 480 * scale,
                              height: 480 * scale,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: brandPrimary.withAlpha(
                                    isDark ? 25 : 18,
                                  ),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            // Middle wave ring (360px)
                            Container(
                              width: 360 * scale,
                              height: 360 * scale,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: brandPrimary.withAlpha(
                                    isDark ? 40 : 28,
                                  ),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            // Inner wave ring (240px)
                            Container(
                              width: 240 * scale,
                              height: 240 * scale,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: brandPrimary.withAlpha(
                                    isDark ? 60 : 42,
                                  ),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            // Ambient radial glow
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: brandPrimary.withAlpha(isDark ? 35 : 20),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // 2. Central Hero: Goddess Vani Icon, Name & Sacred Identity
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Floating Goddess Vani Resonator Icon
                        AnimatedBuilder(
                          animation: _floatAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _floatAnimation.value),
                              child: child,
                            );
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Golden Aura Halo
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(36),
                                  gradient: const RadialGradient(
                                    colors: [
                                      Color(0x55F59E0B),
                                      Color(0x224F46E5),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),

                              // Physical Squircle App Icon Frame
                              Container(
                                width: 104,
                                height: 104,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1E1B4B)
                                          .withAlpha(isDark ? 160 : 60),
                                      blurRadius: 24,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: Image.asset(
                                    'assets/icons/vani_app_icon.png',
                                    width: 104,
                                    height: 104,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Elegant vector fallback if asset loading delays
                                      return Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF4F46E5),
                                              Color(0xFF3730A3),
                                              Color(0xFF1E1B4B),
                                            ],
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.graphic_eq,
                                          size: 52,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Title & Devanagari Badge: Vani वाणी
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Vani',
                              style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: brandText,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF26204E)
                                    : const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFA5B4FC).withAlpha(120),
                                ),
                              ),
                              child: const Text(
                                'वाणी',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4F46E5),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Goddess Vani Subtitle & Sanskrit Epithet
                        Text(
                          'VĀGDEVĪ • GODDESS OF VOICE & WISDOM',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: isDark
                                ? const Color(0xFFC7D2FE)
                                : const Color(0xFF4338CA),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Product Tagline
                        Text(
                          'Every word, within reach.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? VaniColors.darkTextSecondary
                                : const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Sacred Resonance Feature Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? VaniColors.darkSurfaceContainer
                                : Colors.white.withAlpha(230),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? VaniColors.darkBorder
                                  : const Color(0xFFE2E8F0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(isDark ? 40 : 15),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Neural Speech Engine',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? VaniColors.darkTextPrimary
                                      : const Color(0xFF1E293B),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Text(
                                  '|',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.withAlpha(120),
                                  ),
                                ),
                              ),
                              Text(
                                'हिन्दी + English Auto',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? VaniColors.darkTextSecondary
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Bottom Launch Area: Progress Bar & Privacy Anchor
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 24,
                  child: Column(
                    children: [
                      // Calibration Progress Bar (Stitch design)
                      Container(
                        width: 260,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _progressAnimation.value.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF4F46E5),
                                  Color(0xFF6366F1),
                                  Color(0xFF818CF8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Status & Percentage Row
                      SizedBox(
                        width: 260,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.graphic_eq,
                                    size: 14,
                                    color: Color(0xFF4F46E5),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _statusText,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? VaniColors.darkTextSecondary
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$percent%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? VaniColors.darkTextPrimary
                                    : const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Privacy Guarantee Anchor
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF141724)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? VaniColors.darkBorder
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_user,
                              size: 14,
                              color: Color(0xFF059669),
                            ),
                            SizedBox(width: 6),
                            Text(
                              '100% On-Device • Zero Audio Sent to Cloud',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
