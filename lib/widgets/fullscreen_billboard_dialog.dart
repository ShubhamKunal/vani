import 'package:flutter/material.dart';

import '../models/quick_phrase.dart';
import '../theme/vani_colors.dart';
import '../theme/vani_typography.dart';

class FullscreenBillboardDialog extends StatefulWidget {
  final QuickPhrase phrase;
  final VoidCallback onDismiss;

  const FullscreenBillboardDialog({
    super.key,
    required this.phrase,
    required this.onDismiss,
  });

  @override
  State<FullscreenBillboardDialog> createState() =>
      _FullscreenBillboardDialogState();
}

class _FullscreenBillboardDialogState extends State<FullscreenBillboardDialog> {
  bool _isFlipped180 = false;

  void _toggleFlip() {
    setState(() {
      _isFlipped180 = !_isFlipped180;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: const Color(0xFF191C1B),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              // Top Action Strip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dismiss button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withAlpha(25),
                      foregroundColor: const Color(0xFFFBF9F5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: widget.onDismiss,
                    icon: const Icon(Icons.close, size: 22),
                    label: const Text(
                      'Dismiss',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  // Flip 180° for cashier / person facing you
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VaniColors.lightSecondaryContainer,
                      foregroundColor: VaniColors.lightPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _toggleFlip,
                    icon: const Icon(Icons.sync, size: 20),
                    label: Text(
                      _isFlipped180 ? 'Upright' : 'Flip 180°',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              // Billboard text container (animated rotation)
              Expanded(
                child: Center(
                  child: AnimatedRotation(
                    turns: _isFlipped180 ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.record_voice_over,
                            size: 48,
                            color: Color(0xFFC1ECDA),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '"${widget.phrase.phrase}"',
                            textAlign: TextAlign.center,
                            style:
                                VaniTypography.displayLg(
                                  const Color(0xFFFBF9F5),
                                ).copyWith(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                ),
                          ),
                          if (widget.phrase.secondaryTranslation != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              widget.phrase.secondaryTranslation!,
                              textAlign: TextAlign.center,
                              style: VaniTypography.bodyMd(
                                const Color(0xFFDCE3DE),
                              ).copyWith(fontSize: 18),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom status info
              Text(
                _isFlipped180
                    ? 'Screen flipped 180° for the person opposite you.'
                    : 'Tap "Flip 180°" to show across a table or counter.',
                style: const TextStyle(color: Color(0xFF707975), fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
