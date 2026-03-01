import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/quran_tajweed_service.dart';

class TajweedDigitalParser {
  static const Map<String, Color> _ruleColors = {
    'ghunnah': Color(0xFF4CAF50), // Green
    'ikhfa': Color(0xFF2196F3), // Blue
    'ikhfa_shafawi': Color(0xFF2196F3),
    'madd_2': Color(0xFFE91E63), // Pink/Red
    'madd_246': Color(0xFFE91E63),
    'madd_6': Color(0xFFD32F2F), // Dark Red
    'madd_munfasil': Color(0xFFC62828),
    'madd_muttasil': Color(0xFFE53935),
    'qalqalah': Color(0xFFFF9800), // Orange
    'idghaam_ghunnah': Color(0xFF009688), // Teal
    'idghaam_no_ghunnah': Color(0xFF00796B),
    'idghaam_mutajanisayn': Color(0xFF00695C),
    'idghaam_mutaqaribayn': Color(0xFF00695C),
    'idghaam_shafawi': Color(0xFF009688),
    'iqlab': Color(0xFF3F51B5), // Indigo
    'hamzat_wasl': Color(0xFF9E9E9E), // Gray
    'lam_shamsiyyah': Color(0xFFFFC107), // Yellow/Amber
    'silent': Color(0xFF9E9E9E),
  };

  static List<TextSpan> parse(AyahTajweed ayah, {
    required double fontSize,
    required Color defaultColor,
    String? fontFamily,
  }) {
    final runes = ayah.text.runes.toList();
    final annotations = ayah.annotations..sort((a, b) => a.start.compareTo(b.start));
    final spans = <TextSpan>[];
    
    int lastIdx = 0;
    
    for (final ann in annotations) {
      // Add plain text before annotation
      if (ann.start > lastIdx) {
        spans.add(TextSpan(
          text: String.fromCharCodes(runes.sublist(lastIdx, ann.start)),
          style: TextStyle(
            color: defaultColor,
            fontSize: fontSize,
            fontFamily: fontFamily,
            height: 1.8,
          ),
        ));
      }
      
      // Add annotated text
      final ruleColor = _ruleColors[ann.rule] ?? defaultColor;
      spans.add(TextSpan(
        text: String.fromCharCodes(runes.sublist(ann.start, ann.end)),
        style: TextStyle(
          color: ruleColor,
          fontSize: fontSize,
          fontFamily: fontFamily,
          height: 1.8,
        ),
      ));
      
      lastIdx = ann.end;
    }
    
    // Remaining text
    if (lastIdx < runes.length) {
      spans.add(TextSpan(
        text: String.fromCharCodes(runes.sublist(lastIdx)),
        style: TextStyle(
          color: defaultColor,
          fontSize: fontSize,
          fontFamily: fontFamily,
          height: 1.8,
        ),
      ));
    }
    
    return spans;
  }
}
