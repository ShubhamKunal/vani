import 'package:flutter/material.dart';

import '../controllers/quick_responses_controller.dart';
import '../models/quick_phrase.dart';
import '../theme/vani_colors.dart';
import '../theme/vani_typography.dart';
import '../widgets/fullscreen_billboard_dialog.dart';

class QuickResponsesScreen extends StatefulWidget {
  final QuickResponsesController controller;
  final VoidCallback onReturnToCaptions;

  const QuickResponsesScreen({
    super.key,
    required this.controller,
    required this.onReturnToCaptions,
  });

  @override
  State<QuickResponsesScreen> createState() => _QuickResponsesScreenState();
}

class _QuickResponsesScreenState extends State<QuickResponsesScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  void _showAddCustomPhraseDialog() {
    final phraseTextController = TextEditingController();
    final translationTextController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Custom Response'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phraseTextController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Phrase text',
                hintText: 'e.g. Please speak into my good ear',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: translationTextController,
              decoration: const InputDecoration(
                labelText: 'Optional Hindi / Secondary text',
                hintText: 'e.g. कृपया मेरे कान के पास बोलें',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = phraseTextController.text.trim();
              if (text.isNotEmpty) {
                widget.controller.addPhrase(
                  text,
                  translation: translationTextController.text.trim().isEmpty
                      ? null
                      : translationTextController.text.trim(),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save Phrase'),
          ),
        ],
      ),
    );
  }

  void _presentFullscreen(QuickPhrase phrase) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (_) => FullscreenBillboardDialog(
        phrase: phrase,
        onDismiss: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? VaniColors.darkPrimary
        : VaniColors.lightPrimary;
    final phrases = widget.controller.phrases;
    final activePhrase =
        widget.controller.selectedPhrase ??
        (phrases.isNotEmpty
            ? phrases.first
            : const QuickPhrase(id: '0', phrase: 'Ready'));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Return to Live Captions',
          onPressed: widget.onReturnToCaptions,
        ),
        title: Text(
          'Quick Responses',
          style: VaniTypography.headlineMd(primaryColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add custom response',
            onPressed: _showAddCustomPhraseDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              children: [
                // 1. Hero Billboard Display Card (Ready to show across counter/table)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'READY TO SHOW ACROSS TABLE',
                              style: VaniTypography.speakerLabel(primaryColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'One-Tap Flip',
                      style: VaniTypography.caption(
                        isDark
                            ? VaniColors.darkOutline
                            : VaniColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Card(
                  elevation: 2,
                  color: isDark
                      ? VaniColors.darkSurfaceContainer
                      : VaniColors.lightContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: primaryColor, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? VaniColors.darkPrimary.withAlpha(50)
                                    : VaniColors.lightSecondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.visibility,
                                    size: 15,
                                    color: isDark
                                        ? VaniColors.darkSecondary
                                        : VaniColors.lightPrimary,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'HIGH LEGIBILITY',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? VaniColors.darkSecondary
                                          : VaniColors.lightPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () => _presentFullscreen(activePhrase),
                              icon: const Icon(Icons.fullscreen, size: 18),
                              label: const Text('Fullscreen'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        InkWell(
                          onTap: () => _presentFullscreen(activePhrase),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              '"${activePhrase.phrase}"',
                              textAlign: TextAlign.center,
                              style:
                                  VaniTypography.headlineLg(
                                    isDark
                                        ? VaniColors.darkTextPrimary
                                        : VaniColors.lightTextPrimary,
                                  ).copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),

                        if (activePhrase.secondaryTranslation != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            activePhrase.secondaryTranslation!,
                            textAlign: TextAlign.center,
                            style: VaniTypography.bodyMd(
                              isDark
                                  ? VaniColors.darkTextSecondary
                                  : VaniColors.lightTextSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),

                        const Divider(height: 1),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.screen_rotation,
                              size: 16,
                              color: isDark
                                  ? VaniColors.darkSecondary
                                  : VaniColors.lightSecondary,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Tap "Fullscreen" to flip 180° for the other person',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? VaniColors.darkOutline
                                      : VaniColors.lightTextSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Essential Phrases List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'ESSENTIAL RESPONSES',
                        style: VaniTypography.speakerLabel(primaryColor),
                      ),
                    ),
                    Text(
                      'Tap to set billboard',
                      style: VaniTypography.caption(
                        isDark
                            ? VaniColors.darkOutline
                            : VaniColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                ...phrases.map((phrase) {
                  final isSelected = activePhrase.id == phrase.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Material(
                      color: isSelected
                          ? (isDark
                                ? VaniColors.darkPrimary.withAlpha(40)
                                : VaniColors.lightSecondaryContainer.withAlpha(
                                    120,
                                  ))
                          : (isDark
                                ? VaniColors.darkSurfaceContainerLow
                                : VaniColors.lightContainerLowest),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? primaryColor
                              : (isDark
                                    ? VaniColors.darkBorder
                                    : VaniColors.lightHairlineBorder),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => widget.controller.selectPhrase(phrase),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primaryColor
                                      : (isDark
                                            ? VaniColors.darkSurfaceContainer
                                            : VaniColors.lightContainer),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  isSelected
                                      ? Icons.check
                                      : Icons.chat_bubble_outline,
                                  size: 18,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      phrase.phrase,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isDark
                                            ? VaniColors.darkTextPrimary
                                            : VaniColors.lightTextPrimary,
                                      ),
                                    ),
                                    if (phrase.secondaryTranslation !=
                                        null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        phrase.secondaryTranslation!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? VaniColors.darkTextSecondary
                                              : VaniColors.lightTextSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.open_in_full, size: 18),
                                tooltip: 'Present Fullscreen',
                                onPressed: () => _presentFullscreen(phrase),
                              ),
                              if (!phrase.isDefault)
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: Colors.redAccent,
                                  ),
                                  tooltip: 'Delete custom phrase',
                                  onPressed: () =>
                                      widget.controller.deletePhrase(phrase.id),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),

                // Add Custom Phrase Button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: primaryColor,
                      width: 1.5,
                      style: BorderStyle.solid,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _showAddCustomPhraseDialog,
                  icon: const Icon(Icons.add_circle),
                  label: const Text(
                    '+ Add Custom Phrase',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // 3. Fixed Bottom Bar: Prominent Return Trigger (Zero Anxiety 56dp+ Button)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? VaniColors.darkSurface
                  : VaniColors.lightContainerLowest,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? VaniColors.darkBorder
                      : VaniColors.lightHairlineBorder,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                onPressed: widget.onReturnToCaptions,
                icon: const Icon(Icons.mic, size: 24),
                label: const Text(
                  'Return to Live Captions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
