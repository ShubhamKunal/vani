import '../theme/vani_theme.dart';

/// User accessibility preferences and operational toggles.
class AppSettings {
  final double textScale; // 1.0 (100%) to 1.6 (160%)
  final AppThemeMode themeMode;
  final bool hapticsEnabled;
  final bool keepScreenAwake;
  final bool showTimestamps;
  final bool showSpeakerLabels;

  const AppSettings({
    this.textScale = 1.0,
    this.themeMode = AppThemeMode.light,
    this.hapticsEnabled = true,
    this.keepScreenAwake = true,
    this.showTimestamps = true,
    this.showSpeakerLabels = true,
  });

  AppSettings copyWith({
    double? textScale,
    AppThemeMode? themeMode,
    bool? hapticsEnabled,
    bool? keepScreenAwake,
    bool? showTimestamps,
    bool? showSpeakerLabels,
  }) {
    return AppSettings(
      textScale: textScale ?? this.textScale,
      themeMode: themeMode ?? this.themeMode,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      showTimestamps: showTimestamps ?? this.showTimestamps,
      showSpeakerLabels: showSpeakerLabels ?? this.showSpeakerLabels,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'textScale': textScale,
      'themeMode': themeMode.name,
      'hapticsEnabled': hapticsEnabled,
      'keepScreenAwake': keepScreenAwake,
      'showTimestamps': showTimestamps,
      'showSpeakerLabels': showSpeakerLabels,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      textScale: (json['textScale'] as num?)?.toDouble() ?? 1.0,
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => AppThemeMode.light,
      ),
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      keepScreenAwake: json['keepScreenAwake'] as bool? ?? true,
      showTimestamps: json['showTimestamps'] as bool? ?? true,
      showSpeakerLabels: json['showSpeakerLabels'] as bool? ?? true,
    );
  }
}
