import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DuaSettings {
  final double arabicFontSize;
  final double transcriptionFontSize;
  final double translationFontSize;

  DuaSettings({
    required this.arabicFontSize,
    required this.transcriptionFontSize,
    required this.translationFontSize,
  });

  DuaSettings copyWith({
    double? arabicFontSize,
    double? transcriptionFontSize,
    double? translationFontSize,
  }) {
    return DuaSettings(
      arabicFontSize: arabicFontSize ?? this.arabicFontSize,
      transcriptionFontSize: transcriptionFontSize ?? this.transcriptionFontSize,
      translationFontSize: translationFontSize ?? this.translationFontSize,
    );
  }
}

class DuaSettingsNotifier extends StateNotifier<DuaSettings> {
  DuaSettingsNotifier()
      : super(DuaSettings(
          arabicFontSize: 20.0,
          transcriptionFontSize: 20.0,
          translationFontSize: 15.0,
        )) {
    _loadSettings();
  }

  static const String _keyArabicSize = 'dua_arabic_font_size';
  static const String _keyTranscriptionSize = 'dua_transcription_font_size';
  static const String _keyTranslationSize = 'dua_translation_font_size';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = DuaSettings(
      arabicFontSize: prefs.getDouble(_keyArabicSize) ?? 20.0,
      transcriptionFontSize: prefs.getDouble(_keyTranscriptionSize) ?? 20.0,
      translationFontSize: prefs.getDouble(_keyTranslationSize) ?? 15.0,
    );
  }

  Future<void> setArabicFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyArabicSize, size);
    state = state.copyWith(arabicFontSize: size);
  }

  Future<void> setTranscriptionFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyTranscriptionSize, size);
    state = state.copyWith(transcriptionFontSize: size);
  }

  Future<void> setTranslationFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyTranslationSize, size);
    state = state.copyWith(translationFontSize: size);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyArabicSize);
    await prefs.remove(_keyTranscriptionSize);
    await prefs.remove(_keyTranslationSize);
    state = DuaSettings(
      arabicFontSize: 20.0,
      transcriptionFontSize: 20.0,
      translationFontSize: 15.0,
    );
  }
}

final duaSettingsProvider = StateNotifierProvider<DuaSettingsNotifier, DuaSettings>((ref) {
  return DuaSettingsNotifier();
});
