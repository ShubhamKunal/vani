import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/transcript_segment.dart';
import '../services/speech_service.dart';

/// Central controller managing live caption stream state, continuous session lifecycle,
/// memory bounds, and mic gain telemetry.
class CaptionController extends ChangeNotifier {
  final SpeechRecognitionService speechService;
  final int maxSegments;

  final List<TranscriptSegment> _segments = [];
  TranscriptSegment? _interimSegment;
  double _micGainLevel = 0.0;
  final ValueNotifier<double> micLevelNotifier = ValueNotifier<double>(0.0);
  SpeechRecognitionState _engineState = SpeechRecognitionState.idle;
  String? _errorMessage;
  bool _isAutoScrollEnabled = true;

  StreamSubscription<SpeechRecognitionState>? _stateSub;
  StreamSubscription<TranscriptEvent>? _transcriptSub;
  StreamSubscription<double>? _soundLevelSub;
  StreamSubscription<SpeechErrorEvent>? _errorSub;

  CaptionController({
    required this.speechService,
    this.maxSegments = 200,
    bool keepAwake = true,
  }) {
    _initListeners();
    if (keepAwake) {
      _applyWakelock(true);
    }
  }

  List<TranscriptSegment> get segments => List.unmodifiable(_segments);
  TranscriptSegment? get interimSegment => _interimSegment;
  double get micGainLevel => _micGainLevel;
  SpeechRecognitionState get engineState => _engineState;
  String? get errorMessage => _errorMessage;
  bool get isAutoScrollEnabled => _isAutoScrollEnabled;

  bool get isListening => _engineState == SpeechRecognitionState.listening;
  bool get isPaused => _engineState == SpeechRecognitionState.paused;
  bool get isProcessing => _engineState == SpeechRecognitionState.processing;
  bool get hasError => _engineState == SpeechRecognitionState.error;
  bool get isUnavailable => _engineState == SpeechRecognitionState.unavailable;

  void _initListeners() {
    _engineState = speechService.currentState;

    _stateSub = speechService.stateStream.listen((state) {
      _engineState = state;
      if (state == SpeechRecognitionState.listening) {
        _errorMessage = null;
      }
      notifyListeners();
    });

    _transcriptSub = speechService.transcriptStream.listen((event) {
      if (event.isInterim) {
        _interimSegment = event.segment;
      } else {
        _interimSegment = null;
        final newText = event.segment.text.trim();
        if (newText.isEmpty) return;

        if (_segments.isNotEmpty) {
          final last = _segments.last;
          // Duplicate suppression
          if (last.text == newText) return;

          // Merge if within 3s and new text extends the previous segment
          final diff = event.segment.timestamp
              .difference(last.timestamp)
              .inSeconds;
          if (last.speakerId == event.segment.speakerId &&
              diff <= 3 &&
              newText.startsWith(last.text)) {
            _segments[_segments.length - 1] = event.segment;
            notifyListeners();
            return;
          }
        }

        _segments.add(event.segment);
        if (_segments.length > maxSegments) {
          _segments.removeRange(0, _segments.length - maxSegments);
        }
      }
      notifyListeners();
    });

    _soundLevelSub = speechService.soundLevelStream.listen((level) {
      _micGainLevel = level;
      micLevelNotifier.value = level;
    });

    _errorSub = speechService.errorStream.listen((error) {
      _errorMessage = error.message;
      notifyListeners();
    });
  }

  Future<void> _applyWakelock(bool enable) async {
    try {
      if (enable) {
        await WakelockPlus.enable();
      } else {
        await WakelockPlus.disable();
      }
    } catch (_) {
      // Graceful fallback on unsupported platforms/tests
    }
  }

  Future<void> updateKeepAwake(bool keepAwake) async {
    await _applyWakelock(keepAwake);
  }

  Future<bool> start() async {
    final hasPerm = await speechService.hasPermission();
    if (!hasPerm) {
      final granted = await speechService.requestPermission();
      if (!granted) {
        _errorMessage =
            'Microphone permission is required to transcribe live speech.';
        notifyListeners();
        return false;
      }
    }

    _errorMessage = null;
    await speechService.startListening();
    return true;
  }

  Future<void> togglePauseResume() async {
    if (isListening || isProcessing) {
      await speechService.pauseListening();
    } else if (isPaused ||
        _engineState == SpeechRecognitionState.idle ||
        hasError) {
      _errorMessage = null;
      await speechService.resumeListening();
    }
  }

  Future<void> stop() async {
    await speechService.stopListening();
  }

  void clearSession() {
    _segments.clear();
    _interimSegment = null;
    notifyListeners();
  }

  void setAutoScroll(bool enabled) {
    if (_isAutoScrollEnabled != enabled) {
      _isAutoScrollEnabled = enabled;
      notifyListeners();
    }
  }

  String exportFormattedTranscript() {
    final buffer = StringBuffer();
    buffer.writeln('--- VANI LIVE CAPTION TRANSCRIPT ---');
    buffer.writeln('Exported on: ${DateTime.now().toLocal()}');
    buffer.writeln('');

    for (final seg in _segments) {
      if (seg.isSoundEvent) {
        buffer.writeln('[Sound Event: ${seg.text}]');
      } else {
        final timeStr =
            '${seg.timestamp.hour.toString().padLeft(2, '0')}:${seg.timestamp.minute.toString().padLeft(2, '0')}:${seg.timestamp.second.toString().padLeft(2, '0')}';
        buffer.writeln('${seg.speakerName} ($timeStr):');
        buffer.writeln('${seg.text}\n');
      }
    }
    return buffer.toString();
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _transcriptSub?.cancel();
    _soundLevelSub?.cancel();
    _errorSub?.cancel();
    micLevelNotifier.dispose();
    _applyWakelock(false);
    super.dispose();
  }
}
