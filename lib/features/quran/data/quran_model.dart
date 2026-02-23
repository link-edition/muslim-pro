/// Sura (bo'lim) modeli
class SurahModel {
  final int number;         // Sura raqami (1-114)
  final String name;        // Arabcha nomi
  final String englishName; // Inglizcha nomi
  final String nameUz;      // O'zbekcha nomi
  final String revelationType; // Makka yoki Madina
  final int ayahCount;      // Oyatlar soni
  final int startPage;      // Boshlanish sahifasi
  final int endPage;        // Tugash sahifasi

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

  /// JSON dan o'qish (API javobidan - api.quran.com)
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

  /// JSON ga yozish (kesh uchun)
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

/// Oyat modeli
class AyahModel {
  final int id;
  final int numberInSurah;   // Sura ichidagi raqami
  final String text;         // Arabcha matni
  final String? textTajweed; // Tajvidli matni
  final String verseKey;     // Sura:Oyat kaliti (masalan "1:1")
  final String? translation; // Tarjimasi
  final String? audioUrl;    // Audio URL
  final bool isActive;       // Hozir o'qilmoqda
  final int pageNumber;      // Mushaf sahifa raqami (1-604)
  final int juzNumber;       // Juz raqami (1-30)

  const AyahModel({
    required this.id,
    required this.numberInSurah,
    required this.text,
    this.textTajweed,
    required this.verseKey,
    this.translation,
    this.audioUrl,
    this.isActive = false,
    this.pageNumber = 1,
    this.juzNumber = 1,
  });

  AyahModel copyWith({bool? isActive, String? audioUrl}) {
    return AyahModel(
      id: id,
      numberInSurah: numberInSurah,
      text: text,
      textTajweed: textTajweed,
      verseKey: verseKey,
      translation: translation,
      audioUrl: audioUrl ?? this.audioUrl,
      isActive: isActive ?? this.isActive,
      pageNumber: pageNumber,
      juzNumber: juzNumber,
    );
  }

  factory AyahModel.fromQuranFoundation(Map<String, dynamic> json) {
    String? translationText;
    if (json['translations'] != null && (json['translations'] as List).isNotEmpty) {
      translationText = json['translations'][0]['text'];
    }

    return AyahModel(
      id: json['id'] as int,
      numberInSurah: json['verse_number'] as int,
      text: json['text_uthmani'] as String? ?? '',
      textTajweed: json['text_uthmani_tajweed'] as String?,
      verseKey: json['verse_key'] as String,
      translation: translationText,
      pageNumber: json['page_number'] as int? ?? 1,
      juzNumber: json['juz_number'] as int? ?? 1,
    );
  }
}
