import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../models/transcript_segment.dart';
import 'speech_service.dart';

/// Production native implementation wrapping Android SpeechRecognizer
/// and iOS SFSpeechRecognizer via `speech_to_text`.
/// Highly sensitive to nearby voices with robust continuous listening recovery.
class NativeSpeechRecognitionService implements SpeechRecognitionService {
  final stt.SpeechToText _speech = stt.SpeechToText();

  final _stateController = StreamController<SpeechRecognitionState>.broadcast();
  final _transcriptController = StreamController<TranscriptEvent>.broadcast();
  final _soundLevelController = StreamController<double>.broadcast();
  final _errorController = StreamController<SpeechErrorEvent>.broadcast();

  SpeechRecognitionState _currentState = SpeechRecognitionState.idle;
  bool _isInitialized = false;
  bool _userIntendsListening = false;
  bool _isPaused = false;
  String? _activeLocaleId;

  // Ultra-fast auto-restart throttle for natural silence timeouts
  Timer? _restartDebounceTimer;
  int _consecutiveFailures = 0;
  static const int _maxConsecutiveFailures = 6;

  @override
  SpeechRecognitionState get currentState => _currentState;

  @override
  Stream<SpeechRecognitionState> get stateStream => _stateController.stream;

  @override
  Stream<TranscriptEvent> get transcriptStream => _transcriptController.stream;

  @override
  Stream<double> get soundLevelStream => _soundLevelController.stream;

  @override
  Stream<SpeechErrorEvent> get errorStream => _errorController.stream;

  void _updateState(SpeechRecognitionState newState) {
    if (_currentState == SpeechRecognitionState.disposed) return;
    _currentState = newState;
    _stateController.add(newState);
  }

  @override
  Future<bool> hasPermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  @override
  Future<bool> requestPermission() async {
    _updateState(SpeechRecognitionState.requestingPermission);
    final status = await Permission.microphone.request();
    final granted = status.isGranted;
    _updateState(
      granted
          ? SpeechRecognitionState.idle
          : SpeechRecognitionState.unavailable,
    );
    return granted;
  }

