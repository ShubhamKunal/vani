import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vani/controllers/caption_controller.dart';
import 'package:vani/controllers/quick_responses_controller.dart';
import 'package:vani/models/app_settings.dart';
import 'package:vani/screens/live_caption_screen.dart';
import 'package:vani/screens/quick_responses_screen.dart';
import 'package:vani/screens/settings_screen.dart';
import 'package:vani/screens/splash_screen.dart';
import 'package:vani/services/fake_speech_service.dart';
import 'package:vani/services/settings_service.dart';
import 'package:vani/theme/vani_theme.dart';
import 'package:vani/widgets/fullscreen_billboard_dialog.dart';
import 'package:vani/widgets/status_pill.dart';
import 'package:vani/widgets/tactile_mic_meter.dart';

void main() {
  late FakeSpeechRecognitionService fakeService;
  late SettingsService settingsService;
  late CaptionController captionController;
  late QuickResponsesController quickResponsesController;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settingsService = await SettingsService.create();
    fakeService = FakeSpeechRecognitionService();
    captionController = CaptionController(
      speechService: fakeService,
      keepAwake: false,
    );
    quickResponsesController = QuickResponsesController(
      settingsService: settingsService,
    );
  });

  tearDown(() {
    captionController.dispose();
    quickResponsesController.dispose();
    fakeService.dispose();
  });

  Widget buildTestWidget({AppSettings? settings}) {
    final appSettings = settings ?? const AppSettings();
    return MaterialApp(
      theme: VaniTheme.lightTheme(appSettings.textScale),
      home: LiveCaptionScreen(
        captionController: captionController,
        quickResponsesController: quickResponsesController,
        settingsService: settingsService,
        appSettings: appSettings,
        onSettingsChanged: (_) {},
      ),
    );
  }

  group('LiveCaptionScreen Widget Tests', () {
    testWidgets('renders identity, status pill, and empty state', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Brand Identity
      expect(find.text('Vani'), findsOneWidget);
      expect(find.text('LIVE'), findsOneWidget);

      // Status & Meter
      expect(find.byType(StatusPill), findsOneWidget);
      expect(find.byType(TactileMicMeter), findsOneWidget);
      expect(find.text('LISTENING • HI/EN AUTO'), findsOneWidget);

      // Empty State
      expect(find.textContaining('Listening for speech'), findsOneWidget);

      // Bottom Control Bar
      expect(find.text('PAUSE'), findsOneWidget);
      expect(find.text('Phrases'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('renders incoming partial and finalized speech turns', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Simulate partial hypothesis
      fakeService.emitInterimHypothesis('Good morning everyone');
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.textContaining('Good morning everyone'), findsOneWidget);

      // Simulate final utterance
      fakeService.emitFinalSegment(
        "Good morning everyone. आज की meeting में we need to finalize the deployment before शाम को.",
        speakerId: 'S1',
        speakerName: 'Dr. Mehta',
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Dr. Mehta'), findsOneWidget);
      expect(find.textContaining('आज की meeting में'), findsOneWidget);

      // Simulate turn 2
      fakeService.emitFinalSegment(
        "हाँ बिल्कुल. Server load test is complete.",
        speakerId: 'S2',
        speakerName: 'Ananya',
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Ananya'), findsOneWidget);
      expect(
        find.textContaining('Server load test is complete'),
        findsOneWidget,
      );
    });

    testWidgets('pause and resume toggle button interaction', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Initial state is Listening
      expect(find.text('PAUSE'), findsOneWidget);

      // Tap PAUSE
      await tester.tap(find.text('PAUSE'));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('RESUME'), findsOneWidget);
      expect(find.text('PAUSED'), findsOneWidget);

      // Tap RESUME
      await tester.tap(find.text('RESUME'));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('PAUSE'), findsOneWidget);
      expect(find.text('LISTENING • HI/EN AUTO'), findsOneWidget);
    });

    testWidgets('Aa button expands and collapses Text Scale slider', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Text Scale (Reading Comfort)'), findsNothing);

      // Tap font size icon button
      await tester.tap(find.byIcon(Icons.format_size));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Text Scale (Reading Comfort)'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);

      // Tap close
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Text Scale (Reading Comfort)'), findsNothing);
    });
  });

  group('QuickResponsesScreen Widget Tests', () {
    testWidgets('renders hero billboard and phrase selection', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: VaniTheme.lightTheme(),
          home: QuickResponsesScreen(
            controller: quickResponsesController,
            onReturnToCaptions: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Hero Billboard
      expect(find.text('READY TO SHOW ACROSS TABLE'), findsOneWidget);
      expect(find.text('Fullscreen'), findsOneWidget);
      expect(
        find.textContaining("I'm deaf or hard of hearing"),
        findsAtLeastNWidgets(1),
      );

      // Tap second phrase: "Please speak a little slower."
      final secondPhrase = find.text('Please speak a little slower.');
      expect(secondPhrase, findsOneWidget);
      await tester.tap(secondPhrase);
      await tester.pumpAndSettle();

      expect(find.text('"Please speak a little slower."'), findsOneWidget);
    });

    testWidgets('opens Fullscreen billboard dialog with 180° flip button', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: VaniTheme.lightTheme(),
          home: QuickResponsesScreen(
            controller: quickResponsesController,
            onReturnToCaptions: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Fullscreen button
      await tester.tap(find.text('Fullscreen'));
      await tester.pumpAndSettle();

      // Fullscreen dialog opens
      expect(find.byType(FullscreenBillboardDialog), findsOneWidget);
      expect(find.text('Flip 180°'), findsOneWidget);
      expect(find.text('Dismiss'), findsOneWidget);

      // Tap Flip 180°
      await tester.tap(find.text('Flip 180°'));
      await tester.pumpAndSettle();
      expect(find.text('Upright'), findsOneWidget);

      // Tap Dismiss
      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();
      expect(find.byType(FullscreenBillboardDialog), findsNothing);
    });
  });

  group('SettingsScreen Widget Tests', () {
    testWidgets('renders all accessibility sections and updates theme', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      AppSettings changedSettings = const AppSettings();
      await tester.pumpWidget(
        MaterialApp(
          theme: VaniTheme.lightTheme(),
          home: SettingsScreen(
            settingsService: settingsService,
            currentSettings: const AppSettings(),
            onSettingsChanged: (s) => changedSettings = s,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Accessibility & Settings'), findsOneWidget);
      expect(find.text('READABILITY & TEXT SCALING'), findsOneWidget);
      expect(find.text('THEME & VISUAL CONTRAST'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('100% On-Device Privacy Guarantee'),
        200,
      );
      expect(find.text('100% On-Device Privacy Guarantee'), findsOneWidget);

      // Select Dark Mode radio tile
      await tester.tap(find.text('Obsidian Edition (Dark Mode)'));
      await tester.pumpAndSettle();
      expect(changedSettings.themeMode, AppThemeMode.dark);
    });
  });

  group('TactileMicMeter Widget Tests', () {
    testWidgets('renders semantic label and bars according to input level', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: TactileMicMeter(level: 0.85))),
        );
        await tester.pump();

        expect(find.byType(TactileMicMeter), findsOneWidget);
        expect(
          find.bySemanticsLabel('Microphone level: Strong audio input'),
          findsOneWidget,
        );
      } finally {
        handle.dispose();
      }
    });
  });

  group('SplashScreen Widget Tests', () {
    testWidgets(
      'renders Goddess Vani branding, Sanskrit title, and privacy badge',
      (tester) async {
        bool completed = false;
        await tester.pumpWidget(
          MaterialApp(
            theme: VaniTheme.lightTheme(),
            home: SplashScreen(
              speechService: fakeService,
              settingsService: settingsService,
              appSettings: const AppSettings(),
              onInitializationComplete: () => completed = true,
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Vani'), findsOneWidget);
        expect(find.text('वाणी'), findsOneWidget);
        expect(
          find.text('VĀGDEVĪ • GODDESS OF VOICE & WISDOM'),
          findsOneWidget,
        );
        expect(find.text('Every word, within reach.'), findsOneWidget);
        expect(
          find.text('100% On-Device • Zero Audio Sent to Cloud'),
          findsOneWidget,
        );

        // Tap screen to complete transition immediately
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pump(const Duration(milliseconds: 50));
        expect(completed, isTrue);
      },
    );
  });
}
