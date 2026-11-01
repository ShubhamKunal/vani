/// Predefined and custom high-contrast quick response phrases.
class QuickPhrase {
  final String id;
  final String phrase;
  final String? secondaryTranslation;
  final bool isDefault;
  final int order;

  const QuickPhrase({
    required this.id,
    required this.phrase,
    this.secondaryTranslation,
    this.isDefault = false,
    this.order = 0,
  });

  QuickPhrase copyWith({
    String? id,
    String? phrase,
    String? secondaryTranslation,
    bool? isDefault,
    int? order,
  }) {
    return QuickPhrase(
      id: id ?? this.id,
      phrase: phrase ?? this.phrase,
      secondaryTranslation: secondaryTranslation ?? this.secondaryTranslation,
      isDefault: isDefault ?? this.isDefault,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phrase': phrase,
      'secondaryTranslation': secondaryTranslation,
      'isDefault': isDefault,
      'order': order,
    };
  }

  factory QuickPhrase.fromJson(Map<String, dynamic> json) {
    return QuickPhrase(
      id: json['id'] as String,
      phrase: json['phrase'] as String,
      secondaryTranslation: json['secondaryTranslation'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      order: json['order'] as int? ?? 0,
    );
  }

  /// Initial default accessibility phrases per Stitch designs & specification.
  static List<QuickPhrase> defaultPhrases() {
    return [
      const QuickPhrase(
        id: 'phrase_1',
        phrase: "I'm deaf or hard of hearing. Please speak facing me.",
        secondaryTranslation:
            "मैं सुन नहीं सकता/सकती। कृपया मेरी ओर देखकर बोलें।",
        isDefault: true,
        order: 0,
      ),
      const QuickPhrase(
        id: 'phrase_2',
        phrase: "Please speak a little slower.",
        secondaryTranslation: "कृपया थोड़ा धीरे बोलें।",
        isDefault: true,
        order: 1,
      ),
      const QuickPhrase(
        id: 'phrase_3',
        phrase: "Could you repeat that?",
        secondaryTranslation: "क्या आप इसे दोबारा दोहरा सकते हैं?",
        isDefault: true,
        order: 2,
      ),
      const QuickPhrase(
        id: 'phrase_4',
        phrase: "Please write it down.",
        secondaryTranslation: "कृपया इसे लिख दीजिए।",
        isDefault: true,
        order: 3,
      ),
      const QuickPhrase(
        id: 'phrase_5',
        phrase: "Just a moment, reading captions.",
        secondaryTranslation: "कृपया एक पल रुकिए, मुझे पढ़ने दीजिए।",
        isDefault: true,
        order: 4,
      ),
      const QuickPhrase(
        id: 'phrase_6',
        phrase: "Thank you.",
        secondaryTranslation: "धन्यवाद।",
        isDefault: true,
        order: 5,
      ),
    ];
  }
}
