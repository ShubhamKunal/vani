import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vani/controllers/caption_controller.dart';
import 'package:vani/controllers/quick_responses_controller.dart';
import 'package:vani/models/transcript_segment.dart';
import 'package:vani/services/fake_speech_service.dart';
import 'package:vani/services/settings_service.dart';
import 'package:vani/theme/vani_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TranscriptSegment Model Tests', () {
    test('creates segment and serializes/deserializes correctly', () {
      final now = DateTime.now();
      final segment = TranscriptSegment(
        id: 'turn_1',
        text: 'आज की meeting में we need to finalize the deployment.',
        isFinal: true,
        timestamp: now,
        speakerId: 'S1',
        speakerName: 'Dr. Mehta',
        confidence: 0.94,
        language: 'hi-IN',
      );

      final json = segment.toJson();
      expect(json['id'], 'turn_1');
      expect(json['text'], contains('meeting'));
      expect(json['confidence'], 0.94);
      expect(json['language'], 'hi-IN');

      final fromJson = TranscriptSegment.fromJson(json);
      expect(fromJson.id, segment.id);
      expect(fromJson.text, segment.text);
      expect(fromJson.isFinal, isTrue);
      expect(fromJson.speakerId, 'S1');
    });

    test('acoustic sound event segment properties', () {
      final event = TranscriptSegment(
        id: 'event_1',
        text: '[Door opens • Footsteps entering]',
        isFinal: true,
        timestamp: DateTime.now(),
        isSoundEvent: true,
      );

      expect(event.isSoundEvent, isTrue);
      expect(event.text, contains('[Door opens'));
    });
  });

  group('CaptionController Unit Tests', () {
    late FakeSpeechRecognitionService fakeService;
    late CaptionController controller;

    setUp(() {
      fakeService = FakeSpeechRecognitionService();
      controller = CaptionController(
        speechService: fakeService,
        maxSegments: 5,
        keepAwake: false,
      );
    });

    tearDown(() {
      controller.dispose();
      fakeService.dispose();
    });

    test('initial state is idle and segments are empty', () {
      expect(controller.segments, isEmpty);
      expect(controller.interimSegment, isNull);
      expect(controller.errorMessage, isNull);
    });

    test(
      'receives partial interim hypotheses followed by finalization',
      () async {
        await controller.start();
        expect(controller.isListening, isTrue);

        // 1. Partial hypothesis 1
        fakeService.emitInterimHypothesis('Good morning');
        await Future.delayed(const Duration(milliseconds: 10));
        expect(controller.interimSegment?.text, 'Good morning');
        expect(controller.segments, isEmpty);

        // 2. Partial hypothesis 2 (extended)
        fakeService.emitInterimHypothesis('Good morning everyone');
        await Future.delayed(const Duration(milliseconds: 10));
        expect(controller.interimSegment?.text, 'Good morning everyone');
        expect(controller.segments, isEmpty);

        // 3. Finalized utterance
        fakeService.emitFinalSegment(
          "Good morning everyone. आज की meeting में we need to finalize the deployment before शाम को.",
        );
        await Future.delayed(const Duration(milliseconds: 10));
        expect(controller.interimSegment, isNull);
        expect(controller.segments.length, 1);
        expect(controller.segments.first.text, contains('meeting'));
      },
    );

    test('deduplicates identical finalized segments', () async {
      await controller.start();
      fakeService.emitFinalSegment('Server load test is complete.');
      await Future.delayed(const Duration(milliseconds: 10));
      expect(controller.segments.length, 1);

      // Emitting same final text again
      fakeService.emitFinalSegment('Server load test is complete.');
      await Future.delayed(const Duration(milliseconds: 10));
      expect(controller.segments.length, 1); // Deduplicated!
    });

    test('enforces bounded memory retention (maxSegments)', () async {
      await controller.start();

      for (int i = 1; i <= 8; i++) {
        fakeService.emitFinalSegment('Utterance number $i');
        await Future.delayed(const Duration(milliseconds: 5));
      }

      // Max capacity is 5
      expect(controller.segments.length, 5);
      expect(controller.segments.first.text, 'Utterance number 4');
      expect(controller.segments.last.text, 'Utterance number 8');
    });

    test('pause and resume transitions', () async {
      await controller.start();
      expect(controller.isListening, isTrue);

      await controller.togglePauseResume();
      expect(controller.isPaused, isTrue);

      await controller.togglePauseResume();
      expect(controller.isListening, isTrue);
    });

    test(
      'exportFormattedTranscript formats all turns and timestamps',
      () async {
        await controller.start();
        fakeService.emitFinalSegment(
          'Hello there.',
          speakerId: 'S1',
          speakerName: 'Dr. Mehta',
        );
        fakeService.emitAcousticEvent('[Applause]');
        fakeService.emitFinalSegment(
          'Thank you.',
          speakerId: 'S2',
          speakerName: 'Ananya',
        );
        await Future.delayed(const Duration(milliseconds: 10));

        final exported = controller.exportFormattedTranscript();
        expect(exported, contains('VANI LIVE CAPTION TRANSCRIPT'));
        expect(exported, contains('Dr. Mehta'));
        expect(exported, contains('Hello there.'));
        expect(exported, contains('[Sound Event: [Applause]]'));
        expect(exported, contains('Ananya'));
        expect(exported, contains('Thank you.'));
      },
    );
  });

  group('QuickResponsesController & SettingsService Unit Tests', () {
    late SettingsService settingsService;
    late QuickResponsesController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      settingsService = await SettingsService.create();
      controller = QuickResponsesController(settingsService: settingsService);
    });

    tearDown(() {
      controller.dispose();
    });

    test('loads default accessibility phrases', () {
      expect(controller.phrases.length, greaterThanOrEqualTo(5));
      expect(
        controller.selectedPhrase?.phrase,
        contains("I'm deaf or hard of hearing"),
      );
    });

    test('can add and select custom response phrase', () async {
      await controller.addPhrase(
        'Please write your question on this screen.',
        translation: 'कृपया अपना प्रश्न इस स्क्रीन पर लिखें।',
      );

      expect(
        controller.phrases.last.phrase,
        'Please write your question on this screen.',
      );
      expect(
        controller.selectedPhrase?.phrase,
        'Please write your question on this screen.',
      );
    });

    test('can delete custom response phrase', () async {
      await controller.addPhrase('Custom phrase to remove');
      final addedId = controller.phrases.last.id;
      expect(controller.phrases.any((p) => p.id == addedId), isTrue);

      await controller.deletePhrase(addedId);
      expect(controller.phrases.any((p) => p.id == addedId), isFalse);
    });

    test('persists AppSettings in SharedPreferences', () async {
      final initial = settingsService.loadSettings();
      expect(initial.textScale, 1.0);
      expect(initial.themeMode, AppThemeMode.light);

      final updated = initial.copyWith(
        textScale: 1.4,
        themeMode: AppThemeMode.dark,
        showTimestamps: false,
      );
      await settingsService.saveSettings(updated);

      final reloaded = settingsService.loadSettings();
      expect(reloaded.textScale, 1.4);
      expect(reloaded.themeMode, AppThemeMode.dark);
      expect(reloaded.showTimestamps, isFalse);
    });
  });

  group('Microphone Gain & Acoustic Sensitivity Tests', () {
    double normalizeLevel(double level) {
      if (level < -15.0) {
        // iOS dBFS scale
        return ((level + 45.0) / 35.0).clamp(0.0, 1.0);
      } else {
        // Android RMS dB scale
        if (level > 0.0) {
          return (level / 7.0).clamp(0.0, 1.0);
        } else {
          return 0.0;
        }
      }
    }

    test('silence produces zero gain on both Android and iOS curves', () {
      expect(normalizeLevel(-2.0), 0.0); // Android ambient silence
      expect(normalizeLevel(0.0), 0.0); // Android floor
      expect(normalizeLevel(-50.0), 0.0); // iOS floor
    });

    test('faint whisper illuminates Bar 1 (> 0.05)', () {
      final androidWhisper = normalizeLevel(0.8);
      expect(androidWhisper, greaterThan(0.05));
      expect(androidWhisper, lessThan(0.35));

      final iosWhisper = normalizeLevel(-40.0);
      expect(iosWhisper, greaterThan(0.05));
      expect(iosWhisper, lessThan(0.35));
    });

    test('normal conversation illuminates Bar 2 (> 0.35)', () {
      final androidSpeech = normalizeLevel(3.5);
      expect(androidSpeech, greaterThan(0.35));
      expect(androidSpeech, lessThan(0.70));

      final iosSpeech = normalizeLevel(-28.0);
      expect(iosSpeech, greaterThan(0.35));
      expect(iosSpeech, lessThan(0.70));
    });

    test('loud voice illuminates Bar 3 (> 0.70)', () {
      final androidLoud = normalizeLevel(6.0);
      expect(androidLoud, greaterThan(0.70));

      final iosLoud = normalizeLevel(-18.0);
      expect(iosLoud, greaterThan(0.70));
    });
  });

  group('VaniTheme & Design Token Contrast Tests', () {
    test('light, dark, and high contrast themes generate valid ThemeDatas', () {
      final light = VaniTheme.lightTheme(1.0);
      expect(light.brightness, equals(Brightness.light));
      expect(light.scaffoldBackgroundColor, isNotNull);

      final dark = VaniTheme.darkTheme(1.2);
      expect(dark.brightness, equals(Brightness.dark));
      expect(dark.scaffoldBackgroundColor, isNotNull);

      final highContrast = VaniTheme.highContrastTheme(1.5);
      expect(highContrast.brightness, equals(Brightness.dark));
      expect(
        highContrast.scaffoldBackgroundColor,
        equals(const Color(0xFF000000)),
      );
    });
  });
}
