import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/quick_phrase.dart';

class SettingsService {
  static const _settingsKey = 'vani_app_settings';
  static const _phrasesKey = 'vani_quick_phrases';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  static Future<SettingsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService(prefs);
  }

  AppSettings loadSettings() {
    final raw = _prefs.getString(_settingsKey);
    if (raw == null) return const AppSettings();
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AppSettings.fromJson(map);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    final raw = jsonEncode(settings.toJson());
    await _prefs.setString(_settingsKey, raw);
  }

  List<QuickPhrase> loadPhrases() {
    final rawList = _prefs.getStringList(_phrasesKey);
    if (rawList == null || rawList.isEmpty) {
      return QuickPhrase.defaultPhrases();
    }

    try {
      return rawList.map((str) {
        final map = jsonDecode(str) as Map<String, dynamic>;
        return QuickPhrase.fromJson(map);
      }).toList();
    } catch (_) {
      return QuickPhrase.defaultPhrases();
    }
  }

  Future<void> savePhrases(List<QuickPhrase> phrases) async {
    final rawList = phrases.map((p) => jsonEncode(p.toJson())).toList();
    await _prefs.setStringList(_phrasesKey, rawList);
  }
}
