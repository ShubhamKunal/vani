import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'controllers/caption_controller.dart';
import 'controllers/quick_responses_controller.dart';
import 'models/app_settings.dart';
import 'screens/live_caption_screen.dart';
import 'screens/splash_screen.dart';
import 'services/native_speech_service.dart';
import 'services/settings_service.dart';
import 'services/speech_service.dart';
import 'theme/vani_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force upright orientation initially to prevent accidental rotation during dictation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final settingsService = await SettingsService.create();
  final initialSettings = settingsService.loadSettings();

  // Production speech engine: on-device native speech recognition
  final speechService = NativeSpeechRecognitionService();

  runApp(
    VaniApp(
      speechService: speechService,
      settingsService: settingsService,
      initialSettings: initialSettings,
    ),
  );
}

class VaniApp extends StatefulWidget {
  final SpeechRecognitionService speechService;
  final SettingsService settingsService;
  final AppSettings initialSettings;
  final bool showSplash;

  const VaniApp({
    super.key,
    required this.speechService,
    required this.settingsService,
    required this.initialSettings,
    this.showSplash = true,
  });

  @override
  State<VaniApp> createState() => _VaniAppState();
}

class _VaniAppState extends State<VaniApp> {
  late AppSettings _appSettings;
  late CaptionController _captionController;
  late QuickResponsesController _quickResponsesController;
  late bool _showSplash;

  @override
  void initState() {
    super.initState();
    _showSplash = widget.showSplash;
    _appSettings = widget.initialSettings;
    _captionController = CaptionController(
      speechService: widget.speechService,
      keepAwake: _appSettings.keepScreenAwake,
    );
    _quickResponsesController = QuickResponsesController(
      settingsService: widget.settingsService,
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    _quickResponsesController.dispose();
    widget.speechService.dispose();
    super.dispose();
  }

  void _onSettingsChanged(AppSettings newSettings) {
    if (_appSettings.keepScreenAwake != newSettings.keepScreenAwake) {
      _captionController.updateKeepAwake(newSettings.keepScreenAwake);
    }
    setState(() {
      _appSettings = newSettings;
    });
  }

  ThemeData _buildCurrentTheme() {
    switch (_appSettings.themeMode) {
      case AppThemeMode.light:
        return VaniTheme.lightTheme(_appSettings.textScale);
      case AppThemeMode.dark:
        return VaniTheme.darkTheme(_appSettings.textScale);
      case AppThemeMode.highContrast:
        return VaniTheme.highContrastTheme(_appSettings.textScale);
      case AppThemeMode.system:
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.dark
            ? VaniTheme.darkTheme(_appSettings.textScale)
            : VaniTheme.lightTheme(_appSettings.textScale);
    }
  }

  void _onSplashComplete() {
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vani',
      debugShowCheckedModeBanner: false,
      theme: _buildCurrentTheme(),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _showSplash
            ? SplashScreen(
                key: const ValueKey('splash'),
                speechService: widget.speechService,
                settingsService: widget.settingsService,
                appSettings: _appSettings,
                onInitializationComplete: _onSplashComplete,
              )
            : LiveCaptionScreen(
                key: const ValueKey('live_caption'),
                captionController: _captionController,
                quickResponsesController: _quickResponsesController,
                settingsService: widget.settingsService,
                appSettings: _appSettings,
                onSettingsChanged: _onSettingsChanged,
              ),
      ),
    );
  }
}
