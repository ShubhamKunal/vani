/// Represents a discrete utterance or acoustic event in the live transcription stream.
class TranscriptSegment {
  final String id;
  final String text;
  final bool isFinal;
  final DateTime timestamp;
  final String speakerId;
  final String speakerName;
  final double? confidence;
  final String? language;
  final bool isSoundEvent;

  const TranscriptSegment({
    required this.id,
    required this.text,
    required this.isFinal,
    required this.timestamp,
    this.speakerId = 'S1',
    this.speakerName = 'Speaker 1',
    this.confidence,
    this.language,
    this.isSoundEvent = false,
  });

  TranscriptSegment copyWith({
    String? id,
    String? text,
    bool? isFinal,
    DateTime? timestamp,
    String? speakerId,
    String? speakerName,
    double? confidence,
    String? language,
    bool? isSoundEvent,
  }) {
    return TranscriptSegment(
      id: id ?? this.id,
      text: text ?? this.text,
      isFinal: isFinal ?? this.isFinal,
      timestamp: timestamp ?? this.timestamp,
      speakerId: speakerId ?? this.speakerId,
      speakerName: speakerName ?? this.speakerName,
      confidence: confidence ?? this.confidence,
      language: language ?? this.language,
      isSoundEvent: isSoundEvent ?? this.isSoundEvent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isFinal': isFinal,
      'timestamp': timestamp.toIso8601String(),
      'speakerId': speakerId,
      'speakerName': speakerName,
      'confidence': confidence,
      'language': language,
      'isSoundEvent': isSoundEvent,
    };
  }

  factory TranscriptSegment.fromJson(Map<String, dynamic> json) {
    return TranscriptSegment(
      id: json['id'] as String,
      text: json['text'] as String,
      isFinal: json['isFinal'] as bool? ?? true,
      timestamp: DateTime.parse(json['timestamp'] as String),
      speakerId: json['speakerId'] as String? ?? 'S1',
      speakerName: json['speakerName'] as String? ?? 'Speaker 1',
      confidence: (json['confidence'] as num?)?.toDouble(),
      language: json['language'] as String?,
      isSoundEvent: json['isSoundEvent'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptSegment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text &&
          isFinal == other.isFinal &&
          speakerId == other.speakerId;

  @override
  int get hashCode =>
      id.hashCode ^ text.hashCode ^ isFinal.hashCode ^ speakerId.hashCode;
}
