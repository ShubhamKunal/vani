import 'package:flutter/foundation.dart';

import '../models/quick_phrase.dart';
import '../services/settings_service.dart';

class QuickResponsesController extends ChangeNotifier {
  final SettingsService settingsService;
  List<QuickPhrase> _phrases = [];
  QuickPhrase? _selectedPhrase;
  bool _isFlipped180 = false;
  bool _isFullscreenModalOpen = false;

  QuickResponsesController({required this.settingsService}) {
    _load();
  }

  List<QuickPhrase> get phrases => List.unmodifiable(_phrases);
  QuickPhrase? get selectedPhrase =>
      _selectedPhrase ?? (_phrases.isNotEmpty ? _phrases.first : null);
  bool get isFlipped180 => _isFlipped180;
  bool get isFullscreenModalOpen => _isFullscreenModalOpen;

  void _load() {
    _phrases = List<QuickPhrase>.from(settingsService.loadPhrases());
    if (_phrases.isNotEmpty) {
      _selectedPhrase = _phrases.first;
    }
    notifyListeners();
  }

  void selectPhrase(QuickPhrase phrase) {
    _selectedPhrase = phrase;
    notifyListeners();
  }

  void toggleFlip180() {
    _isFlipped180 = !_isFlipped180;
    notifyListeners();
  }

  void setFullscreen(bool isOpen) {
    _isFullscreenModalOpen = isOpen;
    if (!isOpen) {
      _isFlipped180 = false;
    }
    notifyListeners();
  }

  Future<void> addPhrase(String phraseText, {String? translation}) async {
    final trimmed = phraseText.trim();
    if (trimmed.isEmpty) return;

    final newPhrase = QuickPhrase(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      phrase: trimmed,
      secondaryTranslation: translation?.trim(),
      isDefault: false,
      order: _phrases.length,
    );

    _phrases.add(newPhrase);
    _selectedPhrase = newPhrase;
    await settingsService.savePhrases(_phrases);
    notifyListeners();
  }

  Future<void> deletePhrase(String id) async {
    _phrases.removeWhere((p) => p.id == id);
    if (_selectedPhrase?.id == id) {
      _selectedPhrase = _phrases.isNotEmpty ? _phrases.first : null;
    }
    await settingsService.savePhrases(_phrases);
    notifyListeners();
  }
}
