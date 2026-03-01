import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranSettingsState {
  final double arabicFontSize;
  final double translationFontSize;
  final String translationScript;

  QuranSettingsState({
    this.arabicFontSize = 22.0,
    this.translationFontSize = 13.0,
    this.translationScript = 'latin',
  });

  QuranSettingsState copyWith({
    double? arabicFontSize,
    double? translationFontSize,
    String? translationScript,
  }) {
    return QuranSettingsState(
      arabicFontSize: arabicFontSize ?? this.arabicFontSize,
      translationFontSize: translationFontSize ?? this.translationFontSize,
      translationScript: translationScript ?? this.translationScript,
    );
  }
}

class QuranSettingsNotifier extends StateNotifier<QuranSettingsState> {
  QuranSettingsNotifier() : super(QuranSettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = QuranSettingsState(
      arabicFontSize: prefs.getDouble('quran_arabic_font_size') ?? 22.0,
      translationFontSize: prefs.getDouble('quran_translation_font_size') ?? 13.0,
      translationScript: prefs.getString('quran_translation_script') ?? 'latin',
    );
  }

  Future<void> setArabicFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('quran_arabic_font_size', size);
    state = state.copyWith(arabicFontSize: size);
  }

  Future<void> setTranslationFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('quran_translation_font_size', size);
    state = state.copyWith(translationFontSize: size);
  }

  Future<void> setTranslationScript(String script) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quran_translation_script', script);
    state = state.copyWith(translationScript: script);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('quran_arabic_font_size', 22.0);
    await prefs.setDouble('quran_translation_font_size', 13.0);
    await prefs.setString('quran_translation_script', 'latin');
    state = QuranSettingsState();
  }
}

final quranSettingsProvider = StateNotifierProvider<QuranSettingsNotifier, QuranSettingsState>((ref) {
  return QuranSettingsNotifier();
});
