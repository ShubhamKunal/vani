import 'dart:async';

import '../models/transcript_segment.dart';

/// Represents the explicit, mutually exclusive lifecycle states of the speech engine.
enum SpeechRecognitionState {
  idle,
  requestingPermission,
  initializing,
  listening,
  processing,
  paused,
  unavailable,
  error,
  disposed,
}

/// Event emitted when speech recognition produces an interim hypothesis or final segment.
class TranscriptEvent {
  final TranscriptSegment segment;
  final bool isInterim;

  const TranscriptEvent({required this.segment, required this.isInterim});
}

/// Structured error reported by the recognition provider.
class SpeechErrorEvent {
  final String message;
  final bool isPermanent;
  final String? errorCode;

  const SpeechErrorEvent({
    required this.message,
    this.isPermanent = false,
    this.errorCode,
  });

  @override
  String toString() =>
      'SpeechErrorEvent: $message (code: $errorCode, permanent: $isPermanent)';
}

/// Abstract, vendor-agnostic interface decoupling the Flutter UI from any speech SDK.
abstract class SpeechRecognitionService {
  SpeechRecognitionState get currentState;
  Stream<SpeechRecognitionState> get stateStream;
  Stream<TranscriptEvent> get transcriptStream;
  Stream<double> get soundLevelStream; // 0.0 to 1.0 normalized mic gain
  Stream<SpeechErrorEvent> get errorStream;

  Future<bool> hasPermission();
  Future<bool> requestPermission();
  Future<bool> initialize();
  Future<void> startListening({String? localeId});
  Future<void> stopListening();
  Future<void> pauseListening();
  Future<void> resumeListening();
  Future<void> dispose();
  Future<List<String>> getSupportedLocales();
}
