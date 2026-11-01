import 'dart:async';

import '../models/transcript_segment.dart';
import 'speech_service.dart';

/// Explicit test and development harness for deterministic automated tests.
/// This implementation MUST NEVER be silently invoked in production.
class FakeSpeechRecognitionService implements SpeechRecognitionService {
  final _stateController = StreamController<SpeechRecognitionState>.broadcast();
  final _transcriptController = StreamController<TranscriptEvent>.broadcast();
  final _soundLevelController = StreamController<double>.broadcast();
  final _errorController = StreamController<SpeechErrorEvent>.broadcast();

  SpeechRecognitionState _currentState = SpeechRecognitionState.idle;
  bool _permissionGranted = true;
  bool _initializeSuccess = true;

  void setPermissionGranted(bool granted) => _permissionGranted = granted;
  void setInitializeSuccess(bool success) => _initializeSuccess = success;

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
    _currentState = newState;
    _stateController.add(newState);
  }

  @override
  Future<bool> hasPermission() async => _permissionGranted;

  @override
  Future<bool> requestPermission() async {
    _updateState(SpeechRecognitionState.requestingPermission);
    await Future.delayed(const Duration(milliseconds: 10));
    _updateState(
      _permissionGranted
          ? SpeechRecognitionState.idle
          : SpeechRecognitionState.unavailable,
    );
    return _permissionGranted;
  }

  @override
  Future<bool> initialize() async {
    _updateState(SpeechRecognitionState.initializing);
    await Future.delayed(const Duration(milliseconds: 10));
    if (_initializeSuccess) {
      _updateState(SpeechRecognitionState.idle);
      return true;
    } else {
      _updateState(SpeechRecognitionState.unavailable);
      _errorController.add(
        const SpeechErrorEvent(
          message: 'Speech engine unavailable in test harness',
          isPermanent: true,
        ),
      );
      return false;
    }
  }

  @override
  Future<void> startListening({String? localeId}) async {
    _updateState(SpeechRecognitionState.listening);
    _soundLevelController.add(0.75);
  }

  @override
  Future<void> pauseListening() async {
    _updateState(SpeechRecognitionState.paused);
    _soundLevelController.add(0.0);
  }

  @override
  Future<void> resumeListening() async {
    _updateState(SpeechRecognitionState.listening);
    _soundLevelController.add(0.6);
  }

  @override
  Future<void> stopListening() async {
    _updateState(SpeechRecognitionState.idle);
    _soundLevelController.add(0.0);
  }

  @override
  Future<List<String>> getSupportedLocales() async => [
    'en-IN',
    'hi-IN',
    'en-US',
  ];

  /// Test helper: manually simulate an incoming partial hypothesis
  void emitInterimHypothesis(String text, {String speakerId = 'S1'}) {
    final segment = TranscriptSegment(
      id: 'interim_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      isFinal: false,
      timestamp: DateTime.now(),
      speakerId: speakerId,
      confidence: 0.85,
    );
    _transcriptController.add(
      TranscriptEvent(segment: segment, isInterim: true),
    );
  }

  /// Test helper: manually simulate a finalized segment
  void emitFinalSegment(
    String text, {
    String speakerId = 'S1',
    String? speakerName,
    double confidence = 0.95,
  }) {
    final segment = TranscriptSegment(
      id: 'final_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      isFinal: true,
      timestamp: DateTime.now(),
      speakerId: speakerId,
      speakerName:
          speakerName ?? (speakerId == 'S1' ? 'Speaker 1' : 'Speaker 2'),
      confidence: confidence,
    );
    _transcriptController.add(
      TranscriptEvent(segment: segment, isInterim: false),
    );
  }

  /// Test helper: emit an acoustic event (e.g. door opening, applause)
  void emitAcousticEvent(String label) {
    final segment = TranscriptSegment(
      id: 'event_${DateTime.now().millisecondsSinceEpoch}',
      text: label,
      isFinal: true,
      timestamp: DateTime.now(),
      isSoundEvent: true,
    );
    _transcriptController.add(
      TranscriptEvent(segment: segment, isInterim: false),
    );
  }

  /// Test helper: emit sound level
  void emitSoundLevel(double level) {
    _soundLevelController.add(level);
  }

  /// Test helper: emit error
  void emitError(String message, {bool isPermanent = false}) {
    _errorController.add(
      SpeechErrorEvent(message: message, isPermanent: isPermanent),
    );
    if (isPermanent) {
      _updateState(SpeechRecognitionState.error);
    }
  }

  @override
  Future<void> dispose() async {
    _updateState(SpeechRecognitionState.disposed);
    await _stateController.close();
    await _transcriptController.close();
    await _soundLevelController.close();
    await _errorController.close();
  }
}
