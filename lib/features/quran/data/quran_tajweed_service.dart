import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TajweedAnnotation {
  final int start;
  final int end;
  final String rule;

  TajweedAnnotation({required this.start, required this.end, required this.rule});

  factory TajweedAnnotation.fromJson(Map<String, dynamic> json) {
    return TajweedAnnotation(
      start: json['start'] as int,
      end: json['end'] as int,
      rule: json['rule'] as String,
    );
  }
}

class AyahTajweed {
  final int surah;
  final int ayah;
  final List<TajweedAnnotation> annotations;
  final String text;

  AyahTajweed({
    required this.surah,
    required this.ayah,
    required this.annotations,
    required this.text,
  });
}

class QuranTajweedService {
  static List<AyahTajweed> _data = [];
  static bool _isLoaded = false;

  static final provider = FutureProvider<List<AyahTajweed>>((ref) async {
    if (_isLoaded) return _data;

    // Load annotations
    final jsonStr = await rootBundle.loadString('assets/data/quran_tajweed.json');
    final List<dynamic> jsonList = json.decode(jsonStr);

    // Load text
    final textLines = await rootBundle.loadString('assets/data/quran_text.txt');
    final Map<String, String> ayahTexts = {};
    for (var line in textLines.split('\n')) {
      if (line.trim().isEmpty) continue;
      final parts = line.split('|');
      if (parts.length >= 3) {
        ayahTexts['${parts[0]}|${parts[1]}'] = parts[2];
      }
    }

    _data = jsonList.map((item) {
      final s = item['surah'] as int;
      final a = item['ayah'] as int;
      final text = ayahTexts['$s|$a'] ?? '';
      final annotations = (item['annotations'] as List)
          .map((ann) => TajweedAnnotation.fromJson(ann))
          .toList();
      return AyahTajweed(
        surah: s,
        ayah: a,
        annotations: annotations,
        text: text,
      );
    }).toList();

    _isLoaded = true;
    return _data;
  });

  static List<AyahTajweed> getAyahsBySurah(List<AyahTajweed> all, int surahNumber) {
    return all.where((a) => a.surah == surahNumber).toList();
  }
}
