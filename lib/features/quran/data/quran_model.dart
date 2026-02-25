/// Sura (bo'lim) modeli
class SurahModel {
  final int number;         // Sura raqami (1-114)
  final String name;        // Arabcha nomi
  final String englishName; // Inglizcha nomi
  final String nameUz;      // O'zbekcha nomi
  final String revelationType; // Makka yoki Madina
  final int ayahCount;      // Oyatlar soni
  final int startPage;      
  final int endPage;        

  const SurahModel({
    required this.number,
    required this.name,
    required this.englishName,
    required this.nameUz,
    required this.revelationType,
    required this.ayahCount,
    required this.startPage,
    required this.endPage,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      number: json['id'] as int,
      name: json['name_arabic'] as String,
      englishName: json['name_simple'] as String,
      nameUz: json['translated_name'] != null ? json['translated_name']['name'] as String : '',
      revelationType: json['revelation_place'] as String? ?? '',
      ayahCount: json['verses_count'] as int? ?? 0,
      startPage: json['pages'] != null && (json['pages'] as List).isNotEmpty ? json['pages'][0] as int : 1,
      endPage: json['pages'] != null && (json['pages'] as List).length > 1 ? json['pages'][1] as int : 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': number,
      'name_arabic': name,
      'name_simple': englishName,
      'translated_name': {'name': nameUz},
      'revelation_place': revelationType,
      'verses_count': ayahCount,
      'pages': [startPage, endPage],
    };
  }
}

/// Oyat modeli - Faqat Audio va Arabcha matn uchun qisqartirilgan
class AyahModel {
  final int id;
  final int numberInSurah;   
  final String text;         // Toza Arabcha matni
  final String verseKey;     
  final String? audioUrl;    // Remote URL
  final String? localPath;   // Yuklangan joyi
  final bool isActive;       

  const AyahModel({
    required this.id,
    required this.numberInSurah,
    required this.text,
    required this.verseKey,
    this.audioUrl,
    this.localPath,
    this.isActive = false,
  });

  AyahModel copyWith({bool? isActive, String? audioUrl, String? localPath}) {
    return AyahModel(
      id: id,
      numberInSurah: numberInSurah,
      text: text,
      verseKey: verseKey,
      audioUrl: audioUrl ?? this.audioUrl,
      localPath: localPath ?? this.localPath,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Footnote va boshqa kodlardan tozalash
  static String cleanText(String t) {
    return t.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll(RegExp(r'\[\d+\]'), '').trim();
  }

  factory AyahModel.fromQuranFoundation(Map<String, dynamic> json) {
    return AyahModel(
      id: json['id'] as int,
      numberInSurah: json['verse_number'] as int,
      text: cleanText(json['text_uthmani'] as String? ?? ''),
      verseKey: json['verse_key'] as String,
      audioUrl: json['audio_url'] as String?,
    );
  }
}