  @override
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    _updateState(SpeechRecognitionState.initializing);
    try {
      final available = await _speech.initialize(
        onError: _handleNativeError,
        onStatus: _handleNativeStatus,
        debugLogging: kDebugMode,
      );

      _isInitialized = available;
      if (available) {
        _updateState(SpeechRecognitionState.idle);
      } else {
        _updateState(SpeechRecognitionState.unavailable);
        _errorController.add(
          const SpeechErrorEvent(
            message:
                'Speech recognition service is unavailable on this device.',
            isPermanent: true,
          ),
        );
      }
      return available;
    } catch (e) {
      _updateState(SpeechRecognitionState.error);
      _errorController.add(
        SpeechErrorEvent(
          message: 'Failed to initialize speech engine: $e',
          isPermanent: false,
        ),
      );
      return false;
    }
  }

  @override
  Future<void> startListening({String? localeId}) async {
    if (!_isInitialized) {
      final ok = await initialize();
      if (!ok) return;
    }

    _activeLocaleId = localeId;
    _userIntendsListening = true;
    _isPaused = false;
    _consecutiveFailures = 0;

    await _beginNativeListenSession();
  }

  Future<void> _beginNativeListenSession() async {
    if (!_userIntendsListening || _isPaused) return;

    _updateState(SpeechRecognitionState.listening);

    try {
      await _speech.listen(
        onResult: (result) {
          _consecutiveFailures = 0;
          final words = result.recognizedWords.trim();
          if (words.isEmpty) return;

          final segment = TranscriptSegment(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: words,
            isFinal: result.finalResult,
            timestamp: DateTime.now(),
            confidence: result.hasConfidenceRating ? result.confidence : 0.9,
            language: _activeLocaleId ?? 'auto',
          );

          _transcriptController.add(
            TranscriptEvent(segment: segment, isInterim: !result.finalResult),
          );
        },
        onSoundLevelChange: (level) {
          // High-sensitivity audio gain normalization:
          // Android rmsdB is typically -2.0 (silence) to 10.0+ (speech).
          // iOS dBFS is typically -60.0 (silence) to 0.0 (speech).
          double normalized = 0.0;
          if (level < -15.0) {
            // iOS dBFS scale
            normalized = ((level + 45.0) / 35.0).clamp(0.0, 1.0);
          } else {
            // Android RMS dB scale - sensitive to soft whisper / ambient voice
            if (level > 0.0) {
              normalized = (level / 7.0).clamp(0.0, 1.0);
            } else {
              normalized = 0.0;
            }
          }
          _soundLevelController.add(normalized);
        },
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          listenMode: stt.ListenMode.dictation,
          // Extended duration so continuous conversation is not arbitrarily cut off
          listenFor: const Duration(hours: 1),
          // Generous pause threshold (10s) to keep microphone listening through natural conversational breath pauses
          pauseFor: const Duration(seconds: 10),
          localeId: _activeLocaleId,
          onDevice: false, // Leverages high-accuracy neural recognition
        ),
      );
    } catch (e) {
      _handleFailureAndScheduleRestart('Error starting speech session: $e');
    }
  }

  void _handleNativeStatus(String status) {
    if (_currentState == SpeechRecognitionState.disposed) return;

    if (status == 'listening') {
      _updateState(SpeechRecognitionState.listening);
    } else if (status == 'notListening' || status == 'done') {
      _soundLevelController.add(0.0);
      if (_userIntendsListening && !_isPaused) {
        _updateState(SpeechRecognitionState.processing);
        _scheduleSessionRestart();
      } else if (_isPaused) {
        _updateState(SpeechRecognitionState.paused);
      } else {
        _updateState(SpeechRecognitionState.idle);
      }
    }
  }

  void _handleNativeError(SpeechRecognitionError error) {
    // Check if error is a recoverable timeout or transient busy state
    final isTransient =
        error.errorMsg.toLowerCase().contains('timeout') ||
        error.errorMsg.toLowerCase().contains('no match') ||
        error.errorMsg.toLowerCase().contains('busy') ||
        error.errorMsg.toLowerCase().contains('error_speech_timeout');

    if (isTransient && _userIntendsListening && !_isPaused) {
      // Natural silence timeout or transient busy: schedule immediate restart without surfacing error modal
      _scheduleSessionRestart();
      return;
    }

    _errorController.add(
      SpeechErrorEvent(message: error.errorMsg, isPermanent: error.permanent),
    );

    if (error.permanent) {
      _userIntendsListening = false;
      _updateState(SpeechRecognitionState.error);
    } else if (_userIntendsListening && !_isPaused) {
      _handleFailureAndScheduleRestart(error.errorMsg);
    }
  }

  void _scheduleSessionRestart() {
    _restartDebounceTimer?.cancel();
    if (!_userIntendsListening || _isPaused) return;

    // Ultra-fast 60ms restart so adjacent spoken words are captured seamlessly
    _restartDebounceTimer = Timer(const Duration(milliseconds: 60), () {
      if (_userIntendsListening && !_isPaused) {
        _beginNativeListenSession();
      }
    });
  }

  void _handleFailureAndScheduleRestart(String reason) {
    _consecutiveFailures++;
    if (_consecutiveFailures >= _maxConsecutiveFailures) {
      _userIntendsListening = false;
      _updateState(SpeechRecognitionState.error);
      _errorController.add(
        SpeechErrorEvent(
          message:
              'Continuous listening paused after multiple interruptions: $reason',
          isPermanent: false,
        ),
      );
      return;
    }

    final backoff = Duration(milliseconds: 150 * _consecutiveFailures);
    _restartDebounceTimer?.cancel();
    _restartDebounceTimer = Timer(backoff, () {
      if (_userIntendsListening && !_isPaused) {
        _beginNativeListenSession();
      }
    });
  }

  @override
  Future<void> pauseListening() async {
    _isPaused = true;
    _restartDebounceTimer?.cancel();
    await _speech.stop();
    _soundLevelController.add(0.0);
    _updateState(SpeechRecognitionState.paused);
  }

  @override
  Future<void> resumeListening() async {
    if (!_isInitialized) {
      final ok = await initialize();
      if (!ok) return;
    }
    _isPaused = false;
    _userIntendsListening = true;
    _consecutiveFailures = 0;
    await _beginNativeListenSession();
  }

  @override
  Future<void> stopListening() async {
    _userIntendsListening = false;
    _isPaused = false;
    _restartDebounceTimer?.cancel();
    await _speech.stop();
    _soundLevelController.add(0.0);
    _updateState(SpeechRecognitionState.idle);
  }

  @override
  Future<List<String>> getSupportedLocales() async {
    if (!_isInitialized) await initialize();
    try {
      final locales = await _speech.locales();
      return locales.map((l) => l.localeId).toList();
    } catch (_) {
      return ['hi-IN', 'en-IN', 'en-US'];
    }
  }

  @override
  Future<void> dispose() async {
    _restartDebounceTimer?.cancel();
    _userIntendsListening = false;
    await _speech.stop();
    _updateState(SpeechRecognitionState.disposed);
    await _stateController.close();
    await _transcriptController.close();
    await _soundLevelController.close();
    await _errorController.close();
  }
}
