import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../services/settings_service.dart';
import '../theme/vani_colors.dart';
import '../theme/vani_theme.dart';
import '../theme/vani_typography.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsService settingsService;
  final AppSettings currentSettings;
  final ValueChanged<AppSettings> onSettingsChanged;

  const SettingsScreen({
    super.key,
    required this.settingsService,
    required this.currentSettings,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.currentSettings;
  }

  void _updateSettings(AppSettings newSettings) {
    setState(() {
      _settings = newSettings;
    });
    widget.onSettingsChanged(newSettings);
    widget.settingsService.saveSettings(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? VaniColors.darkPrimary
        : VaniColors.lightPrimary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Accessibility & Settings',
          style: VaniTypography.headlineMd(primaryColor),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Section 1: Typography & Text Scaling
          Text(
            'READABILITY & TEXT SCALING',
            style: VaniTypography.speakerLabel(primaryColor),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Caption Font Scale',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${(_settings.textScale * 100).toInt()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _settings.textScale,
                    min: 1.0,
                    max: 1.6,
                    divisions: 6,
                    label: '${(_settings.textScale * 100).toInt()}%',
                    activeColor: primaryColor,
                    onChanged: (val) {
                      _updateSettings(_settings.copyWith(textScale: val));
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Aa (Standard 100%)',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Aa (Large 160%)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Section 2: Theme & Contrast
          Text(
            'THEME & VISUAL CONTRAST',
            style: VaniTypography.speakerLabel(primaryColor),
          ),
          const SizedBox(height: 8),
          Card(
            child: RadioGroup<AppThemeMode>(
              groupValue: _settings.themeMode,
              onChanged: (val) {
                if (val != null) {
                  _updateSettings(_settings.copyWith(themeMode: val));
                }
              },
              child: Column(
                children: const [
                  RadioListTile<AppThemeMode>(
                    title: Text('Editorial Ivory (Light Paper)'),
                    subtitle: Text('Warm paper undertone, WCAG AAA compliant'),
                    value: AppThemeMode.light,
                  ),
                  Divider(height: 1),
                  RadioListTile<AppThemeMode>(
                    title: Text('Obsidian Edition (Dark Mode)'),
                    subtitle: Text(
                      'Deep slate canvas for low-light environments',
                    ),
                    value: AppThemeMode.dark,
                  ),
                  Divider(height: 1),
                  RadioListTile<AppThemeMode>(
                    title: Text('High Contrast (Maximum Visibility)'),
                    subtitle: Text(
                      'Pure black and pure white (>18:1 contrast)',
                    ),
                    value: AppThemeMode.highContrast,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Section 3: Interaction & Accessibility Toggles
          Text(
            'INTERACTION & METADATA',
            style: VaniTypography.speakerLabel(primaryColor),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Keep Screen Awake'),
                  subtitle: const Text(
                    'Prevent display from sleeping during live transcription',
                  ),
                  value: _settings.keepScreenAwake,
                  activeTrackColor: primaryColor,
                  onChanged: (val) {
                    _updateSettings(_settings.copyWith(keepScreenAwake: val));
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Haptic Confirmation'),
                  subtitle: const Text(
                    'Tactile vibration feedback on button presses & speech starts',
                  ),
                  value: _settings.hapticsEnabled,
                  activeTrackColor: primaryColor,
                  onChanged: (val) {
                    _updateSettings(_settings.copyWith(hapticsEnabled: val));
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Show Speaker Indicators'),
                  subtitle: const Text(
                    'Display S1/S2 badges and tactile structural bars',
                  ),
                  value: _settings.showSpeakerLabels,
                  activeTrackColor: primaryColor,
                  onChanged: (val) {
                    _updateSettings(_settings.copyWith(showSpeakerLabels: val));
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Show Timestamps'),
                  subtitle: const Text(
                    'Display relative clock time beside each utterance',
                  ),
                  value: _settings.showTimestamps,
                  activeTrackColor: primaryColor,
                  onChanged: (val) {
                    _updateSettings(_settings.copyWith(showTimestamps: val));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 4: Privacy & Engine Disclosure
          Text(
            'PRIVACY & SPEECH ENGINE',
            style: VaniTypography.speakerLabel(primaryColor),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          '100% On-Device Privacy Guarantee',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vani operates with zero cloud transmission of your spoken audio by default. '
                    'Speech recognition utilizes your device\'s built-in neural speech recognizer. '
                    'No transcripts or raw audio are stored or sent to remote servers.',
                    style: TextStyle(fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  const Text(
                    'About Vani',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Version 1.0.0 • Designed for deaf, hard-of-hearing, and neurodivergent accessibility. '
                    'Tagline: "Every word, within reach."',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
