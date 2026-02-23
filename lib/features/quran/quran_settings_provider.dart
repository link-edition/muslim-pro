import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum QuranTheme { white, sepia, dark }
enum TranslationScript { latin, cyrillic }

class QuranSettings {
  final QuranTheme theme;
  final bool isTajweedMode;
  final double fontSize;
  final TranslationScript script;

  QuranSettings({
    this.theme = QuranTheme.dark,
    this.isTajweedMode = false,
    this.fontSize = 22,
    this.script = TranslationScript.latin,
  });

  QuranSettings copyWith({
    QuranTheme? theme,
    bool? isTajweedMode,
    double? fontSize,
    TranslationScript? script,
  }) {
    return QuranSettings(
      theme: theme ?? this.theme,
      isTajweedMode: isTajweedMode ?? this.isTajweedMode,
      fontSize: fontSize ?? this.fontSize,
      script: script ?? this.script,
    );
  }

  Color get backgroundColor {
    switch (theme) {
      case QuranTheme.white: return Colors.white;
      case QuranTheme.sepia: return const Color(0xFFF4ECD8);
      case QuranTheme.dark: return const Color(0xFF0A0A0A);
    }
  }

  Color get textColor {
    switch (theme) {
      case QuranTheme.white: return Colors.black87;
      case QuranTheme.sepia: return const Color(0xFF5B4636);
      case QuranTheme.dark: return Colors.white;
    }
  }
}

class QuranSettingsNotifier extends StateNotifier<QuranSettings> {
  QuranSettingsNotifier() : super(QuranSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('quran_theme') ?? 2;
    final isTajweed = prefs.getBool('quran_tajweed') ?? false;
    final fSize = prefs.getDouble('quran_font_size') ?? 22.0;
    final scriptIndex = prefs.getInt('quran_script') ?? 0;

    state = QuranSettings(
      theme: QuranTheme.values[themeIndex.clamp(0, 2)],
      isTajweedMode: isTajweed,
      fontSize: fSize,
      script: TranslationScript.values[scriptIndex.clamp(0, 1)],
    );
  }

  Future<void> setTheme(QuranTheme theme) async {
    state = state.copyWith(theme: theme);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quran_theme', theme.index);
  }

  Future<void> setTajweedMode(bool value) async {
    state = state.copyWith(isTajweedMode: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('quran_tajweed', value);
  }

  Future<void> setFontSize(double value) async {
    state = state.copyWith(fontSize: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('quran_font_size', value);
  }

  Future<void> setScript(TranslationScript script) async {
    state = state.copyWith(script: script);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quran_script', script.index);
  }
}

final quranSettingsProvider = StateNotifierProvider<QuranSettingsNotifier, QuranSettings>((ref) {
  return QuranSettingsNotifier();
});
